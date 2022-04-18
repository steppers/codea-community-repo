async function __AssemblyScriptInstantiate(e,t={}){const n={glas:{init:()=>{{let e=document.createElement("meta");e.name="viewport",e.content="initial-scale=1, viewport-fit=cover",document.head.append(e)}document.body.height="100vh",document.body.style.margin=0,document.body.style.overflow="hidden";const e=document.createElement("canvas");e.width=screen.availWidth,e.height=screen.availHeight,document.body.appendChild(e);const t=e.getContext("webgl");if(null===t)return console.warning("[GLAS] Unable to initialize WebGL. Your browser or device may not support it."),!1;Object.defineProperty(window,"gl",{value:t,configurable:!1,writable:!1});let n=[],l=[];return t.__getObject=function(e){let t=e&0xFFFFFFn<<40n,l=n[0xFFFFFFFFFFn&e];if(void 0===l||l.gen!=t)throw new Error("[GL] Object does not exist!");return l.obj},t.__track=function(e){let t;if(l.length>0){t=l.pop(),n[0xFFFFFFFFFFn&t].obj=e,t+=0x000001n<<40n}else t=BigInt(n.push({gen:0,obj:e})-1);return t},t.__release=function(e){let t=0xFFFFFFFFFFn&e,r=e&0xFFFFFFn<<40n,i=n[t];if(void 0===i)throw new Error("[GL] Object does not exist!");if(i.gen!=r)throw new Error("[GL] Double free!");n[t].gen=16777215&++n[t].gen,l.push(e)},t.clearColor(0,0,0,1),t.clear(t.COLOR_BUFFER_BIT),console.log("[GLAS] Initialised"),!0},setLoopFunction:e=>{e=__liftFunction(e),window.requestAnimationFrame((function t(n){n*=.001,void 0===t.lastTimestamp&&(t.lastTimestamp=n);let l=n-t.lastTimestamp;t.lastTimestamp=n,e(l),window.requestAnimationFrame(t)}))}},getDisplayWidth:()=>screen.availWidth,getDisplayHeight:()=>screen.availHeight},l={glGetBooleanv:(...e)=>gl.getParameter(...e),glCullFace:(...e)=>gl.cullFace(...e),glClearColor:(...e)=>gl.clearColor(...e),glClearStencil:(...e)=>gl.clearStencil(...e),glDepthMask:(...e)=>gl.depthMask(...e),GL_SCISSOR_TEST:WebGLRenderingContext.SCISSOR_TEST,GL_STENCIL_TEST:WebGLRenderingContext.STENCIL_TEST,glSampleCoverage:(...e)=>gl.sampleCoverage(...e),GL_DEPTH_TEST:WebGLRenderingContext.DEPTH_TEST,glActiveTexture:(...e)=>gl.activeTexture(...e),glBindBuffer:(e,t)=>gl.bindBuffer(e,gl.__getObject(t)),glBlendColor:(...e)=>gl.blendColor(...e),glClear:(...e)=>gl.clear(...e),GL_SAMPLE_COVERAGE:WebGLRenderingContext.SAMPLE_COVERAGE,GL_VERTEX_SHADER:WebGLRenderingContext.VERTEX_SHADER,glViewport:(...e)=>gl.viewport(...e),glColorMask:(...e)=>gl.colorMask(...e),GL_COLOR_BUFFER_BIT:WebGLRenderingContext.COLOR_BUFFER_BIT,glLineWidth:(...e)=>gl.lineWidth(...e),glBlendEquationSeparate:(...e)=>gl.blendEquationSeparate(...e),glDisable:(...e)=>gl.disable(...e),glBlendFuncSeparate:(...e)=>gl.blendFuncSeparate(...e),glFrontFace:(...e)=>gl.frontFace(...e),glHint:(...e)=>gl.hint(...e),glClearDepth:(...e)=>gl.clearDepth(...e),glEnable:(...e)=>gl.enable(...e),glStencilOp:(...e)=>gl.stencilOp(...e),GL_SAMPLE_ALPHA_TO_COVERAGE:WebGLRenderingContext.SAMPLE_ALPHA_TO_COVERAGE,glIsEnabled:(...e)=>gl.isEnabled(...e),glScissor:(...e)=>gl.scissor(...e),glStencilFunc:(...e)=>gl.stencilFunc(...e),glStencilMaskSeparate:(...e)=>gl.stencilMaskSeparate(...e),glDeleteShader:e=>{gl.deleteShader(gl.__getObject(e)),gl.__release(e)},glStencilFuncSeparate:(...e)=>gl.stencilFuncSeparate(...e),glBlendEquation:(...e)=>gl.blendEquation(...e),glGetIntegerv:(...e)=>gl.getParameter(...e),GL_FRAGMENT_SHADER:WebGLRenderingContext.FRAGMENT_SHADER,glGetFloati_v:(e,t)=>gl.getParameter(e)[t],GL_DITHER:WebGLRenderingContext.DITHER,glPolygonOffset:(...e)=>gl.polygonOffset(...e),glDepthFunc:(...e)=>gl.depthFunc(...e),GL_CULL_FACE:WebGLRenderingContext.CULL_FACE,GL_POLYGON_OFFSET_FILL:WebGLRenderingContext.POLYGON_OFFSET_FILL,GL_STENCIL_BUFFER_BIT:WebGLRenderingContext.STENCIL_BUFFER_BIT,glGetBooleani_v:(e,t)=>gl.getParameter(e)[t],GL_DEPTH_BUFFER_BIT:WebGLRenderingContext.DEPTH_BUFFER_BIT,glGetIntegeri_v:(e,t)=>gl.getParameter(e)[t],glCreateShader:(...e)=>gl.__track(gl.createShader(...e)),glStencilOpSeparate:(...e)=>gl.stencilOpSeparate(...e),GL_BLEND:WebGLRenderingContext.BLEND,glBlendFunc:(...e)=>gl.blendFunc(...e),glDepthRange:(...e)=>gl.depthRange(...e),glPixelStorei:(...e)=>gl.pixelStorei(...e),glStencilMask:(...e)=>gl.stencilMask(...e),glGetError:()=>gl.getError(),glGetFloatv:(...e)=>gl.getParameter(...e)},r={_error:console.error,warning:console.warning,print:console.log},i={glas:Object.assign(Object.create(n),{"glas.init":()=>n.glas.init()?1:0,"glas.setLoopFunction"(e){e=function(e){if(!e)return null;const t=new F(function(e){if(e){const t=_.get(e);t?_.set(e,t+1):_.set(o.__pin(e),1)}return e}(e));return s.register(t,e),t}(e>>>0),n.glas.setLoopFunction(e)}}),gl:Object.assign(Object.create(l),{glClear(e){l.glClear(e>>>=0)}}),env:Object.assign(Object.create(globalThis),t.env||{},{abort(e,t,n,l){e=c(e>>>0),t=c(t>>>0),n>>>=0,l>>>=0,(()=>{throw Error(`${e} in ${t}:${n}:${l}`)})()}}),codea:Object.assign(Object.create(r),{print(e){e=c(e>>>0),r.print(e)}})},{instance:a}=await WebAssembly.instantiate(e,i),o=a.exports,g=o.memory||t.env.memory;function c(e){if(!e)return null;const t=e+new Uint32Array(g.buffer)[e-4>>>2]>>>1,n=new Uint16Array(g.buffer);let l=e>>>1,r="";for(;t-l>1024;)r+=String.fromCharCode(...n.subarray(l,l+=1024));return r+String.fromCharCode(...n.subarray(l,t))}const s=new FinalizationRegistry((function(e){if(e){const t=_.get(e);if(1===t)o.__unpin(e),_.delete(e);else{if(!t)throw Error(`invalid refcount '${t}' for reference '${e}'`);_.set(e,t-1)}}}));class F extends Number{}const _=new Map;const d=o.table;return __liftFunction=e=>{if(!e)return null;const t=new Uint32Array(g.buffer,e,1)[0];return d.get(t)},o}