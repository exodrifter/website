---
title: lost contact art pipeline
published: 2023-11-28
aliases:
- lost contact art pipeline
---

# lost contact art pipeline

![A scene of a messy bedroom on a space station, with a desk in the center with a triple monitor setup, several monitors nearby, flanked by cages filled with gas tanks, a stack of mattresses in the foreground, and a small bed nook recessed into the wall on the left.](20231128_lost-contact-art-pipeline-scene.png)

Today I broke ground on [my first day making _lost contact_](https://vods.exodrifter.space/2023/11/27/1508) by (mostly) figuring out how the asset pipeline would work. As a test, I put together some of the 3D assets that @Titanseek3r (who I will refer to Tanuki from here on out) has made over the last few days.

One of my [guiding principles](20231014_guiding-principles.md) is to make it trivial to explore possibilities. To that end, I want to develop an art pipeline that allows me to change aspects quickly and easily at any time. I _don't_ want to have to go back and forth between tools or ask an artist for frequent revisions to tweak aspects of the game, especially since _lost contact_, as a hidden object game, will need lots of tweaks to the placement of things.

I discussed this strategy with Tanuki (who, thank goodness, knows much more about 3D art pipelines than me) and, with respect to this strategy, we agreed on the following aspects:

- Design models in a way that they can be recolored at runtime.
- Models will be designed into modular pieces so they can be snapped together in the editor to create a variety of scenes.
- Avoid texturing the models as much as possible.
- Rely on decals to provide more detail to scenes (and make the decals recolor-able too).

First, I had to assemble all of the models into a scene. I tried to use `GridMap`, but since our modular tiles are not uniform sizes, this didn't work well. You can see in the following picture that everything looks awful; all of the models made by Tanuki had default placeholder materials with the colors pink, green, and yellow. You can imagine the assets at this stage as a new 3D "coloring book".

![The same scene, but it's flat colored in entirely pinks, greens, and yellows.](20231128_lost-contact-art-pipeline-import.png)

Then, I created materials to fill in each material slot of the models. This colors in the "coloring book".

![The same scene, but it's flat-colored, mostly with greys.](20231128_lost-contact-art-pipeline-color.png)

Then, I created some simple 2D textures and used them as decals to detail the scene.

![The same scene, with some 2D decal textures used to indicate wear and texture on some surfaces, including a logo on the back wall.](20231128_lost-contact-art-pipeline-decal.png)

Then, I added some lights...

![The same scene, with some white and orange lighting from the front and right, respectively.](20231128_lost-contact-art-pipeline-light.png)

And finally, I set some environment settings in Godot, including ambient light, SSAO, glow, volumetric fog, and some contrast and saturation tweaks:

![The same image featured at the top of this post.](20231128_lost-contact-art-pipeline-scene.png)

I was able to figure out the pipeline from scratch today and the result is pretty good, so I'm happy with it. It feels pretty nice to not get stuck hopping back and forth between different editors to make changes and I'm looking forward to making more scenes with this approach.

# colophon

Posted at:
- [cohost!](https://cohost.org/exodrifter/post/3682828-lost-contact-art-pip) on November 28, 2023 at 12:00 AM UTC