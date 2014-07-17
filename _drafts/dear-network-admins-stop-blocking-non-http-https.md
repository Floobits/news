---
date: '2014-07-17 21:05:14'
layout: post
slug: dear-network-admins-stop-blocking-non-http
published: true
title: 'Dear Network Admins, Stop Blocking Non-HTTP/HTTPS'
authors:
    - ggreer
categories:
    - PSA
---

One of the biggest problems we've had at Floobits is network filtering. Many network administrators block outbound connections that use protocols besides HTTP/HTTPS. It's not uncommon for this to happen in schools, large companies, government offices, and hotels. This needs to stop.

We recently released new versions of our plugins that detect port blocking and work-around it. If our plugins can't connect to `floobits.com` on port `3448`, they try `proxy.floobits.com` on port `443`. All of our plugins communicate over TLS, so the network traffic looks like HTTPS. Unless the connection is man-in-the-middled, it should work without users noticing. Building this took weeks of planning, development, and testing. This was time that could have- should have- been used for more productive purposes.

Network admins make various excuses for this censorship. It prevents abuse. It stops people from using protocols associated with piracy. These points are valid, but there are better ways to address them. More importantly, the costs far outweigh the benefits. Unfortunately, these costs are paid by users and developers, not network admins.

To give a concrete example: I recently vacationed in Canada with my parents and siblings. We stayed at one hotel that restricted outbound network access. This was particularly frustrating at the time, because my grandmother had passed away recently, and my mother was trying to get grandma's headstone made. Because outbound SMTP was blocked, she couldn't change a message on the headstone. She fortunately managed to find a different connection, but the point is made: one cannot fully anticipate the consequences of restricting outbound Internet access. Many users hardly notice the restrictions. Many are annoyed by them. But occasionally, someone's quality of life is seriously affected by port blocking.

The Internet is more than just the web. There are thousands of protocols besides HTTP. Individually, each one may not be popular, but the majority of people use some of them. Blocking these protocols harms everyone. It frustrates users. It forces developers to build work-arounds. It stifles innovation in network protocols. Competent administrators can secure their networks and prevent abuse without resorting to such heavy-handed tactics. If you are a network administrator, I urge you to reconsider port blocking.
