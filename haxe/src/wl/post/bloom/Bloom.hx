package wl.post.bloom;
import dat.gui.GUI;
import haxe.Resource;
import js.Browser;
import js.three.Blending;
import js.three.BlendingEquation;
import js.three.Color;
import js.three.Material;
import js.three.Mesh;
import js.three.OrthographicCamera;
import js.three.PixelFormat;
import js.three.PlaneBufferGeometry;
import js.three.Renderer;
import js.three.RenderTarget;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.TextureDataType;
import js.three.TextureFilter;
import js.three.Three;
import js.three.UniformsUtils;
import js.three.Vector2;
import js.three.Vector3;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderTargetOptions;
import js.three.WebGLRenderer;
import wl.debug.Debug;

/**
 * Ported to haxe by Exca/Wide Load/Konvergence
 * @author spidersharma / http://eduperiment.com/
 Inspired from Unreal Engine::
 https://docs.unrealengine.com/latest/INT/Engine/Rendering/PostProcessEffects/Bloom/
 */
class Bloom
{
	private static var BlurDirectionX = new Vector2( 1.0, 0.0 );
	private static var BlurDirectionY = new Vector2( 0.0, 1.0 );
	
	private var uniforms:Dynamic = {
		
	};
	
	public var enabled:Bool;
	public var renderToScreen:Bool;
	public var needsSwap:Bool;
	private var material:ShaderMaterial;
	
	public var strength:Float;
	public var resolution:Vector2;
	public var radius:Float;
	public var threshold:Float;
	
	private var camera:OrthographicCamera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	private var scene:Scene  = new Scene();
	
	private var quad:Mesh = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
	
	private var renderTargetsHorizontal:Array<WebGLRenderTarget>;
	private var renderTargetsVertical:Array<WebGLRenderTarget>;
	private var nMips:Int = 5;
	private var renderTargetBright:WebGLRenderTarget;
	
	private var highPassUniforms:Dynamic;
	
	private var separableBlurMaterials:Array<ShaderMaterial>;
	private var compositeMaterial:ShaderMaterial;
	private var materialHighPassFilter:ShaderMaterial;
	
	private var bloomTintColors:Array<Vector3>;
	private var copyUniforms:Dynamic;
	private var materialCopy:ShaderMaterial;
	
	private var oldClearColor:Color;
	private var oldClearAlpha:Float;
	
	public function setupDatGui(folder:GUI):Void
	{
		var f:GUI = folder.addFolder("Bloom");
		f.add(this, "strength").step(0.01);
		f.add(this, "radius").step(0.01);
		f.add(this, "threshold").step(0.01);
	}
	
