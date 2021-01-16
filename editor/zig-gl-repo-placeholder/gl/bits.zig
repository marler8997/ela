///////////////////////
// gl.h 1.0
///////////////////////
pub const GLvoid     = c_void;
pub const GLenum     = u32;
pub const GLfloat    = f32;
pub const GLclampf   = f32;
pub const GLint      = i32;
pub const GLsizei    = i32;
pub const GLbitfield = u32;
pub const GLdouble   = f64;
pub const GLuint     = u32;
pub const GLboolean  = u8;
pub const GLubyte    = u8;
pub const GLchar     = u8;
pub const GLsizeiptr = isize;

// Extensions
pub const GL_OES_VERSION_1_0                = 1;
pub const GL_OES_read_format                = 1;
pub const GL_OES_compressed_paletted_texture = 1;

// ClearBufferMask
pub const GL_DEPTH_BUFFER_BIT               = 0x00000100;
pub const GL_STENCIL_BUFFER_BIT             = 0x00000400;
pub const GL_COLOR_BUFFER_BIT               = 0x00004000;

// Boolean
pub const GL_FALSE                          = 0;
pub const GL_TRUE                           = 1;

// BeginMode
pub const GL_POINTS                         = 0x0000;
pub const GL_LINES                          = 0x0001;
pub const GL_LINE_LOOP                      = 0x0002;
pub const GL_LINE_STRIP                     = 0x0003;
pub const GL_TRIANGLES                      = 0x0004;
pub const GL_TRIANGLE_STRIP                 = 0x0005;
pub const GL_TRIANGLE_FAN                   = 0x0006;

// AlphaFunction
pub const GL_NEVER                          = 0x0200;
pub const GL_LESS                           = 0x0201;
pub const GL_EQUAL                          = 0x0202;
pub const GL_LEQUAL                         = 0x0203;
pub const GL_GREATER                        = 0x0204;
pub const GL_NOTEQUAL                       = 0x0205;
pub const GL_GEQUAL                         = 0x0206;
pub const GL_ALWAYS                         = 0x0207;

// BlendingFactorDest
pub const GL_ZERO                           = 0;
pub const GL_ONE                            = 1;
pub const GL_SRC_COLOR                      = 0x0300;
pub const GL_ONE_MINUS_SRC_COLOR            = 0x0301;
pub const GL_SRC_ALPHA                      = 0x0302;
pub const GL_ONE_MINUS_SRC_ALPHA            = 0x0303;
pub const GL_DST_ALPHA                      = 0x0304;
pub const GL_ONE_MINUS_DST_ALPHA            = 0x0305;

// BlendingFactorSrc
pub const GL_DST_COLOR                      = 0x0306;
pub const GL_ONE_MINUS_DST_COLOR            = 0x0307;
pub const GL_SRC_ALPHA_SATURATE             = 0x0308;

// CullFaceMode
pub const GL_FRONT                          = 0x0404;
pub const GL_BACK                           = 0x0405;
pub const GL_FRONT_AND_BACK                 = 0x0408;

// EnableCap
pub const GL_FOG                            = 0x0B60;
pub const GL_LIGHTING                       = 0x0B50;
pub const GL_TEXTURE_2D                     = 0x0DE1;
pub const GL_CULL_FACE                      = 0x0B44;
pub const GL_ALPHA_TEST                     = 0x0BC0;
pub const GL_BLEND                          = 0x0BE2;
pub const GL_COLOR_LOGIC_OP                 = 0x0BF2;
pub const GL_DITHER                         = 0x0BD0;
pub const GL_STENCIL_TEST                   = 0x0B90;
pub const GL_DEPTH_TEST                     = 0x0B71;
pub const GL_POINT_SMOOTH                   = 0x0B10;
pub const GL_LINE_SMOOTH                    = 0x0B20;
pub const GL_SCISSOR_TEST                   = 0x0C11;
pub const GL_COLOR_MATERIAL                 = 0x0B57;
pub const GL_NORMALIZE                      = 0x0BA1;
pub const GL_RESCALE_NORMAL                 = 0x803A;
pub const GL_POLYGON_OFFSET_FILL            = 0x8037;
pub const GL_VERTEX_ARRAY                   = 0x8074;
pub const GL_NORMAL_ARRAY                   = 0x8075;
pub const GL_COLOR_ARRAY                    = 0x8076;
pub const GL_TEXTURE_COORD_ARRAY            = 0x8078;
pub const GL_MULTISAMPLE                    = 0x809D;
pub const GL_SAMPLE_ALPHA_TO_COVERAGE       = 0x809E;
pub const GL_SAMPLE_ALPHA_TO_ONE            = 0x809F;
pub const GL_SAMPLE_COVERAGE                = 0x80A0;

