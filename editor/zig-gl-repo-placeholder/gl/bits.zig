///////////////////////
// gl.h 1.0
///////////////////////

//
// OpenGL defines many type aliases.  For those that are only defined because they require
// exact bitdepth, no alias is needed for the Zig bindings (because in Zig you can specify
// the exact bitdepth of a type). Others are defined for documentation purposes (i.e.
// GLclampf is a 32-bit float between 0 and 1), for these we also use an alias.
//
// The following table shows the OpenGL type and its equivalent Zig type
// ---------------------------------------------------------------------------------------------------------------------------------
// GLvoid     | void
// GLbyte     | i8
// GLubyte    | u8
// GLshort    | i16
// GLushort   | u16
// GLint      | i32
// GLuint     | u32
// GLfloat    | f32
// GLdouble   | f64
// GLsizeiptr | usize (for memory offsets and ranges)
// GLsizei    | u32 (Should we make a Size alias for this for documentation?)
// GLboolean  | glindex.bits.Boolean (just a u8 but Boolean documents the value is a bool)
// GLchar     | glindex.bits.Char (just a u8 but Char documents the value is a char)
// GLenum     | glindex.bits.Enum (just a u32 but Enum documents the value is an enumeration)
// GLbitfield | glindex.bits.Bitfield (just a u32 but Bitfield documents the value is a bitfield)
// GLclampf   | glindex.bits.Clamp32 (just an f32 but Clamp32 documents the value is between 0 and 1 inclusive)
// GLclampd   | glindex.bits.Clamp64 (just an f64 but Clamp64 documents the value is between 0 and 1 inclusive)

pub const Boolean  = u8;  // equivalent to GLboolean
pub const Char     = u8;  // equivalent to GLchar
pub const Enum     = u32; // equivalent to GLenum
pub const Bitfield = u32; // equivalent to GLbitfield
pub const Clamp32  = f32; // equivalent to GLclampf: a 32-bit float between 0 and 1 (inclusive)
pub const Clamp64  = f64; // equivalent to GLclampd: a 64-bit float between 0 and 1 (inclusive)

// Extensions
pub const OES_VERSION_1_0                = 1;
pub const OES_read_format                = 1;
pub const OES_compressed_paletted_texture = 1;

// ClearBufferMask
pub const DEPTH_BUFFER_BIT               = 0x00000100;
pub const STENCIL_BUFFER_BIT             = 0x00000400;
pub const COLOR_BUFFER_BIT               = 0x00004000;

// Boolean
pub const FALSE                          = 0;
pub const TRUE                           = 1;

// BeginMode
pub const POINTS                         = 0x0000;
pub const LINES                          = 0x0001;
pub const LINE_LOOP                      = 0x0002;
pub const LINE_STRIP                     = 0x0003;
pub const TRIANGLES                      = 0x0004;
pub const TRIANGLE_STRIP                 = 0x0005;
pub const TRIANGLE_FAN                   = 0x0006;

// AlphaFunction
pub const NEVER                          = 0x0200;
pub const LESS                           = 0x0201;
pub const EQUAL                          = 0x0202;
pub const LEQUAL                         = 0x0203;
pub const GREATER                        = 0x0204;
pub const NOTEQUAL                       = 0x0205;
pub const GEQUAL                         = 0x0206;
pub const ALWAYS                         = 0x0207;

// BlendingFactorDest
pub const ZERO                           = 0;
pub const ONE                            = 1;
pub const SRC_COLOR                      = 0x0300;
pub const ONE_MINUS_SRC_COLOR            = 0x0301;
pub const SRC_ALPHA                      = 0x0302;
pub const ONE_MINUS_SRC_ALPHA            = 0x0303;
pub const DST_ALPHA                      = 0x0304;
pub const ONE_MINUS_DST_ALPHA            = 0x0305;

// BlendingFactorSrc
pub const DST_COLOR                      = 0x0306;
pub const ONE_MINUS_DST_COLOR            = 0x0307;
pub const SRC_ALPHA_SATURATE             = 0x0308;

// CullFaceMode
pub const FRONT                          = 0x0404;
pub const BACK                           = 0x0405;
pub const FRONT_AND_BACK                 = 0x0408;

