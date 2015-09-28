---
date: '2015-09-22 22:16:22'
layout: post
slug: developing-atom-plugins-on-the-bleeding-edge
published: true
title: 'Developing Atom Plugins, Part 1: On the Bleeding Edge'
authors:
  - ggreer
categories:
  - Atom
  - Bugs
  - Tech
---

Back in February of 2014, GitHub [announced their new editor: Atom](http://blog.atom.io/2014/02/26/introducing-atom.html). We've followed Atom since it went public, and recently developed [a Floobits plugin for it](https://github.com/Floobits/floobits-atom). What follows are our impressions from the experience.

### The History of Atom in 30 Seconds

At the time of its release, Atom was slow, buggy, and lacked basic features. Many wrote it off it as cheap imitation of [Sublime Text](https://www.sublimetext.com/). In the subsequent 18 months, Atom has improved remarkably. The [recent 1.0 release](http://blog.atom.io/2015/06/25/atom-1-0.html) is a powerful, extensible editor suited for everyday use. Atom still isn't as fast or as stable as Sublime Text, but it's catching up quickly. Or to put it more accurately: Sublime Text development has stagnated. Since the first release of Atom, Sublime Text 2 has had *zero* releases. Sublime Text 3 Beta has had three, one of which was a minor bug fix. Considering the difference in development speed, Atom will almost certainly improve faster than Sublime Text.


### Not All Rainbows and Unicorns

That said, Atom's journey hasn't been completely pleasant. Its development process is accurately described by Facebook's slogan: "Move fast and break things." Since its initial release, Atom's API has [changed drastically](https://atom.io/docs/v0.186.0/upgrading/upgrading-your-package), breaking package compatibility multiple times. Even the [license has changed](http://blog.atom.io/2014/05/06/atom-is-now-open-source.html). Most of these changes have been for the better, but keeping up with them requires significant time and effort. Hopefully, things will settle down now that Atom is 1.x.


### It's a Browser... Sort Of

Many of Atom's detractors point out that it's based on a browser: Chromium. While this does increase resource usage and startup time, there are significant advantages to building on top of Chromium:

* Fewer cross-platform issues. Chromium already works well on OS X, Windows, and Linux.
* Plugins are written using JavaScript, HTML, and CSS. Web developers can quickly learn to extend Atom.
* Tracking down errors in Atom is much easier than other editors, thanks to Chromium's debugger. Only IntelliJ has comparable self-debugging abilities.
* Chromium has browser technologies such as [WebRTC](https://en.wikipedia.org/wiki/WebRTC), which aren't available in any other editor or IDE. [Floobits for Atom](https://github.com/Floobits/floobits-atom) uses WebRTC for video chat. It's very nice.

Leveraging a browser has advantages and disadvantages, but I think GitHub made the right choice.


### A Few Missing Pieces

The Atom devs have done a great job over the past 18 months, but a few conspicuous issues still linger. By far, the most glaring bug is binary safety. If you open a binary file with Atom and save it without making any changes, [the file will be corrupted](https://github.com/atom/node-pathwatcher/issues/62). The only other editor I know that does this is [nano](https://en.wikipedia.org/wiki/GNU_nano).

Another glaring omission is Atom's lack of GitHub integration. Some extensions are GitHub-specific, but the editor itself has no GitHub features. Built-in GitHub authentication would be useful for many extensions. Instead of setting your GitHub API key/secret in each plugin, Atom could provide it (with appropriate prompting, of course).

If you want a more technical discussion of Atom's current issues, read [part 2]({% post_url 2015-09-24-developing-atom-plugins-so-much-potential-so-many-bugs %}).

<!--
advantages:
javascript (always bet on js) ✓
  https://discuss.atom.io/t/coffeescript---extends-vs-util-inherits-inheritance-in-js/2536
it's a browser ✓
  webrtc ✓
  its a browser, sorta:
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
  the good:
    https://atom.io/docs/api/v1.0.7/Disposable#instance-dispose
-->
