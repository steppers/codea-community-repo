#version 120

// Fisheye

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

// 150 degrees (set fov in options.txt to 2.0)
uniform float C1 = 1.8; //2.617993877991494; // fov in radians
uniform float C2 = 0.4; //0.133974596215561; // 0.5/tan(C1*0.5)
uniform float Rlim = 0.6; //0.565685424949238; // sqrt(0.4*0.4 + 0.4*0.4)


void main() {
	float X = texCoord.x - 0.5;
	float Y = texCoord.y - 0.5;
	
	// Distance from centre of screen
    float R = sqrt(X*X + Y*Y);
	
	// Discard pixels for which the tangent wraps around
	//if(R > Rlim) discard;
	
	R = clamp(R,0.0,Rlim);
	
	float T = tan(C1*R)*C2;
	float C = T/R;
	
	//X = X*C + 0.5;
	//Y = Y*C + 0.5;
	X *= C;
	Y *= C;
	
	if(abs(X)>0.5 || abs(Y)>0.5) discard;
	
	float A = 2*abs(X);
	if(A>1.0) {
		X = X/A;
		Y = Y/A;
	}

	A = 2*abs(Y);
	if(A>1.0) {
		X = X/A;
		Y = Y/A;
	}

	X += 0.5;
	Y += 0.5;

	// --- Bilinear interpolation smooths the low resolution parts somewhat ---
	//gl_FragColor = texture2D(DiffuseSampler,vec2(X,Y));
	

	// Texel coordinates for interpolation
	vec2 texels = vec2(X,Y)/oneTexel;
	vec2 texelsFract = fract(texels);


	vec4 v11 = texture2D(DiffuseSampler, vec2(X,			 	Y 				));
	vec4 v12 = texture2D(DiffuseSampler, vec2(X+oneTexel.x,		Y 				));
	vec4 v21 = texture2D(DiffuseSampler, vec2(X,		  		Y+oneTexel.y 	));
	vec4 v22 = texture2D(DiffuseSampler, vec2(X+oneTexel.x,		Y+oneTexel.y 	));

	vec4 color = mix(mix(v11, v12, texelsFract.x), mix(v21, v22, texelsFract.x), texelsFract.y);
	gl_FragColor = vec4(color.rgb, 1.0);
}