// EnableCap
pub const FOG                            = 0x0B60;
pub const LIGHTING                       = 0x0B50;
pub const TEXTURE_2D                     = 0x0DE1;
pub const CULL_FACE                      = 0x0B44;
pub const ALPHA_TEST                     = 0x0BC0;
pub const BLEND                          = 0x0BE2;
pub const COLOR_LOGIC_OP                 = 0x0BF2;
pub const DITHER                         = 0x0BD0;
pub const STENCIL_TEST                   = 0x0B90;
pub const DEPTH_TEST                     = 0x0B71;
pub const POINT_SMOOTH                   = 0x0B10;
pub const LINE_SMOOTH                    = 0x0B20;
pub const SCISSOR_TEST                   = 0x0C11;
pub const COLOR_MATERIAL                 = 0x0B57;
pub const NORMALIZE                      = 0x0BA1;
pub const RESCALE_NORMAL                 = 0x803A;
pub const POLYGON_OFFSET_FILL            = 0x8037;
pub const VERTEX_ARRAY                   = 0x8074;
pub const NORMAL_ARRAY                   = 0x8075;
pub const COLOR_ARRAY                    = 0x8076;
pub const TEXTURE_COORD_ARRAY            = 0x8078;
pub const MULTISAMPLE                    = 0x809D;
pub const SAMPLE_ALPHA_TO_COVERAGE       = 0x809E;
pub const SAMPLE_ALPHA_TO_ONE            = 0x809F;
pub const SAMPLE_COVERAGE                = 0x80A0;

// ErrorCode
pub const NO_ERROR                       = 0;
pub const INVALID_ENUM                   = 0x0500;
pub const INVALID_VALUE                  = 0x0501;
pub const INVALID_OPERATION              = 0x0502;
pub const STACK_OVERFLOW                 = 0x0503;
pub const STACK_UNDERFLOW                = 0x0504;
pub const OUT_OF_MEMORY                  = 0x0505;

// FogMode
pub const EXP                            = 0x0800;
pub const EXP2                           = 0x0801;

// FogParameter
pub const FOG_DENSITY                    = 0x0B62;
pub const FOG_START                      = 0x0B63;
pub const FOG_END                        = 0x0B64;
pub const FOG_MODE                       = 0x0B65;
pub const FOG_COLOR                      = 0x0B66;

// FrontFaceDirection
pub const CW                             = 0x0900;
pub const CCW                            = 0x0901;

// GetPName
pub const SMOOTH_POINT_SIZE_RANGE        = 0x0B12;
pub const SMOOTH_LINE_WIDTH_RANGE        = 0x0B22;
pub const ALIASED_POINT_SIZE_RANGE       = 0x846D;
pub const ALIASED_LINE_WIDTH_RANGE       = 0x846E;
pub const IMPLEMENTATION_COLOR_READ_TYPE_OES = 0x8B9A;
pub const IMPLEMENTATION_COLOR_READ_FORMAT_OES = 0x8B9B;
pub const MAX_LIGHTS                     = 0x0D31;
pub const MAX_TEXTURE_SIZE               = 0x0D33;
pub const MAX_MODELVIEW_STACK_DEPTH      = 0x0D36;
pub const MAX_PROJECTION_STACK_DEPTH     = 0x0D38;
pub const MAX_TEXTURE_STACK_DEPTH        = 0x0D39;
pub const MAX_VIEWPORT_DIMS              = 0x0D3A;
pub const MAX_ELEMENTS_VERTICES          = 0x80E8;
pub const MAX_ELEMENTS_INDICES           = 0x80E9;
pub const MAX_TEXTURE_UNITS              = 0x84E2;
pub const NUM_COMPRESSED_TEXTURE_FORMATS = 0x86A2;
pub const COMPRESSED_TEXTURE_FORMATS     = 0x86A3;
pub const SUBPIXEL_BITS                  = 0x0D50;
pub const RED_BITS                       = 0x0D52;
pub const GREEN_BITS                     = 0x0D53;
pub const BLUE_BITS                      = 0x0D54;
pub const ALPHA_BITS                     = 0x0D55;
pub const DEPTH_BITS                     = 0x0D56;
pub const STENCIL_BITS                   = 0x0D57;

// HintMode
pub const DONT_CARE                      = 0x1100;
pub const FASTEST                        = 0x1101;
pub const NICEST                         = 0x1102;

// HintTarget
pub const PERSPECTIVE_CORRECTION_HINT    = 0x0C50;
pub const POINT_SMOOTH_HINT              = 0x0C51;
pub const LINE_SMOOTH_HINT               = 0x0C52;
pub const POLYGON_SMOOTH_HINT            = 0x0C53;
pub const FOG_HINT                       = 0x0C54;

// LightModelParameter
pub const LIGHT_MODEL_AMBIENT            = 0x0B53;
pub const LIGHT_MODEL_TWO_SIDE           = 0x0B52;

// LightParameter
pub const AMBIENT                        = 0x1200;
pub const DIFFUSE                        = 0x1201;
pub const SPECULAR                       = 0x1202;
pub const POSITION                       = 0x1203;
pub const SPOT_DIRECTION                 = 0x1204;
pub const SPOT_EXPONENT                  = 0x1205;
pub const SPOT_CUTOFF                    = 0x1206;
pub const CONSTANT_ATTENUATION           = 0x1207;
pub const LINEAR_ATTENUATION             = 0x1208;
pub const QUADRATIC_ATTENUATION          = 0x1209;

