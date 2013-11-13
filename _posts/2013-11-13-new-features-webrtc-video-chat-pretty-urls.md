---
date: '2013-11-13 00:32:57'
layout: post
slug: new-features-webrtc-video-chat-pretty-urls
published: true
title: 'New Features: WebRTC Video Chat, Nicer URLs'
authors:
  ggreer
categories:
---

#### WebRTC Video Chat
You may have noticed some new icons in our web editor. Google+ Hangouts are handy, but we don't want to require Floobits users to have a Google account. That's why we've built [WebRTC](http://en.wikipedia.org/wiki/WebRTC) video chat into our editor. It's still in an alpha/testing state, but we use it daily in our own work.

To try out our new video chat, you'll need to have edit permission in a workspace. Once you do, click on the video camera in the upper right:

![WebRTC Video Toggle](/images/webrtc_video.png)

WebRTC works in Chrome and Firefox, although Firefox still has some issues reconnecting after a network interruption. This technology is very new, so don't expect it to be flawless.

<br />
#### Cleaner URLs

We've also cleaned up some of our URLs. We've removed the `/r` from `floobits.com/r/username/workspace` and taken the `/u` out of `floobits.com/u/username`. Old URLs now redirect to the clean ones.


<br />
#### Flootty Improvements

Finally, we've fixed some nagging issues with non-UTF8 data in [flootty](https://floobits.com/help/flootty/). Flootty now works even if a misbehaving process spews binary data to the terminal. Be sure to update by running `pip install --upgrade flootty`


<br />
<br />

That's what we've done recently. Next up: we're going to merge some big changes to our editor plugins for Sublime Text, Emacs, and Vim.
