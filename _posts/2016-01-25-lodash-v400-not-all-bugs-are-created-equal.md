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
excerpt_separator: <!--more-->
---

On January 13th (two weeks ago), [Lodash](https://lodash.com/) v4.0 [was released](https://github.com/lodash/lodash/releases/tag/4.0.0). After waiting a week (for others to shake out the bugs), I branched our repos, bumped the lodash dependency in them, and fixed compatibility issues. I tried [lodash-migrate](https://github.com/lodash/lodash-migrate), but it wasn't particularly useful. `lodash-migrate` works by running all lodash functions twice (once with the old version and once with the new), then logging if the results are different. That means any code with side effects will trigger a false positive or just break. Instead, I read [the v4.0 changelog](https://github.com/lodash/lodash/wiki/Changelog#compatibility-warnings) and reviewed every incompatible call in our codebase. (This wasn't as hard as it sounds. There were only a few dozen.) After reviewing, testing, and manually poking around after deploying to staging, I deployed the new release to prod. Success!

...or maybe not.<!--more--> Soon after deploying, I noticed increased load on our back-end servers. When I ssh'd in to diagnose the issue, I saw that our back-end was replicating data like crazy. This didn't endanger any information, but it was incredibly wasteful. Digging deeper, I noticed that if a single buffer in a workspace had changed, the entire contents of the workspace were copied in the next replication pass. Clearly, the lodash upgrade was responsible for this behavior, but how? I went back to my editor and looked at the code responsible:

{% highlight javascript linenos linenostart=187 %}
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

I could reproduce the issue on staging, so I enabled debug logging and data logging. I immediately saw that not only did `rbuf` and `local_buf` have the keys, they also had the same the data! What was going on?! The only thing that changed was lodash, so I opened a REPL and double-checked the behavior of `_.isEqual()`:

{% highlight text %}
> require("lodash").isEqual({"a": "a", "b": "b"}, {"a": "a", "b": "b"})
true
> require("lodash").isEqual({"a": "a", "b": "b"}, {"b": "b", "a": "a"})
false
{% endhighlight %}

WTF? I couldn't believe it. I ran similar object comparisons a dozen times. I triple-checked the JS objects I was comparing. I *had* to be making a mistake. I thought, "This can't be a problem with lodash. It's so basic." I double-checked the ECMA spec to make sure object keys aren't ordered. (They're not.) I installed lodash 3 and re-ran the offending line in a REPL:

{% highlight text %}
> require("lodash").isEqual({"a": "a", "b": "b"}, {"b": "b", "a": "a"})
true
{% endhighlight %}

At this point, I was pretty sure this was a bug in lodash. I went to lodash's GitHub project and prepared a bug report. Out of habit, I searched for existing issues. The result? [An issue that had been closed 10 days earlier](https://github.com/lodash/lodash/issues/1758). A fix had been committed, but a new release hadn't been tagged. `:(`To fix the issue in production, I applied the patch to lodash in each project's `node_modules`, then deployed again. Not ideal, but at least the bug didn't affect Floobits anymore.

Despite my comment on the issue, a new release *still* hasn't been tagged. In my opinion, this is a critical bug. Object comparison is simply broken in lodash 4.0.0. I'm not sure why there's been such a delay. While the code has been committed, a bug isn't truly fixed until it's deployed.
