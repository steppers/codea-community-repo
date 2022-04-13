// GLAS definitions ==============================================

// Internal functions
declare function getDisplayWidth(): u32;
declare function getDisplayHeight(): u32;

// Exported functions
@global namespace glas {
	declare function init(): bool;
	declare function setLoopFunction(fn: (dt: f32) => void): void;
	
	function getDisplayResolution(): Vec2i {
    	return new Vec2i(getDisplayWidth(), getDisplayHeight());
	}
}





// GLAS functions ===============================
@js_import glas.init =
() => {
	
	// Add metadata to ensure correct scaling
	{
		let meta = document.createElement('meta');
		meta.name = "viewport";
		meta.content = "initial-scale=1, viewport-fit=cover";
		document.head.append(meta);
	}
	
    // Make body fullscreen & disable scrolling
    document.body.height = '100vh';
    document.body.style.margin = 0;
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
        console.warning("[GLAS] Unable to initialize WebGL. Your browser or device may not support it.");
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
    // upper 24 bits reserved for the generation ID.
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
@js_end

@js_import glas.setLoopFunction =
(fn) => {
	// Convert the function ref to an actual function
	// we can call
	fn = __liftFunction(fn);
	
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
@js_end

// Internal functions
@js_import getDisplayWidth =
() => screen.availWidth
@js_end

@js_import getDisplayHeight =
() => screen.availHeight
@js_end