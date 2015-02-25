---
date: '2015-02-23 15:09:46'
layout: post
slug: moving-to-io.js
published: true
title: Moving to io.js
authors:
  - ggreer
categories:
  - Tech
---

Last weekend, we migrated our production environment from [Node.js](https://nodejs.org/) to [io.js](https://iojs.org/).<sup>[\[1\]](#ref_1)</sup> This move may seem premature, but we had several reasons for switching.

For starters, we were growing increasingly frustrated with Node's stagnation. Node.js v0.10 came out in March of 2013, 10 months after v0.8's release. Work on v0.12 began the same month. In January of 2014, Joyent's TJ Fontaine claimed [v0.12 was "imminent"](https://www.joyent.com/blog/node-js-and-the-road-ahead). Yet v0.12 finally shipped in February of 2015, over a year later. Compared to previous releases, those two years of development didn't bring many changes. Just look at API differences between [v0.8-v0.10](https://github.com/joyent/node/wiki/Api-changes-between-v0.8-and-v0.10) and [v0.10-v0.12](https://github.com/joyent/node/wiki/Api-changes-between-v0.10-and-v0.12). It's sad that such a useful, popular project has run out of steam lately. Even Node's latest release ships with old, unsupported versions of V8 (3.28.73) and libuv (1.0.2). Io.js has current releases: V8 4.1.0.14 and libuv 1.4.0. These bring performance improvements, bug fixes, and many new features.

The decision to switch wasn't driven solely by Node's issues. Many of io.js's features appealed to us. For example, io.js has [ECMAScript 6](https://iojs.org/en/es6.html) enabled by default, and supports more of ES6 than Node's `--harmony` flag. This may seem trivial, but it's actually a big deal. ES6 transforms JavaScript into a more powerful, more forgiving, and generally more pleasant-to-use language. [Template strings](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/template_strings) are a welcome bit of syntactic sugar. [`let`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let) and [`const`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/const) help programmers avoid whole classes of mistakes. [Generators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function*) and [promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) make it easier to translate one's mental models into straightforward code. In short, ES6 has changed how we write server-side JavaScript more than any major release of Node.js.

Despite io.js's rapid development, it has maintained or improved upon the stability of Node. Io.js's extensive test framework, frequent-but-small release cycle, and talented team of contributors have all helped to find and fix bugs faster than ever. Io.js is the most stable server-side JavaScript framework today.

Lastly, we found that the effort to switch from Node v0.12 to io.js was quite small. Since we were already planning on upgrading to Node v0.12, the benefits of io.js were worth the slight increase in work. Ours was a bit of a special case, as we had to do tweak a few of our [native modules](https://iojs.org/api/addons.html). For most users, io.js is a drop-in replacement.

If you're considering upgrading to Node v0.12, give io.js a try. You may be pleasantly surprised at the outcome.

---

Please note that this post should not be construed as disparaging or insulting Node.js or its contributors. I personally wish them the best of luck and hope they can regain momentum. While we prefer io.js right now, that could easily change. After all, io.js was unheard of only 90 days ago. May the best product win.

---

1. <span id="ref_1"></span> If you missed our downtime page, you can always view it [here](https://floobits.com/static/503.html).
