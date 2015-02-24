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

Yesterday, we migrated our production environment from [Node.js](https://nodejs.org/) to [io.js](https://iojs.org/).<sup>[\[1\]](#ref_1)</sup> We made this decision for several reasons.

First, we were growing increasingly frustrated with Node's stagnation. Node.js v0.10 came out in March of 2013, 10 months after v0.8's release. Work on 0.12 began the same month. In January of 2014, Joyent's TJ Fontaine claimed [v0.12 was "imminent"](https://www.joyent.com/blog/node-js-and-the-road-ahead). Yet v0.12 finally shipped in February of 2015, more than a year later. Compared to previous releases, those two years of development didn't bring much. Just look at API changes between [v0.8-v0.10](https://github.com/joyent/node/wiki/Api-changes-between-v0.8-and-v0.10) and [v0.10-v0.12](https://github.com/joyent/node/wiki/Api-changes-between-v0.10-and-v0.12). It's both sad and 

But the decision to switch wasn't just driven by Node's issues.  io.js genuinely enticed us. Many [ECMAScript 6](https://iojs.org/en/es6.html) features are enabled out of the box. ES6 turns JavaScript into a much more pleasant, forgiving language. Just `let` and `const` allow one to avoid whole classes of mistakes.


If you're planning on switching to Node 0.12, the incremental effort to switch to io.js is quite small. For many uses, the benefits far outweigh the slight increase in work.



1. <span id="ref_1"></span> If you missed our downtime page, you can always view it [here](https://floobits.com/static/503.html).
