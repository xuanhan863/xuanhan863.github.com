---
layout: post
title: "Git tricks: stash"
date: 2012-07-27 17:33
comments: true
categories: 
---

> Git tricks: stash
> 
> Git’s stash functionality is something
> that you won’t need very often (in my
> experience, ever) if you’re just
> hacking away at something in private.
> However, as soon as you introduce
> other factors
> - a boss, say - you’ll find you need to tweak your work-flow to make
> yourself more interruptible.
> 
> Sometimes, something needs fixing
> ASAP, and you have 260 build-breaking
> lines an hour away from being
> commit-worthy - you want to store that
> code safely somewhere while you work
> on the emergency. Without git stash,
> you have two possibilities.

    

 1. Create a temporary branch, commit
    the broken code, and later abuse git
    reset to undo the commit, Pure git,
    very ugly, and it’s easy to bork
    things with the git reset call.

    

 2. Clone a new copy of the repository.
    Much simpler, but not feasible for
    larger repositories, and incredibly
    hacky.

Git stash introduces the idea of a temporary commit, orphaned in the sense that it does not belong to any branch, but can be restored later, on top of any other commit. The simplest usage:

    $ git stash
    $ fix emergency
    $ git commit -a -m "Emergency fix"
    $ git stash pop

Of course, this being git, every feature has to be a little more powerful than that. The commit stored by stash is just like any other commit - it’s a patch which can be applied anywhere. Say you have a lot of branches flying around, and you accidentally start to make a change to the wrong one:

    $ git checkout widget-a
    $ # add widget B
    $ git stash -u
    $ git checkout widget-b
    $ git stash pop

The -u (equivalent to --include-untracked) put all untracked files in the stash as well, meaning that when you check out widget-b, you won’t have to re-compile your changes.

Or say you want to pull without committing, but some of your changes conflict:

    $ git stash && git pull && git stash pop

You can also drop and list stashes, and apply them without removing them from the stash stack.

Article from : [http://bytbox.net/blog/2012/07/git-stash.html][1]
