mini-frameworks
===============

Mini Frameworks are extremely useful tiny frameworks which are entirely self contained. They follow these two rules:

- Each mini framework consists of at most 2 files: a `.h` and a `.m`.
- A mini framework may not include other files with the exception of system frameworks and files.

Mini Frameworks should try to tackle a single idea. Typically, they should have at most one external class and limit the number of methods as much as possible.

Mini Frameworks are under no obligation to remain backwards compatible. In fact, they are encouraged to break backwards compatibility if a better solution to the problem is found.

Use
---

1. Find a mini framework that helps you
2. Grab it and copy it into your project
3. Use it

Do not try to statically link or share mini frameworks between projects. Just copy them directly into your project. You will thank yourself later for doing it that way.

You are encouraged to manipulate mini frameworks in whatever way helps you. If you need to rename a file or add something specific to a mini framework for your current project, **do it!** When you start your next project, come back here and get a fresh copy.

The Goal
--------

The goal of mini-frameworks is to create a large set of useful and easy to use mini frameworks covering a broad range of uses that anyone can toss into their project.

> Example: John needs to base 64 a string. He looks in mini-frameworks and **bam** he finds MFBase64. He throws it in his project and is good to go.

If you come up with a really slick mini framework and would like for me to add it to this list, do not hesitate to send a pull request or the files. However, I might not add everything I get.

I encourage you to make your own mini frameworks repos. If everybody shared their little tricks think of how much better off we'd all be.

License
-------

Licensed under the MIT license. You can check it out in the LICENSE.txt file. Basically, you can do whatever you want with it but there are no guarantees.