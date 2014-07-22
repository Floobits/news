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

It's been almost a year since I wrote, "[...any disadvantage of remote working is a software problem](http://geoff.greer.fm/2013/08/28/an-office-made-of-software/)", but I still think it's true. Unfortunately, remote collaboration software still has a ways to go.

We use Floobits to develop Floobits, so we encounter many of the same pain points as our users. One problem we had was chat. Often, we wanted to be able to communicate without necessarily working on the same code. Our first solution was to have a special workspace for chatting (both text and video). We also kept notes in that workspace. Still, the experience was definitely sub-optimal.

In an office, it's easy to tell when someone doesn't want to be interrupted. Once they're not "in the zone", you can walk up and ask for help or information. If you want to have a conversation without distracting others, you can go to a meeting room.

Staying in the same Google+ Hangout or keeping video chat open all day is not like this. Most importantly, it doesn't scale. A conversation between two people can distract everyone else. We needed a way to talk to each other without forcing our coworkers to leave the video chat or mute their sound.

