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

Another issue that had been plaguing our Atom package was random React-related crashes. None of the stack traces involved any Floobits code, so it took me a while to figure out the root cause. Seriously, try to find the common thread in all of these issues:

- [Floobits-atom: Uncaught TypeError: Cannot read property 'null' of undefined](https://github.com/Floobits/floobits-atom/issues/127)
- [Floobits-atom: Uncaught TypeError: warnUnknownProperty is not a function](https://github.com/Floobits/floobits-atom/issues/123)
- [Floobits-term3: Uncaught TypeError: Expecting a function in instanceof check, but got #\<Collection\>](https://github.com/Floobits/atom-term3/issues/56)


React starts in production mode,


NODE_ENV
https://github.com/atom/atom/issues/12024
https://github.com/atom/atom/pull/12028


startup time
