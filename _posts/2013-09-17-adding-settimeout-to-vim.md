---
date: '2013-09-17 09:31:23'
layout: post
slug: adding-settimeout-to-vim
published: true
title: Adding setTimeout to Vim
authors:
    ggreer
categories:
    Vim
---

At the end of [the previous post]({{ page.previous.url }}), we finally got the bright idea to patch Vim. Both of us have experience contributing to open source projects, but we knew very little about contributing to Vim. To maximize our chance of success, we decided on some guidelines:

* Our patch should make Vim better for everyone, not just us.
* Any new API we expose should be familiar to as many developers as possible.
* We should make the minimum necessary change.

After some deliberation, we decided to build a JavaScript-style [`setTimeout()`](https://developer.mozilla.org/en-US/docs/Web/API/window.setTimeout).


<br class="separator" />
### Understanding Vim

Step 0 was to clone Vim and start poking around. The Vim codebase is intimidating, to put it mildly. A quarter-century of development by some of the best minds in software has created a text editor that, while powerful and extensible, is not without cruft. Vim was originally written for Amiga, and `os_amiga.c` still exists. There appears to be support for VMX, 16-bit Windows, BeOS, and even MS-DOS.

As mentioned previously, Vim is input-driven. For the most part, Vim reacts to input from the user. There's no easy way to tell Vim, "run this in 500 milliseconds" or "run this *every* 500 milliseconds." There's only, "run this after user does X." This assumption is built into every level of Vim, down to the architecture-specific input functions. We discovered this by following the code.

If you want to check it out for yourself, try building Vim and running it in `gdb`. This example is slightly simplified. Most of the time, we used `gdb attach` to avoid corrupting Vim's terminal.

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

Do this for a little while to get past Vim's initialization code. You may have to backspace to get rid of some control characters.

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

After playing around more in `gdb`, we got a good idea of Vim's [control flow](http://en.wikipedia.org/wiki/Control_flow). Vim's main loop is, naturally, a function called `main_loop()` in `main.c`. There are a few ways the main loop can end-up calling low-level input functions, but eventually control gets to `RealWaitForChar()` in `os_unix.c`. `RealWaitForChar()` calls `select()` or falls back to `poll()` if `select()` isn't available.

Running Vim in a GUI follows a different path, but it still boils down to one function: `gui_wait_for_chars()` in `gui.c`. 

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
### Implementing Settimeout

Our desired API was simple. We'd make three functions: `settimeout()`, `setinterval()`, and `canceltimeout()`. `settimeout()` and `setinterval()` would take milliseconds and a command to evaluate. For example, `let timeout_id = settimeout(2000, 'echo("hello")')` would print "hello" after two seconds. Calling `canceltimeout(timeout_id)` would cancel the timeout.



<br class="separator" />
### Timeouts

Representing pending timeouts is pretty straightforward. Timeouts are run in order, so a [linked-list](http://en.wikipedia.org/wiki/Linked_list) sorted by time makes a lot of sense. There are more efficient data structures for timeouts, but this is a decent first-pass.

{% highlight c %}
struct timeout_T {
    int id;                     /* timeout/interval id */
    int interval;               /* interval period if interval, otherwise -1 */
    unsigned long long tm;      /* time to fire (epoch milliseconds) */
    char_u *cmd;                /* vim command to run */
    struct timeout_T *next;     /* pointer to next timeout in linked list */
};
typedef struct timeout_T timeout_T;
{% endhighlight %}


<br class="separator" />
### Select Loops

`RealWaitForChar()` can either take a timeout or block until there's user input. The initial plan was to put a loop in `RealWaitForChar()` 


Since `select()` was already being called in `RealWaitForChar()`, we decided to make a `select()` loop. The loop is pretty simple: until

call_timeouts()


Once we thought our work was ready for others to see, [we posted the patch to Vim-dev](https://groups.google.com/d/msg/vim_dev/-4pqDJfHCsM/LkYNCpZjQ70J). After some healthy discussion (and a little bikeshedding), we 


nitpick: need cross-platform monotonic timers (link to http://geekwhisperer.blogspot.co.uk/2010/01/twisty-maze-of-linux-clocks-all.html)


first commit Thu Mar 21 22:29:44 2013

https://groups.google.com/d/msg/vim_dev/-4pqDJfHCsM/BSy3spynGwoJ

https://github.com/Floobits/vim/compare/835cc6e85d8fbc14c4e659a4c0452ca5f699d805...master
