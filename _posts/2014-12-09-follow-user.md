---
date: '2014-12-09 13:50:05'
layout: post
slug: Follow Individual Users
published: true
title: New Feature&#58; Follow Individual Users
authors:
  - bjorn
categories:
  - editors
---



We have added a new feature! You can now follow changes from specific individuals connected to a workspace. We have added this feature to all of our editor plugins and our web editor. It is still possible to follow all changes made in the workspace.

Following the entire workspace was impossible when more than one person was editing at a time as there would be too much jumping around. This was a feature requested by our users and we wanted it ourselves.

What follows are instructions for how use this feature in our various editor plugins. Note, you can only follow people who have edit permissions in the workspace. In the case of editor plugins, people who do not have edit permissions do not even show up in the list of users you can follow. You can follow more than one user at a time.

## Web Editor

To follow individual users click the magnet icon on their user image on the right. To stop following that user click it again. The magnet icon will reflect the current state. A solid looking magnet means you are following that user.

## Sublime Text

To follow individual users in Sublime Text open up the command prompt and search for "Floobits - Follow User", after selecting this option you will be presented with a list of usernames that you can follow. You should see the username of the person you are following in your status bar. To unfollow a user select "Floobits - Follow User" again and click the username you wish to unfollow. You can also stop following everyone with the "Floobits - Stop Following Workspace" command.

<p>Follow user in Sublime Text</p>
<img src="/images/follow_user/st_follow_user.png" width="500" alt="Follow user"/>
<p>Select user</p>
<img src="/images/follow_user/st_select_user.png" width="500" alt="Select user"/>
<p>Confirmation</p>
<img src="/images/follow_user/st_follow_confirmation.png" width="500" alt="Confirmation"/>
<p>Unfollow</p>
<img src="/images/follow_user/st_unfollow.png" width="500" alt="Unfollow"/>

## IntelliJ, WebStorm, PyCharm, RubyMine, Android Studio, PHPStorm

In an IntelliJ based editor you can go to tools -> Floobits -> Follow Selected Users or search for `Follow Selected Users` from the command prompt (⌘/Cntrl+Shift+A). A list of users with edit permissions will appear. Check the box next to each username that you wish to follow. Open this same list whenever you want to unfollow anyone. To stop following completely select `Toggle Follow Mode` from the command prompt. You can also use the toolbar menu Tools -> Floobits -> "Disable follow mode" to achieve the same thing.

<p>Follow user in intellij</p>
<img src="/images/follow_user/intellij_follow_user.png" width="500" alt="Follow user"/>
<p>Select user</p>
<img src="/images/follow_user/intellij_select_user.png" width="500" alt="select user"/>

## Emacs

In emacs type `M-x` and select `follow-user`. This will present a list of users with edit permissions you can follow. `floobits-follow-mode-toggle` will allow you to stop following all those you’ve elected to follow.

<p>Follow user in emacs</p>
<img src="/images/follow_user/emacs_follow_user.png" width="250"/ alt="Follow user in emacs">
<p>Select user</p>
<img src="/images/follow_user/emacs_select_user.png" width="250" alt="Select user"/>
<p>Confirmation</p>
<img src="/images/follow_user/emacs_follow_confirmation.png" width="250" "Confirmation"/>

## Neovim

To follow specific individuals in NeoVim type `:FlooFollowUser`. To unfollow all followed users type `:FlooToggleFollowMode`.

<p>Follow user in Neovim</p>
<img src="/images/follow_user/nvim_follow_user.png" width="500"/>
<p>Select user</p>
<img src="/images/follow_user/nvim_select_user.png" width="500"/>
