---
date: '2014-07-02 13:50:05'
layout: post
slug: error-reporting-in-floobits
published: true
title: Error Reporting in Floobits
authors:
  - bjorn
  - ggreer
categories:
  - Tech
---

Automated error reporting is an often-overlooked way to improve software. Linters, tests, QA, and pairing can all reduce bugs, but they don't answer the most important question: **Do users encounter errors?** Internal testing simply can't imagine (let alone discover) the myriad ways in which users will break your code. Detecting and reporting errors gives feedback that can find gaps in your testing and QA. Error reporting also makes our customers happier. Users love it when we contact them, apologize for an error they ran into, and mention that we've shipped a fix.

We make use of error reporting throughout our software. We receive error reports from our editor plugins, client-side JavaScript, and server-side code. If anything breaks, we know. 

In all cases we receive e-mails when things go wrong and our goal is to fix every error we receive. In each instance we also attempt to identify the user affected by the problem so we can assist if needed and ask questions to help us resolve the problem.



## Server side

Our website uses [Django middleware]() to report errors. Any e-mail sent from our Django application is added to a separately managed job queue to prevent the possibility of sending e-mails affecting website availability. Our node.js services use similar error reporting.

## Client side

To be notified of client errors we created an API endpoint. In the browser we use [onerror]() to be notified of JavaScript errors, though our approach is nuanced.

`onerror` can generate a lot of errors in quick succession, thousands in some cases, so we throttle each unique kind of error. Throttled occurrences are captured and reported back later in aggregate. We also filter out errors caused by extensions, content scripts and unsupported browsers.

Chrome sends additional helpful information such as a stack trace and the line and column number which helps since our JavaScript is minified to a single line.

With each report we attempt to capture information about the state of the application being sure to remove any sensitive information. We also use our client side logging API for other events, such as timeouts that might occur when users attempt to link their editor plugin with their Floobits account on the website.

## Plugin

Each of our editor plugins makes use of the same client reporting API that the website uses. We use it to notify us when our plugins crash. Detecting plugin crashes can be challenging as there is no all-encompassing error event we can handle. We have to make use of `try except` in Python and `try catch` in Java to gain as wide as coverage as possible. Asynchronous calls will not be caught by a single try catch so there are multiple points where we need to handle potential exceptions. 

Though some errors may not end up having been reported to us, it is likely something was logged either via the editor’s default logging system or to a shared floobits log file. If users are running into problems it always helps if they send us a log file as well as provide information about the editor they are using, its version and the operating system version, as well as the version of the floobits plugin.

Given that we are always making improvements to our plugins and fixing problems when we see them, it is good if everyone keeps their Floobits plugin up to date. The best way to do this is to install the plugin via the recommended method as documented in our help page for each supported editor. For example, Sublime Text users using Package Control and IntelliJ IDEA users using the Jetbrains plugin repository should receive automatic plugin updates or notifications. If the plugin was installed manually, users must remember to update regularly or at least when they’ve encountered an issue.
