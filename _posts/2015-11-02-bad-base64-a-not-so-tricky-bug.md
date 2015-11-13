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


## The Key Clue

After deploying a patched Node.js, we added code to our services to detect and log invalid base64. Tailing the logs showed messages like this:

{% highlight text %}
Invalid base64 for 5827/94 Screen Shot 2015-10-03 at 23.59.15.png:
�PNG\r\n\u001a\n\u0000\u0000\u0000\rIHDR\u0000\u0000\u0005�\u0000\u0000\u00028\b\u0006\u0000\u0000\u0000�wo�\u0000\u0000\f\u001aiCCPICC Profile\u0000\u0000H��W\u0007XS�\u0016�[R\b\t-\u0010\u0001)�7Az�\u001a:\bH\u0007\u001b!\t\u0010J\f��bG\u0016\u0015\\\u000b\*�(\*...
{% endhighlight %}

As soon as I saw that, I knew what the problem was. The line noise you see is a [Node Buffer](https://nodejs.org/api/buffer.html) (in this case a [PNG](https://en.wikipedia.org/wiki/Portable_Network_Graphics)) that has been run through `.toString()`. To get base64, one needs to use `buffer.toString("base64")`. Somewhere in our codebase, we were missing an encoding parameter. But where, and why?


## Our Service Architecture

To understand the issue, one also needs to know a little about our service architecture. Here is an extremely ornate diagram:

<pre style="font-size: 10px; overflow-wrap: none;">
                         Front-end servers                  Master                   Back-end servers

                         +-------------+                    +---------+              +--------+
         +-------------> |httpd        |                    |colab    | +----------> |colab   | <-----+
         +-------------> |colabalancer | +----+----+------> |         | |\           |        |       |
         |               +-------------+     /    /         +---------+ | \          +--------+       |
         |                                  /    /                      |  \                          |
         |               +-------------+   /    /                       |   \        +--------+       |
Internet +-------------> |httpd        |  /    /                        |    ------> |colab   | <-----+
         +-------------> |colabalancer | +----/--------------------------\---------> |        |       |
         |               +-------------+     /                            \          +--------+       |
         |                                  /                              \                          |
         |               +-------------+   /                                \        +--------+       |
         +-------------> |httpd        |  /                                  ------> |colab   | <-----+
         +-------------> |colabalancer | +-----------------------------------------> |        |
                         +-------------+                                             +--------+
</pre>

All clients connect to our front-end servers. If the request is HTTP(S) (port 80 or 443), Apache httpd handles it. If it's our protocol (port 3448), our colabalancer service handles it. Also, if the HTTP(S) request is a [websocket](https://en.wikipedia.org/wiki/WebSocket), httpd proxies it to colabalancer.

When a client sends its auth info (api key, secret, workspace, etc), the colabalancer asks colab master, "Which slave has workspace X?" When the master responds, the balancer connects to that slave and pipes data between it and the client.


## Our Protocol

All Floobits clients use our [Realtime Differential Synchronization Protocol (RDSP)](https://floobits.com/protocol). Colab slaves use the same protocol to replicate data amongst each other. That way even if a server suffers a hardware failure, everyone's data is safe.

You can read more about our protocol [here](https://floobits.com/protocol), but the key point is that the current version of our protocol uses JSON, which isn't binary safe. Originally, we didn't think it would be necessary to synchronize binary files. After all, who edits those in Sublime Text, Vim, Emacs, etc? But users wanted it, so we implemented it. To get around JSON's limitation, binary files are base64 encoded. Since earlier versions of our plugins didn't understand this change to our protocol, we added a `supported_encodings` field to our auth frame. If that field didn't exist, we defaulted to `utf-8`.

Unfortunately, a bad copy-paste omitted the `supported_encodings` from our own colab code.


## Conclusion

Really, we shouldn't have used our own protocol for back-end replication. While more efficient —and an interesting technical problem to solve— it wasn't worth the extra complexity. We could have built the same system with [Cassandra](http://cassandra.apache.org/) much more quickly.
