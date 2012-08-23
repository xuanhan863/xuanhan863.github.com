---
layout: post
title: "Le.git for humans"
date: 2012-08-23 12:16
comments: true
categories: 
---

**Let' git.. 
让git的工作流程变的更可读, 简单.**

    $ git switch <branch>
    # Switches to branch. Stashes and restores unstaged changes.
    
    $ git sync
    # Syncronizes current branch. Auto-merge/rebase, un/stash.
    
    $ git publish <branch>
    # Publishes branch to remote server.
    
    $ git unpublish <branch>
    # Removes branch from remote server.
    
    $ git harvest <branch>
    # Auto-merge/rebase commits from given branch.
    
    $ git sprout <branch>
    # Sprout a new branch from the current branch.
    
    $ git graft <branch>
    # Merge unpublished branch into current branch, then remove it.
    
    $ git branches
    # Nice & pretty list of branches + publication status.

**Installing Legit**

**To install the legit command:**

    $ pip install legit

**To enable the git aliases:**

    $ legit install


***Nice and simple — the way it should be.***


github : <a href="https://github.com/kennethreitz/legit"> legit </a>
