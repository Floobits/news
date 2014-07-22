---
date: '2014-07-22 15:21:12'
layout: post
slug: building-an-office-in-software
published: true
title: 'Building an Office in Software'
authors:
  - ggreer
categories:
  - Features
---

We use Floobits to develop Floobits, so we encounter many of the same pain points as our users. One problem we've had is chat. Often, we want to be able to communicate without necessarily working on the same code. Our first solution was to designate one workspace for chatting (both text and video). This worked, but the experience was definitely sub-optimal.

In an office, it's easy to tell when someone doesn't want to be interrupted. When they're not "in the zone", you can walk up and ask for help or information. If you want to have a conversation without distracting others, there are meeting rooms. Staying in the same Google+ Hangout or keeping video chat open all day is a very different experience. Unlike in an office, a conversation between two people distracts everyone. We needed a way to talk to each other without forcing our coworkers to leave the video chat or mute their sound. So we built a new feature: Org chat.

<img src="/images/Screen Shot 2014-07-22 at 1.56.44 PM.png" style="max-width: 100%;" alt="A typical moment in Floobits chat" title="A typical moment in Floobits chat" />

Every Floobits organization now has a chat page, which can only be accessed by members of that organization. People using org chat have a picture that updates periodically. Clicking on that picture starts a video chat with that person. You can rope in more people by clicking on more pictures. Clicking on a video stops the chat for that user. Clicking on yourself causes you to leave video chat.<sup>[\[1\]](#ref_1)</sup> There's also text chat for less attention-grabbing communication. This interaction is much closer to being in the same room. In some ways, it's better. People aren't distracted by others conversing nearby.

While building this feature, we discovered it had other advantages. It uses much less bandwidth than continuous video chat. This makes it usable over metered (often mobile) connections. Also, it improves battery life for laptop users, since less time is spent powering the camera, encoding video, and transmitting it. All of these benefits have helped org chat quickly become the stardard way we interact when we're not pairing.

If you are a member of a Floobits org, you can try org chat with your teammates right now. Just go to [your org list](https://floobits.com/dash/orgs) and click on a "Chat" button. The only requirements are a camera, microphone, and a WebRTC-capable browser such as Firefox or Chrome. Even Chrome on Android works.

We like to release early and often, so consider the current org chat a first draft. We plan on adding some very useful features in the near future, including:

* Screen sharing.
* Indicators of who is currently video chatting.
* Showing who is in each workspace.

We're also toying with adding notes and an IRC bridge, but those features are farther off.

It's been almost a year since I wrote, "[...any disadvantage of remote working is a software problem.](http://geoff.greer.fm/2013/08/28/an-office-made-of-software/)" I still think that's true. Remote collaboration software still has a long way to go, but we're doing our best to move it forward.


1. <span id="ref_1"></span>Credit where credit is due. This workflow was inspired by [Sqwiggle](https://www.sqwiggle.com/).
