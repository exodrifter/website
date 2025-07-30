---
title: Marzaders
created: 2013-05-13T21:41:00Z
migrated: 2025-07-30T05:48:39Z
aliases:
- Marzaders
tags:
- cpp
- project
---

# Marzaders

> Space Invaders in 3D.

![](https://www.youtube.com/watch?v=l7_jVuSeuTs)

Marzaders is a game that I made with two other teammates over the course of about a month for my CS 378 Game Technology class at UT Austin. Initially, the game was supposed to be a simple multiplayer dogfighting game, but then we realized we didn't have enough time to do that along with all of the other projects we were being assigned in other classes. We decided instead to make a 3D space invaders game.

We had to pull together various libraries to make it work, using Bullet for physics, Ogre for rendering, SDL for sound, and, if we had enough time for networking, Boost Asio. This wasn't the first time we had to do this; we already had to make a game in this fashion for the class earlier in the semester, when we made a multiplayer version of Pong.

We wrote the code that held all of the parts together in C++ and it was finished in May 2013. 

If you download the game, you can build the game on Linux by executing "./buildit" inside of the build folder. This should work well on the computer science lab machines at UT unless the installed dependencies have been changed since spring 2013.
