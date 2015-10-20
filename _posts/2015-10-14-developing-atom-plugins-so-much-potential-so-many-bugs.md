---
date: '2015-10-14 08:58:38'
layout: post
slug: developing-atom-plugins-so-much-potential-so-many-bugs
published: true
title: 'Developing Atom Plugins, Part 2: So Much Potential, So Many Bugs'
categories:
authors:
  - ggreer
categories:
  - Atom
  - Bugs
  - Tech
excerpt_separator: <!--more-->
---

Atom has improved drastically, but it's nowhere near perfect. While building our Atom plugin, we ran into quite a few bugs. Some have been fixed, but many still persist. [Previously]({% post_url 2015-09-22-developing-atom-plugins-on-the-bleeding-edge %}), I discussed Atom and its progress. Much of that post addressed larger, broader issues. This post is an addendum of specifics.

<!--more-->

### Yay, it's a Browser. Oh no, it's a Browser!

As mentioned previously, Atom is based on Chromium. While this does have the advantage of writing plugins with JavaScript and HTML, it also causes some problems. For example: In a browser, submitting a form causes a page reload. Atom behaves the same. So unless you call `event.preventDefault()`, Atom will reload the tab, losing state and breaking many UI elements.

Another issue with Atom being a "sorta-browser" is caused when one tries to load remote content. The first thing most people try is an iframe. Unfortunately, many sites [kill frames](https://en.wikipedia.org/wiki/Framekiller) to prevent [clickjacking](https://en.wikipedia.org/wiki/Clickjacking). The solution is to use a [web view](https://github.com/atom/electron/blob/master/docs/api/web-view-tag.md). Since this feature isn't available in regular browsers, most web developers aren't aware of it.


### Packaging

Compared to other editors, Atom's packaging system is amazing. Most editors don't even come with a package manager. Instead, users are forced to install third-party managers such as [Package Control](https://github.com/wbond/package_control) or [Vundle](https://github.com/VundleVim/Vundle.vim). Atom's package manager is great for users and developers alike. Users can easily find, install, and update packages. Developers can specify dependencies using the `package.json` format used by [npm](https://www.npmjs.com/). Packages can even [depend on other packages](https://atom.io/docs/latest/behind-atom-interacting-with-other-packages-via-services). That can really come in handy. For example, our Atom plugin depends on [Term3](https://atom.io/packages/term3). That allowed us to avoid copying a bunch of terminal-related code into our main plugin source tree. With luck, we'll be able to get our changes merged into [Term2](https://github.com/f/atom-term2) and depend on it instead. If not for Atom's package management, that prospect would be all but hopeless.

Of course, like many parts of Atom, packaging does have a few rough edges. [Packages can load other packages](https://atom.io/docs/api/v1.0.19/PackageManager#instance-enablePackage)... most of the time. If a package uses `activationCommands`, [you're out of luck](https://discuss.atom.io/t/cant-activate-package-in-specs/13672/9). [There are a few undocumented ways to work around this](https://discuss.atom.io/t/can-you-force-the-activation-of-another-package/10885/18), but these hacky solutions are likely to break in minor Atom updates.


### The View System

Atom's view system has been a long series of misadventures. Early on, Atom recommended [Space Pen](https://github.com/atom-archive/space-pen
), which was little more than a wrapper around [JQuery](https://jquery.com/). Then, [Atom moved to React](http://blog.atom.io/2014/07/02/moving-atom-to-react.html). Unfortunately, they haven't kept up with Facebook's React, choosing instead to stay on [an old fork](https://www.npmjs.com/package/react-atom-fork). It's unclear what the will happen to Atom's React, but its future doesn't seem promising.

More recently, Atom has started to implement parts of their visible UI in special-purpose HTML tags.

The API for opening new windows is also a mess. For example, `atom.open({'pathsToOpen': ['~/code/example'], 'newWindow': false});` [opens a new window](https://github.com/atom/atom/issues/5138), despite the fact that `newWindow` is false. Annoyingly, `atom.open()` can also *close* current windows.

###

Despite all these changes, there are s

https://github.com/abe33/atom-utils#resizedetection

https://github.com/abe33/atom-utils/blob/master/src/mixins/resize-detection.coffee#L25



view system - a fucking mess!
  space pen - wrapper around jquery! https://github.com/atom-archive/space-pen
    no longer supported maybe?
  react -
    http://blog.atom.io/2014/07/02/moving-atom-to-react.html
    some core functionality was implemented in react, cementing the entire community to a fork https://www.npmjs.com/package/react-atom-fork .11.5
  html5 custom elements
    no more jquery, but we not everything is supported natively - see https://github.com/abe33/atom-utils#resizedetection

  we have space pen views in CS as well as JS, as well as html5 views and a html5 react wrapper

  we duck type/mock an atom Pane as they don't expose one anywhere to load external html
    https://github.com/Floobits/floobits-atom/blob/master/templates/pane.coffee

Another big annoyance for us was API changes.