	public function new(?resolution:Vector2, ?strength:Float=0.5, ?radius:Float=0, ?threshold:Float=0) 
	{
		if (resolution == null) resolution = new Vector2(2048, 2048);
		this.resolution = resolution;
		this.strength = strength;
		this.radius = radius;
		this.threshold = threshold;
		this.enabled = true;
		
		// render targets
		var pars:WebGLRenderTargetOptions =cast { minFilter: TextureFilter.LinearFilter, magFilter: TextureFilter.LinearFilter, format: PixelFormat.RGBAFormat };
		this.renderTargetsHorizontal = [];
		this.renderTargetsVertical = [];
		this.nMips = 5;
		var resx:Int = Math.round(this.resolution.x/2);
		var resy:Int = Math.round(this.resolution.y/2);

		this.renderTargetBright = new WebGLRenderTarget( resx, resy, pars );
		this.renderTargetBright.texture.generateMipmaps = false;

		for ( i in 0...this.nMips)
		{
			var renderTarget = new WebGLRenderTarget( resx, resy, pars );
			renderTarget.texture.generateMipmaps = false;
			this.renderTargetsHorizontal.push(renderTarget);
			var renderTarget = new WebGLRenderTarget( resx, resy, pars );
			renderTarget.texture.generateMipmaps = false;
			this.renderTargetsVertical.push(renderTarget);
			resx = Math.round(resx/2);
			resy = Math.round(resy/2);
		}
		
		// luminosity high pass material, create it through inline js for now.
		if ( untyped __js__("THREE.LuminosityHighPassShader") == null )
			trace( "THREE.UnrealBloomPass relies on THREE.LuminosityHighPassShader" );
		
		var highPassShader:Dynamic =untyped __js__("THREE.LuminosityHighPassShader");
		this.highPassUniforms = UniformsUtils.clone( highPassShader.uniforms );
		
		this.highPassUniforms.luminosityThreshold.value = threshold;
		this.highPassUniforms.smoothWidth.value = 0.01;
		
		this.materialHighPassFilter = new ShaderMaterial( {
			uniforms: this.highPassUniforms,
			vertexShader:  highPassShader.vertexShader,
			fragmentShader: highPassShader.fragmentShader,
			defines: {}
		} );
		
		// Gaussian Blur Materials
		this.separableBlurMaterials = [];
		var kernelSizeArray:Array<Int> = [3, 5, 7, 9, 11];
		var resx:Int = Math.round(this.resolution.x/2);
		var resy:Int = Math.round(this.resolution.y/2);

		for ( i in 0...this.nMips) 
		{
			this.separableBlurMaterials.push(this.getSeperableBlurMaterial(kernelSizeArray[i]));
			this.separableBlurMaterials[i].uniforms.texSize.value = new Vector2(resx, resy);
			resx = Math.round(resx/2);
			resy = Math.round(resy/2);
		}
		
		// Composite material
		this.compositeMaterial = this.getCompositeMaterial(this.nMips);
		this.compositeMaterial.uniforms.blurTexture1.value = this.renderTargetsVertical[0].texture;
		this.compositeMaterial.uniforms.blurTexture2.value = this.renderTargetsVertical[1].texture;
		this.compositeMaterial.uniforms.blurTexture3.value = this.renderTargetsVertical[2].texture;
		this.compositeMaterial.uniforms.blurTexture4.value = this.renderTargetsVertical[3].texture;
		this.compositeMaterial.uniforms.blurTexture5.value = this.renderTargetsVertical[4].texture;
		this.compositeMaterial.uniforms.bloomStrength.value = strength;
		this.compositeMaterial.uniforms.bloomRadius.value = 0.1;
		this.compositeMaterial.needsUpdate = true;

		var bloomFactors:Array<Float> = [1.0, 0.8, 0.6, 0.4, 0.2];
		this.compositeMaterial.uniforms.bloomFactors.value = bloomFactors;
		this.bloomTintColors = [new Vector3(1,1,1), new Vector3(1,1,1), new Vector3(1,1,1)
													,new Vector3(1,1,1), new Vector3(1,1,1)];
		this.compositeMaterial.uniforms.bloomTintColors.value = this.bloomTintColors;
		
		// copy material
		if ( untyped __js__("THREE.CopyShader") == null )
			trace( "THREE.BloomPass relies on THREE.CopyShader" );
		
		var copyShader:Dynamic = untyped __js__("THREE.CopyShader");
		
		this.copyUniforms = UniformsUtils.clone( copyShader.uniforms );
		this.copyUniforms.opacity.value = 1.0;

		this.materialCopy = new ShaderMaterial( {
			uniforms: this.copyUniforms,
			vertexShader: copyShader.vertexShader,
			fragmentShader: copyShader.fragmentShader,
			blending: Blending.AdditiveBlending,
			depthTest: false,
			depthWrite: false,
			transparent: true
		} );

		this.enabled = true;
		this.needsSwap = false;

		this.oldClearColor = new Color();
		this.oldClearAlpha = 1;

		this.camera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
		this.scene  = new Scene();

		this.quad = new Mesh( new PlaneBufferGeometry( 2, 2 ), null );
		this.scene.add( this.quad );
		
	}
	
