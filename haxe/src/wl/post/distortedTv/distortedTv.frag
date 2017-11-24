uniform float distortAmount;
uniform sampler2D tDiffuse;
uniform float time;
uniform float greenamplify;
uniform float blueamplify;
uniform float vignAmount;
uniform float offsetAmount;
uniform float brightMultiplier;
uniform float brightLimit;
varying vec2 vUv;

void main()
{
	vec2 uv = vUv;
    float offset = mod(ceil(uv.y*distortAmount+time)*time,0.012);
    vec4 tColor = texture2D(tDiffuse,vec2(uv.x+offsetAmount*offset,uv.y));
    tColor.g *= greenamplify;
    tColor.b *= blueamplify;
    float vign = 1.0-length(vec2(0.5,0.5)-uv)*vignAmount;
    
	vec3 brightness = tColor.rgb;
	vec3 mp = vec3(1.)-smoothstep(vec3(brightLimit), vec3(1.), brightness)*brightMultiplier;
	tColor*=vec4(mp,1.);
	
    tColor *= vign;
	gl_FragColor = tColor;
}