// ErrorCode
pub const GL_NO_ERROR                       = 0;
pub const GL_INVALID_ENUM                   = 0x0500;
pub const GL_INVALID_VALUE                  = 0x0501;
pub const GL_INVALID_OPERATION              = 0x0502;
pub const GL_STACK_OVERFLOW                 = 0x0503;
pub const GL_STACK_UNDERFLOW                = 0x0504;
pub const GL_OUT_OF_MEMORY                  = 0x0505;

// FogMode
pub const GL_EXP                            = 0x0800;
pub const GL_EXP2                           = 0x0801;

// FogParameter
pub const GL_FOG_DENSITY                    = 0x0B62;
pub const GL_FOG_START                      = 0x0B63;
pub const GL_FOG_END                        = 0x0B64;
pub const GL_FOG_MODE                       = 0x0B65;
pub const GL_FOG_COLOR                      = 0x0B66;

// FrontFaceDirection
pub const GL_CW                             = 0x0900;
pub const GL_CCW                            = 0x0901;

// GetPName
pub const GL_SMOOTH_POINT_SIZE_RANGE        = 0x0B12;
pub const GL_SMOOTH_LINE_WIDTH_RANGE        = 0x0B22;
pub const GL_ALIASED_POINT_SIZE_RANGE       = 0x846D;
pub const GL_ALIASED_LINE_WIDTH_RANGE       = 0x846E;
pub const GL_IMPLEMENTATION_COLOR_READ_TYPE_OES = 0x8B9A;
pub const GL_IMPLEMENTATION_COLOR_READ_FORMAT_OES = 0x8B9B;
pub const GL_MAX_LIGHTS                     = 0x0D31;
pub const GL_MAX_TEXTURE_SIZE               = 0x0D33;
pub const GL_MAX_MODELVIEW_STACK_DEPTH      = 0x0D36;
pub const GL_MAX_PROJECTION_STACK_DEPTH     = 0x0D38;
pub const GL_MAX_TEXTURE_STACK_DEPTH        = 0x0D39;
pub const GL_MAX_VIEWPORT_DIMS              = 0x0D3A;
pub const GL_MAX_ELEMENTS_VERTICES          = 0x80E8;
pub const GL_MAX_ELEMENTS_INDICES           = 0x80E9;
pub const GL_MAX_TEXTURE_UNITS              = 0x84E2;
pub const GL_NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2;
pub const GL_COMPRESSED_TEXTURE_FORMATS     = 0x86A3;
pub const GL_SUBPIXEL_BITS                  = 0x0D50;
pub const GL_RED_BITS                       = 0x0D52;
pub const GL_GREEN_BITS                     = 0x0D53;
pub const GL_BLUE_BITS                      = 0x0D54;
pub const GL_ALPHA_BITS                     = 0x0D55;
pub const GL_DEPTH_BITS                     = 0x0D56;
pub const GL_STENCIL_BITS                   = 0x0D57;

// HintMode
pub const GL_DONT_CARE                      = 0x1100;
pub const GL_FASTEST                        = 0x1101;
pub const GL_NICEST                         = 0x1102;

// HintTarget
pub const GL_PERSPECTIVE_CORRECTION_HINT    = 0x0C50;
pub const GL_POINT_SMOOTH_HINT              = 0x0C51;
pub const GL_LINE_SMOOTH_HINT               = 0x0C52;
pub const GL_POLYGON_SMOOTH_HINT            = 0x0C53;
pub const GL_FOG_HINT                       = 0x0C54;

// LightModelParameter
pub const GL_LIGHT_MODEL_AMBIENT            = 0x0B53;
pub const GL_LIGHT_MODEL_TWO_SIDE           = 0x0B52;

