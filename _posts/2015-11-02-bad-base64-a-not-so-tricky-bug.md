---
date: '2015-11-02 12:58:41'
layout: post
slug: bad-base64-a-not-so-tricky-bug
published: true
title: Bad Base64, a Not-so-Tricky Bug
authors:
  - ggreer
categories:
  - Node.js
  - Bugs
  - Tech
---

Last week, I explained how we found [a bug that caused Node.js to crash when given invalid base64]({% post_url 2015-10-26-why-is-nodejs-crashing-a-deep-dive-into-a-tricky-bug %}). That post was already rather long, so I didn't explain how one of our back-end services was getting invalid base64. Today, I satisfy everyone's curiosity.

## Our Service Architecture

To understand the issue, one also needs to know a little about our service architecture. Here's an extremely ornate diagram:

<pre style="font-size: 14px; overflow-wrap: none;">
                         Front-end servers                  Master                   Back-end servers

                         +-------------+                    +---------+              +--------+
         +-------------> |httpd        |                    |postgres |              |colab   | <-----+
         +-------------> |colabalancer | +----------+-----> |colab    | +----------> |        |       |
         |               +-------------+            |       +---------+ |            +--------+       |
         |                                          |                   |                             |
         |               +-------------+            |                   |            +--------+       |
Internet +-------------> |httpd        |            |            /------+----------> |colab   | <-----+
         +-------------> |colabalancer | +----------+-----------/       |            |        |       |
         |               +-------------+            |                   |            +--------+       |
         |                                          |                   |                             |
         |               +-------------+            |                   |            +--------+       |
         +-------------> |httpd        |            |            /------+----------> |colab   | <-----+
         +-------------> |colabalancer | +----------+-----------/                    |        |
                         +-------------+                                             +--------+
</pre>

All clients connect to our front-end servers. If the request is HTTP(S) (port 80 or 443), Apache httpd handles it. If it's our protocol (port 3448), our colabalancer service handles it. Also, if the http(s) reqquest is a websocket, httpd proxies it to colabalancer.


## Our Protocol



Background:
we use our own protocol for data replication

Base64
Supported encodings missing
Defaulted to UTF8
Noticed logs always dumb data
