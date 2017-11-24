varying vec2 vUv;
uniform float intensity;
uniform float jitter;
uniform float size;
uniform sampler2D tDiffuse;
uniform sampler2D tNoise;
uniform float time;
uniform float holdTime;
uniform float colorNoise;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
	vec2 uv = vUv;
	
	uv.x += (rand(vec2(time*0.1, uv.y*1920.))-0.5)*0.008*jitter;
	uv.y += (rand(vec2(time))-0.5)*0.01*jitter;
	
	vec4 base = (vec4(-0.5)+vec4(rand(vec2(uv.y*1080.,time)),rand(vec2(1080.,time+1.0)),rand(vec2(1080.,time+2.0)),0))*0.1*colorNoise;
	base += texture2D(tDiffuse,uv);
	float noise = texture2D(tNoise,uv+vec2(time,time*0.1)).r;
	
	if((noise*mod(uv.y + holdTime*0.2, 1.) > size) || 
		(noise*mod(uv.y + (holdTime+1.5)*0.2, 1.) > size) ||
		(noise*mod(uv.y + (holdTime+3.)*0.2, 1.) > size)) base+=vec4(1.)*intensity;
	
	
	gl_FragColor = base;
}
