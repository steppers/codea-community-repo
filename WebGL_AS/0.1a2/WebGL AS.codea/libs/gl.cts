// WebGL types ==================================================
// (INTERNAL ONLY)

type GLenum = u32;
type GLboolean = bool;
type GLbitfield = u32;
type GLbyte = i8;
type GLshort = i16;
type GLint = i32;
type GLsizei = i32;
type GLintptr = i64;
type GLsizeiptr = i64;
type GLubyte = u8;
type GLushort = u16;
type GLuint = u32;
type GLfloat = f32;
type GLclampf = f32; // Not sure about this?


// WebGL constants ==============================================

@global declare const GL_COLOR_BUFFER_BIT: u32;
@js_import GL_COLOR_BUFFER_BIT = WebGLRenderingContext.COLOR_BUFFER_BIT @js_end

@global declare const GL_DEPTH_BUFFER_BIT: u32;
@js_import GL_DEPTH_BUFFER_BIT = WebGLRenderingContext.DEPTH_BUFFER_BIT @js_end

@global declare const GL_STENCIL_BUFFER_BIT: u32;
@js_import GL_STENCIL_BUFFER_BIT = WebGLRenderingContext.STENCIL_BUFFER_BIT @js_end



@global declare const GL_VERTEX_SHADER: u32;
@js_import GL_VERTEX_SHADER = WebGLRenderingContext.VERTEX_SHADER @js_end

@global declare const GL_FRAGMENT_SHADER: u32;
@js_import GL_FRAGMENT_SHADER = WebGLRenderingContext.FRAGMENT_SHADER @js_end



@global declare const GL_BLEND: GLenum;
@js_import GL_BLEND = WebGLRenderingContext.BLEND @js_end

@global declare const GL_CULL_FACE: GLenum;
@js_import GL_CULL_FACE = WebGLRenderingContext.CULL_FACE @js_end

@global declare const GL_DEPTH_TEST: GLenum;
@js_import GL_DEPTH_TEST = WebGLRenderingContext.DEPTH_TEST @js_end

@global declare const GL_DITHER: GLenum;
@js_import GL_DITHER = WebGLRenderingContext.DITHER @js_end

@global declare const GL_POLYGON_OFFSET_FILL: GLenum;
@js_import GL_POLYGON_OFFSET_FILL = WebGLRenderingContext.POLYGON_OFFSET_FILL @js_end

@global declare const GL_SAMPLE_ALPHA_TO_COVERAGE: GLenum;
@js_import GL_SAMPLE_ALPHA_TO_COVERAGE = WebGLRenderingContext.SAMPLE_ALPHA_TO_COVERAGE @js_end

@global declare const GL_SAMPLE_COVERAGE: GLenum;
@js_import GL_SAMPLE_COVERAGE = WebGLRenderingContext.SAMPLE_COVERAGE @js_end

@global declare const GL_SCISSOR_TEST: GLenum;
@js_import GL_SCISSOR_TEST = WebGLRenderingContext.SCISSOR_TEST @js_end

@global declare const GL_STENCIL_TEST: GLenum;
@js_import GL_STENCIL_TEST = WebGLRenderingContext.STENCIL_TEST @js_end





// WebGL functions ==============================================

// Viewing & Clipping
@global declare function glScissor(x: GLint, y: GLint, width: GLsizei, height: GLsizei): void;
@global declare function glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei): void;



// State information
@global declare function glActiveTexture(texture: GLenum): void;
@global declare function glBlendColor(r: f32, g: f32, b: f32, a: f32): void;
@global declare function glBlendEquation(mode: GLenum): void;
@global declare function glBlendEquationSeparate(modeRGB: GLenum, modeAlpha: GLenum): void;
@global declare function glBlendFunc(sfactor: GLenum, dfactor: GLenum): void;
@global declare function glBlendFuncSeparate(srcRGB: GLenum, dstRGB: GLenum, srcAlpha: GLenum, dstAlpha: GLenum): void;
@global declare function glClearColor(r: f32, g: f32, b: f32, a: f32): void;
@global declare function glClearDepth(depth: GLclampf): void;
@global declare function glClearStencil(s: GLint): void;
@global declare function glColorMask(r: GLboolean, g: GLboolean, b: GLboolean, a: GLboolean): void;
@global declare function glCullFace(mode: GLenum): void;
@global declare function glDepthFunc(func: GLenum): void;
@global declare function glDepthMask(flag: GLboolean): void;
@global declare function glDepthRange(zNear: GLclampf, zFar: GLclampf): void;
@global declare function glDisable(cap: GLenum): void;
@global declare function glEnable(cap: GLenum): void;
@global declare function glFrontFace(mode: GLenum): void;
// TODO: These need some more thought
// @global declare function glGetBooleanv(pname: GLenum): Array<GLboolean>;
// @global declare function glGetFloatv(pname: GLenum): Array<GLfloat>;
// @global declare function glGetIntegerv(pname: GLenum): Array<GLint>;
// @global declare function glGetBooleani_v(pname: GLenum, index: GLuint): Array<GLboolean>;
// @global declare function glGetFloati_v(pname: GLenum, index: GLuint): Array<GLfloat>;
// @global declare function glGetIntegeri_v(pname: GLenum, index: GLuint): Array<GLint>;
@global declare function glGetError(): GLenum;
@global declare function glHint(target: GLenum, mode: GLenum): void;
@global declare function glIsEnabled(cap: GLenum): void;
@global declare function glLineWidth(width: Glfloat): void;
@global declare function glPixelStorei(pname: GLenum, param: GLint): void;
@global declare function glPolygonOffset(factor: GLfloat, units: GLfloat): void;
@global declare function glSampleCoverage(value: GLclampf, invert: GLboolean): void;
@global declare function glStencilFunc(func: GLenum, ref: GLint, mask: GLuint): void;
@global declare function glStencilFuncSeparate(face: GLenum, func: GLenum, ref: GLint, mask: GLuint): void;
@global declare function glStencilMask(mask: GLuint): void;
@global declare function glStencilMaskSeparate(face: GLenum, mask: GLuint): void;
@global declare function glStencilOp(fail: GLenum, zfail: GLenum, zpass: GLenum): void;
@global declare function glStencilOpSeparate(face: GLenum, fail: GLenum, zfail: GLenum, zpass: GLenum): void;



