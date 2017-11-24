uniform float brightness;
uniform float gamma;
uniform sampler2D tDiffuse;
varying vec2 vUv;

void main() {
	vec2 uv = vUv;
	vec4 c = texture2D(tDiffuse,uv);
	c = pow(c, vec4(1.0/gamma));
	c+=brightness;
	gl_FragColor = c;
}