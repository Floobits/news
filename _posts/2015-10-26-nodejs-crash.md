---
date: '2015-10-26 09:59:01'
layout: post
slug: nodejs-crash
published: false
title: nodejs crash
authors:
  - ggreer
categories:
  - Node.js
  - Bugs
  - Tech
---

In early September, we started seeing Node.js crash with the following error:

    2015-09-10_23:28:11.75413 node: ../src/node_buffer.cc:226: v8::MaybeLocal<v8::Object> node::Buffer::New(v8::Isolate*, v8::Local<v8::String>, node::encoding): Assertion `(data) != (nullptr)' failed.


intermittent Crash in prod

os x realloc manpage
thought it was a weird threading bug or race condition or something
couldn't create an easily reproducible test case. could only trigger in prod or staging

paired on the bug with matt
looked at linux manpage for realloc. oh hey, it can return null if len 0. fuck

added some logging to node. deployed to staging

base64 encoded bufs are culprit


https://github.com/nodejs/node/issues/3496