// DataType
pub const BYTE                           = 0x1400;
pub const UNSIGNED_BYTE                  = 0x1401;
pub const SHORT                          = 0x1402;
pub const UNSIGNED_SHORT                 = 0x1403;
pub const INT                            = 0x1404;
pub const UNSIGNED_INT                   = 0x1405;
pub const FLOAT                          = 0x1406;
pub const FIXED                          = 0x140C;

// LogicOp
pub const CLEAR                          = 0x1500;
pub const AND                            = 0x1501;
pub const AND_REVERSE                    = 0x1502;
pub const COPY                           = 0x1503;
pub const AND_INVERTED                   = 0x1504;
pub const NOOP                           = 0x1505;
pub const XOR                            = 0x1506;
pub const OR                             = 0x1507;
pub const NOR                            = 0x1508;
pub const EQUIV                          = 0x1509;
pub const INVERT                         = 0x150A;
pub const OR_REVERSE                     = 0x150B;
pub const COPY_INVERTED                  = 0x150C;
pub const OR_INVERTED                    = 0x150D;
pub const NAND                           = 0x150E;
pub const SET                            = 0x150F;

// MaterialParameter
pub const EMISSION                       = 0x1600;
pub const SHININESS                      = 0x1601;
pub const AMBIENT_AND_DIFFUSE            = 0x1602;

// MatrixMode
pub const MODELVIEW                      = 0x1700;
pub const PROJECTION                     = 0x1701;
pub const TEXTURE                        = 0x1702;

// PixelFormat
pub const ALPHA                          = 0x1906;
pub const RGB                            = 0x1907;
pub const RGBA                           = 0x1908;
pub const LUMINANCE                      = 0x1909;
pub const LUMINANCE_ALPHA                = 0x190A;

pub const POINT                          = 0x1B00;
pub const LINE                           = 0x1B01;
pub const FILL                           = 0x1B02;

// PixelStoreParameter
pub const UNPACK_ALIGNMENT               = 0x0CF5;
pub const PACK_ALIGNMENT                 = 0x0D05;

// PixelType
pub const UNSIGNED_SHORT_4_4_4_4         = 0x8033;
pub const UNSIGNED_SHORT_5_5_5_1         = 0x8034;
pub const UNSIGNED_SHORT_5_6_5           = 0x8363;

// ShadingModel
pub const FLAT                           = 0x1D00;
pub const SMOOTH                         = 0x1D01;

// StencilOp
pub const KEEP                           = 0x1E00;
pub const REPLACE                        = 0x1E01;
pub const INCR                           = 0x1E02;
pub const DECR                           = 0x1E03;

// StringName
pub const VENDOR                         = 0x1F00;
pub const RENDERER                       = 0x1F01;
pub const VERSION                        = 0x1F02;
pub const EXTENSIONS                     = 0x1F03;

// TextureEnvMode
pub const MODULATE                       = 0x2100;
pub const DECAL                          = 0x2101;
pub const ADD                            = 0x0104;

// TextureEnvParameter
pub const TEXTURE_ENV_MODE               = 0x2200;
pub const TEXTURE_ENV_COLOR              = 0x2201;

// TextureEnvTarget
pub const TEXTURE_ENV                    = 0x2300;

// TextureMagFilter
pub const NEAREST                        = 0x2600;
pub const LINEAR                         = 0x2601;

pub const NEAREST_MIPMAP_NEAREST         = 0x2700;
pub const LINEAR_MIPMAP_NEAREST          = 0x2701;
pub const NEAREST_MIPMAP_LINEAR          = 0x2702;
pub const LINEAR_MIPMAP_LINEAR           = 0x2703;

// TextureParameterName
pub const TEXTURE_MAG_FILTER             = 0x2800;
pub const TEXTURE_MIN_FILTER             = 0x2801;
pub const TEXTURE_WRAP_S                 = 0x2802;
pub const TEXTURE_WRAP_T                 = 0x2803;

