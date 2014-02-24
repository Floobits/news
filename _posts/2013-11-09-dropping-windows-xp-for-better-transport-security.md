---
date: '2013-11-09 16:12:06'
layout: post
slug: dropping-windows-xp-for-better-transport-security
published: true
title: Dropping Windows XP for Better Transport Security
authors:
    - ggreer
categories:
---

If you still use Windows XP, you might have some trouble visiting Floobits.com.

That's because we've changed our [cipher suites](http://en.wikipedia.org/wiki/Cipher_suite). As of today, we only use strong ciphers that provide [perfect forward secrecy](https://www.eff.org/deeplinks/2013/08/pushing-perfect-forward-secrecy-important-web-privacy-protection). Unfortunately, some older browsers and operating systems don't support any ciphers that meet those criteria. That includes all versions of Internet Explorer on Windows XP.

Deciding on a list of cipher suites isn't easy. While some are very secure, only newer versions of OpenSSL and browsers support them. The tradeoff between compatibility and security is bad enough, but there are additional complications. For example, only the [RC4 cipher](http://en.wikipedia.org/wiki/RC4) can mitigate [BEAST](http://en.wikipedia.org/wiki/Transport_Layer_Security#BEAST_attack) attacks against older clients. Unfortunately, [RC4 is very weak](http://blog.cryptographyengineering.com/2013/03/attack-of-week-rc4-is-kind-of-broken-in.html).

In the end, we chose security in modern browsers over compatibility with older browsers. If you'd like to configure your site similarly, here's the relevant snippet of our Apache web server config:

{% highlight apache %}
# Disable SSLv2 and v3
SSLProtocol All -SSLv2 -SSLv3
SSLCompression Off
SSLHonorCipherOrder On
# Avoid insecure ciphers and support perfect forward secrecy
SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:EDH+aRSA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4
{% endhighlight %}

[SSL Labs](https://www.ssllabs.com/ssltest/index.html) has a great tool for testing HTTPS. Compare your results to [ours](https://www.ssllabs.com/ssltest/analyze.html?d=floobits.com&s=54.200.46.41).

If you'd like to know more about our security practices, check out [our security page](https://floobits.com/security).
