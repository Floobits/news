---
date: '2013-09-16 13:08:39'
layout: post
slug: adding-settimeout-to-vim
published: true
title: Adding Realtime Collaboration to Vim
authors:
    kansface
categories:
    Vim
---

When we started Floobits, we thought we'd be able to write one editor plugin per month. [Like most estimates, ours were ridiculously optimistic](http://en.wikipedia.org/wiki/Planning_fallacy). So far we've averaged 3 months per editor. Vim has taken longer than average.

Vim was our second target after Sublime Text. We thought it was a good choice because the Vim community is full of hackers and collaborative editing is a [highly requested feature](http://www.vim.org/sponsor/vote_results.php). In hindsight, no one has built realtime collaborative editing into Vim (a 23 year-old editor) for a reason.

Building realtime collaboration is *hard*. Most actions in editors are user-initiated. You type keys and text changes. With collaborative editing, actions can be initiated remotely. You *don't* type keys and text changes. The easiest way to solve this problem is to use an event handler for network I/O ([open-network-stream in Emacs](http://www.gnu.org/software/emacs/manual/html_node/elisp/Network.html)). This model is simple: update text when data comes in. Vim doesn't natively support async network connections, so we were forced to build our own.

This should have been easy! We had already a working event loop for Sublime. The existing code could read data off the wire and patch buffers. We just needed to find a way to integrate our loop with Vim, but none of the usual methods would work. We couldn't run it in a separate thread because Vim isn't thread-safe. We couldn't run it in a separate process because all [IPC](http://en.wikipedia.org/wiki/Inter-process_communication) in Vim is blocking and must be initiated by Vim. We couldn't even use the [netbeans interface](http://vimdoc.sourceforge.net/htmldoc/netbeans.html) because the implementation is buggy and incomplete.

Fundamentally, all we really needed to drive our event loop was the ability to execute a function every 100 milliseconds or so. Since a given iteration of the loop typically finishes within a few milliseconds, the end user wouldn't notice. Vim has its own event loop, but it blocks until the user gives input. When the user is idle, there's no way to handle incoming events. Fortunately, Vim has event hooks in the form of [autocommands](http://vimdoc.sourceforge.net/htmldoc/autocmd.html).

While there are no autocommands for timers, [`CusorHold`](http://vimdoc.sourceforge.net/htmldoc/autocmd.html#CursorHold) is close. If Vim receives no input for `updatetime` milliseconds, `CusorHold` runs a user defined command. `Updatetime` defaults to 4000, but plugins can change it.  If we could write a callback that made Vim think a key was pressed (thereby triggering another `CursorHold` event), we could use `CusorHold` to form an asynchronous loop.

As it turns out, making a loop with `CursorHold` is easy. The following example prints "Hello" every 100 milliseconds by sending Vim the `f` key followed by `escape` key.

{% highlight text %}
function !cursor_hold()
    echo 'Hello'
    call feedkeys('f\e', 'n')
endfunction

set updatetime=100
autocmd CursorHold call cursor_hold()
{% endhighlight %}

Hooray, we had our event loop!

In practice, the details were messy. CursorHold only fires when Vim is in normal mode. CursorHoldI is like CursorHold, but only fires while in insert mode. In Vim, escape aborts a command but also is used to exit insert mode. The CursorHoldI callback looks something like this:

{% highlight text %}
if len(text) > 0:
    if cursor_is_at_beginnging():
        # press right arrow, left arrow
        feedkeys("<Right><Left>")
    else:
        # press left arrow, right arrow
        feedkeys("<Left><Right>")
else:
    # file is empty, leave insert mode, enter insert mode
    feedkeys("\ei")
{% endhighlight %}

We showed off our Vim plugin and its shiny new event loop to [jirwin](https://github.com/jirwin) who uses Vim daily.

### "Floobits broke my Vim"
It turns out, sending Vim `escape` aborts any multi-character command, not just the `f`. For example, the window navigation commands look something like `CTRL+w j`.  Vim would see `CTRL+w f escape j` and clear everything before the j. The command only worked if it was typed completely within the 100ms window! Worse yet, we were at war with other plugins! They also changed the value of the global variable, `updatetime`, and none of them set it to 100ms!  Maybe this would be OK if only we could fix the multi character commands.  As luck would have it, there was no way to save the current state of Vim's internal buffer before sending `escape`. We were now in the business of finding a magic key sequence with no side-effects.

Before version 7.2.025, a different hack existed around `CursorHold`, which used an undocumented key sequence (`\x80\xFD\x35`) known as `K_IGNORE`. `K_IGNORE` is simply an internal code which specifies that Vim should do nothing. Vim performs no validation on input so its possible to feed `K_IGNORE` to Vim as if a user is typing it. Perfect! ...almost.  This bug/feature was removed in 2010 because it could cause an infinite loop. Optimistically, we reversed the 5 line patch and compiled Vim. The bug still existed and we soon abandoned `CursorHold`.

### Just a 100x decrease in performance

Some versions of Vim are compiled with an optional feature called clientserver. Launched in server mode, Vim would behave as a command server, accepting messages from a client Vim and executing them. Instead of trying to create a timer in Vim script, we would use an external process to tell Vim to run an iteration of our event loop.

From a terminal, the command would look something like:

{% highlight text %}
vim --servername VIM --remote-expr g:floobits_global_tick()
{% endhighlight %}

The new hack would launch an external python process at startup. The python process would popen a Vim process with the necessary flags every 100ms. The new, short lived Vim, would instruct the original Vim to execute the thing we actually cared about (`floobits_global_tick`).

Spawning 10 to 20 new Vims a second is incredibly inefficient. Vim now ate 15% or more of one CPU core (compared to the previous 0.1%). We looked into talking directly to the Vim Server from the external python process, but the implementation of clientserver is not standardized. In other words, only MacVim can talk to other MacVims and only gvim can talk to gvims. Reverse engineering the different protocols was not an option.

Apart from the 100x decrease in performance, clientserver mode worked surpisingly well for our needs. It didn't break the CTRL-W commands and it didn't need to change `updatetime`. However, not all Vims are compiled with support for clientserver. That wasn't a huge deal; we would just fall back to CursorHold and hope for the best. The actual deal breaker was interrupting maps.

In Vim, user defined shortcuts, called maps, start with the mapleader (comma is a popular choice).  Plugins can also define maps though few of them change the map leader. From the Vim docs:

{% highlight text %}
:map <Leader>A  oanother line<Esc> 
Works like:
        :map \A  oanother line<Esc>
But after:
        :let mapleader = ","
It works like:
        :map ,A  oanother line<Esc>
{% endhighlight %}

Abusing remote-expr broke all maps, making our plugin worthless for power users. It also caused the screen to flicker since we were forced to call redraw to update the terminal! At wits end, we wrote a lame workaround that let the user toggle the event loop on and off. This had all sorts of problems; what would happen if a user forgot to turn the event loop back on? How would we educate new users? We briefly consider trying to dynamically remap sequences at runtime but that too, led nowhere.

We had spent four months, on and off, desperately searching for a way to make Vim work with Floobits. So far, we had an event loop that worked for a subset of Vim users, but broke some useful features, that would fall back to a method that really broke Vim. It was about this time that [philips](https://github.com/philips) suggested we patch and distribute our own version of Vim.

Next up: [writing event loops, and patching Vim]({{ page.next.url }})!
