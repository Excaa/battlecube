uniform float time;
uniform vec2 resolution;

uniform float sizeX;
uniform float wallX;
uniform float sizeY;
uniform float wallY;
uniform sampler2D fftMap;

varying vec2 vUv;

uniform vec2 fft;
uniform float speed;

void main( void ) {
	
	vec2 uv = vUv;
	
	float intX = abs(mod(uv.x, sizeX)-sizeX*.5);
	intX-=wallX;
	if (intX < 0.) intX =0.;
	intX = intX/sizeX*1.;
	
	float intY = abs(mod(uv.y+time*speed, sizeY)-sizeY*.5);
	intY-=wallY;
	if (intY < 0.) intY =0.;
	intY = intY/sizeY*1.;
	
	float intS = (max(intX, intY));
	//intS*=intS*intS*intS*intS;
	vec4 bc = vec4(uv-vec2(0.,speed),0.5+0.5*sin(time),1.0);
	//bc = vec4(1.);
	intS=smoothstep(0.,0.25,intS);
	gl_FragColor = bc*(mix(fft.x,fft.y,uv.x)+0.20)*intS;

}