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

> NOTE: There is a maximum number of vertex attributes we're allowed to declare limited by the hardware. OpenGL guarantees there are always at least 16 4-component vertex attributes available, but some hardware may allow for more which you can retrieve by querying GL_MAX_VERTEX_ATTRIBS with `glGetIntegerv`.

# Vertex Array Object (VAO)

A "vertex array object" (VAO) can also be bound like a VBO, and any vertex attribute calls will be stored inside the VAO.

# Element Buffer Objects

Element Buffer Objects contain indices to vertecies from a VBO (Vertex Buffer Object).  This is analogous to a bitmap image where there is a color table and the image itself is encoded as indices into the color table.  Like a bitmap, the vbo (vertex buffer object) is a table of vertices that are indexed by the ebo.

Example:
```
// Setting data for an ebo
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, ...);

// ...

// Rendering an ebo
glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, null);
```

# Shaders

Types:

```
bool: how many bits?
int: 32-bit signed integer
uint: 32-bit unsigned integer
float: 32-bit float
double: 64-bit float
```

### Vectors

```
vecN: vector of float
bvecN: vector of bool
ivecN: vector of int
uvecN: vector of uint
dvecN: vector or double
```

Vector elements can be accessed via any of these fields:

Domain         | 0 | 1 | 2 | 3
---------------|---|---|---|---
space          | x | y | z | w
color          | r | g | b | a
texture coords | s | t | p | q

Because the fields are always one letter, they can be "swizzled".

```glsl
vec2 someVec;
vec4 differentVec = someVec.xyxx;
vec3 anotherVec = differentVec.zyw;
vec4 otherVec = someVec.xxxx + anotherVec.yxzy;
```

Vectors can also be created via constructors
```glsl
vec2 vect = vec2(0.5, 0.7);
vec4 result = vec4(vect, 0.0, 0.0);
vec4 otherResult = vec4(result.xyz, 1.0);
```

# Ins and Outs


We can send data from the vertex shader to the fragment shader by declaring outs and ins.

# Textures

> TODO: go through this tutorial: https://learnopengl.com/Getting-started/Textures

I'd like to go through the Transformations tutorial first.

NOTE: there seems to be a nice single-file image library here: https://github.com/nothings/stb


# Vector and Matrix Math

https://learnopengl.com/Getting-started/Transformations

## Vector Multiplication

2 kinds, "Dot Product" and "Cross Product".

#### Dot Product

Calculated by adding the components from each vector multiplied together.

```
[1 2 3] DOT_PRODUCT [4 5 6] = (1 * 4) + (2 * 5) + (3 * 6) = 32
```

Note that the dot product is also equal to

```
Length(V1) * Length(V2) * cos(AngleBetween(V1, V2))
```

Note that this also means that if `V1` and `V2` are unit vectors, then their dot product is equal to `cos(AngleBetween(V1,V2))`.  This make the dot product an easy way to see if vectors are orthogonal, since the cos of their angle would be equal to 0.

The way to visualize the dot product is to thing of it in 2 stages.  Stage 1, think of each component as a vector along its axis, then scale each vector using the corresponding value from the second vector (i.e. multiple them together).  Then, take all these vectors and line them up on a number line front to back, keeping the negative positive direction,  the result will be the final position of the last vector.

#### Cross Product

This product is only defined in 3 dimensions.  This one is a bit complex.

## Matrices

Matrices are ordered by Height/Row, then Width/Column.

`2x3` matrix:
```
  1   2   3
  4   5   6
```

The element at index `(0,2)` is `3` (row 0, column 3).

* Multiplying 2 matrices together requires that width of the left matrix is equal to the height of the right matrix.
* Matrix multiplication is NOT COMMUTATIVE
* Multiplying a matrix by a vector requires that the width of the matrix equals the size of the vector, and results in a vector with a size equal to the height of the matrix.

##### Matrix to Scale a Vector

