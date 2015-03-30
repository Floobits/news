---
date: '2013-08-02 14:20:00'
layout: post
slug: floomatic-a-headless-floobits-client
published: true
title: 'Floomatic: A Headless Floobits Client'
authors:
  - ggreer
categories:
---

We made a new tool: [Floomatic](https://floobits.com/help/floomatic). Floomatic synchronizes a directory with a Floobits workspace. Like [our plugins](https://floobits.com/help/plugins), Floomatic is open source software. [Check it out on GitHub](https://github.com/Floobits/floomatic).

We use Floobits to develop Floobits, so a lot of the features we build are to solve our own problems. While we could easily collaborate on code, we sometimes had difficulty showing each other the results of our changes. This was especially apparent when doing web development. Usually, one of us would run a local development instance of Floobits. Then we'd screen-share or (more likely) describe to each other what the changes looked like or any tracebacks we encountered.

Floomatic solves this problem by allowing us to ship changes to a shared server in real-time. We simply ssh in, `cd` into wwwroot, and run...

`floomatic --read-only --join https://floobits.com/r/owner_name/workspace_name`

...and we can both visit our development server in a browser to see changes.

Floomatic also supports hooks that are called after files change. We use hooks to regenerate CSS whenever our [LESS](http://lesscss.org/) changes, and rebuild our [compressed JavaScript](https://github.com/jezdez/django_compressor).

Like our [Sublime Text](https://github.com/Floobits/floobits-sublime) and [Vim](https://github.com/Floobits/floobits-vim) plugins, Floomatic obeys `.gitignore` and `.flooignore` files. If you don't want to ship your local settings to a shared development server, simply add them to `.flooignore`.

For instructions on setting up and installing Floomatic, see [our help page](https://floobits.com/help/floomatic).
