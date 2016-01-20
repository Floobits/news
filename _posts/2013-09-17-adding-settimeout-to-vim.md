---
date: '2013-09-17 09:31:23'
layout: post
slug: adding-settimeout-to-vim
published: true
title: Adding setTimeout to Vim
authors:
    - ggreer
categories:
    - Vim
---

At the end of [the previous post]({{ page.previous.url }}), Matt and I finally got the bright idea to patch Vim. Both of us had experience contributing to open source projects, but we knew very little about contributing to Vim. To maximize our chance of success, we decided on a few guidelines:

* Our patch should make Vim better for everyone, not just us.
* Any new API we create should be familiar to as many developers as possible.
* We should make the minimum necessary change.

After some deliberation, we decided to build a JavaScript-style [`setTimeout()`](https://developer.mozilla.org/en-US/docs/Web/API/window.setTimeout).


<br class="separator" />

### Understanding Vim

Step 0 was to clone Vim and start poking around. The Vim codebase is intimidating, to put it mildly. A quarter-century of development has created a text editor that, while powerful and extensible, is not without cruft. Vim was originally written for Amiga, and `os_amiga.c` still exists. There appears to be support for VMX, 16-bit Windows, BeOS, and even MS-DOS.

As mentioned previously, Vim is input-driven. For the most part, Vim reacts to input from the user. There's no easy way to tell Vim, "run this in 500 milliseconds" or "run this *every* 500 milliseconds." There's only, "run this after the user does X." This assumption is built into every level of Vim, down to the architecture-specific input functions. We discovered this by following the code.

If you want to see for yourself, try building Vim and running it in `gdb`. This example is slightly simplified. Most of the time, we used `gdb attach` to avoid corrupting Vim's terminal.

{% highlight text %}
ggreer@lithium:~/code/vim% CFLAGS="-g -DDEBUG" ./configure --with-features=huge
...
ggreer@lithium:~/code/vim% make
...
ggreer@lithium:~/code/vim% gdb ./src/vim
Reading symbols from /home/ggreer/code/vim/src/vim...done.
(gdb) break RealWaitForChar
Breakpoint 1 at 0x54efba: file os_unix.c, line 5069.
(gdb) run
Breakpoint 1, RealWaitForChar (fd=0, msec=0, check_for_gpm=0x0) at os_unix.c:5069
5069        int         nb_fd = netbeans_filedesc();
(gdb) c
Continuing.
(gdb) c
Continuing.
(gdb) c
Continuing.
(gdb) c
Continuing.
...
{% endhighlight %}

You'll have to do this for a little while to get past Vim's initialization code. You may also have to hit backspace to get rid of some control characters.

{% highlight text %}
...
(gdb) c
Continuing.
Breakpoint 1, RealWaitForChar (fd=0, msec=4000, check_for_gpm=0x0) at os_unix.c:5069
5069        int         nb_fd = netbeans_filedesc();
(gdb) bt
#0  RealWaitForChar (fd=0, msec=0, check_for_gpm=0x0) at os_unix.c:5069
#1  0x000000000054eea0 in mch_breakcheck () at os_unix.c:4963
#2  0x00000000005e1a9d in ui_breakcheck () at ui.c:367
#3  0x00000000004cdd35 in vgetorpeek (advance=1) at getchar.c:2026
#4  0x00000000004cd54a in vgetc () at getchar.c:1590
#5  0x00000000004cda92 in safe_vgetc () at getchar.c:1795
#6  0x000000000051e0ac in normal_cmd (oap=0x7fffffffe2d0, toplevel=1) at normal.c:666
#7  0x000000000062ab2c in main_loop (cmdwin=0, noexmode=0) at main.c:1329
#8  0x000000000062a438 in main (argc=1, argv=0x7fffffffe5d8) at main.c:1020
(gdb)
{% endhighlight %}

After playing around more in `gdb`, we got a good idea of Vim's [control flow](http://en.wikipedia.org/wiki/Control_flow). Vim's main loop is, naturally, a function called `main_loop()` in `main.c`. There are a few ways the main loop can call low-level input functions, but eventually control is passed to `RealWaitForChar()` in `os_unix.c`. `RealWaitForChar()` calls `select()`, or falls back to `poll()` if `select()` isn't available.

Running Vim in a GUI follows a different path, but it still boils down to one function: `gui_wait_for_chars()` in `gui.c`. 

Armed with our newfound knowledge, we set off to build `setTimeout()`.

<!-- main.c main_loop has a while loop which calls
getchar.c vgetc
which calls inchar
which calls ui_inchar
which calls:
  if gui:
    gui_wait_for_chars (gui.c)
      gui_mch_wait_for_chars
        uses gui-specific waiting (usually not select())
  no gui:
    mch_inchar (os-specific, os_unix.c)
      which calls WaitForChar
        which calls RealWaitForChar -->


<br class="separator" />

### Settimeout

Our desired API was simple. The plan was to make three new Vimscript functions:

* `settimeout()`
* `setinterval()`
* `canceltimeout()`

Like their JavaScript counterparts, Vim's `settimeout()` and `setinterval()` would take a number in milliseconds and a command to evaluate. For example...

{% highlight text %}
let timeout_id = settimeout(2000, 'echo("hello")')
{% endhighlight %}

...would print "hello" after two seconds. Calling...

{% highlight text %}
canceltimeout(timeout_id)
{% endhighlight %}

...would cancel the timeout. Nothing too crazy there.

<br class="separator" />

### Timeouts

Representing timeouts is pretty straightforward. Timeouts are run in order, so a [linked-list](http://en.wikipedia.org/wiki/Linked_list) sorted by time makes a lot of sense. There are more efficient data structures for timeouts, but this is a decent first-pass.

{% highlight cpp %}
struct timeout_T {
    int id;                     /* timeout/interval id */
    int interval;               /* interval period if interval, otherwise -1 */
    unsigned long long tm;      /* time to fire (epoch milliseconds) */
    char_u *cmd;                /* vim command to run */
    struct timeout_T *next;     /* pointer to next timeout in linked list */
};
typedef struct timeout_T timeout_T;

timeout_T *timeouts = NULL;
{% endhighlight %}

Ordered insertion is `O(n)`, but fortunately `n` is very small in most cases.

{% highlight cpp %}
/*
 * Insert a new timeout into the timeout linked list.
 * This is called by set_timeout() in eval.c
 */
void insert_timeout(to)
    timeout_T *to;  /* timeout to insert */
{
    timeout_T *cur = timeouts;
    timeout_T *prev = NULL;

    if (timeouts == NULL) {
        timeouts = to;
        return;
    }

    while (cur != NULL) {
        if (cur->tm > to->tm) {
            if (prev) {
                prev->next = to;
            } else {
                timeouts = to;
            }
            to->next = cur;
            return;
        }
        prev = cur;
        cur = cur->next;
    }
    prev->next = to;
    to->next = NULL;
}
{% endhighlight %}

Calling timeouts isn't too complicated either. Just go through list until there's an interval in the future.

{% highlight cpp %}
/*
 * Execute timeouts that are due.
 * This is called every ticktime milliseconds by low-level input functions.
 */
void call_timeouts(void)
{
    unsigned long long tm = get_monotonic_time();
    timeout_T *tmp;

    while (timeouts != NULL && timeouts->tm < tm) {
        do_cmdline_cmd(timeouts->cmd);  /* Execute Vim command */
        tmp = timeouts;
        timeouts = timeouts->next;
        if (tmp->interval == -1) {
            free(tmp->cmd);
            free(tmp);
        } else {
            /* This is an interval, not a timeout. Re-add it. */
            tmp->tm = tm + tmp->interval;
            insert_timeout(tmp);
        }
    }
}
{% endhighlight %}

Now all we have to do is run `call_timeouts()` often enough and the job is done!


<br class="separator" />

### Select Loops

Vim's `RealWaitForChar()` can take a timeout, or it can block until there's user input. The initial plan was to put a loop in `RealWaitForChar()` and periodically run `call_timeouts()` while waiting for user input.

Once we delved deeper into the code, we noticed much of our work was already done. `RealWaitForChar()` had a loop in it. It even called `select()`. To make our lives easier and minimize the number of changes, we decided to take advantage of this `select()` loop. 

The idea behind the loop is pretty simple: until `RealWaitForChar()`'s timeout is reached, run `call_timeouts()` every 100 milliseconds. The implementation in Vim is a little tricky, but a typical `select()` loop looks like this:

{% highlight cpp %}
int rv;
fd_set read_fds;
struct timeval tv;

FD_ZERO(&read_fds);
FD_SET(STDIN, &read_fds);

tv.tv_sec = 0;
tv.tv_usec = 100000; /* 100 milliseconds */

while (1) {
    rv = select(STDIN + 1, &read_fds, NULL, NULL, &tv);
    if (rv == -1) {
        printf("Error in select: %s\n", strerror(errno));
        exit(1);
    }
    call_timeouts();

    if (FD_ISSET(STDIN, &read_fds)) {
        printf("Somebody typed something.\n");
    }
}
{% endhighlight %}

This loop runs `call_timeouts()` every 100 milliseconds, or more often if the user types something. Reducing `tv` will give more accurate timer resolution at the cost of more CPU usage. It's also possible to set `tv` based on the next timeout in the linked list. If there are a few widely-spaced timeouts, this can be more efficient. On the other hand, it also makes it easier to waste tons of CPU time.


<br class="separator" />

### Submitting the Patch

Once we thought our work was ready for others to see, [we posted the patch to Vim-dev](https://groups.google.com/d/msg/vim_dev/-4pqDJfHCsM/LkYNCpZjQ70J). After some healthy discussion (and a little bikeshedding), we followed some suggestions to improve our patch. The biggest change was implementing cross-platform monotonic timers. It's often forgotten that `gettimeofday()` is not required to increase. A user can change the clock, causing timeouts to be called too early or too late. Worse, services like [`ntpd`](http://en.wikipedia.org/wiki/Ntpd) can tweak the system clock without the user noticing. There is no cross-platform monotonic clock API, so we had to write code specific to Linux, OS X, BSD, and Windows.

[Our latest patch](https://github.com/Floobits/vim/compare/835cc6e85d8fbc14c4e659a4c0452ca5f699d805...master) is the culmination of all our research, hard work, and wild flailing-about. If you'd like to play around with `settimeout()`, clone [our Vim fork on GitHub](https://github.com/Floobits/vim).

We've learned a lot from this project, but we're glad the finish line is in sight. There is no shortage of editors we want to support.
