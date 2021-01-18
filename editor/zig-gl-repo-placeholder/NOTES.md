https://learnopengl.com/Getting-started/Hello-Triangle

The OpenGL pipeline has 6 stages, where the output of each stage is passed as input to the next stage.

1. Vertex Shader: inputs vertex data, transform vertices into another set of vertices
2. Primitive Assembly: turn vertices into primitives (aka "shapes")
3. Gemotry Shader: transform primitives into other primitives
4. Rasterization: map primitives to fragments (aka "pixels") (note: clipping is also done here before running the fragment shader)
5. Fragment Shader: calculate final color (uses light/shadow data)
6. Tests and Blending

Steps 1, 3 and 5 are customizable through shaders.  There are a couple more steps not discussed yet (i.e. tessellation/transform feedback loop).

Note that geometry shader is optional, but vertex and fragment shaders are required (they have no default).

All OpenGL 3D coordinates are between `-1.0` and `1.0` on 3 axes.  All coordinates in this "normalized" range end up visible on the screen and coordinates outside will not.

> NOTE: The Vertex Shader outputs "Normalized Device Coordinates".  This means that those vertices will only be visible if they are between `-1.0` and `1.0`.

* Vertex data is stored in "Vertex Buffer Objects" (VBO).
* OpenGL can bind multiple buffer types as once so long as they are different types. Each buffer type has its own binding.

GL_ARRAY_BUFFER - VBO (vertex buffer object)

```
// after this call, any calls we make on the GL_ARRAY_BUFFER target will apply to `my_vbo`
glBindBuffer(GL_ARRAY_BUFFER, my_vbo);
```

This following will send vertex data to `my_vbo`
```
// sends vertices to the current buffer bound to GL_ARRAY_BUFFER
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
```

The fourth parameter of `glBufferData`

* GL_STREAM_DRAW: the data is set only once and used by the GPU at most a few times.
* GL_STATIC_DRAW: the data is set only once and used many times.
* GL_DYNAMIC_DRAW: the data is changed a lot and used many times.
