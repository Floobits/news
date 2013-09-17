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

When we started Floobits, decideed to support Sublime Text first. This was natural; we both used it daily. Vim was second on our list, for two reasons: First, the Vim community is full of hackers, tinkerers, and friends. Second, collaborative editing is Vim's [third-most requested feature](http://www.vim.org/sponsor/vote_results.php). Emacs rounded-out our list. It is the yang to Vim's yin. We couldn't choose just one.

We thought we'd be able to write one editor plugin per month. [Like most estimates, ours were ridiculously optimistic](http://en.wikipedia.org/wiki/Planning_fallacy). So far we've averaged 3 months per editor. Vim took longer than average.

Building real-time collaboration into editors is *hard*. Most actions in editors are user-initiated. You type keys and text changes. With collaborative editing, actions can be initiated remotely. You *don't* type keys and text changes. The easiest way to solve this problem is to use an event handler for network I/O: when data comes in, update text.  Most editors (including Vim) don't support this behavior. We had to build our own event loop to handle incoming data.

We researched ways to run our event loop but only found dead ends. We couldn't run it in a separate thread because Vim isn't thread-safe. We couldn't run it in a separate process because all [IPC](http://en.wikipedia.org/wiki/Inter-process_communication) in Vim is blocking and must be initiated by Vim. We couldn't use the [netbeans interface](http://vimdoc.sourceforge.net/htmldoc/netbeans.html) because the implementation was buggy and incomplete.

All we really needed to drive our event loop was the ability to execute a function every 100 milliseconds or so. Vim has its own event loop, but it blocks until the user gives input. If the user is idle, there's no way to handle incoming events from other collaborators.

If user input is the only thing that can drive Vim's event loop, our efforts are hopeless. Fortunately, Vim has event hooks called [autocommands](http://vimdoc.sourceforge.net/htmldoc/autocmd.html).

For example, `autocmd BufEnter echo 'Hello'` will echo "Hello" every time you switch buffers. There are no autocommands for timers, but there is [`CusorHold`](http://vimdoc.sourceforge.net/htmldoc/autocmd.html#CursorHold). `CusorHold` runs a command if there have been no keys pressed for `updatetime` milliseconds. It's possible to abuse `CursorHold` to get an event loop. We just need to write a `CursorHold` handler that makes Vim think a key was pressed. The keys pressed need to be invisible to the user. We don't want to fire off an 'i' and switch to insert mode.

`Updatetime` defaults to 4000 milliseconds, but plugins can change it. This will print "Hello" every 100 milliseconds.

    function !cursor_hold()
        echo 'Hello'
        " literally the key 'f' followed by the 'escape' key
        call feedkeys('f\e', 'n')
    endfunction

    set updatetime=100
    autocmd CursorHold call cursor_hold()

Hooray! Once we find a key sequence with no side-effects, we should be set.  

CursorHold only fires when Vim is in normal mode.  CursorHoldI is like CursorHold, but only fires while in Insert Mode.  In Vim, escape aborts a command but also is used to exit insert mode, so we have to resort to a different 

Before 7.2.025, exactly such a command existed in the form of the K_IGNORE byte sequence and feedkeys.

    " K_IGNORE
    call feedkeys('\x80\xFD\x35', 'n')

K_IGNORE is an undocumented, internal feature of Vim which is used to implement things like CursorHold.  Internally, Vim translates all inputs into keycodes.  For instance, a left mouse click turns into K_MOUSEDOWN.  K_IGNORE is such a key code which does nothing. Vim does no validation on input so its possible to feed K_IGNORE to Vim as if a user is typing it. Unfortunately, if the plugin were to call into Vim internals in any meaningful way, it would create an infinte loop.  This bug/feature was removed in 2010.  In the [thread concerning its removing](http://vim.1045645.n5.nabble.com/K-IGNORE-trick-periodic-execution-td1194386.html), Bram suggested plugin authors instead use the key sequence "f\e" instead.
 

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