// LightParameter
pub const GL_AMBIENT                        = 0x1200;
pub const GL_DIFFUSE                        = 0x1201;
pub const GL_SPECULAR                       = 0x1202;
pub const GL_POSITION                       = 0x1203;
pub const GL_SPOT_DIRECTION                 = 0x1204;
pub const GL_SPOT_EXPONENT                  = 0x1205;
pub const GL_SPOT_CUTOFF                    = 0x1206;
pub const GL_CONSTANT_ATTENUATION           = 0x1207;
pub const GL_LINEAR_ATTENUATION             = 0x1208;
pub const GL_QUADRATIC_ATTENUATION          = 0x1209;

// DataType
pub const GL_BYTE                           = 0x1400;
pub const GL_UNSIGNED_BYTE                  = 0x1401;
pub const GL_SHORT                          = 0x1402;
pub const GL_UNSIGNED_SHORT                 = 0x1403;
pub const GL_FLOAT                          = 0x1406;
pub const GL_FIXED                          = 0x140C;

// LogicOp
pub const GL_CLEAR                          = 0x1500;
pub const GL_AND                            = 0x1501;
pub const GL_AND_REVERSE                    = 0x1502;
pub const GL_COPY                           = 0x1503;
pub const GL_AND_INVERTED                   = 0x1504;
pub const GL_NOOP                           = 0x1505;
pub const GL_XOR                            = 0x1506;
pub const GL_OR                             = 0x1507;
pub const GL_NOR                            = 0x1508;
pub const GL_EQUIV                          = 0x1509;
pub const GL_INVERT                         = 0x150A;
pub const GL_OR_REVERSE                     = 0x150B;
pub const GL_COPY_INVERTED                  = 0x150C;
pub const GL_OR_INVERTED                    = 0x150D;
pub const GL_NAND                           = 0x150E;
pub const GL_SET                            = 0x150F;

// MaterialParameter
pub const GL_EMISSION                       = 0x1600;
pub const GL_SHININESS                      = 0x1601;
pub const GL_AMBIENT_AND_DIFFUSE            = 0x1602;

// MatrixMode
pub const GL_MODELVIEW                      = 0x1700;
pub const GL_PROJECTION                     = 0x1701;
pub const GL_TEXTURE                        = 0x1702;

// PixelFormat
pub const GL_ALPHA                          = 0x1906;
pub const GL_RGB                            = 0x1907;
pub const GL_RGBA                           = 0x1908;
pub const GL_LUMINANCE                      = 0x1909;
pub const GL_LUMINANCE_ALPHA                = 0x190A;

pub const GL_POINT                          = 0x1B00;
pub const GL_LINE                           = 0x1B01;
pub const GL_FILL                           = 0x1B02;

// PixelStoreParameter
pub const GL_UNPACK_ALIGNMENT               = 0x0CF5;
pub const GL_PACK_ALIGNMENT                 = 0x0D05;

// PixelType
pub const GL_UNSIGNED_SHORT_4_4_4_4         = 0x8033;
pub const GL_UNSIGNED_SHORT_5_5_5_1         = 0x8034;
pub const GL_UNSIGNED_SHORT_5_6_5           = 0x8363;

// ShadingModel
pub const GL_FLAT                           = 0x1D00;
pub const GL_SMOOTH                         = 0x1D01;

// StencilOp
pub const GL_KEEP                           = 0x1E00;
pub const GL_REPLACE                        = 0x1E01;
pub const GL_INCR                           = 0x1E02;
pub const GL_DECR                           = 0x1E03;

// StringName
pub const GL_VENDOR                         = 0x1F00;
pub const GL_RENDERER                       = 0x1F01;
pub const GL_VERSION                        = 0x1F02;
pub const GL_EXTENSIONS                     = 0x1F03;

// TextureEnvMode
pub const GL_MODULATE                       = 0x2100;
pub const GL_DECAL                          = 0x2101;
pub const GL_ADD                            = 0x0104;

// TextureEnvParameter
pub const GL_TEXTURE_ENV_MODE               = 0x2200;
pub const GL_TEXTURE_ENV_COLOR              = 0x2201;

// TextureEnvTarget
pub const GL_TEXTURE_ENV                    = 0x2300;

