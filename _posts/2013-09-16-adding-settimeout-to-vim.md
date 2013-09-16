---
date: '2013-09-16 13:08:39'
layout: post
slug: adding-settimeout-to-vim
published: true
title: Adding setTimeout to Vim
authors:
    ggreer
    kansface
categories:
---

When we started Floobits, we had to decide which editors to support first. Sublime Text was our first choice, since we both used it daily. Vim was second on our list, for two reasons: First, the Vim community is full of hackers, tinkerers, and friends. Second, collaborative editing is Vim's [third-most requested feature](http://www.vim.org/sponsor/vote_results.php).

Emacs rounded-out our list. It is the yang to Vim's yin. We couldn't choose just one.

We thought we'd be able to write one editor plugin per month. Like most estimates, ours were ridiculously optimistic. We ended up taking 2-3 months per editor.

Building real-time collaboration into editors is *hard*. Most actions in editors are user-initiated. You type keys and text changes. With collaborative editing, actions can be initiated remotely. You *don't* type keys and text changes. To solve this problem, we need an event handler for network I/O: when data comes in, update buffers. Most editor plugin architectures don't support this behavior. (Emacs does. Thanks, Emacs!) So to work around this lack-of-feature, we had to build our own event loop.

put select() loop example and settimeout and stuff

need to execute a function every 100ms(or similiar). need timer to do that

matt researched ways to get async behavior in vim
things that definitely won't work
twisted (covim)


things that might work:

[Autocommands](http://vimdoc.sourceforge.net/htmldoc/autocmd.html) are a powerful feature of Vim. They let you define commands to run after certain actions. For example, `autocmd BufEnter echo 'Hello'` will echo "Hello" every time you switch buffers. There are no autocommands for timers, but it is possible to abuse [`CusorHold`](http://vimdoc.sourceforge.net/htmldoc/autocmd.html#CursorHold) to get an event loop. `CusorHold` runs a command if there have been no keys pressed for `updatetime` milliseconds, which defaults to 4000. 

To make an event loop, we just have to have a `CursorHold` autocommand that makes Vim think a key was hit. Then it will fire every `updatetime` milliseconds. For example, to get Vim to echo "Hello" every 100 milliseconds:

    function !cursor_hold()
        echo 'Hello'
        call feedkeys('f\e', 'n')
    endfunction

    set updatetime=50
    autocmd CursorHold call cursor_hold()


If you search for ways to make a timer in vim, one of the first things you'll stumble into is the `K_IGNORE` trick.  The basic idea is that Vim munges various forms of input into sequences it knows how to deal with.  Input can be anything from a mouse, to the network, to a user typing (or not in some cases).  Sometimes, it is desirable to take a pass through the event loop but take no other actions.  For instance, the CursorHold autocommand fire off after 'updatetime' number of seconds if no action is taken.  The autocommand will only fire again after the user takes some action.  Vim uses K_IGNORE to fulfill this function.  Before 7.2.025, it was possible to simply change the updatetime to be quite small, say 50 ms, wait for the CursorHold autocommand to fire, then to pass Vim K_IGNORE via the feedkeys command.  K_IGNORE reset the timer for the autocommand, forming a loop.  Unfortunately, if the plugin were to call into Vim internals in any meaningful way, you'd create an infinte loop due to implementation details.  This bug/feature was removed in 2010.  In the [thread concerning its removing](http://vim.1045645.n5.nabble.com/K-IGNORE-trick-periodic-execution-td1194386.html), Bram suggested plugin authors instead use the key sequence "f\e" instead.

Since current versions of Vim removed the K_IGNORE hack, we took Bram's advice and implemented the new hack.  The basic idea here is the same as before, except to use what could be the start of a command and to escape it instead of an undocumented internal byte sequence ("\x80\xFD\x35").  We our first implemention of our event loop used f\e on Apr 9.  It seemed to work, but that was only because we were largley unfamiliar with Vim at that time.
Vim has modes.  The default mode is command line mode, whereby the user can type commands for Vim.  Inputing text into a buffer must be done in Insert Mode.  Unfortunately, escape exits insert mode into command line mode.  So, this isn't too bad, you just use CursorHoldI (ie, cursorhold for insert mode), and then do some other action that has no effect, like moving the cursor left, then right.


    linelen = int(vim.eval("col('$')-1"))
    if linelen > 0:
        if int(vim.eval("col('.')")) == 1:
            vim.command("call feedkeys(\"\<Right>\<Left>\",'n')")
        else:
            vim.command("call feedkeys(\"\<Left>\<Right>\",'n')")
    else:
        vim.command("call feedkeys(\"\ei\",'n')")
broke leaderkeys and all other maps because the escape escapes everything before it, fucks with updatetime which breaks other plugins

feedkeys suggested by bram as an alternative to k_ignore, call feedkeys("f\e") ... ()
    https://github.com/Floobits/floobits-vim/commit/4177b2a26bc42aa1bf418c58512d60f3063af33c
    
client-server (not supported by all vims, different implementation everywhere, breaks leaderkeys, forces us to call redraw (makes vim's command line blink), and is stupidly ineffcient)
    https://github.com/Floobits/floobits-vim/commit/efb4e08372bfd6a4845e91e53e11bd46525bd858
    Sun May 19 20:58:02 2013 -0700
multithreaded- vim is not thread safe


philips said, "why don't you just patch vim?"

patching vim to have settimeout/setinterval

vim is character-driven

(explain functions that are called down to realwaitforchar)
(maybe whine about vim's codebase and how horrible it is, but not too much)

select() loop to check if timeouts need to be fired

nitpick: need cross-platform monotonic timers (link to http://geekwhisperer.blogspot.co.uk/2010/01/twisty-maze-of-linux-clocks-all.html)

https://groups.google.com/forum/#!topic/vim_dev/-4pqDJfHCsM

first commit Thu Mar 21 22:29:44 2013
