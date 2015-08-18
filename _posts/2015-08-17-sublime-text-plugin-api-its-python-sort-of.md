---
date: '2015-08-17 15:37:18'
layout: post
slug: sublime-text-plugin-api-its-python-sort-of
published: true
title: "Sublime Text's Plugin API: It's Python... Sort Of"
authors:
  - ggreer
categories:
  - 'Sublime Text'
  - Bugs
excerpt_separator: <!--more-->
---

> "Sort of" is such a harmless thing to say... sort of. It's just a filler. Sort of... it doesn't really mean anything. But after certain things, sort of means everything. Like... after "I love you"... or "You're going to live."

— [Demetri Martin](https://en.wikipedia.org/wiki/Demetri_Martin)

[Sublime Text](http://www.sublimetext.com/) is my editor of choice. It's powerful, flexible, and accessible. But as much as I like it, Sublime Text has one glaring problem: its plugin API is Python... sort of. That "sort of" is responsible for much frustration and annoyance.

<!--more-->

For most devs most of the time, writing Sublime Text plugins is scarcely different from writing normal Python. Just import some modules, define your [Sublime commands](https://www.sublimetext.com/docs/3/api_reference.html#sublime_plugin.ApplicationCommand), and you're golden. At Floobits, we learned the hard way that this isn't always the case. Two years ago, after months of extensive development and testing, we finally judged our Sublime Text plugin ready. We released it to the world... only to suffer a deluge of complaints. Many on Windows and Linux couldn't use our plugin. Merely activating our plugin raised exceptions on their systems.

This confused us. Though we develop on Macs, the code should work fine everywhere. Except for a few well-documented edge cases, Python behaves the same on Windows, OS X, and Linux.

Sadly, that's not true for Sublime Text's Python. The Python that ships with Sublime Text varies significantly in its capabilities. On some platforms and Sublime Text verisons, standard modules are broken. You can verify this yourself. Open Sublime Text 2 on Windows and run `import select` in the console:

<img src="/images/st2_win_select.png" />

Or if you're on Linux, open Sublime Text 2 or 3, then try to `import ssl`<sup>[\[1\]](#ref_1)</sup>:

<img src="/images/st2_linux_ssl.png" />

For Floobits, these errors were deal-breakers. Our plugins need `select()` for asynchronous network I/O. Our network protocol always uses encryption, necessitating the `ssl` module. For our purposes, these modules had no alternatives or substitutes. At the time, this realization was extremely disheartening. We racked our brains for solutions. It took a while, but we had an insight: Sublime's Python might lack `ssl`, but the operating system's Python should be fine. If we could hand encryption/decryption work to the OS's Python, we'd be in business. Once we knew what to do, [our solution](https://github.com/Floobits/floobits-sublime/pull/144) took only a week to code.

Our users were happy, but the experience left me disillusioned. [I reported the `import ssl` issue](https://github.com/SublimeTextIssues/Core/issues/177) almost two years ago, but it still hasn't been fixed. At this point, I doubt it ever will be.

1. <span id="ref_1"></span> This may not error for users of [Package Control](https://packagecontrol.io/), which can install its own ssl module.
