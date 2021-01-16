pub const GLvoid     = c_void;
pub const GLenum     = u32;
pub const GLfloat    = f32;
pub const GLint      = i32;
pub const GLsizei    = i32;
pub const GLbitfield = u32;
pub const GLdouble   = f64;
pub const GLuint     = u32;
pub const GLboolean  = u8;
pub const GLubyte    = u8;
pub const GLchar     = u8;
pub const GLsizeiptr = isize;

pub const GL_VERSION = 0x1F02;
pub const GL_COLOR_BUFFER_BIT = 16384;
pub const GL_TRIANGLES = 4;


pub const GL_BUFFER_SIZE                    = 0x8764;
pub const GL_BUFFER_USAGE                   = 0x8765;
pub const GL_QUERY_COUNTER_BITS             = 0x8864;
pub const GL_CURRENT_QUERY                  = 0x8865;
pub const GL_QUERY_RESULT                   = 0x8866;
pub const GL_QUERY_RESULT_AVAILABLE         = 0x8867;
pub const GL_ARRAY_BUFFER                   = 0x8892;
pub const GL_ELEMENT_ARRAY_BUFFER           = 0x8893;
pub const GL_ARRAY_BUFFER_BINDING           = 0x8894;
pub const GL_ELEMENT_ARRAY_BUFFER_BINDING   = 0x8895;
pub const GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F;
pub const GL_READ_ONLY                      = 0x88B8;
pub const GL_WRITE_ONLY                     = 0x88B9;
pub const GL_READ_WRITE                     = 0x88BA;
pub const GL_BUFFER_ACCESS                  = 0x88BB;
pub const GL_BUFFER_MAPPED                  = 0x88BC;
pub const GL_BUFFER_MAP_POINTER             = 0x88BD;
pub const GL_STREAM_DRAW                    = 0x88E0;
pub const GL_STREAM_READ                    = 0x88E1;
pub const GL_STREAM_COPY                    = 0x88E2;
pub const GL_STATIC_DRAW                    = 0x88E4;
pub const GL_STATIC_READ                    = 0x88E5;
pub const GL_STATIC_COPY                    = 0x88E6;
pub const GL_DYNAMIC_DRAW                   = 0x88E8;
pub const GL_DYNAMIC_READ                   = 0x88E9;
pub const GL_DYNAMIC_COPY                   = 0x88EA;
pub const GL_SAMPLES_PASSED                 = 0x8914;
pub const GL_SRC1_ALPHA                     = 0x8589;
pub const GL_VERTEX_ARRAY_BUFFER_BINDING    = 0x8896;
pub const GL_NORMAL_ARRAY_BUFFER_BINDING    = 0x8897;
pub const GL_COLOR_ARRAY_BUFFER_BINDING     = 0x8898;
pub const GL_INDEX_ARRAY_BUFFER_BINDING     = 0x8899;



pub const GL_FRAGMENT_SHADER = 0x8B30;
pub const GL_VERTEX_SHADER = 0x8B31;
pub const GL_DELETE_STATUS = 0x8B80;
pub const GL_COMPILE_STATUS = 0x8B81;
pub const GL_LINK_STATUS = 0x8B82;
pub const GL_INFO_LOG_LENGTH = 0x8B84;
