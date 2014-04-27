---
date: '2014-04-27 16:14:29'
layout: post
slug: a-tale-of-two-newlines
published: true
title: A Tale of Two Newlines
authors:
  - ggreer
categories:
  - Bugs
  - Post-mortem
---

Text files; they're the lowest common denominator. Practically anything that runs on electrons can understand them. There's just one tiny wrinkle: newlines.

Not all operating systems and protocols use the same bytes to represent newlines. Unix-based systems use a single line feed (LF) character. This is usually represented as a <code>\n</code> in programming languages. Windows uses a carriage return (CR) followed by a line feed. The carriage return is typically <code>\r</code>. Since Floobits lets people edit files simultaneously, we have to translate between Windows and Unix newlines.

At first glance, this seems like a trivial issue: Just detect the user's operating system and use the right newline. But Linux users don't always want LFs. Likewise, Windows users don't always want CRLFs. To fix this, we had to modify our plugins to take into account the OS, the global editor settings, the editor settings for the current buffer, and the file on disk. With all these inputs, we can get as close as possible to "magical" behavior: Users don't notice any problems. Git (with the default config) shows no specious whitespace diffs. It's like shaving: do the job right, and nobody will notice it's been done at all.

There was just one problem: our clever code didn't work. Users complained about files having extra CRs. Some lines would end in LFCRCR. This made no sense to us.Internally, our protocol uses LFs. If any client sends data containing CRs, our server code strips them before applying the text transformation and sending updates to other clients. Clients then insert CRs based on the heuristics outlined above. It was almost as if our server code *wasn't* stripping out CRs...

After much experimenting and debugging, we found the bug in this function:

{% highlight javascript %}
// Strip Windows newlines and make sure the buffer is a Buffer containing utf8, not a JS string
TextBuffer.prototype.normalize = function (state) {
  var self = this;

  if (!_.isString(state)) {
    state = state.toString(self.encoding);
  }
  state = state.replace("\r\n", "\n");
  return new Buffer(state, self.encoding);
};
{% endhighlight %}

Can you spot the bug? It's subtle. You could stare at that function for hours without seeing the problem. It requires knowledge of how JavaScript's <code>[String.replace()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace)</code> works:

{% highlight text %}
ggreer@carbon:~% node
> "123 123 123".replace("123", "456")
'456 123 123'
> 
{% endhighlight %}

If the first argument to <code>String.replace()</code> is a string, only the first instance of that string is replaced. To replace all instances, a regex is necessary:

{% highlight text %}
> "123 123 123".replace(/123/g, "456")
'456 456 456'
> 
{% endhighlight %}

We had a similar issue stripping CRs from patches. Since clients expected all CRs to be stripped, they inserted CRs before every LF in buffers that they decided should have CRLFs. But many lines *already* had CRLFs, so they ended up with CRCRLF. And if a user edited that line and sent another patch, it would become CRCRCRLF. Ad infinitum.


### Post-mortem

After fixing this bug, we thought of ways to reduce the chances of similar issues happening in the future. That meant first outlining ways in which we had failed:

1. Our tests used only one newline. Had they used more, we would have caught this bug before it ever ran in production.
1. We all use macs as our primary development machines, so we didn't do enough manual testing on Windows. 
1. Our plugin didn't have crash reporting.
1. The client knows when a transformation wasn't applied properly, it just didn't report that back to the server. We should have tracked how often this happened and to which clients it happened.

Then we thought of ways to ameliorate these problems:

1. We're adding more/better tests. Everyone says, "We should have more/better tests." but few actually follow through.
1. We added crash reporting to our plugins. If there's an unhandled exception, we see a stack trace.
1. We're working on a way to monitor the fraction of incorrectly-applied transformations, with the ability to slice by editor type, editor version, Python/Java version, and operating system.
1. We're testing plugins more thorougly on other operating systems before tagging a release.

We've already seen benefits from the changes we've made so far. Crash reports have informed us of unusual edge-case conditions that we'd never have thought to test ourselves. More thourough testing on other operating systems has saved us from some bugs in our newest plugin releases. Client statistics will take some time to implement, but I'm very excited to see the results.
