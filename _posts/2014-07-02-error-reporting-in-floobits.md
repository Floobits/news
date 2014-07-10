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

Automated error reporting is an oft-overlooked way to improve software. Linters, tests, QA, and pairing can all reduce bugs, but they don't answer the most important question: **Do users encounter errors?** Internal testing simply can't imagine (let alone discover) the myriad ways in which users will break your code. Detecting and reporting errors gives feedback that can find gaps in your testing and QA. Error reporting also makes customers happier. Users love it when we contact them, apologize for an error they ran into, and mention that we've shipped a fix.

We make use of error reporting throughout our software. We receive reports from our editor plugins, client-side JavaScript, and server-side code. If anything breaks, we know.

The specifics of each form of error reporting are explained below, in the hope that others may learn from our set-up.

## Django

We use a customized version of [Django's exception reporting](https://docs.djangoproject.com/en/1.7/howto/error-reporting/). Instead of sending e-mails from Python, errors are added to an on-disk queue, which our [Gurgitator](https://github.com/Floobits/gurgitator) service consumes. This lets [our error page](https://floobits.com/static/500.html) load sooner, since the HTTP response isn't blocked by sending an e-mail.


## Back-end services

Our back-end services use similar error reporting. All of our services are managed by [runit](http://smarden.org/runit/). If a service dies with a non-zero exit code, the service's `finish` script drops a message into Gurgitator's job directory.


## JavaScript

We use browser [onerror](https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers.onerror) handlers to detect JavaScript errors. We then log those errors by hitting our own API endpoint.

`onerror` can generate a lot of errors in quick succession &mdash; thousands in some cases &mdash; so we uniqify and throttle errors. Throttled occurrences are aggregated before being reported. We also filter out errors caused by extensions, content scripts and unsupported browsers.

Chrome sends additional helpful information such as a stack trace and the line and column number which helps since our JavaScript is minified to a single line.

With each report, we attempt to capture information about the state of the application while being sure to remove any sensitive information. We also use our client-side logging API for other events, such as timeouts that might occur when users attempt to link their editor plugin with their Floobits account on the website.


## Editor Plugins

Each of our editor plugins makes use of the same client reporting API that the website uses. We use it to notify us when our plugins crash. Detecting plugin crashes can be challenging as there is no all-encompassing error event we can handle. We have to make use of `try except` in Python and `try catch` in Java to gain as wide as coverage as possible. Asynchronous calls will not be caught by a single try catch so there are multiple points where we need to handle potential exceptions. 

Though some errors may not end up having been reported to us, it is likely something was logged either via the editor’s default logging system or to a shared floobits log file. If users are running into problems it always helps if they send us a log file as well as provide information about the editor they are using, its version and the operating system version, as well as the version of the floobits plugin.

Given that we are always making improvements to our plugins and fixing problems when we see them, it is good if everyone keeps their Floobits plugin up to date. The best way to do this is to install the plugin via the recommended method as documented in our help page for each supported editor. For example, Sublime Text users using Package Control and IntelliJ IDEA users using the Jetbrains plugin repository should receive automatic plugin updates or notifications. If the plugin was installed manually, users must remember to update regularly or at least when they’ve encountered an issue.
