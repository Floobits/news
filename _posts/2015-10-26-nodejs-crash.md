---
date: '2015-10-26 09:59:01'
layout: post
slug: nodejs-crash
published: true
title: nodejs crash
authors:
  - ggreer
categories:
  - Node.js
  - Bugs
  - Tech
---

In early September, we started seeing one of our backend services crash with the following error:

    2015-09-10_23:28:11.75413 node: ../src/node_buffer.cc:226: v8::MaybeLocal<v8::Object> node::Buffer::New(v8::Isolate*, v8::Local<v8::String>, node::encoding): Assertion `(data) != (nullptr)' failed.

Typically, node.js exits with a stack trace. But in this case, the error was at a lower level. Node.js was dying because of an assertion in its Buffer code. The exact function was in [`node_buffer.cc` on line 225](https://github.com/nodejs/node/blob/v4.2.1/src/node_buffer.cc#L225):

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

Somehow, `data` was null. Thinking the `realloc()` on line 224 might have failed, I double-checked memory usage on the servers. They were not in danger of reaching any limits, and crashes didn't seem to depend on memory usage. The service crashed while using 1GB of RAM just as often as it did using 100MB. Dang. Not an easy fix. It was a slim hope anyways. Modern OSes don't return null from `malloc()` and friends.<sup>[\[1\]](#ref_1)</sup>

The next thing I did was `man realloc`, to try and figure out how it could return null. Except for an out-of-memory condition, it wasn't possible. Even passing null to `realloc()` returned a usable chunk of memory:

> If ptr is NULL, realloc() is identical to a call to malloc() for size bytes.  If size is zero and ptr is not NULL, a new, minimum sized object is allocated and the original object is freed.

So there was simply no way for that function, executed sequentially, to fail in this way. Therefore (I reasoned), the bug must be another thread modifying shared state. Probably a hard-to-reproduce race condition. Ugh. Still, I needed to fix the issue. Desiring to know more, I tried to build a reproducible test case.

Unfortunately, I could only trigger the crash in production and staging, and only when copying lots of data between instances of our colab service. Having a lot of other stuff to do, I mitigated the issue by reducing the peak rate at which the service copied data.

A month later, Matt finally got tired of seeing crash emails. We paired to try and find the underlying cause. When I was explaining the issue to Matt, I pointed out that `realloc()` never returns null. He double-checked the manpage and disagreed. When he linked to the manpage describing `realloc()`'s behavior, it said:

> If size was equal to 0, either NULL or a pointer suitable to be passed to free() is returned.

Wait, what?! It turned out that I had run `man realloc` on my mac, while he had googled for realloc and clicked on the first result. That result described `realloc()` on linux. Apparently, the two behaved differently. Here are the relevant lines from `Buffer::New`:

{% highlight cpp linenos linenostart=220 %}
size_t actual = StringBytes::Write(isolate, data, length, string, enc);
CHECK(actual <= length);

if (actual < length) {
  data = static_cast<char*>(realloc(data, actual));
  CHECK_NE(data, nullptr);
}
{% endhighlight %}

If `realloc()` returns null, `actual` must be zero.

We paired on the issue and fixed it in five hours.


paired on the bug with matt
looked at linux manpage for realloc. oh hey, it can return null if len 0. fuck

added some logging to node. deployed to staging

base64 encoded bufs are culprit

{% highlight javascript %}
ggreer@lithium:~% node
> new Buffer("=" + new Array(10000).join("A"), "base64");
node: ../src/node_buffer.cc:225: v8::MaybeLocal<v8::Object> node::Buffer::New(v8::Isolate*, v8::Local<v8::String>, node::encoding): Assertion `(data) != (nullptr)' failed.
zsh: abort (core dumped)  node
ggreer@lithium:~%
{% endhighlight %}

https://github.com/nodejs/node/issues/3496


1. <span id="ref_1"></span> Even when a process asks for more memory than is available, modern OSes return a usable pointer. Only when the memory is accessed will the OS jump into action and free memory by [killing processes](http://linux-mm.org/OOM_Killer).
