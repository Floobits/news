---
date: '2015-10-26 09:59:01'
layout: post
slug: why-is-nodejs-crashing-a-deep-dive-into-a-tricky-bug
published: true
title: 'Why is Node.js Crashing? A Deep Dive into a Tricky Bug'
authors:
  - ggreer
categories:
  - Node.js
  - Bugs
  - Tech
excerpt_separator: <!--more-->
---

In early September, we started seeing one of our backend services exit with the following error:

    2015-09-10_23:28:11.75413 node: ../src/node_buffer.cc:226: v8::MaybeLocal<v8::Object> node::Buffer::New(v8::Isolate*, v8::Local<v8::String>, node::encoding): Assertion `(data) != (nullptr)' failed.

Typically, Node.js exits with a JavaScript stack trace. This error was at a lower level. Node.js was dying because of an assertion in its [Buffer](https://nodejs.org/api/buffer.html) code. At worst, creating a new Buffer should throw an exception. This was a crash. This was a Node.js bug.

<!--more-->

The first thing I did was look at the code containing the assertion error. This was in [`node_buffer.cc` on line 225](https://github.com/nodejs/node/blob/v4.2.1/src/node_buffer.cc#L225). I've included the entire `Buffer::New()` constructor below:

{% highlight cpp hl_lines="17" linenos linenostart=209 %}
MaybeLocal<Object> New(Isolate* isolate,
                       Local<String> string,
                       enum encoding enc) {
  EscapableHandleScope scope(isolate);

  size_t length = StringBytes::Size(isolate, string, enc);
  char* data = static_cast<char*>(malloc(length));

  if (data == nullptr)
    return Local<Object>();

  size_t actual = StringBytes::Write(isolate, data, length, string, enc);
  CHECK(actual <= length);

  if (actual < length) {
    data = static_cast<char*>(realloc(data, actual));
    CHECK_NE(data, nullptr);
  }

  Local<Object> buf;
  if (New(isolate, data, actual).ToLocal(&buf))
    return scope.Escape(buf);

  // Object failed to be created. Clean up resources.
  free(data);
  return Local<Object>();
}
{% endhighlight %}

Somehow, `data` was `NULL`. Thinking the `realloc()` on line 224 might have failed, I double-checked memory usage on the servers. They were not in danger of reaching any limits, and crashes didn't seem to depend on memory usage. The service crashed while using 1GB of RAM just as often as it did while using 100MB. Dang. Not an easy fix. It was a slim hope anyways. Modern OSes don't return `NULL` from `malloc()` and friends.<sup>[\[1\]](#ref_1)</sup>

The next thing I did was `man realloc`, to try and figure out how it could return `NULL`. Except for an out-of-memory condition, it wasn't possible. Even passing `NULL` to `realloc()` returned a usable chunk of memory:

> If ptr is NULL, realloc() is identical to a call to malloc() for size bytes.  If size is zero and ptr is not NULL, a new, minimum sized object is allocated and the original object is freed.

There was simply no way for `Buffer::New()`, executed sequentially, to fail in this way. Therefore (I reasoned), the bug must be another thread modifying shared state. Probably a hard-to-reproduce race condition. Ugh. Still, I needed to fix the issue. Desiring to know more, I tried to build a reproducible test case. Annoyingly, I could only trigger the crash in production and staging, and only when copying lots of data between instances of the service. Having a lot of other stuff to do, I mitigated the issue by reducing the peak rate at which the service copied data.

A month later, Matt finally got tired of seeing crash emails. We paired to try and find the underlying cause. When I was explaining the issue to Matt, I pointed out that `realloc()` never returns `NULL`. He double-checked the docs and disagreed. When he linked to the manpage describing `realloc()`'s behavior, it said:

> If size was equal to 0, either NULL or a pointer suitable to be passed to free() is returned.

Wait, what?! It turned out that I had run `man realloc` on my mac, while he had googled "realloc" and clicked on the first result. That result described `realloc()` on Linux. The two behaved differently, and that difference was crucial. Again, here are the relevant lines from `Buffer::New`:

{% highlight cpp linenos linenostart=220 %}
size_t actual = StringBytes::Write(isolate, data, length, string, enc);
CHECK(actual <= length);

if (actual < length) {
  data = static_cast<char*>(realloc(data, actual));
  CHECK_NE(data, nullptr);
}
{% endhighlight %}

If `realloc()` returns null, `actual` must be 0. If `actual` is 0, `StringBytes::Write()` must have returned 0. But to get to line 220, `length` must be greater than 0. How could this happen? Well, `length` is only set on line 214:

{% highlight cpp linenos linenostart=214 %}
size_t length = StringBytes::Size(isolate, string, enc);
{% endhighlight %}

So `StringBytes::Size()` thinks the buffer is a certain size, but `StringBytes::Write()` disagrees or fails in some way. To confirm this hypothesis, Matt and I added a `printf()` before the `realloc()`:

{% highlight cpp linenos linenostart=220 %}
size_t actual = StringBytes::Write(isolate, data, length, string, enc);
CHECK(actual <= length);

if (actual < length) {
  printf("actual: %u length: %u\n", actual, length);
  data = static_cast<char*>(realloc(data, actual));
  CHECK_NE(data, nullptr);
}
{% endhighlight %}

I deployed this custom Node.js build to staging, and soon saw crashes. The crashes were preceded by lines such as:

{% highlight text %}
2015-10-17_19:22:45.89086 actual: 0 length: 11518
{% endhighlight %}

Yahtzee! We were on the right track. Now how could `StringBytes::Write()` return 0? We both suspected [base64](https://en.wikipedia.org/wiki/Base64)-encoded buffers. Delving into [`string_bytes.cc`](https://github.com/nodejs/node/blob/v4.2.1/src/string_bytes.cc), we saw that `StringBytes::Size()` called `base64_decoded_size()`, which called `base64_decoded_size_fast()`, which basically returned `length / 4 * 3`.<sup>[\[2\]](#ref_1)</sup> At no point did any of these methods check for valid base64 encoded data. They didn't strip whitespace or invalid characters. They just multiplied by 0.75.

It was a different story for `StringBytes::Write()`. That function called `base64_decode()`, which called `base64_decode_fast()`, which could return early with invalid base64 data. In that case, `base64_decode()` falls back to calling `base64_decode_slow()`. Let's take a look at that function, which starts at [line 167 of `string_bytes.cc`](https://github.com/nodejs/node/blob/v4.2.1/src/string_bytes.cc#L167):

{% highlight cpp linenos hl_lines="16 17" linenostart=167 %}
template <typename TypeName>
size_t base64_decode_slow(char* dst, size_t dstlen,
                          const TypeName* src, size_t srclen) {
  uint8_t hi;
  uint8_t lo;
  size_t i = 0;
  size_t k = 0;
  for (;;) {
#define V(expr)                                             \
    while (i < srclen) {                                    \
      const uint8_t c = src[i];                             \
      lo = unbase64\(c\);                                     \
      i += 1;                                               \
      if (lo < 64)                                          \
        break;  /\* Legal character. \*/                      \
      if (c == '=')                                         \
        return k;                                           \
    }                                                       \
    expr;                                                   \
    if (i >= srclen)                                        \
      return k;                                             \
    if (k >= dstlen)                                        \
      return k;                                             \
    hi = lo;
    V(/* Nothing. */);
    V(dst[k++] = ((hi & 0x3F) << 2) | ((lo & 0x30) >> 4));
    V(dst[k++] = ((hi & 0x0F) << 4) | ((lo & 0x3C) >> 2));
    V(dst[k++] = ((hi & 0x03) << 6) | ((lo & 0x3F) >> 0));
#undef V
  }
  UNREACHABLE();
}
{% endhighlight %}

This macro-fied code may be a little hard to follow, but the behavior we care about is straightforward. Look at lines 182 and 183. Any "`=`" in the data causes the function to return early. It doesn't matter if `src` is a megabyte. If the first character is "`=`", `k` is still zero when line 183 is hit. Once we figured that out, it wasn't too hard to reproduce the issue in a line of JavaScript. Try this with Node.js (or io.js) from v3.0.0 to v4.2.1:

{% highlight javascript %}
ggreer@lithium:~% node
> new Buffer("=" + new Array(10000).join("A"), "base64");
node: ../src/node_buffer.cc:225: v8::MaybeLocal<v8::Object> node::Buffer::New(v8::Isolate*, v8::Local<v8::String>, node::encoding): Assertion `(data) != (nullptr)' failed.
zsh: abort (core dumped)  node
ggreer@lithium:~%
{% endhighlight %}

Armed with a one-liner crash, I [reported the issue](https://github.com/nodejs/node/issues/3496) and described how I thought it was breaking. It only took a day for [Ben Noordhuis](https://github.com/bnoordhuis) to fix the bug in master. Node.js v4.2.2 and v5.0.0 shipped with the fix. Mission accomplished!

Except… we didn't answer some important questions: Where was this invalid base64 coming from? Why was our back-end service processing it? Those answers are in [the next post]({% post_url 2015-11-02-bad-base64-a-not-so-tricky-bug %}).

---

Thanks to Matt Kaniaris, Ben Noordhuis, and the rest of the Node.js team for their help.

1. <span id="ref_1"></span> Even when a process asks for more memory than is available, modern OSes return a usable pointer. Only when the memory is accessed will the OS jump into action and free memory by [killing processes](http://linux-mm.org/OOM_Killer).

2. <span id="ref_2"></span> Why `length / 4 * 3` instead of `length * 0.75` or `(length * 3) / 4`? This is C++, so the former requires a type conversion to float or double, followed by rounding. The latter could overflow if `length` is greater than `SIZE_MAX / 3`.
