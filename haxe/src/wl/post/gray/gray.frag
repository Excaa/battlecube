varying vec2 vUv;
uniform sampler2D tDiffuse;
uniform float gray;

void main() {
	vec2 uv = vUv;
	vec4 c = texture2D(tDiffuse,uv);
	float gr = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    vec3 fc = mix(c.rgb, vec3(gr), gray);
	gl_FragColor =vec4(fc,1.);
}
