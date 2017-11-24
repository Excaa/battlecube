varying vec2 vUv;
uniform float rshift;
uniform float gshift;
uniform float bshift;
uniform sampler2D tDiffuse;

void main() {
	vec4 c = texture2D(tDiffuse,vUv);
	float ro = texture2D(tDiffuse,vec2(vUv.x-rshift, vUv.y)).r;
	float go = texture2D(tDiffuse,vec2(vUv.x-gshift, vUv.y)).g;
	float bo = texture2D(tDiffuse,vec2(vUv.x-bshift, vUv.y)).b;
	gl_FragColor = vec4(ro, go, bo, c.w);
}