	public function setSize(width:Int, height:Int) 
	{
		var resx:Int = Math.round(width/2);
		var resy:Int = Math.round(height/2);
		
		this.renderTargetBright.setSize(resx, resy);
		
		for ( i in 0...this.nMips)
		{
			this.renderTargetsHorizontal[i].setSize(resx, resy);
			this.renderTargetsVertical[i].setSize(resx, resy);
			this.separableBlurMaterials[i].uniforms.texSize.value = new Vector2(resx, resy);
			resx = Math.round(resx/2);
			resy = Math.round(resy/2);
		}
	}
	
	public function render(renderer:WebGLRenderer, writeBuffer:WebGLRenderTarget, readBuffer:WebGLRenderTarget, delta:Float):Void
	{
		this.oldClearColor.copy( renderer.getClearColor() );
		this.oldClearAlpha = renderer.getClearAlpha();
		var oldAutoClear = renderer.autoClear;
		renderer.autoClear = false;

		renderer.setClearColor( new Color( 0, 0, 0 ), 0 );

		// 1. Extract Bright Areas
		this.highPassUniforms.tDiffuse.value = readBuffer.texture;
		this.highPassUniforms.luminosityThreshold.value = this.threshold;
		this.quad.material = this.materialHighPassFilter;
		renderer.render( this.scene, this.camera, this.renderTargetBright, true );
		
		// 2. Blur All the mips progressively
		var inputRenderTarget = this.renderTargetBright;

		for (i in 0...this.nMips)
		{
			this.quad.material = this.separableBlurMaterials[i];
			this.separableBlurMaterials[i].uniforms.colorTexture.value = inputRenderTarget.texture;
			this.separableBlurMaterials[i].uniforms.direction.value = Bloom.BlurDirectionX;
			renderer.render( this.scene, this.camera, this.renderTargetsHorizontal[i], true );
			this.separableBlurMaterials[i].uniforms.colorTexture.value = this.renderTargetsHorizontal[i].texture;
			this.separableBlurMaterials[i].uniforms.direction.value = Bloom.BlurDirectionY;
			renderer.render( this.scene, this.camera, this.renderTargetsVertical[i], true );
			inputRenderTarget = this.renderTargetsVertical[i];
		}
		
		// Composite All the mips
		this.quad.material = this.compositeMaterial;
		this.compositeMaterial.uniforms.bloomStrength.value = this.strength;
		this.compositeMaterial.uniforms.bloomRadius.value = this.radius;
		this.compositeMaterial.uniforms.bloomTintColors.value = this.bloomTintColors;
		renderer.render( this.scene, this.camera, this.renderTargetsHorizontal[0], true );
		
		// Blend it additively over the input texture
		this.quad.material = this.materialCopy;
		this.copyUniforms.tDiffuse.value = this.renderTargetsHorizontal[0].texture;
		
		
		renderer.render( this.scene, this.camera, readBuffer, false );
		renderer.setClearColor( this.oldClearColor, this.oldClearAlpha );
		renderer.autoClear = oldAutoClear;
	}
	