// TextureMagFilter
pub const GL_NEAREST                        = 0x2600;
pub const GL_LINEAR                         = 0x2601;

pub const GL_NEAREST_MIPMAP_NEAREST         = 0x2700;
pub const GL_LINEAR_MIPMAP_NEAREST          = 0x2701;
pub const GL_NEAREST_MIPMAP_LINEAR          = 0x2702;
pub const GL_LINEAR_MIPMAP_LINEAR           = 0x2703;

// TextureParameterName
pub const GL_TEXTURE_MAG_FILTER             = 0x2800;
pub const GL_TEXTURE_MIN_FILTER             = 0x2801;
pub const GL_TEXTURE_WRAP_S                 = 0x2802;
pub const GL_TEXTURE_WRAP_T                 = 0x2803;

// TextureUnit
pub const GL_TEXTURE0                       = 0x84C0;
pub const GL_TEXTURE1                       = 0x84C1;
pub const GL_TEXTURE2                       = 0x84C2;
pub const GL_TEXTURE3                       = 0x84C3;
pub const GL_TEXTURE4                       = 0x84C4;
pub const GL_TEXTURE5                       = 0x84C5;
pub const GL_TEXTURE6                       = 0x84C6;
pub const GL_TEXTURE7                       = 0x84C7;
pub const GL_TEXTURE8                       = 0x84C8;
pub const GL_TEXTURE9                       = 0x84C9;
pub const GL_TEXTURE10                      = 0x84CA;
pub const GL_TEXTURE11                      = 0x84CB;
pub const GL_TEXTURE12                      = 0x84CC;
pub const GL_TEXTURE13                      = 0x84CD;
pub const GL_TEXTURE14                      = 0x84CE;
pub const GL_TEXTURE15                      = 0x84CF;
pub const GL_TEXTURE16                      = 0x84D0;
pub const GL_TEXTURE17                      = 0x84D1;
pub const GL_TEXTURE18                      = 0x84D2;
pub const GL_TEXTURE19                      = 0x84D3;
pub const GL_TEXTURE20                      = 0x84D4;
pub const GL_TEXTURE21                      = 0x84D5;
pub const GL_TEXTURE22                      = 0x84D6;
pub const GL_TEXTURE23                      = 0x84D7;
pub const GL_TEXTURE24                      = 0x84D8;
pub const GL_TEXTURE25                      = 0x84D9;
pub const GL_TEXTURE26                      = 0x84DA;
pub const GL_TEXTURE27                      = 0x84DB;
pub const GL_TEXTURE28                      = 0x84DC;
pub const GL_TEXTURE29                      = 0x84DD;
pub const GL_TEXTURE30                      = 0x84DE;
pub const GL_TEXTURE31                      = 0x84DF;

// TextureWrapMode
pub const GL_REPEAT                         = 0x2901;
pub const GL_CLAMP_TO_EDGE                  = 0x812F;

// PixelInternalFormat
pub const GL_PALETTE4_RGB8_OES              = 0x8B90;
pub const GL_PALETTE4_RGBA8_OES             = 0x8B91;
pub const GL_PALETTE4_R5_G6_B5_OES          = 0x8B92;
pub const GL_PALETTE4_RGBA4_OES             = 0x8B93;
pub const GL_PALETTE4_RGB5_A1_OES           = 0x8B94;
pub const GL_PALETTE8_RGB8_OES              = 0x8B95;
pub const GL_PALETTE8_RGBA8_OES             = 0x8B96;
pub const GL_PALETTE8_R5_G6_B5_OES          = 0x8B97;
pub const GL_PALETTE8_RGBA4_OES             = 0x8B98;
pub const GL_PALETTE8_RGB5_A1_OES           = 0x8B99;

// LightName
pub const GL_LIGHT0                         = 0x4000;
pub const GL_LIGHT1                         = 0x4001;
pub const GL_LIGHT2                         = 0x4002;
pub const GL_LIGHT3                         = 0x4003;
pub const GL_LIGHT4                         = 0x4004;
pub const GL_LIGHT5                         = 0x4005;
pub const GL_LIGHT6                         = 0x4006;
pub const GL_LIGHT7                         = 0x4007;

///////////////////////
// end of gl.h 1.0
///////////////////////

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
