---
date: '2013-08-02 14:20:00'
layout: post
slug: floomatic-a-headless-floobits-client
published: true
title: Floomatic: A Headless Floobits Client
categories:
---

Today we're happy to announce a new Floobits tool: [Floomatic](https://floobits.com/help/floomatic/). Floomatic synchronizes a directory with a Floobits workspace. Like [our plugins](https://floobits.com/help/plugins/), Floomatic is open source software. [Check it out on GitHub](https://github.com/Floobits/floomatic).


To share a directory, just run `floomatic --share /path/to/share` and you'll get everything synced.

To join an existing workspace, simply `floomatic --join https://floobits.com/r/owner_name/workspace_name`

Most development environments run on the developer's local machine. While convenient, this makes it hard to work with others. Getting around [Firewalls](http://en.wikipedia.org/wiki/Firewall_%28computing%29) and [NAT](http://en.wikipedia.org/wiki/Network_address_translation) is frustrating.

 and you eventually wind up with testing on an environment that doesn't exactly match production. Using a shared FS is slow. Rsync is slow. PKI is painful, particularlly on local VMs. Committing to git just to test code is misusing git. alt tab + ctrl c + up arrow/enter 3 times after every file save is ridiculous for programmers.


We use Floobits to develop Floobits, so a lot of the features we build are to solve our own problems. The zen/tao/ of Floobits is 

issue we had was that we could collaborate on code just fine, but it wasn't easy for both of us to see the results of our changes. This was especially apparent when doing web development. Usually, one of us would run a local development instance of Floobits. Then we'd screen-share or just describe to each other what the changes looked like.



was that we wanted to ship changes to a shared development/testing server while we paired. It's no fun if only one person runs a local instance for development.

Our first stab at solving this problem was [the diffshipper](https://github.com/Floobits/diffshipper). Although it was useful, it was very hard to set up. Any user

gitignores, reloading hooks