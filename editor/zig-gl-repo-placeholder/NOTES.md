# TODO

* Go through https://learnopengl.com/In-Practice/Debugging



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

### Vertex Attributes

In a vertex shader, the data for each vertex is defined by "vertex attributes".  Here is an example of a vertex attribute declared in a vertex shader:

```
layout (location = 0) in vec3 aPos;
```

And here is an example of data that could be input to this vertex attribute:
```c
float vertices[] = {
     0.5f,  0.5f, 0.0f,  // top right
     0.5f, -0.5f, 0.0f,  // bottom right
    -0.5f, -0.5f, 0.0f,  // bottom left
    -0.5f,  0.5f, 0.0f   // top left
};
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
```

Note that the `location = 0` in the vertex shader is used by the code later to reference that attribute, this is called the "index" of the attribute. The `glVertexAttributePointer` function will configure how a vbo is linked to a vertex attribute.

In this example, we can configure the `vertices` format with the following
```
// NOTE: glVertexAttribute configures the format for whatever VBO is currently bound to GL_ARRAY_BUFFER
glVertexAttribPointer(
    0, // index: configuring the vertex attribute at location 0
    3, // size: the number of components per attribute, i.e. a vec3 takes 3 floats
    GL_FLOAT, // 32-bit floats (note: all vec* types in GLSL are vectors of 32-bit floats)
    GL_FALSE, // only applicable to integer types, normalizes them to the -1 to 1 or 0 to 1 range
    (0)   OR  (sizeof(float)*3), // if 0, means the attribute data is "tightly packed", otherwise,
                                 // it's the byte distance between attributes
    0, // this is the offset into the buffer where the attribute data starts
);
// the next call enables vertex attribute 0, not sure what this means exactly???
glEnableVertexAttribArray(0);
```

So with this function, we can customize where the vertex attribute data comes from by specifing the
    * type of the data (note: is this completely redundant with the type in the vertex shader?)
    * the number of components (note: is this completely redundant with the type in the vertex shader?)
    * the offset of the data within the buffer
    * the stride of each element within the buffer


# Vertex Array Object (VAO)

A "vertex array object" (VAO) can also be bound like a VBO, and any vertex attribute calls will be stored inside the VAO.

# Element Buffer Objects
