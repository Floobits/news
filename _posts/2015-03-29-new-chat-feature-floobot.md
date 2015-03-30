---
date: '2015-03-29 22:06:28'
layout: post
slug: new-chat-feature-floobot
published: true
title: 'New Chat Feature: Floobot'
authors:
  - ggreer
categories:
  - Features
---

If you chat in workspaces or our [organization chat](https://floobits.com/help/orgs#video_chat), you might notice that pasting URLs can cause a mysterious "Floobot" user to describe them. Don't be startled, this is expected behavior. Similar to showing images in chat, Floobot helps you to get information about a URL without having to click on it.

Floobot does more than just parse `<title>` tags. If the link is to a GitHub repo, it will mention the number of forks and stargazers. If the link is a tweet, it will give a summary, along with the number of favorites and retweets. Floobot also describes [YouTube](https://youtube.com/) videos and [Hacker News](https://news.ycombinator.com/) submissions. Basically, if you paste a URL, Floobot tries its best to give a one-line summary of what's there.

Here's a screenshot of what Floobot typically looks like in org chat:

[![Floobot in Floobits Chat](/images/Screen Shot 2015-03-30 at 13.18.10.png)](/images/Screen Shot 2015-03-30 at 13.18.10.png)

Currently, Floobot's code is based on our open-source [IRC Floobot](https://github.com/Floobits/floobot). We plan to split out the site parsing code and turn it into a node module. That way, everyone can take advantage of our tool. In the mean time, enjoy the useful descriptions of URLs. And if you have any suggestions or bug reports, please <a id="email_us" href="">email us</a> or [open an issue](https://github.com/Floobits/floobot/issues).

{% include email.html %}
