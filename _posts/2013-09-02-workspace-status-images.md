---
date: '2013-09-02 22:29:12'
layout: post
slug: workspace-status-images
published: true
title: Workspace Status Images
authors:
  - ggreer
categories:
  - Features
---

Similar to services such as [Travis-CI](https://travis-ci.org), we've added status images to Floobits workspaces. This makes it easy to let others know when you're working on something.

Here's the status image for our news workspace:

<a href="https://floobits.com/Floobits/news/redirect">
  <img alt="Floobits status" width="100" height="40" src="https://floobits.com/Floobits/news.png" />
</a>

The HTML looks like this:

    <a href="https://floobits.com/Floobits/news/redirect">
      <img alt="Floobits status" width="100" height="40" src="https://floobits.com/Floobits/news.png" />
    </a>

If the workspace is actively being edited, you'll see a green-bordered image and the link will redirect to the Floobits web editor. If not, the image will be grayed-out and the link will redirect to a page containing the workspace info.

You can find the HTML for your own workspaces on their settings pages.

In unrelated news, [we've submitted a patch to Vim](https://groups.google.com/forum/#!topic/vim_dev/-4pqDJfHCsM). If merged, it will make asynchronous Vim plugins a breeze. We'll write a post about this soon.
