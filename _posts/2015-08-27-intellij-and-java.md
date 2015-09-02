---
date: '2015-08-27 14:20:00'
layout: post
slug: intellij-idea-plugin-development-and-java-6
published: true
title: IntelliJ IDEA Plugin Development and Java 6
authors:
  - bjorn
categories:
  - IntelliJ
  - Bugs
---

Based on my experience of the last couple of years writing editor plugins for Floobits, I can say that IntelliJ IDEA’s plugin system is phenomenal. Extending IntelliJ IDEA is particularly stellar. Unlike most editors, IntelliJ's plugin API gives you access to everything. The IDE architecture is very well designed. The core is [open source](https://github.com/JetBrains/intellij-community) and easy to follow. And IntelliJ plugins have all of Java's libraries available. It is quite amazing.

There is a lot to rave about, but one thing that isn’t great is Java versioning. IntelliJ IDEA is a cross-platform Java-based editor, and its plugins must share the JRE that the editor runs on. The version of Java you choose for writing your plugin must be compatible with your target audience’s installed Java. If the user does not have the correct version of Java, your plugin will cause a nasty error at start time and your plugin will be automatically disabled. There is no way to specify in the plugin configuration file (`plugin.xml`) which version of Java you support. That means there's no way to prevent people from installing something that will explode on them. If a user encounters this error, there’s no easy way to explain what happened or what to do about it.

The solution recommended by JetBrains is to use Java 6 for plugin IntelliJ IDEA development. But Java 6 is old. It's so old that Oracle [no longer provides security updates](http://www.oracle.com/technetwork/java/archive-139210.html). Compared to Java 8 (or even 7), Java 6 is terrible to work with. There are no [lambdas](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html). There are none of the [new `nio` APIs](https://en.wikipedia.org/wiki/Non-blocking_I/O_%28Java%29) to reduce the pain of working with file I/O and threads.

Most people are running at least Java 7 now, so I looked into why JetBrains recommends Java 6. It turns out that for OS X users, Java 6 is what most people have, if they even have Java at all. Apple used to develop their own version of Java for OS X, but they gave it up, and the last version they supported was Java 6. Apple [still makes this old version available](https://support.apple.com/downloads/java), and it still gets security updates, but Apple refers to it as ‘legacy’ and has no plans to support any new versions of Java. Oracle does supply newer versions of Java that are OS X compatible, but they have a severe problem: The font-rendering is *atrocious* on OS X. This is a huge problem for an IDE! Blurry, pixelated, aliased fonts are not what you want to stare at for hours at end. Oracle is looking to fix this for newer versions of Java, but for now we are stuck with Java 6.

Given the state of Java on OS X, JetBrains has done a great job. Recently, they forked OpenJDK, fixed the font-rendering on OS X, and built versions of each of their IntelliJ IDEA based editors that [include this version of Java](https://confluence.jetbrains.com/display/IntelliJIDEA/Previous+IntelliJ+IDEA+Releases). Unfortunately, this download is not the default. Discovering it requires clicking through a link for “previous releases.” In my opinion, this version of IntelliJ IDEA should be the default version for all OS X users and the version without a JRE should be an alternate download. Sadly, even if this was the case, there would still be many Java 6 installs. For now, plugins must be written to match the lowest common denominator: the JRE for Java 6.

I [asked about Java version detection](https://devnet.jetbrains.com/message/5548947) on the JetBrains plugin development forum, and [was told](https://devnet.jetbrains.com/message/5548962#5548962):

> There is no possibility to mark a plugin in this way (and we don't plan to provide one). If you want to use lambdas and new things, please consider writing your plugin in Kotlin, which does have lambdas and new things, but compiles to regular Java 6 bytecode.

Our IntelliJ plugin is already written in Java, but if we were to build it today, we'd probably use [Kotlin](http://kotlinlang.org/). Kotlin is a pretty amazing programing language. It provides many modern programming language concepts, such as lambdas, null-pointer saftey, and first-class functions. It does this without making it difficult to use Java libraries and code. Though using Kotlin still wouldn't give us access to the `nio` APIs, the situation would be better.

In order to bring Floobits to as many editors and platforms possible, we have to endure the pain that is editor plugin development. Whenever we build plugins, we run into issues that most developers would walk away from. We don't have that option, so Java 6 it is. Having said that, IntelliJ IDEA actually has the best plugin development API out there. This post doesn’t mean to detract from that.

If you're curious, you can [see our IntelliJ plugin's code on GitHub](https://github.com/Floobits/floobits-intellij).
