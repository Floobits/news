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

It's been almost a year since I wrote, "[...any disadvantage of remote working is a software problem.](http://geoff.greer.fm/2013/08/28/an-office-made-of-software/)" I still think that's true.

We use Floobits to develop Floobits, so we encounter many of the same pain points as our users. One problem we've had is chat. Often, we want to be able to communicate without necessarily working on the same code. Our first solution was to designate one workspace for chatting (both text and video). This worked, but the experience was definitely sub-optimal.

In an office, it's easy to tell when someone doesn't want to be interrupted. Once they're not "in the zone", you can walk up and ask for help or information. If you want to have a conversation without distracting others, there are meeting rooms. Staying in the same Google+ Hangout or keeping video chat open all day is very different from that. Unlike in an office, a conversation between two people distracts everyone else. We needed a way to talk to each other without forcing our coworkers to leave the video chat or mute their sound.

So we built a new feature: Org chat. Every Floobits organization now has a chat page. Only members of the organization can use it. People using org chat have their picture taken periodically. Clicking on a picture starts video chat with that person. You can rope in more people by clicking on more pictures. Clicking on a video stops the chat for that user. Clicking on yourself causes you to leave video chat. There's also text chat for less 

This interaction is much closer to being in the same room.

While building this feature, we discovered it had other advantages. It uses much less bandwidth than continuous video chat. Also, it improves battery life for laptop users. 

If you are a member of a Floobits org, just go to [your org list](https://floobits.com/dash/orgs) and click on a "Chat" button. You'll need a WebRTC-capable browser (Firefox or Chrome)

