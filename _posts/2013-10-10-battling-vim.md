---
date: '2013-10-10 17:19:54'
layout: post
slug: battling-vim
published: false
title: battling-vim
categories:
---

In [part one the Vim trilogy]({{ page.previous.previous.url }}), we exhasted all efforts to hack existing features in Vim to create asyncronous, evented IO without horrible side effects.  At the end of [the previous post]({{ page.previous.url }}), we had resigned ourselves to building a patch for Vim that added support for setting and canceling timeouts.  It seemed like the finish line was in sight; after a few minor changes the Floobits Vim Plugin finally worked as expected. Of course, patching Vim wouldn't be that easy.

Maintaining and distrubing a fork of Vim would be a huge undertaking; Vim supports DOS, Amiga, VMS, and win-16 to name just a few of the unpopular ones. Worse yet, Vim has a half dozen common, different packages[macvim, gvim, vim, spf13]. We needed our patch to be accepted into Vim or we would inherit all of those operating systems and distributions.  We were now in the business of making our patch acceptible to the community.

Oddly enough, we received practically no feedback about our implemention from the Vim devs.  Apart from the advice to use monotonic timers and change where we put curly braces, we were on our own.

### How can we break it?

What input can we throw at set_timeout to break it?  What about calling set_timeout from within another timeout?

Fixed.

Cancel a timeout from its own callback.


### Just a 100x decrease in performance (again?!)

Everything we threw at timers worked as expected apart from one function, :Explore.  

:Explore is implemented in #netrw, an untaimed morass of vim script shipped with Vim nearly 10K loc.  

first tried to understand it- no debugger, so we had to understand it.

Opening a local directory for exploration uses the same code that handles all remote file io?  
Maybe we forgot to do some initialization or setup before we called into it so we were really hitting a network timeout?  

calls to do_cdmline were the same and ubuiquitous throughout the code base, so that couldn't be the cause.

Decho is essentially a pretty printer for debugging vim scripts.  Instead of using logging levels, the commands are just commented out and check in.  uncommenting " call Decho commands was fruitless.

Next up was Instruments.app, which showed nothing strange- most of the time was spent in select, certainly not opening up sockets.

Use the Vim Profiler (after recompiling vim) ...

{% highlight text %}
:call settimeout(0, "Explore ~")
count total (s) self (s) function
1 2.620059 0.027059 netrw#Explore()
1 2.593000 0.000131 netrw#LocalBrowseCheck()
1 2.446097 0.000347 <SNR>26_NetrwBrowse()
1 1.443353 0.062179 <SNR>26_PerformListing()
1 0.978938 0.000448 <SNR>26_NetrwGetBuffer()
1 0.978304 0.000426 <SNR>26_NetrwEnew()
3 0.957588 0.001165 <SNR>26_NetrwOptionRestore()
1 0.748296 <SNR>26_NetrwSetSort()
1 0.271453 <SNR>26_NetrwListHide()
2 0.168370 0.042646 <SNR>13_SynSet()
1 0.128560 0.128315 <SNR>26_LocalListing()
1 0.126958 0.000222 <SNR>26_NetrwSafeOptions()
2 0.125646 netrw#NetrwRestorePosn()
1 0.083888 0.021126 netrw#NetrwSavePosn()
2 0.041997 <SNR>10_LoadFTPlugin()
1 0.021434 0.021221 <SNR>26_NetrwBookHistRead()
68 0.001621 <SNR>26_NetrwInit()
1 0.001439 0.001433 <SNR>26_NetrwMaps()
2 0.000417 <SNR>26_NetrwOptionSave()
1 0.000228 <SNR>26_LocalFastBrowser()


:Explore ~
count total (s) self (s) function
1 0.021241 0.006975 netrw#Explore()
1 0.014266 0.000074 netrw#LocalBrowseCheck()
1 0.013968 0.000296 <SNR>26_NetrwBrowse()
1 0.008547 0.000448 <SNR>26_PerformListing()
1 0.003741 0.003255 <SNR>26_NetrwBookHistSave()
1 0.003012 0.000424 <SNR>26_NetrwGetBuffer()
1 0.002976 0.002806 <SNR>26_LocalListing()
2 0.002871 0.000588 <SNR>26_NetrwEnew()
4 0.002356 0.001092 <SNR>26_NetrwOptionRestore()
1 0.001364 0.001358 <SNR>26_NetrwMaps()
1 0.001356 0.000218 <SNR>26_NetrwSafeOptions()
2 0.001330 0.000472 <SNR>13_SynSet()
1 0.001310 <SNR>26_NetrwSetSort()
68 0.001304 <SNR>26_NetrwInit()
2 0.000763 <SNR>10_LoadFTPlugin()
1 0.000630 0.000156 <SNR>4_mergelists()
3 0.000572 <SNR>26_NetrwOptionSave()
1 0.000393 0.000133 ctrlp#mrufiles#cachefile()
1 0.000334 0.000008 <SNR>4_savetofile()
1 0.000326 0.000313 ctrlp#utils#writecache()
{% endhighlight %}

None of the extra time is spent in self.

I remembered that our initial implementation in MacVim didn't have this problem- so it has to be how we are calling timeouts.  printf statment next to select calls showed the problem- calling select every 20ms!