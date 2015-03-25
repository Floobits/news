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

We have made some changes to our IntelliJ IDEA user interface. We now make it more apparent what line others are on.  An indicator has been added to the right side of the editor when others in the workspace move to new lines. You will see this indicator if you are in the same file as someone else in the work space. This indicator will show a user's gravatar and it will also show their username. The border of the indicator will match their highlight color in the editor.

<img src="/images/intellij/balloon.png" width="500" alt="User indicator"/>

The list of people connected to the workspace has also been updated. Each user will show a larger version of their gravatar and also a list of the clients they are connected with. Previously each client was its own item in a list, but now they are grouped by user.

<img src="/images/intellij/user_list.png" width="500" alt="User list"/>

You can right click and use the context menu to follow or unfollow as well as kick specific clients or all of them at once. It is also possible to edit permissions.

<img src="/images/intellij/manage_users.png" width="500" alt="Manage users from the context menu."/>

We have also fixed a performance issues associated with highlights. This update should work in the most recent version of IntelliJ IDEA and its forks including PHPStorm, RubyMine, PyCharm, WebStorm, Android Studio, CLion and AppCode.

If you notice any performance issues or have any feedback about these UI changes please do not hesitate to email us at support@floobits.com. We worked hard to make sure the new changes performed well and were not too obtrusive, but we are open to what our customers think. We have seen a steady increase in usage of our IntelliJ IDEA plugin and are excited to keep improving it, making it better with each release.
