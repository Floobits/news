---
date: '2014-07-04 21:05:14'
layout: post
slug: dear-network-admins-stop-blocking-non-http
published: false
title: 'Dear Network Admins, Stop Blocking Non-HTTP/HTTPS'
authors:
    - ggreer
categories:
    - PSA
---

One of the biggest problems we've had at Floobits is that many networks block outbound connections on ports besides 80 or 443. In other words, all protocols besides HTTP and HTTPS are blocked. It's not uncommon for this to happen in schools, large companies, government offices, and hotels.

Recently we released a new major version of our Sublime Text plugin. The biggest feature we added is the ability to detect port blocking and work-around it. If our plugin can't connect to `floobits.com` on port `3448`, it tries `proxy.floobits.com` on port `443`. Building this work-around took weeks of planning and development.

Various excuses are made for this censorship. It prevents abuse. It stops people from torrenting. ...... These points are valid, but there are better ways to solve the issues. More importantly, the costs far outweigh the benefits. Unfortunately, these costs are paid by the users, not the network admins.

For example, I recently vacationed in Canada with my family. One hotel we stayed at restricted outbound network access. This was particularly frustrating at the time, because my mother was trying to get her mother's headstone made. Because outbound SMTP was blocked, she couldn't change a message on the headstone. Fortunately, she managed to use a different connection. Still, the point is made: one cannot anticipate the full consequences of restricting outbound Internet access.

The Internet is more than just the web. There are thousands of protocols besides HTTP. Individually, each one may not be popular, but the majority of people use at least one of them.
