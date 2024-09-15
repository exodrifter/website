---
aliases:
- "`ViewportTexture` does not have mipmaps"
---

# `ViewportTexture` does not have mipmaps

In both Godot 3 and 4, `ViewportTexture`s do not have mipmaps. To get around this issue, we can increase the number of samples we make based on how much the UV value changes and average the colors of all those samples:

```gdshader
shader_type spatial;

uniform sampler2D albedo_texture: filter_linear;

vec3 sample(sampler2D sampler, vec2 uv) {
	// Project the pixel onto the texture to find out how many texels we want to
	// sample. We're approximating the shape of the projection here as a
	// parallelogram; in perspective this projection would actually result in a
	// different shape, but this is close enough.
	vec2 uvdx = dFdx(uv);
	vec2 uvdy = dFdy(uv);
	vec2 tex_size = vec2(textureSize(sampler, 0));
	vec2 extents = vec2(length(uvdx*tex_size), length(uvdy*tex_size));

	// In each direction along the parallelogram, we want to sample at minimum
	// once and at most 32 times.
	extents = clamp(round(extents), vec2(1, 1), vec2(32, 32));
	uvdx /= extents.x;
	uvdy /= extents.y;

	// We want to start sampling from the top-left of the parallelogram, but
	// we need to offset this by half of the distance so that the sample points
	// are centered on the original UV coordinate. In other words, we want to
	// sample the fences and not the fence posts.
	uv -= (extents.x*0.5 - 0.5)*uvdx + (extents.y*0.5 - 0.5)*uvdy;
	vec3 result = vec3(0);
	for (float i = 0.0; i < extents.x; i++) {
		for (float j = 0.0; j < extents.y; j++) {
			result += texture(sampler, uv + i*uvdx + j*uvdy).rgb;
		}
	}

	return result / (extents.x*extents.y);
}

void fragment() {
	ALBEDO = sample(albedo_texture, UV);
}
```

## History

![20240620_221253](../entries/20240620_221253.md)

![20240621_054605](../entries/20240621_054605.md)

![20240621_214324](../entries/20240621_214324.md)

![20240622_185329](../entries/20240622_185329.md)
