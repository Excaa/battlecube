package wl.sounds;
import createjs.soundjs.Sound;
import createjs.soundjs.SoundInstance;
import js.html.audio.ScriptProcessorNode;
import wl.core.Demo;
import wl.core.Signal;
import wl.debug.Debug;

import js.html.audio.AnalyserNode;
import js.html.audio.AudioContext;
import js.html.audio.DynamicsCompressorNode;
import js.html.Float32Array;
import js.html.Uint8Array;
import wl.core.Config;
import wl.core.TimeSig;

/**
 * ...
 * @author Henri Sarasvirta
 */
class SoundWL
{
	public static var FFT_PRECISION:Int = 1024;
	public static var sampleRate;
	public static var onSoundLoaded:Signal = new Signal();
	public static var onSoundComplete:Signal = new Signal();
	public static var onSoundReady:Signal = new Signal();
	
	private static var time:TimeSig = new TimeSig();
	private static var volume:Float = 1;
	
	public static var instance:SoundInstance;
	private static var context:AudioContext;
	
	private static var startTime:Float = 0;
	
	private static var loaded:Bool = false;
	
	private static var analyserNodeRight:AnalyserNode;
	private static var analyserNodeLeft:AnalyserNode;
	private static var dynamicsCompressorNode:DynamicsCompressorNode;
	private static var lastFFT:Float = 0;
	private static var FFT:FFT = 
	{
		dbLeft : null, /*freqfloatdaata*/
		frequencyLeft: null, /*freqByteData*/
		waveformLeft: null, /*timeByData*/
		dbRight : null, /*freqfloatdaata*/
		frequencyRight: null, /*freqByteData*/
		waveformRight: null, /*timeByData*/
		fftsize:1024,
		sampleRate:44100
	}
	
	private static var freqFloatDataLeft:Float32Array;
	private static var freqByteDataLeft:Uint8Array;
	private static var timeByteDataLeft:Uint8Array;

	private static var freqFloatDataRight:Float32Array;
	private static var freqByteDataRight:Uint8Array;
	private static var timeByteDataRight:Uint8Array;

	private static var scriptProcessor:ScriptProcessorNode;
	
	public function new() 
	{
		throw "Sound is static";
	}
	
	public static function init():Void
	{
		loadMusicFile();
		SoundWL.context = Sound.activePlugin.context;
		SoundWL.sampleRate = Sound.activePlugin.context.sampleRate;
		SoundWL.dynamicsCompressorNode = Sound.activePlugin.dynamicsCompressorNode;
		if(Config.ENABLE_FFT)
			initializeFFT();
	
	}
	
	public static function setVolume(volume){
    	SoundWL.volume = volume;
    	if(SoundWL.instance != null){
    		SoundWL.instance.volume = volume;
    	}
    }
	
	public static function getPosition():TimeSig
	{
		if (SoundWL.instance != null)
		{
			time.fromTime(SoundWL.instance.getPosition() / 1000 / 60 - Config.MUSIC_BEGIN / 1000 / 60);
		}
		else if (SoundWL.context != null)
		{
			time.fromTime((SoundWL.context.currentTime-SoundWL.startTime) / 60 - Config.MUSIC_BEGIN / 1000 / 60);
		}
		return time;
	}
	
	public static function getFFT():FFT
	{
		return SoundWL.FFT;
	}
	
	private static function updateFFT():Void
	{
		if(!Debug.paused && (SoundWL.instance!=null || SoundWL.context!=null) && Config.ENABLE_FFT && SoundWL.analyserNodeLeft !=null)
		{
			//Fetch the values from browser.
			analyserNodeLeft.getFloatFrequencyData(freqFloatDataLeft); // this gives us the dBs
			analyserNodeLeft.getByteFrequencyData(freqByteDataLeft); // this gives us the frequency
			analyserNodeLeft.getByteTimeDomainData(timeByteDataLeft); // this gives us the waveform
			analyserNodeRight.getFloatFrequencyData(freqFloatDataRight); // this gives us the dBs
			analyserNodeRight.getByteFrequencyData(freqByteDataRight); // this gives us the frequency
			analyserNodeRight.getByteTimeDomainData(timeByteDataRight); // this gives us the waveform
		}
	}
	
