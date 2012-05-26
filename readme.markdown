mini-frameworks
===============

Mini Frameworks are extremely useful tiny frameworks which are entirely self contained. They follow these two rules:

- Each Mini Framework consists of at most 2 files: a `.h` and a `.m`.
- A Mini Framework may not include other files with the exception of system frameworks and files.

Mini Frameworks should try to tackle a single idea. Typically, they should have at most one external class and limit the number of methods as much as possible.

Mini Frameworks are under no obligation to remain backwards compatible. In fact, they are encouraged to break backwards compatibility if a better solution to the problem is found.

Use
---

1. Find a Mini Framework that helps you
2. Grab it and copy it into your project
3. Use it

The Goal
--------

The goal of mini-frameworks is to create a large set of useful and easy to use Mini Frameworks covering a broad range of uses that anyone can toss into their project.

> Ex: John needs to base 64 a string. He looks in mini-frameworks and **bam** he finds MFBase64. He throws it in his project and is good to go.

If you come up with a really slick Mini Framework and would like for me to add it to this list, do not hesitate to send a pull request or the files. However, I might not add everything I get.

I encourage you to make your own Mini Frameworks repos. If everybody shared their little tricks think of how much better off we'd all be.
