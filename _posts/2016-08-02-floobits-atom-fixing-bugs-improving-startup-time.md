---
date: '2016-08-02 18:49:23'
layout: post
slug: floobits-atom-fixing-bugs-improving-startup-time
published: true
title: 'Floobits Atom: Fixing Bugs, Improving Startup Time'
authors:
  - ggreer
categories:
  - Atom
  - Tech
---

Our Atom package has been improved significantly since it was originally announced. Several of these improvements were thanks to fixes in Atom.

## Fixing Video Chat: Content Security Policy

When Atom 1.7 was released, users complained that [video chat showed a black screen](https://github.com/Floobits/floobits-atom/issues/114). Our plugin hadn't changed, so I suspected something in Atom was responsible. I soon tracked it down to [Content Security Policy](https://en.wikipedia.org/wiki/Content_Security_Policy) headers. The new version of Atom used a new version of Electron, which was based on a newer version of Chromium. The newer Chromium had [stricter CSP behavior](https://bugs.chromium.org/p/chromium/issues/detail?id=473904), such that `self` no longer included `blob:`. I found the relevant code in Atom and [submitted a pull request](https://github.com/atom/atom/pull/11552). It took a while for the Atom team to get around to merging it, but the fix is now in Atom 1.9.

## Fixing Crashes: Avoiding `NODE_ENV` Erasure

Another issue that had been plaguing our Atom package was random React-related crashes. None of the stack traces involved any Floobits code, so it took me a while to figure out the root cause. Try to find the common thread in all of these issues:

- [Floobits-atom: Uncaught TypeError: Cannot read property 'validated' of undefined #121](https://github.com/Floobits/floobits-atom/issues/121)
- [Floobits-atom: Uncaught TypeError: warnUnknownProperty is not a function](https://github.com/Floobits/floobits-atom/issues/123)
- [Floobits-atom: Uncaught TypeError: Cannot read property 'null' of undefined](https://github.com/Floobits/floobits-atom/issues/127)
- [Floobits-term3: Uncaught TypeError: Expecting a function in instanceof check, but got #\<Collection\>](https://github.com/Floobits/atom-term3/issues/56)
- [Floobits-term3: Uncaught TypeError: Cannot read property 'null' of undefined](https://github.com/Floobits/atom-term3/issues/63)

I went gallivanting through the React code and managed to figure it out. React was starting up in production mode, then later switching to debug mode. React only initializes certain debugging data structures if it starts up in debug mode. Switching to debug mode caused it to attempt to access things that didn't exist, throwing errors. Oops.

React chooses modes by checking `process.env.NODE_ENV`. If it's set to "production", it will run in production mode. Otherwise, it uses debug mode. So something in Atom was changing the `NODE_ENV` environment variable.


https://github.com/atom/atom/blob/a5fdf3e18a512349e7efb91b3c297b1a2b91bf63/src/initialize-application-window.coffee#L20


https://github.com/atom/atom/blob/a5fdf3e18a512349e7efb91b3c297b1a2b91bf63/src/environment-helpers.js#L75

NODE_ENV
https://github.com/atom/atom/issues/12024
https://github.com/atom/atom/pull/12028


startup time