	public static function start():Void
	{	
		SoundWL.instance = Sound.play("music");
		SoundWL.instance.on("complete", handleComplete);
		SoundWL.instance.volume = Config.MUTED ? 0 : SoundWL.volume;
		SoundWL.onSoundReady.emit();
	}
	
	private static function handleComplete():Void
	{
		SoundWL.onSoundComplete.emit();
	}
	
	public static function loadMusicFile():Void
	{
		//Go with the loading
		var sounds = [
			{id:"music", src:Config.SONG_PATH}
		];
		Sound.alternateExtensions = ["mp3"];
		Sound.addEventListener("fileload", handleLoad);
		untyped Sound.registerSounds(sounds);
	}
	
	private static function initializeFFT()
	{
		var context:AudioContext = SoundWL.context;
		var fftsize = FFT_PRECISION;
		if(context != null && context.createAnalyser != null)
		{
			// create an analyser node for left channel
			analyserNodeLeft = context.createAnalyser();
			analyserNodeLeft.fftSize = fftsize; //The size of the FFT used for frequency-domain analysis. This must be a power of two. Should be same as in precalculated data.
			analyserNodeLeft.smoothingTimeConstant = 0.0; //A value from 0 -> 1 where 0 represents no time averaging with the last analysis frame
			analyserNodeLeft.connect(context.destination); // connect to the context.destination, which outputs the audio
			
			// create an analyser node for right channel
			analyserNodeRight = context.createAnalyser();
			analyserNodeRight.fftSize = fftsize; //The size of the FFT used for frequency-domain analysis. This must be a power of two. Should be same as in precalculated data.
			analyserNodeRight.smoothingTimeConstant = 0.0; //A value from 0 -> 1 where 0 represents no time averaging with the last analysis frame
			
			// attach visualizer node to our existing dynamicsCompressorNode, which was connected to context.destination
			var dynamicsNode = SoundWL.dynamicsCompressorNode;// createjs.Sound.activePlugin.dynamicsCompressorNode;
			dynamicsNode.disconnect(); // disconnect from destination
			
			var splitterNode = context.createChannelSplitter(2);
			dynamicsNode.connect(splitterNode);
			
			splitterNode.connect(analyserNodeLeft, 0);
			splitterNode.connect(analyserNodeRight, 1);
			
			// set up the arrays that we use to retrieve the analyserNode data
			freqFloatDataLeft = new Float32Array(analyserNodeLeft.frequencyBinCount);
			freqByteDataLeft = new Uint8Array(analyserNodeLeft.frequencyBinCount);
			timeByteDataLeft = new Uint8Array(analyserNodeLeft.frequencyBinCount);
			// set up the arrays that we use to retrieve the analyserNode data
			freqFloatDataRight = new Float32Array(analyserNodeRight.frequencyBinCount);
			freqByteDataRight = new Uint8Array(analyserNodeRight.frequencyBinCount);
			timeByteDataRight = new Uint8Array(analyserNodeRight.frequencyBinCount);
			
			//TODO - update to multiple channels?
			scriptProcessor = context.createScriptProcessor(FFT_PRECISION*2, 2, 2);
			scriptProcessor.onaudioprocess = updateFFT;
			analyserNodeLeft.connect(scriptProcessor);
			scriptProcessor.connect(context.destination);
		}
		else
		{
			trace("FFT could not be initialized.");
		}
		SoundWL.FFT.dbLeft = freqFloatDataLeft;
		SoundWL.FFT.frequencyLeft = freqByteDataLeft;
		SoundWL.FFT.waveformLeft = timeByteDataLeft;
		SoundWL.FFT.dbRight = freqFloatDataRight;
		SoundWL.FFT.frequencyRight = freqByteDataRight;
		SoundWL.FFT.waveformRight = timeByteDataRight;
	}
	
	private static function handleLoad()
	{
		SoundWL.loaded = true;
		SoundWL.onSoundLoaded.emit();
	}
}

typedef FFT = {
	@:optional public var dbLeft:Float32Array;
	@:optional public var frequencyLeft:Uint8Array;
	@:optional public var waveformLeft:Uint8Array;
	@:optional public var dbRight:Float32Array;
	@:optional public var frequencyRight:Uint8Array;
	@:optional public var waveformRight:Uint8Array;
	@:optional public var fftsize:Int;
	@:optional public var sampleRate:Int;
	
}