	private function getSeperableBlurMaterial(kernelRadius:Float):ShaderMaterial
	{
		return new ShaderMaterial( {

			defines: {
				"KERNEL_RADIUS" : kernelRadius,
				"SIGMA" : kernelRadius
			},
			
			uniforms: {
				"colorTexture": { value: null },
				"texSize": { value: new Vector2( 0.5, 0.5 ) },
				"direction": { value: new Vector2( 0.5, 0.5 ) },
			},
			
			vertexShader:[
				"varying vec2 vUv;",
				"void main() {",
				"	vUv = uv;",
				"	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
				"}"].join("\n"),
			
			fragmentShader:[
				"#include <common>",
				"varying vec2 vUv;",
				"uniform sampler2D colorTexture;",
				"uniform vec2 texSize;",
				"uniform vec2 direction;",
				"float gaussianPdf(in float x, in float sigma) {",
				"	return 0.39894 * exp( -0.5 * x * x/( sigma * sigma))/sigma;",
				"}",
				"void main() {",
				"	vec2 invSize = 1.0 / texSize;",
				"	float fSigma = float(SIGMA);",
				"	float weightSum = gaussianPdf(0.0, fSigma);",
				"	vec3 diffuseSum = texture2D( colorTexture, vUv).rgb * weightSum;",
				"	for( int i = 1; i < KERNEL_RADIUS; i ++ ) {",
				"		float x = float(i);",
				"		float w = gaussianPdf(x, fSigma);",
				"		vec2 uvOffset = direction * invSize * x;",
				"		vec3 sample1 = texture2D( colorTexture, vUv + uvOffset).rgb;",
				"		vec3 sample2 = texture2D( colorTexture, vUv - uvOffset).rgb;",
				"		diffuseSum += (sample1 + sample2) * w;",
				"		weightSum += 2.0 * w;",
				"	}",
				"	gl_FragColor = vec4(diffuseSum/weightSum, 1.0);",
				"}"].join("\n")
		} );
	}
	
	private function getCompositeMaterial(nMips:Int):ShaderMaterial
	{
		return new ShaderMaterial( 
		{
			defines:{
				"NUM_MIPS" : nMips
			},
			
			uniforms: {
				"blurTexture1": { value: null },
				"blurTexture2": { value: null },
				"blurTexture3": { value: null },
				"blurTexture4": { value: null },
				"blurTexture5": { value: null },
				"dirtTexture": { value: null },
				"bloomStrength" : { value: 1.0 },
				"bloomFactors" : { value: null },
				"bloomTintColors" : { value: null },
				"bloomRadius" : { value: 0.0 }
			},
			
			vertexShader:[
				"varying vec2 vUv;",
				"void main() {",
				"	vUv = uv;",
				"	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
				"}"].join("\n"),
			
			fragmentShader:[
				"varying vec2 vUv;",
				"uniform sampler2D blurTexture1;",
				"uniform sampler2D blurTexture2;",
				"uniform sampler2D blurTexture3;",
				"uniform sampler2D blurTexture4;",
				"uniform sampler2D blurTexture5;",
				"uniform sampler2D dirtTexture;",
				"uniform float bloomStrength;",
				"uniform float bloomRadius;",
				"uniform float bloomFactors[NUM_MIPS];",
				"uniform vec3 bloomTintColors[NUM_MIPS];",
				"float lerpBloomFactor(const in float factor) { ",
				"	float mirrorFactor = 1.2 - factor;",
				"	return mix(factor, mirrorFactor, bloomRadius);",
				"}",
				"void main() {",
				"	gl_FragColor = bloomStrength * ( lerpBloomFactor(bloomFactors[0]) * vec4(bloomTintColors[0], 1.0) * texture2D(blurTexture1, vUv) + ",
				"	 							 lerpBloomFactor(bloomFactors[1]) * vec4(bloomTintColors[1], 1.0) * texture2D(blurTexture2, vUv) + ",
				"								 lerpBloomFactor(bloomFactors[2]) * vec4(bloomTintColors[2], 1.0) * texture2D(blurTexture3, vUv) + ",
				"								 lerpBloomFactor(bloomFactors[3]) * vec4(bloomTintColors[3], 1.0) * texture2D(blurTexture4, vUv) + ",
				"								 lerpBloomFactor(bloomFactors[4]) * vec4(bloomTintColors[4], 1.0) * texture2D(blurTexture5, vUv) );",
				"}"].join("\n")
		} );
	}
}

