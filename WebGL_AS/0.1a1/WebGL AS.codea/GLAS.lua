-- GLAS ASSource object
GLAS = ASSource('glas', [==[
    // GLAS definitions ==============================================

    namespace _glas_internal {
        declare function getDisplayWidth(): u32;
        declare function getDisplayHeight(): u32;
    }

    @global declare function glas_init(): bool;
    @global declare function glas_setLoopFunction(fn: (dt: f32) => void): void;
    @global function glas_getDisplayResolution(): Vec2i {
        return new Vec2i(_glas_internal.getDisplayWidth(), _glas_internal.getDisplayHeight());
    }


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
    @global declare const GL_DEPTH_BUFFER_BIT: u32;
    @global declare const GL_STENCIL_BUFFER_BIT: u32;

    @global declare const GL_VERTEX_SHADER: u32;
    @global declare const GL_FRAGMENT_SHADER: u32;
    
    @global declare const GL_BLEND: GLenum;
    @global declare const GL_CULL_FACE: GLenum;
    @global declare const GL_DEPTH_TEST: GLenum;
    @global declare const GL_DITHER: GLenum;
    @global declare const GL_POLYGON_OFFSET_FILL: GLenum;
    @global declare const GL_SAMPLE_ALPHA_TO_COVERAGE: GLenum;
    @global declare const GL_SAMPLE_COVERAGE: GLenum;
    @global declare const GL_SCISSOR_TEST: GLenum;
    @global declare const GL_STENCIL_TEST: GLenum;

    
    // WebGL functions ==============================================

    // Viewing & Clipping
    @global declare function glScissor(x: GLint, y: GLint, width: GLsizei, height: GLsizei): void;
    @global declare function glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei): void;

    // State information
    @global declare function glEnable(cap: GLenum): void;
    @global declare function glDisable(cap: GLenum): void;

    @global declare function glClearColor(r: f32, g: f32, b: f32, a: f32): void;
    @global declare function glClear(flags: u32): void;
    @global declare function glCreateShader(type: u32): u64;
    @global declare function glDeleteShader(shader: u64): void;


]==],
{
    -- GLAS functions ===============================
    ["glas_init() : bool"] = [[
        () => {
            // Make body fullscreen & disable scrolling
            document.body.height = '100vh';
            document.body.style.margin = '0px';
            document.body.style.overflow = 'hidden';
        
            // Create GL canvas element
            const canvas = document.createElement("canvas");
            canvas.width = screen.availWidth;
            canvas.height = screen.availHeight;
            document.body.appendChild(canvas);
        
            // Initialize the GL context
            const gl = canvas.getContext("webgl"); // TODO: investigate using webgl2 if supported on the device
                    
            // Only continue if WebGL is available and working
            if (gl === null) {
                console.warning("[GLAS] Unable to initialize WebGL. Your browser or machine may not support it.");
                return false;
            }
        
            // Add 'gl' object as a const global
            Object.defineProperty(window, 'gl', {
                value: gl,
                configurable: false,
                writable: false
            });
    
            // Initialise object tracking arrays.
            // This uses generation tracking to ensure
            // old objects are not accidentally accessed.
            //
            // Each object ID is a 64 bit integer with the
            // upper 24 bits reserved for the generation ID.s
            let objects = [];
            let freeObjects = [];
            gl.__getObject = function(id) {
                let idx = id & 0xFFFFFFFFFFn;
                let gen = id & (0xFFFFFFn << 40n);
                let objw = objects[idx]; // get the wrapper
                if (objw === undefined || objw.gen != gen)
                {
                    throw new Error("[GL] Object does not exist!");
                }
                return objw.obj;
            }
            gl.__track = function(obj) {
                let id;
                if (freeObjects.length > 0) {
                    // Reusing an ID
                    id = freeObjects.pop();
                    let idx = id & 0xFFFFFFFFFFn;
                    objects[idx].obj = obj;
                    id += (0x000001n << 40n)
                } else {
                    id = BigInt(objects.push({
                        gen: 0,
                        obj: obj
                    }) - 1);
                }
                return id;
            };
            gl.__release = function(id) {
                let idx = id & 0xFFFFFFFFFFn;
                let gen = id & (0xFFFFFFn << 40n);
    
                let objw = objects[idx]; // get the wrapper
                if (objw === undefined)
                {
                    throw new Error("[GL] Object does not exist!");
                }
                if (objw.gen != gen)
                {
                    throw new Error("[GL] Double free!");
                }
                
                objects[idx].gen = (++objects[idx].gen & 0xFFFFFF); // Increment generation
                freeObjects.push(id);
            };
                    
            // Clear to black
            gl.clearColor(0.0, 0.0, 0.0, 1.0);
            gl.clear(gl.COLOR_BUFFER_BIT);
        
            console.log("[GLAS] Initialised");
        
            return true;
        }
    ]],
    
    ["glas_setLoopFunction(fn: function) : void"] = [[
        (fn) => {
            function loop(now) {
        
                // Calculate delta time
                now *= 0.001;
                if (loop.lastTimestamp === undefined) {
                    loop.lastTimestamp = now;
                }
                let delta = now - loop.lastTimestamp;
                loop.lastTimestamp = now;
                
                // Call the provided loop function
                fn(delta);
        
                // Repeat
                window.requestAnimationFrame(loop);
            };
            window.requestAnimationFrame(loop);
        }
    ]],
    
    ["_glas_internal.getDisplayWidth(): u32"] = [[
        () => screen.availWidth
    ]],
    ["_glas_internal.getDisplayHeight(): u32"] = [[
        () => screen.availHeight
    ]],
    
    
    -- WebGL constants ===============================
    -- Capabilities
    ["GL_BLEND"] = "WebGLRenderingContext.BLEND",
    ["GL_CULL_FACE"] = "WebGLRenderingContext.CULL_FACE",
    ["GL_DEPTH_TEST"] = "WebGLRenderingContext.DEPTH_TEST",
    ["GL_DITHER"] = "WebGLRenderingContext.DITHER",
    ["GL_POLYGON_OFFSET_FILL"] = "WebGLRenderingContext.POLYGON_OFFSET_FILL",
    ["GL_SAMPLE_ALPHA_TO_COVERAGE"] = "WebGLRenderingContext.SAMPLE_ALPHA_TO_COVERAGE",
    ["GL_SAMPLE_COVERAGE"] = "WebGLRenderingContext.SAMPLE_COVERAGE",
    ["GL_SCISSOR_TEST"] = "WebGLRenderingContext.SCISSOR_TEST",
    ["GL_STENCIL_TEST"] = "WebGLRenderingContext.STENCIL_TEST",
    ["GL_RASTERIZER_DISCARD"] = "WebGLRenderingContext.RASTERIZER_DISCARD",
    
    ["GL_COLOR_BUFFER_BIT"] = "WebGLRenderingContext.COLOR_BUFFER_BIT",
    ["GL_DEPTH_BUFFER_BIT"] = "WebGLRenderingContext.DEPTH_BUFFER_BIT",
    ["GL_STENCIL_BUFFER_BIT"] = "WebGLRenderingContext.STENCIL_BUFFER_BIT",
    ["GL_VERTEX_SHADER"] = "WebGLRenderingContext.VERTEX_SHADER",
    ["GL_FRAGMENT_SHADER"] = "WebGLRenderingContext.FRAGMENT_SHADER",
    
    
    -- WebGL functions ===============================
    -- Viewing & Clipping
    ["glScissor"] = [[
        (x, y, w, h) => {
            gl.scissor(x, y, w, h);
        }
    ]],
    ["glViewport"] = [[
        (x, y, w, h) => {
            gl.viewport(x, y, w, h);
        }
    ]],
    
    -- State information
    ["glEnable"] = [[
        (cap) => {
            gl.enable(cap);
        }
    ]],
    ["glDisable"] = [[
        (cap) => {
            gl.disable(cap);
        }
    ]],
    
    ["glClearColor"] = [[
        (r, g, b, a) => {
            gl.clearColor(r, g, b, a);
        }
    ]],
    
    ["glClear"] = [[
        (mask) => {
            gl.clear(mask);
        }
    ]],
    
    ["glCreateShader(type: u32): u64"] = [[
        (type) => {
            return gl.__track(gl.createShader(type));
        }
    ]],
    
    ["glDeleteShader(shader: u64)"] = [[
        (shader) => {
            gl.deleteShader(gl.__getObject(shader));
            gl.__release(shader);
        }
    ]]
}, {
    GLAS_UTIL
})
