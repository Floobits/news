---
date: '2014-06-05 13:50:05'
layout: post
slug: Screen Sharing in Floobits
published: true
title: Screen Sharing in Floobits
authors:
  - bjorn
categories:
---

### Floobits is better with screen sharing

Floobits is very useful for working together on code or the command line but sometimes we want to share something else on our computer. We might want to share debugger output in [IntelliJ](https://floobits.com/help/plugins/intellij) or discuss profiling information in Chrome's Web Inspector while trying to track down an issue on Floobits.com. We use Floobits to build Floobits and what we had just was not enough sometimes. Often we need a way to share screens, and our customers probably do too.


### Google Hangouts

Initially, we used Google Hangouts. This helped us not just share screens but also allowed us to hear and see each other. Google Hangouts lets you build applications directly into their product via an embedded iframe and so we integrated Floobits with Hangouts, a feature that still exists today. But while Google Hangouts lets you share screens and provides many features not yet available with WebRTC, it was not the best solution. Users had to enable third-party cookies to load Floobits workspaces in hangouts. Also, hangouts require a Google account linked with Google+. Requiring a Google account to make full use of Floobits did not seem right to us, especially considering enterprise customers who want to [run Floobits behind their firewall](https://floobits.com/enterprise). We needed something better than Google Hangouts for sharing screens on Floobits.

### Screenhero

In addition to trying Google Hangouts we also recently experimented a little bit with a fellow Y Combinator startup we admire called [Screenhero](http://screenhero.com/). It was very easy to get started using Screenhero, in fact much easier than getting started with Floobits. No Google account was required, but you still had to register an account, yet this was very easy. Screenhero is pretty amazing but we found allowing remote viewers to interact with our desktops too distracting. It may be possible to have multiple people share their screen with each other at the same time with Screenhero but if so it was not obvious as to how to do this. There were also issues with copy and paste not working while remote viewers had Screenhero focused on their side and remote viewers had problems seeing screens while windows were being switched or scrolled through too quickly. The other problem was that Screenhero would not be deployable to enterprise customers. Screenhero is great, but not what was needed to make Floobits better.

### Screen sharing on Floobits

Given that we had already replaced Hangouts with our own WebRTC-based video conferencing tools, built directly into Floobits, it only made sense to take advantage of the screen sharing feature that shipped with Chrome. For a time this Chrome feature allowed you to share your screen on Floobits with others. When it worked it was great. We were able to customize the screen sharing experience to suit our needs and it was deployable to enterprise customers. Screen sharing with Chrome does have problems. It can be demanding on the CPU, especially if you are sharing a large screen. Screen sharing with a browser also only works in Chrome and at the time it required users to enable a flag in their settings which might be a security problem. It was a workable solution until Chrome [unexpectedly turned this feature off](https://code.google.com/p/chromium/issues/detail?id=347641), breaking our product.

After Chrome disabled screen sharing we really missed it. [At the suggestion of others](https://news.ycombinator.com/item?id=7782754), we were able to replace what we had by shipping an extension that took advantage of an extension API called [`chooseDesktopMedia`](https://developer.chrome.com/extensions/desktopCapture). It still only works in Chrome but now it is much easier to get started using the extension rather than asking users to change chrome flags. Chrome’s ability to provide extensions with [inline install URLs](https://developer.chrome.com/webstore/inline_installation?hl=en) makes the process even easier. A simple click will prompt users to install our extension. We were able to replace instructions for users with code that completed the task with a click of a button.

<img src="/images/Screen Shot 2014-06-04 at 2.30.44 PM.png" style="height: 369px; width: 663px;" />


### Technical details of screen sharing with Chrome

Sharing your screen with other users involves using [WebRTC](http://www.html5rocks.com/en/tutorials/webrtc/basics/), a topic beyond the scope of this post. You can find [our WebRTC code](https://floobits.com/Floobits/django-stuff#buf-web/floobits/static/js/fl/webrtc.js) on Floobits. Once you have WebRTC working, adding screen sharing is not such a daunting task provided you know the specifics. [Our chrome extension](https://floobits.com/Floobits/chrome-screenshare#buf-extension/background.js) has very little code. It does a couple of things:


* A [content script](https://developer.chrome.com/extensions/content_scripts) replaces a link to install the extension with a link to enable screen sharing.

* It facilitates communication between the extension and the web page using HTML5’s [postMessage](https://developer.mozilla.org/en-US/docs/Web/API/Window.postMessage) and chrome’s [sendMessage](https://developer.chrome.com/extensions/messaging).

* The [background.js](https://developer.chrome.com/extensions/background_pages) script is signaled by the web page when the user wants to share screens. It uses [chooseDesktopMedia](https://developer.chrome.com/extensions/desktopCapture) to prompt the user for authorization via a really nifty dialog. The id is then passed to the web page and given to [getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/Navigator.getUserMedia).

The documentation for these features isn't great, but examples online helped us out through the rough spots. One particular troubling aspect was `chooseDesktopMedia` provides a very important optional argument that is required if you want to allow a web page to make use of the screen share id that is returned to you. You need to pass in as an argument to `chooseDesktopMedia` an instance of the tab that will be permitted to make the call to `getUserMedia`. [It took us a while to figure out.](https://github.com/Floobits/chrome-screenshare/commit/806ded34ad194ccdf949643bb233c81cb24f2e60) The error message we got when we did not do this right was not helpful.

For video chatting were able to reduce the bandwidth WebRTC video consumed by modifying the [SDP](http://tools.ietf.org/id/draft-nandakumar-rtcweb-sdp-01.html) that is shipped in our WebRTC side channel. Making this modification for screen sharing was not ideal because you actually want to see details when sharing screens. As an aside, we actually use our own Floobits protocol as the side channel for WebRTC. The same protocol we use to make real time collaboration work across editors.

With the exception of changing the constraints we used with our call to `getUserMedia`, everything worked pretty much as before used the extension. We had to change `chromeMediaSource` from `screen` to `desktop` and add the id provided by `chooseDesktopmedia` to `chromeMediaSourceId`.

<img src="/images/Screen Shot 2014-06-04 at 2.34.06 PM.png" style="width: 640px;" />

### You should check out Floobits

If you think you might want to easily share screens with others and maybe even video chat while editing code together you should give [Floobits](https://floobits.com) a try. It is getting easier to get started with Floobits every day, as making Floobits better for new users is our #1 primary focus and has been for months. We are not where we want to be yet and we know that, and if you have problems while trying us on, let us know. We will jump head over heals to get your setup working for you. Once Floobits works, you might wonder how you ever made it so long without it.  

To use the screen sharing feature you will need edit permissions on a Floobits workspace. If you have edit permissions, you should see an option to video chat on the bottom left in the sidebar on the web editor. After you click this a pop up that appears should have a link to get you started. Please us know if you have any suggestions or questions.
