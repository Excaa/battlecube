uniform float range;
uniform float value1;
uniform float value2;
uniform float original;
uniform float amount;
uniform vec4 color1;
uniform vec4 color2;
uniform vec2 tile;
uniform sampler2D tDiffuse;
varying vec2 vUv;

void main() {
	vec2 uv = vUv;
	vec4 c = texture2D(tDiffuse,uv*tile);
	
	//Make continuous triangle function
	float val1 = value1*2.;
	val1 = val1 < 1. ? val1 : 2.-val1;
	float val2 = value2*2.;
	val1 = val2 < 1. ? val2 : 2.-val2;
	
	float timeoff1 = mod(val1, 1. + range);
	float timeoff2 = mod(val2, 1. + range);
	
	float mp1 = (abs(c.r - timeoff1) > range) ? 1. : 0.;
	float mp2 = (abs(c.g - timeoff2) > range) ? 1. : 0.;
	
	float avg = (c.r+c.g+c.b)/3.;
	vec4 ads1 = color1 * abs(avg - timeoff1);
	vec4 ads2 = color2 * abs(avg - timeoff2);
	
	vec4 col = (1.- mp1) * ads1 + (1. - mp2)*ads2;
	
	gl_FragColor = c*original + col*amount;
}
