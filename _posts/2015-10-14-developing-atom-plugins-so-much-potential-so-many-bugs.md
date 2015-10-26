---
date: '2015-10-14 08:58:38'
layout: post
slug: developing-atom-plugins-so-much-potential-so-many-bugs
published: true
title: 'Developing Atom Packages, Part 2: So Much Potential, So Many Bugs'
authors:
  - ggreer
categories:
  - Atom
  - Bugs
  - Tech
excerpt_separator: <!--more-->
---

Atom has improved drastically since its first release, but it's still not perfect. While building [our Atom package](https://github.com/Floobits/floobits-atom), we ran into quite a few bugs. Some have been fixed, but many still persist. [Previously]({% post_url 2015-10-12-developing-atom-plugins-on-the-bleeding-edge %}), I discussed Atom and its progress. That post addressed larger, broader issues. This post gets into specifics. *Lots* of specifics.

<!--more-->

### Yay, it's a Browser. Oh no, it's a Browser!

Atom is based on Chromium. While this does have the advantage of allowing for packages to be written with JavaScript and HTML, it also causes some unexpected problems. For example: In a browser, submitting a form causes a page reload. Atom behaves the same. Without a handler on the form that calls `event.preventDefault()`, Atom will reload the *entire* window, losing state and breaking many UI elements.

