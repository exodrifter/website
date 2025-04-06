---
title: Sound Propagation
created: 2025-04-06T15:57:24Z
aliases:
- Sound Propagation
---

# Sound Propagation

**Sound propagation** is the process of simulating what audio sounds like based on the environment you are in. In particular, I'm interested in how it can be done for realtime applications such as games. [^1]

One example of is [GSOUND](https://gamma.cs.unc.edu/GSOUND/) made by Carl Schissler and Dinesh Manocha which has a [video recording](https://gamma.cs.unc.edu/GSOUND/video.mp4) which I find very convincing. This is because it uses both specular reflections and diffraction to calculate the sound you hear. Unfortunately, the code is proprietary but is partially available at [GAMMA-UMD/pygsound](https://github.com/GAMMA-UMD/pygsound). More information about sound propagation written by Carl Schissler can be found [here](http://www.carlschissler.com/index.php?page=publications) as well. [^1]

A much less convincing example is [Raytraced Audio](https://www.youtube.com/watch?v=u6EuAUjq92k) by Vercidium. It only uses specular reflections. [^1]

[^1]: [20250406154946](../entries/20250406154946.md)
