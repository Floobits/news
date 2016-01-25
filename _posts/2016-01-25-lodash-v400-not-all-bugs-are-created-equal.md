---
date: '2016-01-25 00:58:28'
layout: post
slug: lodash-v400-not-all-bugs-are-created-equal
published: true
title: 'Lodash v4.0.0: Not All Bugs are Created `isEqual()`'
authors:
  - ggreer
categories:
  - Bugs
  - JavaScript
  - Tech
---

On January 13th (two weeks ago), Lodash v4.0 [was released](https://github.com/lodash/lodash/releases/tag/4.0.0). After waiting a week for others to shake out the bugs, I branched our projects, bumped the lodash dependency, and fixed compatibility issues. I tried [lodash-migrate](https://github.com/lodash/lodash-migrate), but it wasn't particularly useful. Since it works by running all lodash functions twice (once with the old version and once with the new), any code with side effects will trigger a false positive or just break. Instead, I 

After reviewing, testing, and manually poking around after deploying to staging, I deployed the new release to prod. Success!

...or maybe not. Soon after deploying to prod, I noticed increased load on our back-end servers. When I ssh'd in to diagnose the issue, I saw that our back-end was replicating data like crazy. This didn't endanger the data, but it was incredibly wasteful. Digging deeper, I noticed that if a single buffer in a workspace was changed, the entire contents of the workspace were copied during the next replication pass.

I went back to my editor and looked at the code responsible:

{% highlight javascript %}
...
let local_buf = local_bufs[rbuf.id];
rbuf.deleted = !!rbuf.deleted;
if (!local_buf || local_buf.md5 !== rbuf.md5) {
  log.debug("to_fetch: %s/%s", workspace_id, rbuf.id);
  to_fetch.push(rbuf);
  buf_cb();
  return;
}
if (_.isEqual(local_buf, rbuf)) {
  log.debug("Local copy of %s/%s matches remote. Not fetching.", workspace_id, rbuf.id);
  buf_cb();
  return;
}
log.log("Local copy of %s/%s differs from remote. Fetching.", workspace_id, rbuf.id);
log.debug("local: %s remote %s", _.keys(local_buf), _.keys(rbuf));
if (settings.log_data) {
  log.debug("local:  %s", JSON.stringify(local_buf));
  log.debug("remote: %s", JSON.stringify(rbuf));
}
to_fetch.push(rbuf);
...
{% endhighlight %}



keys were the same
added logging. (
    log.debug("local:  %s", JSON.stringify(local_buf));
    log.debug("remote: %s", JSON.stringify(rbuf));
) deployed to test cluster

stringified json was the same. WTF?!?!

> require("lodash").isEqual({"a": "a", "b": "b"}, {"b": "b", "a": "a"})
false

WTF?!

Try with same order:

> require("lodash").isEqual({"a": "a", "b": "b"}, {"a": "a", "b": "b"})
true

Double-check that order in JS objects doesn't matter. (correct)

Prepare to submit bug report to Lodash. Search existing issues.

Find https://github.com/lodash/lodash/issues/1758

A week with no 