Another issue with Atom being a "sorta-browser" reveals itself when one tries to load remote content, such as a website. Iframes are the obvious choice, but many sites [kill frames](https://en.wikipedia.org/wiki/Framekiller) to prevent [clickjacking](https://en.wikipedia.org/wiki/Clickjacking). The only solution is to use the Chrome-specific [webview tag](https://github.com/atom/electron/blob/master/docs/api/web-view-tag.md). Unlike frames, webviews in Atom can't use `postMessage()` to communicate with the parent window. Instead, the parent has to bind to [the console-message event](https://github.com/atom/electron/blob/master/docs/api/web-view-tag.md#event-console-message). This receives data from `console.log()` calls in the webview. See [our web view template](https://github.com/Floobits/floobits-atom/blob/master/templates/webview.js#L23) for an example. This solution worked for us, but it's not a cure-all. If you can't add `console.log()` calls to the pages loaded in the webview, there's no way to get messages out.

If your package has any visible UI, you're also likely to run into styling conflicts. All Atom packages can include CSS or LESS, and all of their styles are applied globally. In addition, Atom loads a subset of [Bootstrap](http://getbootstrap.com/) for its own styling. To improve load time, Atom's Bootstrap is CSS, not LESS. That means you won't be able to `@import` it for your own package's use.


### Packaging

Compared to other editors, Atom's packaging system is *amazing*. Most editors don't even come with a package manager. Instead, users are forced to install third-party managers such as [Package Control](https://github.com/wbond/package_control) or [Vundle](https://github.com/VundleVim/Vundle.vim). Atom's package manager is great for users *and* developers. Users can easily find, install, and update packages. Developers can specify dependencies using [npm](https://www.npmjs.com/)'s `package.json` format. Packages can even [depend on other packages](https://atom.io/docs/latest/behind-atom-interacting-with-other-packages-via-services). For example, our Atom package depends on [Term3](https://atom.io/packages/term3). That allowed us to avoid copying a bunch of terminal-related code into our main package's source tree. It also means user settings for Term3 are always consistent. With luck, we'll be able to get our changes merged into [Term2](https://github.com/f/atom-term2) and depend on it instead. If not for Atom's package management, we would have a complete fork with polluted history. The prospect of merging would be all but hopeless.

Of course, like many parts of Atom, packaging does have a few rough edges. [Packages can load other packages](https://atom.io/docs/api/v1.0.19/PackageManager#instance-enablePackage)... most of the time. If a package uses `activationCommands`, [you're out of luck](https://discuss.atom.io/t/cant-activate-package-in-specs/13672/9). [There are a few undocumented workarounds](https://discuss.atom.io/t/can-you-force-the-activation-of-another-package/10885/18), but these hacky solutions are likely to break in minor Atom updates. Though packages can declare other packages as service dependencies, and they can (sometimes) load them, the dependent services will not be automatically installed. Users have to manually install them.


### The View System

Atom's view system has been a long series of misadventures. Early on, Atom recommended [Space Pen](https://github.com/atom-archive/space-pen), which was little more than a wrapper around [JQuery](https://jquery.com/). Then, [Atom moved to React](http://blog.atom.io/2014/07/02/moving-atom-to-react.html). Because package writers coded their packages against Atom's React, Atom is forced to stay on [an old fork](https://www.npmjs.com/package/react-atom-fork) (multiple versions of React [can't run in the same context](https://github.com/facebook/react/issues/2402)). It's unclear what will happen to Atom's React, but its future doesn't seem promising. Atom devs have been slowly removing React from core parts of Atom. More recently, Atom has started to implement parts of their visible UI in [special-purpose HTML tags](https://github.com/atom/atom/issues/5756). This doesn't seem to be the end-game for the view system though. The discussion around this topic has yet to nail down a solution.

To summarize:

<table style="width: 450px;">
  <thead>
    <th>Atom View API</th>
    <th>Status</th>
  </thead>
  <tbody>
    <tr>
      <td>Space Pen</td>
      <td><a href="https://github.com/atom/atom-space-pen-views">Deprecated</a></td>
    </tr>
    <tr>
      <td>React</td>
      <td><a href="https://github.com/jgebhardt/react-for-atom#a-single-instance-of-react">Deprecated</a></td>
    </tr>
    <tr>
      <td>Special DOM elements</td>
      <td><a href="https://github.com/atom/atom/issues/3752#issuecomment-60645402">Maybe deprecated soon?</a></td>
    </tr>
  </tbody>
</table>

It's unclear what's next for Atom's view API, but hopefully the community settles on something.

The API for managing windows is also a mess. For example, `atom.open({'pathsToOpen': ['~/code/example'], 'newWindow': false});` [opens a new window](https://github.com/atom/atom/issues/5138), despite the fact that `newWindow` is false. Annoyingly, `atom.open()` can also *close* current windows. The exact circumstances in which this happens are (so far) unpredictable. This bug is bad enough that we've had to add a disclaimer in our Atom package.


### Miscellaneous

Atom's API and internals have changed significantly since its first release, but a few annoyances have persisted. A big one for us has been resize detection. It's very useful to know when a pane was resized. The only way to do that right now is [inefficient polling](https://github.com/abe33/atom-utils#resizedetection). (See the implementation [here](https://github.com/abe33/atom-utils/blob/master/src/mixins/resize-detection.coffee#L25)).

A few pernicious issues stem from faults in Atom's architecture. Packages have no isolation, so it's easy for them to step on each other's toes. Styling conflicts are the most common version of this. Much of Atom itself is implemented as packages, so this lack of isolation means that misbehaving packages can hang or crash Atom. Fixing this is an immense task, as it requires completely changing the plugin architecture. Even if Atom goes down that road, there's no perfect solution. As Chrome extensions show, isolating packages has its own disadvantages.

One thing that Atom has done a great job of is unbinding event handlers. Their [disposable](https://atom.io/docs/api/v1.0.19/CompositeDisposable) objects make cleanup of event handlers trivial. Instead of forcing developers to keep track of bound functions, disposables have a `dispose` method that unbinds the event handler. Disposables can also be collected into a `CompositeDisposable`. I wish more JavaScript codebases used disposables.

---

This post may seem critical of Atom, but that's not the case. I took the time criticize Atom because I care about it, and I want it to be better. I think Atom is a fine editor with a *ton* of potential. It has come a long way in a short time. Hopefully, Atom developers will use this post to improve it even more.

<!-- we duck type/mock an atom Pane as they don't expose one anywhere to load external html
  https://github.com/Floobits/floobits-atom/blob/master/templates/pane.coffee -->
