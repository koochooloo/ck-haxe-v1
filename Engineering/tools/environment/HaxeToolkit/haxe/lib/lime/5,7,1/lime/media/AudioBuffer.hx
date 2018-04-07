package lime.media;


import haxe.io.Bytes;
import haxe.io.Path;
import lime._backend.native.NativeCFFI;
import lime.app.Future;
import lime.app.Promise;
import lime.media.codecs.vorbis.VorbisFile;
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.net.HTTPRequest;
import lime.utils.UInt8Array;

#if howlerjs
import lime.media.howlerjs.Howl;
#end
#if (js && html5)
import js.html.Audio;
#elseif flash
import flash.media.Sound;
import flash.net.URLRequest;
#elseif lime_console
import lime.media.fmod.FMODMode;
import lime.media.fmod.FMODSound;
#end

@:access(lime._backend.native.NativeCFFI)
@:access(lime.Assets)

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class AudioBuffer {
	
	
	public var bitsPerSample:Int;
	public var channels:Int;
	public var data:UInt8Array;
	public var sampleRate:Int;
	public var src (get, set):Dynamic;
	
	@:noCompletion private var __srcAudio:#if (js && html5) Audio #else Dynamic #end;
	@:noCompletion private var __srcBuffer:#if lime_cffi ALBuffer #else Dynamic #end;
	@:noCompletion private var __srcCustom:Dynamic;
	@:noCompletion private var __srcFMODSound:#if lime_console FMODSound #else Dynamic #end;
	@:noCompletion private var __srcHowl:#if howlerjs Howl #else Dynamic #end;
	@:noCompletion private var __srcSound:#if flash Sound #else Dynamic #end;
	@:noCompletion private var __srcVorbisFile:#if lime_vorbis VorbisFile #else Dynamic #end;
	
	
	public function new () {
		
		
		
	}
	
	
	public function dispose ():Void {
		
		#if (js && html5 && howlerjs)
		
		__srcHowl.unload ();
		
		#elseif lime_console
		if (channels > 0) {
			
			src.release ();
			channels = 0;
			
		}
		#end
		
	}
	
	
	#if lime_console
	@:void
	private static function finalize (a:AudioBuffer):Void {
		
		a.dispose ();
		
	}
	#end
	
	
	public static function fromBytes (bytes:Bytes):AudioBuffer {
		
		if (bytes == null) return null;
		
		#if lime_console
		
		lime.Lib.notImplemented ("AudioBuffer.fromBytes");
		
		#elseif (lime_cffi && !macro)
		#if !cs
		
		var audioBuffer = new AudioBuffer ();
		audioBuffer.data = new UInt8Array (Bytes.alloc (0));
		
		return NativeCFFI.lime_audio_load (bytes, audioBuffer);
		
		#else
		
		var data:Dynamic = NativeCFFI.lime_audio_load (bytes, null);
		
		if (data != null) {
			
			var audioBuffer = new AudioBuffer ();
			audioBuffer.bitsPerSample = data.bitsPerSample;
			audioBuffer.channels = data.channels;
			audioBuffer.data = new UInt8Array (@:privateAccess new Bytes (data.data.length, data.data.b));
			audioBuffer.sampleRate = data.sampleRate;
			return audioBuffer;
			
		}
		
		#end
		#end
		
		return null;
		
	}
	
	
	public static function fromFile (path:String):AudioBuffer {
		
		if (path == null) return null;
		
		#if (js && html5 && howlerjs)
		
		var audioBuffer = new AudioBuffer ();
		audioBuffer.__srcHowl = new Howl ({ src: [ path ], preload: false });
		return audioBuffer;
		
		#elseif flash
		
		switch (Path.extension (path)) {
			
			case "ogg", "wav": return null;
			default:
			
		}
		
		var audioBuffer = new AudioBuffer ();
		audioBuffer.__srcSound = new Sound (new URLRequest (path));
		return audioBuffer;
		
		#elseif lime_console
		
		var mode = StringTools.endsWith(path, ".wav") ? FMODMode.LOOP_OFF : FMODMode.LOOP_NORMAL;
		var sound:FMODSound = FMODSound.fromFile (path, mode);
		
		if (sound.valid) {
			
			// TODO(james4k): AudioBuffer needs sound info filled in
			// TODO(james4k): probably move fmod.Sound creation to AudioSource,
			// and keep AudioBuffer as raw data. not as efficient for typical
			// use, but probably less efficient to do complex copy-on-read
			// mechanisms and such. also, what do we do for compressed sounds?
			// usually don't want to decompress large music files. I suppose we
			// can specialize for those and not allow data access.
			var audioBuffer = new AudioBuffer ();
			audioBuffer.bitsPerSample = 0;
			audioBuffer.channels = 1;
			audioBuffer.data = null;
			audioBuffer.sampleRate = 0;
			audioBuffer.__srcFMODSound = sound;
			cpp.vm.Gc.setFinalizer (audioBuffer, cpp.Function.fromStaticFunction (finalize));
			return audioBuffer;
			
		}
		
		#elseif (lime_cffi && !macro)
		#if !cs
		
		var audioBuffer = new AudioBuffer ();
		audioBuffer.data = new UInt8Array (Bytes.alloc (0));
		
		return NativeCFFI.lime_audio_load (path, audioBuffer);
		
		#else
		
		var data:Dynamic = NativeCFFI.lime_audio_load (path, null);
		
		if (data != null) {
			
			var audioBuffer = new AudioBuffer ();
			audioBuffer.bitsPerSample = data.bitsPerSample;
			audioBuffer.channels = data.channels;
			audioBuffer.data = new UInt8Array (@:privateAccess new Bytes (data.data.length, data.data.b));
			audioBuffer.sampleRate = data.sampleRate;
			return audioBuffer;
			
		}
		
		return null;
		
		#end
		#else
		
		return null;
		
		#end
		
	}
	
	
	public static function fromFiles (paths:Array<String>):AudioBuffer {
		
		#if (js && html5 && howlerjs)
		
		var audioBuffer = new AudioBuffer ();
		audioBuffer.__srcHowl = new Howl ({ src: paths, preload: false });
		return audioBuffer;
		
		#else
		
		var buffer = null;
		
		for (path in paths) {
			
			buffer = AudioBuffer.fromFile (path);
			if (buffer != null) break;
			
		}
		
		return buffer;
		
		#end
		
	}
	
	
	#if lime_vorbis
	
	public static function fromVorbisFile (vorbisFile:VorbisFile):AudioBuffer {
		
		if (vorbisFile == null) return null;
		
		var info = vorbisFile.info ();
		
		var audioBuffer = new AudioBuffer ();
		audioBuffer.channels = info.channels;
		audioBuffer.sampleRate = info.rate;
		audioBuffer.bitsPerSample = 16;
		audioBuffer.__srcVorbisFile = vorbisFile;
		
		return audioBuffer;
		
	}
	
	#else
	
	public static function fromVorbisFile (vorbisFile:Dynamic):AudioBuffer {
		
		return null;
		
	}
	
	#end
	
	
	public static function loadFromFile (path:String):Future<AudioBuffer> {
		
		#if (flash || (js && html5))
		
		var promise = new Promise<AudioBuffer> ();
		
		var audioBuffer = AudioBuffer.fromFile (path);
		
		if (audioBuffer != null) {
			
			#if flash
			
			audioBuffer.__srcSound.addEventListener (flash.events.Event.COMPLETE, function (event) {
				
				promise.complete (audioBuffer);
				
			});
			
			audioBuffer.__srcSound.addEventListener (flash.events.ProgressEvent.PROGRESS, function (event) {
				
				promise.progress (event.bytesLoaded, event.bytesTotal);
				
			});
			
			audioBuffer.__srcSound.addEventListener (flash.events.IOErrorEvent.IO_ERROR, promise.error);
			
			#elseif (js && html5 && howlerjs)
			
			if (audioBuffer != null) {
				
				audioBuffer.__srcHowl.on ("load", function () { 
					
					promise.complete (audioBuffer);
					
				});
				
				audioBuffer.__srcHowl.on ("loaderror", function (id, msg) {
					
					promise.error (msg);
					
				});
				
				audioBuffer.__srcHowl.load ();
				
			}
			
			#else
			
			promise.complete (audioBuffer);
			
			#end
			
		} else {
			
			promise.error (null);
			
		}
		
		return promise.future;
		
		#else
		
		// TODO: Streaming
		
		var request = new HTTPRequest<AudioBuffer> ();
		return request.load (path).then (function (buffer) {
			
			if (buffer != null) {
				
				return Future.withValue (buffer);
				
			} else {
				
				return cast Future.withError ("");
				
			}
			
		});
		
		#end
		
	}
	
	
	public static function loadFromFiles (paths:Array<String>):Future<AudioBuffer> {
		
		var promise = new Promise<AudioBuffer> ();
		
		#if (js && html5 && howlerjs)
		
		var audioBuffer = AudioBuffer.fromFiles (paths);
		
		if (audioBuffer != null) {
			
			audioBuffer.__srcHowl.on ("load", function () { 
				
				promise.complete (audioBuffer);
				
			});
			
			audioBuffer.__srcHowl.on ("loaderror", function () {
				
				promise.error (null);
				
			});
			
			audioBuffer.__srcHowl.load ();
			
		} else {
			
			promise.error (null);
			
		}
		
		#else
		
		promise.completeWith (new Future<AudioBuffer> (function () return fromFiles (paths), true));
		
		#end
		
		return promise.future;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_src ():Dynamic {
		
		#if (js && html5)
		#if howlerjs
		
		return __srcHowl;
		
		#else
		
		return __srcAudio;
		
		#end
		#elseif flash
		
		return __srcSound;
		
		#elseif lime_console
		
		return __srcFMODSound;
		
		#elseif lime_vorbis
		
		return __srcVorbisFile;
		
		#else
		
		return __srcCustom;
		
		#end
		
	}
	
	
	private function set_src (value:Dynamic):Dynamic {
		
		#if (js && html5)
		#if howlerjs
		
		return __srcHowl = value;
		
		#else
		
		return __srcAudio = value;
		
		#end
		#elseif flash
		
		return __srcSound = value;
		
		#elseif lime_console
		
		return __srcFMODSound = value;
		
		#elseif lime_vorbis
		
		return __srcVorbisFile = value;
		
		#else
		
		return __srcCustom = value;
		
		#end
		
	}
	
	
}