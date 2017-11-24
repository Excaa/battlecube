varying vec2 vUv;

uniform sampler2D fftMap;
uniform float time;
uniform float mountains;

void main()
{
	vUv = uv;
	float off = texture2D(fftMap, uv).r*0.;
	
	float dist = smoothstep(0.,1.,uv.y)*(smoothstep(0.,0.5,abs(uv.x-0.5)-0.025))*0.5;
	dist = min(0.25, dist);
	dist += sin(time*3.+uv.x*17.+uv.y*12.)*dist+ sin(time*2.+uv.x*60.+uv.y*23.) * dist*0.2+ cos(time*1.2+uv.x*40.+uv.y*33.) * dist*0.1;
	//dist *= (sin(time*3.+uv.x*7.+uv.y*5.)*0.8+cos(1.2-time*3.+uv.x*20.+uv.y*28.)*0.4+cos(2.+time*4.+uv.x*83.+uv.y*88.)*0.1)*dist;
	
	vec4 mvPosition = modelViewMatrix * vec4( position+vec3(0.,0.,off*dist+max(0.,dist*40.))*mountains, 1.0 );
	
	gl_Position = projectionMatrix * mvPosition;
}