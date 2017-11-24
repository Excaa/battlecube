varying vec2 vUv;
uniform int type;
uniform float aspect;
uniform sampler2D tDiffuse;
uniform vec2 resolution;
uniform vec4 color;

void main() {
	float mp = 0.0;
	float resAspect = resolution.x/resolution.y;
	vec2 uv = vUv;
		
	//Black lines left and right
	if(resAspect > aspect)
	{
		float dif = resAspect-aspect;
		mp = uv.x > dif/2. && uv.x < 1.-dif/2. ? 0. : 1.;
	}
	else
	{
		//Black ines top & bottom
		float dif = aspect-resAspect;
		mp = uv.y > dif/2. && uv.y < 1.-dif/2. ? 0. : 1.;
		
	}
	
	//TODO - in fill change uv also. 
	vec4 c = mix(texture2D(tDiffuse,uv), color,mp);

	gl_FragColor = c;
}
