Mini Frameworks
===============

Mini Frameworks are extremely useful tiny frameworks which are entirely self contained. They follow these two rules:

- Each mini framework consists of at most 2 files (a header and an implementation).
- A mini framework may not include other files with the exception of system frameworks and files. (*Mini Framework subclasses, though discouraged, may include their superclass*).


Use
---

1. Find a mini framework that helps you
2. Grab it and copy it into your project
3. Use it

Just copy them directly into your project. Don't try to statically link or share mini frameworks between projects unless you really want to.

You are encouraged to manipulate mini frameworks in whatever way helps you. If you need to rename a file or add something specific to a mini framework for your current project, **do it**! When you start your next project, come back here and get a fresh copy.


The Goal
--------

This repository is a set of useful mini frameworks covering a broad range of uses to show you what a mini framework is and why they are useful. I hope others will create their own repositories and mini frameworks they find useful.

In the future, I hope something along these lines plays out:

> John needs to base 64 a string. He searches for a mini framework that base 64 encodes. He finds one, throws it in his project, and is good to go.


Creating Your Own
-----------------

Mini Frameworks should try to tackle a single idea. Typically, they should have at most one external class and limit the number of methods as much as possible.

Mini Frameworks are under no obligation to remain backwards compatible. In fact, they are encouraged to break backwards compatibility if a better solution to the problem is found.

There is no required code style for a mini framework. You could even make mini frameworks for another coding language if you wanted to. If you'd like to stay consistent with this repository (for example the `MF` prefix), you may, but it is not necessary.

Feel free to link back to this repository from your collection of mini frameworks (or not) so people can read about the rules of mini frameworks.


This Repository
===============


Under Review
------------

The mini frameworks in the `Under Review` folder are ones I'm not sure are "useful enough" to be put on the list. Feel free to look through them and use them if you like.


License
-------

Licensed under the MIT license. You can check it out in the LICENSE.txt file. Basically, you can do whatever you want with it but there are no guarantees.