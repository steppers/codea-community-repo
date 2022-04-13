let asc = null;

async function compileRaw(sources, options) {
	if (typeof sources === "string") sources = { [`input${defaultExtension.ext}`]: sources };
	
	const output = new Object();
	
	var argv = [
		"--outFile", "binary",
		"--textFile", "text",
		"--bindings", "raw"
	];
	Object.keys(options || {}).forEach(key => {
		var val = options[key];
		var opt = asc.options[key];
		if (opt && opt.type === "b") {
			if (val) argv.push(`--${key}`);
		} else {
			if (Array.isArray(val)) {
				val.forEach(val => { argv.push(`--${key}`, String(val)); });
			}
			else argv.push(`--${key}`, String(val));
		}
	});
	
	const { error, stdout, stderr } = await asc.main(
		argv.concat(Object.keys(sources)),
		{
			readFile:	(name) => Object.prototype.hasOwnProperty.call(sources, name) ? sources[name] : null,
			writeFile:	(name, data, baseDir) => { output[name] = data; },
			listFiles: 	(dirname, baseDir) => []
		});
		
	output.stderr = stderr;
		
	return output;
};

            
async function compile(src, optimisationLevel)
{
    // Wait for the compiler to load first
	asc = await importShim("assemblyscript/asc")
            	
    var options = {}
    options.optimizeLevel = optimisationLevel;
    options.exportRuntime = true;
    options.exportTable = true;
    options.importMemory = true;
    options.lib = "./"; // Allows for importing without './'
    // options.enable = [ 'threads' ];
            
    const result = await compileRaw(src, options);
	const { text, binary, stderr } = result;
	const bindings = result['binary.js'];

    // Print errors
    if (binary === undefined) {
        return [ stderr.toString() ];
    }

    return [text, Array.from(binary), bindings];
}

async function minifyImports(imports) {
    for (let mod in imports) {
        for (let imp in imports[mod]) {
            let code = imports[mod][imp];
            
            // Use Terser to minimise the import code
            const min = await Terser.minify(code.toString(), {
                parse: {
                    bare_returns: true
                }
            });

            // Overwrite with minimised code
            imports[mod][imp] = min.code;
        }
    }

    return imports;
}

async function minify(code) {
	const min = await Terser.minify(code.toString());
	return min.code;
}