// Buffers
@global declare function glBindBuffer(target: GLenum, buffer: u64): void;
@global declare function glBufferData(target: GLenum, size: GLsizeiptr, usage: GLenum): void;



@global declare function glClear(flags: u32): void;

@global declare function glCreateShader(type: u32): u64;
@global declare function glDeleteShader(shader: u64): void;





// Function implementations

// Viewing and clipping
@js_import glScissor = (...args) => gl.scissor(...args) @js_end
@js_import glViewport = (...args) => gl.viewport(...args) @js_end



// State information
@js_import glActiveTexture = (...args) => gl.activeTexture(...args) @js_end
@js_import glBlendColor = (...args) => gl.blendColor(...args) @js_end
@js_import glBlendEquation = (...args) => gl.blendEquation(...args) @js_end
@js_import glBlendEquationSeparate = (...args) => gl.blendEquationSeparate(...args) @js_end
@js_import glBlendFunc = (...args) => gl.blendFunc(...args) @js_end
@js_import glBlendFuncSeparate = (...args) => gl.blendFuncSeparate(...args) @js_end
@js_import glClearColor = (...args) => gl.clearColor(...args) @js_end
@js_import glClearDepth = (...args) => gl.clearDepth(...args) @js_end
@js_import glClearStencil = (...args) => gl.clearStencil(...args) @js_end
@js_import glColorMask = (...args) => gl.colorMask(...args) @js_end
@js_import glCullFace = (...args) => gl.cullFace(...args) @js_end
@js_import glDepthFunc = (...args) => gl.depthFunc(...args) @js_end
@js_import glDepthMask = (...args) => gl.depthMask(...args) @js_end
@js_import glDepthRange = (...args) => gl.depthRange(...args) @js_end
@js_import glDisable = (...args) => gl.disable(...args) @js_end
@js_import glEnable = (...args) => gl.enable(...args) @js_end
@js_import glFrontFace = (...args) => gl.frontFace(...args) @js_end
// TODO: These need some more thought
// @js_import glGetBooleanv = (...args) => gl.getParameter(...args) @js_end
// @js_import glGetFloatv = (...args) => gl.getParameter(...args) @js_end
// @js_import glGetIntegerv = (...args) => gl.getParameter(...args) @js_end
// @js_import glGetBooleani_v = (pname, index) => gl.getParameter(pname)[index] @js_end
// @js_import glGetFloati_v = (pname, index) => gl.getParameter(pname)[index] @js_end
// @js_import glGetIntegeri_v = (pname, index) => gl.getParameter(pname)[index] @js_end
@js_import glGetError = () => gl.getError() @js_end
@js_import glHint = (...args) => gl.hint(...args) @js_end
@js_import glIsEnabled = (...args) => gl.isEnabled(...args) @js_end
@js_import glLineWidth = (...args) => gl.lineWidth(...args) @js_end
@js_import glPixelStorei = (...args) => gl.pixelStorei(...args) @js_end
@js_import glPolygonOffset = (...args) => gl.polygonOffset(...args) @js_end
@js_import glSampleCoverage = (...args) => gl.sampleCoverage(...args) @js_end
@js_import glStencilFunc = (...args) => gl.stencilFunc(...args) @js_end
@js_import glStencilFuncSeparate = (...args) => gl.stencilFuncSeparate(...args) @js_end
@js_import glStencilMask = (...args) => gl.stencilMask(...args) @js_end
@js_import glStencilMaskSeparate = (...args) => gl.stencilMaskSeparate(...args) @js_end
@js_import glStencilOp = (...args) => gl.stencilOp(...args) @js_end
@js_import glStencilOpSeparate = (...args) => gl.stencilOpSeparate(...args) @js_end



// Buffers
@js_import glBindBuffer = (target, buffer) => gl.bindBuffer(target, gl.__getObject(buffer)) @js_end



@js_import glClear = (...args) => gl.clear(...args) @js_end

@js_import glCreateShader = (...args) => gl.__track(gl.createShader(...args)) @js_end
@js_import glDeleteShader = (shader) => {
    gl.deleteShader(gl.__getObject(shader));
    gl.__release(shader);
} @js_end