| S1 |  0 |  0 |  0 |
|  0 | S2 |  0 |  0 |
|  0 |  0 | S3 |  0 |
|  0 |  0 |  0 | S4 |

> Note: we can put `1` for `S4`, this will be useful for some reason

##### Matrix to translate a 3d Vector

If our 3d vector is represented as a 4d vector like this `[x y z 1]` (with a `1` for the last element), then we can translate it by multiplying it with this matrix:

|  1 |  0 |  0 | T1 |
|  0 |  1 |  0 | T2 |
|  0 |  0 |  1 | T3 |
|  0 |  0 |  0 |  1 |

The resulting vector will be `[ x+T1  y+T2  z+T3  1]`.

##### Matrix to Scale and Tralsate a 3d Vector at the same time

If our 3d vector is represented as a 4d vector like this `[x y z 1]` (with a `1` for the last element), then we can translate it and scale it at the same time by multiplying it with this matrix:

| S1 |  0 |  0 | T1 |
|  0 | S2 |  0 | T2 |
|  0 |  0 | S3 | T3 |
|  0 |  0 |  0 |  1 |

The resulting vector will be `[ (S1*x)+T1  (S2*y)+T2  (S3*z)+T3  1]`.

##### Rotation

There are also matrices to rotate about the 3 axis.  Fill in more details later.


# Coordinate Systems

https://learnopengl.com/Getting-started/Coordinate-Systems


> OpenGL expects all the vertices, that we want to become visible, to be in normalized device coordinates after each vertex shader run. That is, the x, y and z coordinates of each vertex should be between `-1.0` and `1.0`; coordinates outside this range will not be visible. What we usually do, is specify the coordinates in a range (or space) we determine ourselves and in the vertex shader transform these coordinates to normalized device coordinates (NDC). These NDC are then given to the rasterizer to transform them to 2D coordinates/pixels on your screen.
> Transforming coordinates to NDC is usually accomplished in a step-by-step fashion where we transform an object's vertices to several coordinate systems before finally transforming them to NDC. The advantage of transforming them to several intermediate coordinate systems is that some operations/calculations are easier in certain coordinate systems as will soon become apparent. There are a total of 5 different coordinate systems that are of importance to us:

* Local Space (or Object space)
* World Space
* View Space (or Eye space)
* Clip Space
* Screen Space

Those are all a different state at which our vertices will be transformed in before finally ending up as fragments.

#### Stage 1: Local Space (Object Space)

Vertices define the shape of an object located at the origin.

The vertices are multipled by the "Model Matrix" (rotated/translated/scaled) to get into "World Space".

#### Stage 2: World Space

Vertices define many objects in a global coordinate system relative to some arbitrary origin.  Within this system a camera position exists and is used to transform vertices for the next stage.  The vertices are multiplied by the "View Matrix" to transform them to positions as seem from the camera's perspective.

#### Stage 3: View Space (Eye Space)

Vertices define all the objects from the camera's perspective.  At this stage vertices are multiplied by the "Projection Matrix" and clipped within the `-1.0` and `1.0` range for each axis to enter the "Clip Space".

#### Stage 4: Clip Space

Vertices define all the object from the camera's perspective and with projection/clipping applied.  These coordinates are translated to the coordinate range defined by glViewport and send tto the rasterizer to be turned into fragments.

#### Stage 5: Screen Space

Vertices have been translated to positions within the `glViewport` coordinate range.


These stages give the following equation for translating local vertices into clip space vertices:

```
Vclip = Mprojection * Mview * Mmodel * Vlocal
```


The reason for having all these different stages is that it makes certain operations easy to do so long as they are in the correct stage.  For example, its much easier to rotate an object in "Local Space" than "World Space".


### Projection Types

#### Orthographic Projection

The clip space is defined by a width/length/height and all vertices within this cube are visible (i.e. translated to NDC coordinates).

> TODO: document the layout of an ortho projection matrix, check out https://www.scratchapixel.com/lessons/3d-basic-rendering/perspective-and-orthographic-projection-matrix/orthographic-projection-matrix


