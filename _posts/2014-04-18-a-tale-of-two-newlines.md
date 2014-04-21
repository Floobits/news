---
date: '2014-04-18 16:14:29'
layout: post
slug: a-tale-of-two-newlines
published: true
title: A Tale of Two Newlines
categories:
  Bugs
  Post-mortem
---

Text files; they're the lowest common denominator. Practically anything that runs on electrons can understand them. There's only one tiny wrinkle: newlines.

Not all operating systems and protocols use the same bytes to represent newlines. Unix-based systems use a single line feed (LF) character. Windows uses a carriage return (CR) followed by a line feed.

Since Floobits lets people edit files simultaneously, we have to translate between Windows and Unix newlines.

explain strategy: use \n internally, each editor decides whether to use windows or unix-style newlines

The bug was in this function:

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

Can you spot the bug? It's subtle. You could stare at that function for hours and not see the problem, since it requires knowledge of how JavaScript's <code>[String.replace()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace)</code> works:

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

We had a similar issue stripping CRs from patches. Since clients expected all CRs to be stripped, they duplicated all CRs but the first one.

