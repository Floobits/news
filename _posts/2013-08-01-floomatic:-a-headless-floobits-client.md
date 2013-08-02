---
date: '2013-08-01 14:20:00'
layout: post
slug: floomatic-a-headless-floobits-client
published: true
title: Floomatic: A Headless Floobits Client
categories:
---

We use Floobits to develop Floobits, and one issue we kept having was that we wanted to ship changes to a shared development/testing server while we paired. It's no fun if only one person runs a local instance for development.

Our first stab at solving this problem was [the diffshipper](https://github.com/Floobits/diffshipper). Although it was useful, it was very hard to set up. Any user



Running everything locally makes it hard to work with others because of firewalls/nat, and you eventually wind up with testing on an environment that doesn't exactly match production.  Using a shared FS is slow.  Rsync is slow.  PKI is painful, particularlly on local VMS.  Committing to git just to test code is misusing git. alt tab + ctrl c + up arrow/enter 3 times after every file save is ridiculous for programmers.
