---
date: '2013-08-02 14:20:00'
layout: post
slug: floomatic-a-headless-floobits-client
published: true
title: 'Floomatic: A Headless Floobits Client'
categories:
---

We made a new tool: [Floomatic](https://floobits.com/help/floomatic/). Floomatic synchronizes a directory with a Floobits workspace. Like [our plugins](https://floobits.com/help/plugins/), Floomatic is open source software. [Check it out on GitHub](https://github.com/Floobits/floomatic).

We use Floobits to develop Floobits, so a lot of the features we build are to solve our own problems. One issue we had was that we could collaborate on code just fine, but it wasn't easy for both of us to see the results of our changes. This was especially apparent when doing web development. Usually, one of us would run a local development instance of Floobits. Then we'd screen-share or just describe to each other what the changes looked like.

Floomatic solves this problem. It's very useful for shipping changes to a server in real-time. To sync changes to a testing server, we ssh in, `cd` into wwwroot, and run...

`floomatic --read-only --join https://floobits.com/r/owner_name/workspace_name`

We also built hooks that can be called after a files change. We use hooks to regenerate CSS whenever our [LESS](http://lesscss.org/) changes, and [compress JavaScript](https://github.com/jezdez/django_compressor).

Like our [Sublime Text](https://github.com/Floobits/floobits-sublime) and [Vim](https://github.com/Floobits/floobits-vim) plugins, Floomatic obeys `.gitignore` and `.flooignore` files. If you don't want to ship your local settings to a shared development server, simply add them to `.flooignore`.

For instructions on setting up and installing Floomatic, see [our help page](https://floobits.com/help/floomatic/).
