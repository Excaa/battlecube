varying vec2 vUv;
uniform vec2 pixelamount;
uniform sampler2D tDiffuse;

void main() {
	vec2 uv = vUv;
	uv.x = floor(uv.x*pixelamount.x)/pixelamount.x;
	uv.y = floor(uv.y*pixelamount.y)/pixelamount.y;
	vec4 c = texture2D(tDiffuse,uv);
	gl_FragColor = c;
}