/*

THREE.UnrealBloomPass.prototype = Object.assign( Object.create( THREE.Pass.prototype ), {

	constructor: THREE.UnrealBloomPass,

	dispose: function() {
		for( var i=0; i< this.renderTargetsHorizontal.length(); i++) {
			this.renderTargetsHorizontal[i].dispose();
		}
		for( var i=0; i< this.renderTargetsVertical.length(); i++) {
			this.renderTargetsVertical[i].dispose();
		}
		this.renderTargetBright.dispose();
	},

	setSize: function ( width, height ) {

		var resx = Math.round(width/2);
		var resy = Math.round(height/2);

		this.renderTargetBright.setSize(resx, resy);

		for( var i=0; i<this.nMips; i++) {

			this.renderTargetsHorizontal[i].setSize(resx, resy);
			this.renderTargetsVertical[i].setSize(resx, resy);

			this.separableBlurMaterials[i].uniforms[ "texSize" ].value = new THREE.Vector2(resx, resy);

			resx = Math.round(resx/2);
			resy = Math.round(resy/2);
		}
	},

	render: function ( renderer, writeBuffer, readBuffer, delta, maskActive ) {

		this.oldClearColor.copy( renderer.getClearColor() );
		this.oldClearAlpha = renderer.getClearAlpha();
		var oldAutoClear = renderer.autoClear;
		renderer.autoClear = false;

		renderer.setClearColor( new THREE.Color( 0, 0, 0 ), 0 );

		if ( maskActive ) renderer.context.disable( renderer.context.STENCIL_TEST );

		// 1. Extract Bright Areas
		this.highPassUniforms[ "tDiffuse" ].value = readBuffer.texture;
		this.highPassUniforms[ "luminosityThreshold" ].value = this.threshold;
		this.quad.material = this.materialHighPassFilter;
		renderer.render( this.scene, this.camera, this.renderTargetBright, true );

		// 2. Blur All the mips progressively
		var inputRenderTarget = this.renderTargetBright;

		for(var i=0; i<this.nMips; i++) {

			this.quad.material = this.separableBlurMaterials[i];

			this.separableBlurMaterials[i].uniforms[ "colorTexture" ].value = inputRenderTarget.texture;

			this.separableBlurMaterials[i].uniforms[ "direction" ].value = THREE.UnrealBloomPass.BlurDirectionX;

			renderer.render( this.scene, this.camera, this.renderTargetsHorizontal[i], true );

			this.separableBlurMaterials[i].uniforms[ "colorTexture" ].value = this.renderTargetsHorizontal[i].texture;

			this.separableBlurMaterials[i].uniforms[ "direction" ].value = THREE.UnrealBloomPass.BlurDirectionY;

			renderer.render( this.scene, this.camera, this.renderTargetsVertical[i], true );

			inputRenderTarget = this.renderTargetsVertical[i];
		}

		// Composite All the mips
		this.quad.material = this.compositeMaterial;
		this.compositeMaterial.uniforms["bloomStrength"].value = this.strength;
		this.compositeMaterial.uniforms["bloomRadius"].value = this.radius;
		this.compositeMaterial.uniforms["bloomTintColors"].value = this.bloomTintColors;
		renderer.render( this.scene, this.camera, this.renderTargetsHorizontal[0], true );

		// Blend it additively over the input texture
		this.quad.material = this.materialCopy;
		this.copyUniforms[ "tDiffuse" ].value = this.renderTargetsHorizontal[0].texture;

		if ( maskActive ) renderer.context.enable( renderer.context.STENCIL_TEST );

		renderer.render( this.scene, this.camera, readBuffer, false );

		renderer.setClearColor( this.oldClearColor, this.oldClearAlpha );
		renderer.autoClear = oldAutoClear;
	},

	getSeperableBlurMaterial: function(kernelRadius) {

		return new THREE.ShaderMaterial( {

			defines: {
				"KERNEL_RADIUS" : kernelRadius,
				"SIGMA" : kernelRadius
			},

			uniforms: {
				"colorTexture": { value: null },
				"texSize": 				{ value: new THREE.Vector2( 0.5, 0.5 ) },
				"direction": 				{ value: new THREE.Vector2( 0.5, 0.5 ) },
			},

			vertexShader:
				"varying vec2 vUv;\n\
				void main() {\n\
					vUv = uv;\n\
					gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n\
				}",

			fragmentShader:
				"#include <common>\
				varying vec2 vUv;\n\
				uniform sampler2D colorTexture;\n\
				uniform vec2 texSize;\
				uniform vec2 direction;\
				\
				float gaussianPdf(in float x, in float sigma) {\
					return 0.39894 * exp( -0.5 * x * x/( sigma * sigma))/sigma;\
				}\
				void main() {\n\
					vec2 invSize = 1.0 / texSize;\
					float fSigma = float(SIGMA);\
					float weightSum = gaussianPdf(0.0, fSigma);\
					vec3 diffuseSum = texture2D( colorTexture, vUv).rgb * weightSum;\
					for( int i = 1; i < KERNEL_RADIUS; i ++ ) {\
						float x = float(i);\
						float w = gaussianPdf(x, fSigma);\
						vec2 uvOffset = direction * invSize * x;\
						vec3 sample1 = texture2D( colorTexture, vUv + uvOffset).rgb;\
						vec3 sample2 = texture2D( colorTexture, vUv - uvOffset).rgb;\
						diffuseSum += (sample1 + sample2) * w;\
						weightSum += 2.0 * w;\
					}\
					gl_FragColor = vec4(diffuseSum/weightSum, 1.0);\n\
				}"
		} );
	},

	getCompositeMaterial: function(nMips) {

		return new THREE.ShaderMaterial( {

			defines:{
				"NUM_MIPS" : nMips
			},

			uniforms: {
				"blurTexture1": { value: null },
				"blurTexture2": { value: null },
				"blurTexture3": { value: null },
				"blurTexture4": { value: null },
				"blurTexture5": { value: null },
				"dirtTexture": { value: null },
				"bloomStrength" : { value: 1.0 },
				"bloomFactors" : { value: null },
				"bloomTintColors" : { value: null },
				"bloomRadius" : { value: 0.0 }
			},

			vertexShader:
				"varying vec2 vUv;\n\
				void main() {\n\
					vUv = uv;\n\
					gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n\
				}",

			fragmentShader:
				"varying vec2 vUv;\
				uniform sampler2D blurTexture1;\
				uniform sampler2D blurTexture2;\
				uniform sampler2D blurTexture3;\
				uniform sampler2D blurTexture4;\
				uniform sampler2D blurTexture5;\
				uniform sampler2D dirtTexture;\
				uniform float bloomStrength;\
				uniform float bloomRadius;\
				uniform float bloomFactors[NUM_MIPS];\
				uniform vec3 bloomTintColors[NUM_MIPS];\
				\
				float lerpBloomFactor(const in float factor) { \
					float mirrorFactor = 1.2 - factor;\
					return mix(factor, mirrorFactor, bloomRadius);\
				}\
				\
				void main() {\
					gl_FragColor = bloomStrength * ( lerpBloomFactor(bloomFactors[0]) * vec4(bloomTintColors[0], 1.0) * texture2D(blurTexture1, vUv) + \
					 							 lerpBloomFactor(bloomFactors[1]) * vec4(bloomTintColors[1], 1.0) * texture2D(blurTexture2, vUv) + \
												 lerpBloomFactor(bloomFactors[2]) * vec4(bloomTintColors[2], 1.0) * texture2D(blurTexture3, vUv) + \
												 lerpBloomFactor(bloomFactors[3]) * vec4(bloomTintColors[3], 1.0) * texture2D(blurTexture4, vUv) + \
												 lerpBloomFactor(bloomFactors[4]) * vec4(bloomTintColors[4], 1.0) * texture2D(blurTexture5, vUv) );\
				}"
		} );
	}

} );

THREE.UnrealBloomPass.BlurDirectionX = new THREE.Vector2( 1.0, 0.0 );
THREE.UnrealBloomPass.BlurDirectionY = new THREE.Vector2( 0.0, 1.0 );
*/