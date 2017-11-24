package js.three;

import js.html.*;

// Mapping modes
@:native("THREE")
extern enum Mapping
{
	UVMapping;
	CubeReflectionMapping;
	CubeRefractionMapping;
	EquirectangularReflectionMapping;
	EquirectangularRefractionMapping;
	SphericalReflectionMapping;
}