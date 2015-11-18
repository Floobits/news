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
                         Front-end servers                  Master                   Slaves

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

When a client sends its auth info (api key, secret, workspace, etc), the colabalancer asks colab master, "Which slave has workspace X?" When the master responds, the balancer connects to that slave and pipes data between it and the client. The master also makes sure that there are multiple up-to-date copies of each workspace. If a workspace's replication count is low, it tells a slave to copy the workspace from another slave. That way if a server suffers a hardware failure, everyone's data is safe.


## Our Protocol

All Floobits clients use our [Realtime Differential Synchronization Protocol (RDSP)](https://floobits.com/protocol). Colab slaves use the same protocol to replicate data amongst each other.

You can read more about our protocol [here](https://floobits.com/protocol), but the key point is that the current version of our protocol uses JSON, which isn't binary safe. Originally, we didn't think it would be necessary to synchronize binary files. After all, who edits binary files in Sublime Text, Vim, or Emacs? But users wanted it, so we implemented it. To get around JSON's limitation, binary files are base64 encoded. Since earlier versions of our plugins didn't understand this change to our protocol, we added a `supported_encodings` field to our auth frame. If that field doesn't exist, we default to `utf-8` as the only supported encoding.

Now guess which field was accidentally removed in our colab client code. That's right, `supported_encodings`. :(


## Piecing it Together

Here's how the whole mess went down, step by step:

1. Colab master notices workspace 123 has a low replication count. Master picks candidates based on load and disk usage. It then tells slave01, "Fetch workspace 123 from slave00."
1. slave01 connects to slave00. It sends no `supported_encodings`, so slave00 thinks, "Oh. This client only supports utf8."
1. After authing and receiving `room_info` for workspace 123, slave01 sees that its copy of buffer 456 is out of date. It tells slave00, "Give me buffer 456"
1. Unfortunately, buffer 456 is binary. Slave00 dutifully sends the utf8-encoded (and now corrupted) buffer to 01.
1. Slave01 tries to decode the utf8-encoded buffer as if it were base64.
1. Node.js crashes due to a bug in its base64 decoder.

It may not sound too complicated when put that way, but troubleshooting this issue was very difficult. Because Node.js was crashing, most of our diagnostic and debugging tools were useless. There was no exception to catch, no error callback, no debug port we could attach to. As [our previous post describes]({% post_url 2015-10-26-why-is-nodejs-crashing-a-deep-dive-into-a-tricky-bug %}), it took a lot of thought, logging, and luck to track down the crash.


## Conclusion

Looking back, there were many ways we could have avoided this bug: better tests, more in-depth code reviews, static typing, etc. I think the real lesson to learn is more specific: We shouldn't have used our own protocol for back-end replication. While it is more efficient —and an interesting technical problem to solve— it wasn't worth the extra complexity and potential bugs. We could have saved time and sanity building the same system with a battle-hardend system like [Cassandra](http://cassandra.apache.org/).

So if you're ever thinking of making your own distributed data store, perhaps... reconsider.
