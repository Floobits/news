---
date: '2016-08-02 18:49:23'
layout: post
slug: floobits-atom-fixing-bugs
published: true
title: 'Floobits Atom: Fixing Bugs (in Atom)'
authors:
  - ggreer
categories:
  - Atom
  - Tech
---

Our Atom package has been improved significantly since it was originally announced. Several of these improvements were thanks to fixes in Atom.

## Fixing Video Chat: Content Security Policy

When Atom 1.7 was released, users complained that [video chat showed a black screen](https://github.com/Floobits/floobits-atom/issues/114). Our plugin hadn't changed, so I suspected something in Atom was responsible. I soon tracked it down to [Content Security Policy](https://en.wikipedia.org/wiki/Content_Security_Policy) headers. The new version of Atom used a new version of Electron, which was based on a newer version of Chromium. The newer Chromium had [stricter CSP behavior](https://bugs.chromium.org/p/chromium/issues/detail?id=473904), such that `self` no longer included `blob:`. I found the relevant code in Atom and [submitted a pull request](https://github.com/atom/atom/pull/11552). It took a while for the Atom team to merge it, but the fix is now in Atom 1.9.

## Fixing Crashes: Avoiding `NODE_ENV` Erasure

Another issue that had been plaguing our Atom package was random React-related crashes. None of the stack traces involved any Floobits code, so it took me a while to figure out the root cause. Try to find the common thread in all of these issues:

- [Floobits-atom: Uncaught TypeError: Cannot read property 'validated' of undefined #121](https://github.com/Floobits/floobits-atom/issues/121)
- [Floobits-atom: Uncaught TypeError: warnUnknownProperty is not a function](https://github.com/Floobits/floobits-atom/issues/123)
- [Floobits-atom: Uncaught TypeError: Cannot read property 'null' of undefined](https://github.com/Floobits/floobits-atom/issues/127)
- [Floobits-term3: Uncaught TypeError: Expecting a function in instanceof check, but got #\<Collection\>](https://github.com/Floobits/atom-term3/issues/56)
- [Floobits-term3: Uncaught TypeError: Cannot read property 'null' of undefined](https://github.com/Floobits/atom-term3/issues/63)

I went gallivanting through the React code and managed to figure it out. React was starting up in production mode, then later switching to debug mode. React only initializes certain debugging data structures if it starts up in debug mode. Starting in production and switching to debug mode caused it to attempt to access object properties that didn't exist. Oops.

React chooses modes by checking `process.env.NODE_ENV`. If it's set to "production", it will run in production mode. Otherwise, it uses debug mode. Atom initializes `NODE_ENV` to "production" in [src/initialize-application-window.coffee](https://github.com/atom/atom/blob/a5fdf3e18a512349e7efb91b3c297b1a2b91bf63/src/initialize-application-window.coffee#L20). Something must change it later.

I finally tracked it down to [src/environment-helpers.js](https://github.com/atom/atom/blob/a5fdf3e18a512349e7efb91b3c297b1a2b91bf63/src/environment-helpers.js#L75):

{% highlight js hl_lines="6" linenos linenostart=70 %}
// Fix for #11302 because `process.env` on Windows is a magic object that offers case-insensitive
// environment variable matching. By always cloning to `process.env` we prevent breaking the
// underlying functionality.
function clone (to, from) {
  for (var key in to) {
    delete to[key]
  }

  Object.assign(to, from)
}
{% endhighlight %}

This `clone()` function is called when running `atom` from the command line. If Atom is already running, it replaces the existing environment with the new one, which usually lacks `NODE_ENV`. Oops.

I created [an issue describing the problem](https://github.com/atom/atom/issues/12024), soon followed by [a pull request to fix it](https://github.com/atom/atom/pull/12028).


## A Side Note: Node's `process.env`

While working on the `NODE_ENV` issue, I discovered some surprising behavior in Node's `process.env`. Look at this REPL interaction:

{% highlight js %}
> process.env.TEST = undefined
undefined
> process.env.TEST
'undefined'
> typeof process.env.TEST
'string'
{% endhighlight %}

That's right: `process.env` stringifies any value you try to set. The only way to un-set an environment variable is to `delete` it. This isn't as crazy as it first sounds. Environment variables can only be strings. Still, such behavior is not obvious. [It's documented](https://nodejs.org/api/process.html#process_process_env), but let's be honest: Developers only read docs when they don't think they understand something. If `process.env` looks like an object and walks like and object and quacks like an object, developers will think it's an object. A better solution would be to have explicit `process.setenv()` and `process.getenv()` functions.


## Conclusion

Fixing these bugs taught me some new things about browsers, Atom, and Node.js. No matter how much experience one has with these software projects, there's always plenty more to learn. To debug software is to be constantly reminded of one's hubris.

Lastly: If you've tried Floobits for Atom before and found it lacking, I urge you to check it out again. In addition to these bug fixes, the UI has been revamped. It all makes for a much better experience. And if you do find issues, please [report them](https://github.com/Floobits/floobits-atom/issues). User feedback is incredibly helpful!
