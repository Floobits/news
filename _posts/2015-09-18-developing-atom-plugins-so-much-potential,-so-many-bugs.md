---
date: '2015-09-18 08:58:38'
layout: post
slug: developing-atom-plugins-so-much-potential-so-many-bugs
published: true
title: 'Developing Atom Plugins Part 2: So Much Potential, So Many Bugs'
categories:
authors:
  - ggreer
categories:
  - Atom
  - Bugs
  - Tech
---


[Previously]({% post_url 2015-09-16-developing-atom-plugins-on-the-bleeding-edge %}), I discussed Atom and its progress. While Atom has improved drastically, it's nowhere near perfect. While building our Atom plugin, we ran into many bugs. Some have been fixed, but many still persist.

By far, the biggest annoyance for us was API changes.

As mentioned before, Atom is based on a browser. While this does let you develop plugins with JavaScript and HTML, it causes some problems. For example: In a browser, submitting a form causes a page reload. Atom behaves the same. So unless you call `event.preventDefault()`, Atom will reload the tab, breaking many UI elements.

corrupts all binary files it opens (and saves with no modifications)
https://github.com/atom/node-pathwatcher/issues/62
https://github.com/abe33/atom-utils/blob/master/src/mixins/resize-detection.coffee#L25

API, the bad:
  package dependencies:
    docs for package.json say you can declare a dep on other atom packages https://atom.io/docs/v0.186.0/creating-a-package
    in fact, everything in atom core is in its own package
    activating other packages is almost a thing
      undocumented
      https://atom.io/docs/api/v1.0.11/PackageManager#instance-enablePackage
      does not work if the package relies on an activation command - see https://discuss.atom.io/t/cant-activate-package-in-specs/13672/9
      so we have to monkey patch or call internals - https://discuss.atom.io/t/can-you-force-the-activation-of-another-package/10885/18

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
