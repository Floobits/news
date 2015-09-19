---
date: '2015-09-16 22:16:22'
layout: post
slug: developing-atom-plugins-on-the-bleeding-edge
published: true
title: 'Developing Atom Plugins Part 1: On the Bleeding Edge'
authors:
  - ggreer
categories:
  - Atom
  - Bugs
  - Tech
---

Back in February of 2014, [GitHub announced their new editor: Atom](http://blog.atom.io/2014/02/26/introducing-atom.html). At the time of its release, Atom was slow, buggy, and lacking many popular features. Many wrote it off it as cheap imitation of Sublime Text. In the subsequent 18 months, Atom has improved remarkably. The [recent 1.0 release](http://blog.atom.io/2015/06/25/atom-1-0.html) is a powerful, extensible editor suited for everyday use.

Atom still isn't as fast or as stable as Sublime Text, but it's catching up quickly. Or to put it more accurately, Sublime Text development has stagnated. Since the first release of Atom, Sublime Text 2 has had *zero* releases. Sublime Text 3 Beta has had 3, one of which was a minor bug fix. Considering the difference in development speed, Atom will almost certainly improve faster than Sublime Text.

That said, Atom's journey hasn't been completely pleasant. Its development process is accurately described by Facebook's slogan: "Move fast and break things." Atom's API has changed drastically, breaking plugin compatibility multiple times. [Even its source license changed(http://blog.atom.io/2014/05/06/atom-is-now-open-source.html).

Many of Atom's detractors point out that it's based on a browser: Chromium. While this does increase resource usage and startup time, there are significant advantages to building on top of Chromium. Plugins are written in JavaScript, with a little HTML and CSS. Anyone with web development skills won't have a hard time writing Atom plugins. Leveraging browser code also makes a new class of features possible. [WebRTC](https://en.wikipedia.org/wiki/WebRTC) is supported in Atom. That allowed us to build video chat into our plugin.

issues:
slow ✓
no github auth (would be super handy)

advantages:
javascript (always bet on js) ✓
  https://discuss.atom.io/t/coffeescript---extends-vs-util-inherits-inheritance-in-js/2536
it's a browser ✓
  webrtc ✓
  its a broswer, sorta:
    same origin policy/HSTS fucks loading stuff in iframes
    you can use a webview, but it doesn't honor postmessage events
      use console.message as a channel between plugin and webpage
        https://github.com/Floobits/floobits-atom/blob/master/templates/webview.js#L13

  plugin conflicts:
    everyones CSS conflicts - actual problem in the wild
    I expect front end frameworks will conflict as people write IDE like plugins
      see https://github.com/facebook/react/issues/1939#issuecomment-50632807

  posting forms refreshes the "page" (atom) if you don't preventdefault
  https://github.com/Floobits/floobits-atom/commit/9d478125c9b431f950146bbe644f1cac3fbc2b0e



The API:
  https://atom.io/docs/v0.186.0/upgrading/upgrading-your-package

  the good:
    https://atom.io/docs/api/v1.0.7/Disposable#instance-dispose