// TextureUnit
pub const TEXTURE0                       = 0x84C0;
pub const TEXTURE1                       = 0x84C1;
pub const TEXTURE2                       = 0x84C2;
pub const TEXTURE3                       = 0x84C3;
pub const TEXTURE4                       = 0x84C4;
pub const TEXTURE5                       = 0x84C5;
pub const TEXTURE6                       = 0x84C6;
pub const TEXTURE7                       = 0x84C7;
pub const TEXTURE8                       = 0x84C8;
pub const TEXTURE9                       = 0x84C9;
pub const TEXTURE10                      = 0x84CA;
pub const TEXTURE11                      = 0x84CB;
pub const TEXTURE12                      = 0x84CC;
pub const TEXTURE13                      = 0x84CD;
pub const TEXTURE14                      = 0x84CE;
pub const TEXTURE15                      = 0x84CF;
pub const TEXTURE16                      = 0x84D0;
pub const TEXTURE17                      = 0x84D1;
pub const TEXTURE18                      = 0x84D2;
pub const TEXTURE19                      = 0x84D3;
pub const TEXTURE20                      = 0x84D4;
pub const TEXTURE21                      = 0x84D5;
pub const TEXTURE22                      = 0x84D6;
pub const TEXTURE23                      = 0x84D7;
pub const TEXTURE24                      = 0x84D8;
pub const TEXTURE25                      = 0x84D9;
pub const TEXTURE26                      = 0x84DA;
pub const TEXTURE27                      = 0x84DB;
pub const TEXTURE28                      = 0x84DC;
pub const TEXTURE29                      = 0x84DD;
pub const TEXTURE30                      = 0x84DE;
pub const TEXTURE31                      = 0x84DF;

// TextureWrapMode
pub const REPEAT                         = 0x2901;
pub const CLAMP_TO_EDGE                  = 0x812F;

// PixelInternalFormat
pub const PALETTE4_RGB8_OES              = 0x8B90;
pub const PALETTE4_RGBA8_OES             = 0x8B91;
pub const PALETTE4_R5_G6_B5_OES          = 0x8B92;
pub const PALETTE4_RGBA4_OES             = 0x8B93;
pub const PALETTE4_RGB5_A1_OES           = 0x8B94;
pub const PALETTE8_RGB8_OES              = 0x8B95;
pub const PALETTE8_RGBA8_OES             = 0x8B96;
pub const PALETTE8_R5_G6_B5_OES          = 0x8B97;
pub const PALETTE8_RGBA4_OES             = 0x8B98;
pub const PALETTE8_RGB5_A1_OES           = 0x8B99;

// LightName
pub const LIGHT0                         = 0x4000;
pub const LIGHT1                         = 0x4001;
pub const LIGHT2                         = 0x4002;
pub const LIGHT3                         = 0x4003;
pub const LIGHT4                         = 0x4004;
pub const LIGHT5                         = 0x4005;
pub const LIGHT6                         = 0x4006;
pub const LIGHT7                         = 0x4007;

///////////////////////
// end of gl.h 1.0
///////////////////////

pub const BUFFER_SIZE                    = 0x8764;
pub const BUFFER_USAGE                   = 0x8765;
pub const QUERY_COUNTER_BITS             = 0x8864;
pub const CURRENT_QUERY                  = 0x8865;
pub const QUERY_RESULT                   = 0x8866;
pub const QUERY_RESULT_AVAILABLE         = 0x8867;
pub const ARRAY_BUFFER                   = 0x8892;
pub const ELEMENT_ARRAY_BUFFER           = 0x8893;
pub const ARRAY_BUFFER_BINDING           = 0x8894;
pub const ELEMENT_ARRAY_BUFFER_BINDING   = 0x8895;
pub const VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = 0x889F;
pub const READ_ONLY                      = 0x88B8;
pub const WRITE_ONLY                     = 0x88B9;
pub const READ_WRITE                     = 0x88BA;
pub const BUFFER_ACCESS                  = 0x88BB;
pub const BUFFER_MAPPED                  = 0x88BC;
pub const BUFFER_MAP_POINTER             = 0x88BD;
pub const STREAM_DRAW                    = 0x88E0;
pub const STREAM_READ                    = 0x88E1;
pub const STREAM_COPY                    = 0x88E2;
pub const STATIC_DRAW                    = 0x88E4;
pub const STATIC_READ                    = 0x88E5;
pub const STATIC_COPY                    = 0x88E6;
pub const DYNAMIC_DRAW                   = 0x88E8;
pub const DYNAMIC_READ                   = 0x88E9;
pub const DYNAMIC_COPY                   = 0x88EA;
pub const SAMPLES_PASSED                 = 0x8914;
pub const SRC1_ALPHA                     = 0x8589;
pub const VERTEX_ARRAY_BUFFER_BINDING    = 0x8896;
pub const NORMAL_ARRAY_BUFFER_BINDING    = 0x8897;
pub const COLOR_ARRAY_BUFFER_BINDING     = 0x8898;
pub const INDEX_ARRAY_BUFFER_BINDING     = 0x8899;



pub const FRAGMENT_SHADER = 0x8B30;
pub const VERTEX_SHADER = 0x8B31;
pub const DELETE_STATUS = 0x8B80;
pub const COMPILE_STATUS = 0x8B81;
pub const LINK_STATUS = 0x8B82;
pub const INFO_LOG_LENGTH = 0x8B84;
