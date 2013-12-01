---
date: '2013-08-17 22:52:29'
layout: post
slug: what-we've-been-working-on
published: true
title: What We've Been Working On
categories:
  Features
---

We've been working tirelessly to improve Floobits. If you haven't tried Floobits in a while, you should have another look.  Over the past couple of months we have:

* Added support for `.gitignore` and `.flooignore` files. Now you don't have to sync sensitive or unnecessary files.
* streamlined uploading in our plugins, reducing the likelihood of lockups and beachballs.
* released [Floomatic](https://github.com/Floobits/floomatic), a tool which syncs files and runs hooks when you save files in a workspace.
* added support for binary files. Now images and other non-text files are synced (in Sublime Text and floomatic).
* added support for creating workspaces under organizations from text editors.
* added the ability to create private workspaces from text editors.
* improved documentation.
* fixed most SSL issues on Linux in Sublime Text.
* added the ability to stomp on the files in a workspace. Just use "share directory" on an already-shared directory instead of joining the workspace.
* dramatically improved the stability, performance, and features of our Emacs plugin.

In the near-term, we plan to:

* make it easier to share your workspaces with others, even if they don't have a Floobits account.
* improve support for larger binary files.
* make it easier to discover others' workspaces.

Looking farther out, we plan on adding proper async support to Vim and adding support for IntelliJ. We'd love to hear your suggestions for what we can improve. Please <a id="email_us" href="">email us</a> with feedback.

Sincerely,

-- The Floobits Team

{% include email.html %}