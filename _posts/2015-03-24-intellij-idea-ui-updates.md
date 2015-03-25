---
date: '2015-03-24 16:25:54'
layout: post
slug: intellij-idea-ui-updates
published: true
title: IntelliJ IDEA User Interface Updates
authors:
  - bjorn
categories:
  - editors
  - IntelliJ IDEA
  - PHPStorm
  - WebStorm
  - RubyMine
  - CLion
  - PyCharm
  - AppCode
---

We've listened to your feedback and made some big improvements to our IntelliJ IDEA plugin.

First, it's easier to see where others' cursors are. When someone else moves to a new line, you'll see a small indicator with their Gravatar and username. The border of the indicator matches their highlight color.

<img src="/images/intellij/balloon.png" width="500" alt="User indicator"/>

Second, we've updated the list of people connected to the workspace. Everyone now gets a larger version of their Gravatar, along with a list of the clients they are connected with. Previously, each client was a separate item in the list. Now, we've grouped them by user.

<img src="/images/intellij/user_list.png" width="500" alt="User list"/>

Also, right-clicking on a user opens a context menu allowing you to follow, unfollow, or kick clients or users. In addition, you can edit other users' permissions from this menu.

<img src="/images/intellij/manage_users.png" width="500" alt="Manage users from the context menu."/>

One more thing: Our changes aren't just cosmetic. We've improved performance! Specifically, highlights are rendered significantly faster.

This update should work in the most recent version of IntelliJ IDEA and its forks: PHPStorm, RubyMine, PyCharm, WebStorm, Android Studio, CLion and AppCode.

If you notice any issues, or have any feedback about these changes, don't hesitate to contact us at support@floobits.com. We worked hard to make sure the changes performed well while being unobtrusive, but we're open to feedback. Our IntelliJ IDEA plugin has steadily increased in usage, and we're excited to continue improving it. Your suggestions are a big part of that.
