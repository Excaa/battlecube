uniform float scaleX;
uniform float scaleY;
uniform float zoom;
uniform vec2 offset;
uniform sampler2D tDiffuse;
uniform sampler2D tDispMap;
varying vec2 vUv;

void main() {
	vec2 uv = vUv;
	vec4 cd = texture2D(tDispMap,(uv+offset)*zoom);
	
	//calculate offset
	vec2 offset =vec2( cd.r * scaleX, cd.g*scaleY) - vec2(scaleX*0.5,scaleY*0.5);
	
	vec4 c = texture2D(tDiffuse,uv+offset);
	
	gl_FragColor = c;
}
