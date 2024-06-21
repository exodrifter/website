---
aliases:
- "`ViewportTexture` does not have mipmaps"
---

# `ViewportTexture` does not have mipmaps

In both Godot 3 and 4, `ViewportTexture`s do not have mipmaps. To get around this issue, we can sample the existing texture as if it were a mipmap on the fly in the shader:

```gdshader
shader_type spatial;

uniform sampler2D albedo_texture: filter_nearest;

vec4 sample(vec2 uv, int lod) {
	ivec2 size = textureSize(albedo_texture, 0);
	vec2 uv_step = 1.0 / vec2(size);

	int block = lod * lod;
	int count = 0;
	vec4 color = vec4(0.0);
	for (int i = -block/2; i <= block/2; i++) {
		for (int j = -block/2; j <= block/2; j++) {
			vec2 delta = vec2(uv_step.x * float(i), uv_step.y * float(j));
			color += texture(albedo_texture, uv + delta);
			count += 1;
		}
	}
	return color / float(count);
}

vec4 samplef(vec2 uv, float lod) {
	int low_lod = int(lod);
	int high_lod = int(lod + 1.0);
	return mix(sample(uv, low_lod), sample(uv, high_lod), mod(lod, 1.0));
}

void fragment() {
	float lod = textureQueryLod(albedo_texture, UV).y;
	ALBEDO = samplef(UV, lod).xyz;
}
```

## History

![20240620_221253](../entries/20240620_221253.md)

![20240621_054605](../entries/20240621_054605.md)
