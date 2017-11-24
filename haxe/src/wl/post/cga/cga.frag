varying vec2 vUv;
uniform float amount;
uniform sampler2D tDiffuse;
uniform vec2 resolution;

uniform vec3 colors[16];

void main() {
	vec2 uv = vUv;
	vec4 c = texture2D(tDiffuse,uv);
	float closest = 99999.;
    vec3 selected=vec3(0.);
    for(int i = 0; i < 16; i++)
    {
        float d = distance(colors[i], c.rgb);
        if(closest > d)
        {
         	closest = d;
            selected = colors[i];
        }
    }
	gl_FragColor = mix(c,vec4(selected,1.), amount);
}
