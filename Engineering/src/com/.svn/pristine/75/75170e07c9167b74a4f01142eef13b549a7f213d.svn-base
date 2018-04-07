//
// Copyright (C) 2006-2017, 1st Playable Productions, LLC. All rights reserved.
//
// UNPUBLISHED -- Rights reserved under the copyright laws of the United
// States. Use of a copyright notice is precautionary only and does not
// imply publication or disclosure.
//
// THIS DOCUMENTATION CONTAINS CONFIDENTIAL AND PROPRIETARY INFORMATION
// OF 1ST PLAYABLE PRODUCTIONS, LLC. ANY DUPLICATION, MODIFICATION,
// DISTRIBUTION, OR DISCLOSURE IS STRICTLY PROHIBITED WITHOUT THE PRIOR
// EXPRESS WRITTEN PERMISSION OF 1ST PLAYABLE PRODUCTIONS, LLC.
///////////////////////////////////////////////////////////////////////////

package com.firstplayable.hxlib.audio;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.events.VolumeChangedEvent;
import com.firstplayable.hxlib.loader.ResMan;
import flash.events.EventDispatcher;
import haxe.ds.StringMap;
#if js
#if ( lime > "3.0" )
import lime.media.howlerjs.Howl;
import lime.media.howlerjs.Howler;
#else
import howler.Howl;
import howler.Howler;
#end
#else //if js
import openfl.media.Sound;
import openfl.media.SoundMixer;
#end
import haxe.io.Bytes;
import motion.Actuate;
import motion.actuators.GenericActuator;
import openfl.events.Event;
import openfl.events.EventDispatcher;

using StringTools;
using com.firstplayable.hxlib.audio.WebAudioObject;
using com.firstplayable.hxlib.utils.Utils;

//#if !js
	//#error "WebAudio is only supported in html5 target."
//#end
#if js
//#if (!howlerjs || howlerjs < "1.1.25")
//#error "Could not find haxelib 'howlerjs 1.1.25', does it need to be installed?"
//#end
#end

class WebAudio
{
	private static var HUSH( default, null ):Bool = true;
	
	private static inline var VOL_DEFAULT:Float = 			0.85;
	private static inline var VOL_DEFAULT_SFX:Float = 		VOL_DEFAULT;
	private static inline var VOL_DEFAULT_VO:Float = 		1.0;
	private static inline var VOL_DEFAULT_JINGLE:Float = 	0.9;
	private static inline var VOL_DEFAULT_BGM:Float = 		0.65;
	private static inline var VOL_DEFAULT_MOVIE:Float =     1.0;
	private static inline var VOL_DUCKED_BGM:Float = 		0.4;
	private static inline var BGM_DUCK_MS:Int =				8;
	private static inline var BGM_UNDUCK_MS:Int =			12;
    
    
	/**
	 * Class singleton.
	 */
	public static var instance(get, null):WebAudio;
	
	/**
	 * Globally mutes or unmutes audio.
	 */
	public static var mute(default, set):Bool = false;
	public static var muteBgm(default, set):Bool = false;
	public static var muteSfx:Bool = false;
	public static var muteMovie(default, set):Bool = false;
	
	/**
	 * The global volume level.
	 */
	public static var volume(default, set):Float = VOL_DEFAULT;
	public static var bgmVolume(default, set):Float = VOL_DEFAULT_BGM;
	public static var duckedBgmVolume(default, default) = VOL_DUCKED_BGM;
	public static var movieVolume(default, set):Float = VOL_DEFAULT_MOVIE;
	
	#if !js
	public static var preMuteVolume:Float = VOL_DEFAULT;
	public static var preMuteBgmVolume:Float = VOL_DEFAULT_BGM;
	public static var preMuteMovieVolume:Float = VOL_DEFAULT_MOVIE;
	#end
	
	/**
	 * Change the max size of the queue length. Set to 0 for infinte.
	 */
	public var qLimit:Int = 0;
	
	private static var m_curBgm:WebAudioObject = null;
	private static var m_curBgmID:Int;
	#if !js
	private static var m_bgmTimer:GenericActuator<Dynamic> = null;
	#end

	//local props
	#if js
	private var m_audioOptions:StringMap<HowlOptions>;	//options to store lightweight unloaded audio
	#else
	private var m_audioOptions:StringMap<Array<String>>; //string ID to url map
	#end
	private var m_audioLoads:StringMap<WebAudioObject>;	//storing loaded audio
	private var m_audioQ:Array<WebAudioObject>;			//storing active audio
	private var m_curSnd:WebAudioObject;				//storing currentaudio
	
	private var m_doneCallback:Void->Void;				//called when loading is finished
	
	public var event:EventDispatcher;					//Target for audio setting events.
	
	private static function get_instance():WebAudio
	{
		if ( instance == null )
		{
			instance = new WebAudio();	
			mute = false;
		}
				
		return instance;
	}
	
	//setter for mute
	private static function set_mute( muted:Bool ):Bool
	{
		//TODO: Howler.mute() does not seem to work in CocoonJS environment, but volume() is functional in all environments.
		//Howler.mute( muted );
		#if js
		muted ? Howler.volume( 0 ) : Howler.volume( 1 );
		return mute = muted;
		#else
		if (muted)
		{
			if (!mute)
			{
				preMuteVolume = volume;
			}
			WebAudio.set_volume(0.0);
		}
		else
		{
			WebAudio.set_volume(preMuteVolume);
		}
		set_muteBgm(muted);
		set_muteMovie(muted);
		return mute = muted;
		#end
	}
	
	private static function set_muteBgm( muted:Bool ):Bool
	{
		#if js
		// TODO: Could cache the old volume as a negative value and rely on clamping
		//		 to do the right thing, if that becomes an issue.
		bgmVolume = muted ? 0 : VOL_DEFAULT_BGM;
		return muteBgm = muted;
		#else
		if(muted)
		{
			if (!muteBgm)
			{
				preMuteBgmVolume = bgmVolume;
			}
			WebAudio.set_bgmVolume(0.0);
		}
		else
		{
			WebAudio.set_bgmVolume(preMuteBgmVolume);
		}
		return muteBgm = muted;
		#end
	}
	
	private static function set_muteMovie(muted:Bool):Bool
	{
		#if js
		// TODO: Could cache the old volume as a negative value and rely on clamping
		//	to do the right thing, if that becomes an issue.
		movieVolume = muted ? 0 : VOL_DEFAULT_MOVIE;
		
		return muteMovie = muted;
		#else
		if (muted)
		{
			if (!muteMovie)
			{
				preMuteMovieVolume = movieVolume;
			}
			WebAudio.set_movieVolume(0.0);
		}
		else
		{
			WebAudio.set_movieVolume(preMuteMovieVolume);
		}
		return muteMovie = muted;
		#end
	}
	
	//setter for volume
	private static function set_volume( newVolume:Float ):Float
	{
		#if js
		return volume = Howler.volume( newVolume );
		#else
		if (instance.m_curSnd != null && instance.m_curSnd.isValid() && instance.m_curSnd.channel != null)
		{
			instance.m_curSnd.transform.volume = Math.max( 0, Math.min( newVolume, 1.0 ) );
			instance.m_curSnd.channel.soundTransform = instance.m_curSnd.transform;
		}
		return volume = newVolume;
		#end
	}

	private static function set_bgmVolume( vol:Float ):Float
	{
		if (m_curBgm != null && m_curBgm.isValid())
		{	
			#if js
			m_curBgm.sound.volume( Math.max( 0, Math.min( vol, 1.0 ) ) );
			#else
			if (m_curBgm.channel != null)
			{
				m_curBgm.transform.volume = Math.max( 0, Math.min( vol, 1.0 ) );
				m_curBgm.channel.soundTransform = m_curBgm.transform;
			}
			#end
		}

		return bgmVolume = vol;
	}
	
	private static function set_movieVolume( vol:Float ):Float
	{
		instance.event.dispatchEvent(new VolumeChangedEvent(VolumeChangedEvent.VOLUME_CHANGED_MOVIE, vol));

		return movieVolume = vol;
	}
	
	/**
	 * Construct WebAudio
	 */
	private function new()
	{
		m_audioOptions = new StringMap();
		m_audioLoads = new StringMap();
		m_audioQ = [];
		
		//mute = false; //NOTE: this is handled in get_instance and is not safe to do here.
		
		event = new EventDispatcher();
	}
	
	/**
	 * Stops the current sound and clears the queue.
	 */
	public function interrupt():Void
	{
		if (!HUSH) { Debug.log( "interrupting sounds..." + m_audioQ ); }
		m_audioQ = [];
		
		if( m_curSnd != null && m_curSnd.isValid() )
		{
			#if js
			m_curSnd.sound.off( "end", null );
			m_curSnd.sound.pause();
			m_curSnd.sound.seek( 0 );
			#else
			m_curSnd.pausePosition = 0;
			if (m_curSnd.channel != null)
			{
				m_curSnd.channel.stop();
				m_curSnd.channel = null;
			}
			#end
		}
		
		stop();
	}
	
	/**
	 * Stops all active audio, other than the bgm
	 * TODO: not tested with the queue. May need adjustments.
	 */
	public function stopAllSounds():Void
	{	
		for (loads in m_audioLoads)
		{
			if (!loads.isValid())
			{
				continue;
			}
			if (loads == m_curBgm)
			{
				continue;
			}
			
			#if js
			loads.sound.off( "end", null );
			loads.sound.stop();
			#else
			if (loads.channel != null)
			{
				loads.channel.stop();
				loads.channel = null;
			}
			#end
		}
	}
	
	/**
	 * Maps sound info for reference. Register must be called before a sound can be loaded or used.
	 * @param	url		the file path to the sound, "snd/MY_SOUND.m4a". If one is not provided, the url is used.
	 * @param	id		the id of the sound, "MY_SOUND"
	 */
	public function register( url:String, id:String = null ):Void
	{
		multiRegister( [url], id );
	}
	
	/**
	 * Same as register(), but allows you to specify multiple urls; use this if you want to 
	 * have eg a .ogg and a .m4a of the same sound
	 */
	public function multiRegister( urls:Array<String>, id:String = null ):Void
	{
		var sndName:String = ( id == null ) ? urls[ 0 ] : id;
		sndName = sndName.toLowerCase();
		
		#if js
		var options:HowlOptions = { src: urls };
		//options.src = urls;
		options.onplay = onPlay;
		options.onpause = onPause;
		options.onload = function () onLoad( sndName );
		options.onloaderror = function () onLoadError( sndName );
		options.autoplay = false;
		
		if (m_audioOptions.exists(sndName))
		{
			Debug.warn('Failed to register sound with duplicate id: $sndName');
		}
		else
		{
			m_audioOptions.set( sndName, options );
		}
		#else
		m_audioOptions.set(sndName, urls);
		var srcURL:String = urls[0];
		#if ( ios || android )
		for ( url in urls )
		{
			if ( url.endsWith( ".ogg" ) )
			{
				srcURL = url; // prefer first .ogg entry; TODO better fix
				break;
			}
		}
		#end
		ResMan.instance.addRes( "WebAudio", { src : srcURL, rename : sndName } );
		#end
	}
	
	public function has( id:String ):Bool
	{
		return ( m_audioLoads.get( id ) != null );
	}

	public function duration( id:String ):Float
	{
		id = id.toLowerCase();
		var sound = m_audioLoads.get( id );
		
		#if js
		return sound == null ? 0 : sound.sound.duration();
		#else
		if (sound != null)
		{
			if (sound.isValid())
			{
				return sound.sound.length;
			}
		}
		return 0;
		#end
	}
	
	/**
	 * Unloads and destroys sounds. This will immediately stop all play instances attached to the sounds and remove them from the cache.
	 * @param	ids		List of sound ids, ["MY_SOUND","MY_SOUND2"]
	 */
	public function unload( ids:Array<String> ):Void
	{
		#if js
		if (!HUSH) { Debug.log( "unloading " + ids ); }
		
		for ( id in ids )
		{
			id = id.toLowerCase();
			var sound:WebAudioObject = m_audioLoads.get( id );
			
			if ( !sound.isValid() )
			{
				if (!HUSH) { Debug.log( "sound '" + id + "' not available - load it first" ); }
				continue;
			}
			
			sound.sound.unload();
			m_audioLoads.remove( id );
		}
		#else
		//NOOP
		#end
		
	}
	
	/**
	 * Load a list of sounds into the library for later use.
	 * @param	ids		List of sound ids, ["MY_SOUND","MY_SOUND2"]
	 * @param	onDone	A function to call when loads complete.
	 */
	public function load( ids:Array<String>, onDone:Void->Void = null ):Void
	{
		m_doneCallback = onDone;
		
		#if js
		if (!HUSH) { Debug.log( "loading " + ids ); }
		for ( id in ids )
		{
			id = id.toLowerCase();
			if ( m_audioLoads.exists( id ) )
			{
				if (!HUSH) { Debug.log( "sound '" + id + "' is already loaded - skipping..." ); }
				continue;
			}
			
			var opts = m_audioOptions.get( id );
			
			if ( opts == null )
			{
				if (!HUSH) { Debug.log( "sound '" + id + "' not available - register it first" ); }
				continue;
			}
		
			var snd:WebAudioObject = new WebAudioObject( id , new Howl( opts ) ); //load audio
			m_audioLoads.set( id, snd );
		}
		
		checkDoneLoading();
		#else //if js
		//TODO: this loads everything regardless of which ids you pass in
		ResMan.instance.load("WebAudio", onLoadsComplete);
		for (id in ids)
		{
			id = id.toLowerCase();
			m_audioLoads.set(id, null);
		}
		#end
	}
	
	//triggered for each load completed
	private function onLoad( id:String ):Void
	{
		#if js
		if ( id != null )
		{
			var wao:WebAudioObject = m_audioLoads.get( id );
			if ( wao != null )
			{
				//Debug.log( 'Sound: Loaded $id' );
			}
			else
			{
				Debug.log( 'A sound loaded that we are not tracking: $id' );
			}
		}
		else
		{
			Debug.log( 'A sound loaded with id=null.' );
		}

		checkDoneLoading();
		#else
		//NOOP
		#end
	}
	
	//triggered for each load failed
	private function onLoadError( id:String ):Void
	{
		#if js
		Debug.log( 'A sound failed to load: $id' );
		
		// On load error, things get stuck in "loading" state; need to remove from m_audioLoads.
		m_audioLoads.remove( id );
		
		checkDoneLoading();
		#else
		//NOOP
		#end
	}
	
	//determines if sounds loading are completed
	private function checkDoneLoading():Void
	{
		#if js
		for ( audioObj in m_audioLoads )
		{
			// Seeing a compile error on state()?
			// `haxelib update howlerjs` (until you are >= 2.0.3), then
			// update project.xml howlerjs version, then
			// put a new howler.min.js in your assets\data\lib.
			// Be sure to check in .hxproj, .xml, and .js changes!
			if ( audioObj.sound.state() == "loading" )
			{
				// Something is still loading.
				//Debug.log( "Sound: Still waiting on: " + audioObj.id );
				return;
			}
			
		}
		
		
		onLoadsComplete();
		#else
		//NOOP
		#end
	}
	
	//when lists finish loading
	private function onLoadsComplete():Void
	{
		#if js
		if (!HUSH) { Debug.log( "sounds loaded" ); }

		var failed:Array<String> = [];
		
		for ( id in m_audioOptions.keys() )
		{
			if ( !m_audioLoads.exists( id ) )
			{
				failed.push( id );
			}
		}
		
		for ( webAudioObj in m_audioLoads )
		{
			// See "compile error" note above.
			if ( webAudioObj.sound == null || ( webAudioObj.sound.state() != "loaded" ) )
			{
				failed.push( webAudioObj.id );
			}
		}
			
		if (!HUSH) { Debug.log( "The following sounds failed to load... " + failed ); }
		#else
		
		for ( id in m_audioLoads.keys() )
		{
			var opts = m_audioOptions.get( id );
			
			if ( opts == null )
			{
				if (!HUSH) { Debug.log( "sound '" + id + "' not available - register it first" ); }
				continue;
			}
		
			var snd:WebAudioObject = new WebAudioObject( id , ResMan.instance.getSound(id)); //load audio
			m_audioLoads.set( id, snd );
		}
		#end
		
		if ( m_doneCallback != null )
		{
			m_doneCallback();
		}
	}
	
	//triggered when a sound is told to play
	private function onPlay( ?id:Int ):Void
	{
		#if js
		if (!HUSH) { Debug.log( "sound start " + id ); }

		if ( !m_curSnd.isValid() ) 
		{
			if (!HUSH) { Debug.log("m_curSnd is null"); }
			return;
		}
		#else
		//NOOP
		#end
	}

	//triggered when a sound is paused
	private function onPause( ?id:Int ):Void
	{
		#if js
		if ( !m_curSnd.isValid() ) return;
		if (!HUSH) { Debug.log( "sound paused " + id ); }
		#end
	}
	
	//triggered when a sound ends
	private function onEnd( ?id:Int ):Void
	{
		if (!HUSH) { Debug.log( "sound ended " + id ); }

		if ( !m_curSnd.isValid() ) 
		{
			if (!HUSH) { Debug.log("m_curSnd is null"); }
			return;
		}
		
		playNext();
	}
	
	//attempts to play the next sound in the queue
	private function playNext():Void
	{
		#if js
		if ( m_curSnd.isValid() && m_curSnd.sound.playing()	)
		{
			if (!HUSH) { Debug.log("still playing, skipping..."); }
			return;
		}

		m_curSnd = m_audioQ.shift();
		if ( m_curSnd.isValid() )
		{
			m_curSnd.sound.play();
		}
		#else
		if (m_curSnd.isValid() && m_curSnd.channel != null)
		{
			if (!HUSH) { Debug.log("still playing, skipping..."); }
			return;
		}
		m_curSnd = m_audioQ.shift();
		if (m_curSnd.isValid())
		{
			m_curSnd.channel = m_curSnd.sound.play(0.0, 0, m_curSnd.transform);
			while (m_curSnd.callbacks.length > 0)
			{
				var cb:Dynamic->Void = m_curSnd.callbacks.pop();
				m_curSnd.channel.safeAddListener( Event.SOUND_COMPLETE, cb );
			}
		}
		#end		
	}
	
	/**
	 * Pauses all currently playing sounds (including BGM), otherwise does nothing.
	 */
	public function pause():Void
	{
		if ( m_curSnd.isValid() )
		{
			#if js
			m_curSnd.sound.pause();
			#else
			if (m_curSnd.channel != null)
			{
				m_curSnd.pausePosition = m_curSnd.channel.position;
				m_curSnd.channel.stop();
				m_curSnd.channel = null;
			}
			#end
		}
		
		pauseBGM();
	}
	
	/**
	 * Unpauses all currently paused sounds (including BGM), otherwise does nothing.
	 */
	public function resume():Void
	{
		resumeBGM();
		
		if ( !m_curSnd.isValid() ) return;
		#if js
		m_curSnd.sound.play();
		//TODO: replace with sound id, eventually
		if (!HUSH) { Debug.log( "sound resumed; duration = " + m_curSnd.sound.duration ); }
		#else
		m_curSnd.channel = m_curSnd.sound.play(m_curSnd.pausePosition, 0, m_curSnd.transform);
		#end
	}
	
	/**
	 * Stops the currently playing sound. Will start the next sound in the queue if there is one.
	 * Does NOT stop BGM; call stopBGM() for that.
	 */
	public function stop(?id:String):Void
	{
		if (id != null)
		{
			stopID(id);
		}
		else
		{
			if ( !m_curSnd.isValid() )
			{
				if (!HUSH) { Debug.log("m_curSnd is null"); }
				return;
			}
		
			if (!HUSH) { Debug.log( "stopping sound " ); }
			#if js
			m_curSnd.sound.stop();
			#else
			if (m_curSnd.channel != null)
			{
				m_curSnd.channel.stop();
				m_curSnd.channel = null;
			}
			#end
			onEnd();
		}
	}
	
	
	
	/**
	 * Stops all instances of the sound that matches the ID. Not useful for queue
	 * Does NOT stop BGM; call stopBGM() for that.
	 */
	public function stopID(id:String):Void
	{
	
		id = id.toLowerCase();
		
		#if js
		if (m_audioLoads.exists(id))
		{
			var sound = m_audioLoads.get(id);
			sound.sound.stop();
			if (!HUSH) { Debug.log( "stopping sound " + id ); }
		}
		#else
		if (m_curSnd.isValid() && m_curSnd.id == id)
		{
			if (m_curSnd.channel != null)
			{
				m_curSnd.channel.stop();
				m_curSnd.channel = null;
			}
		}
		//TODO: see if this is actually safe in haxe
		for (snd in m_audioQ)
		{
			if (snd.id == id)
			{
				//m_audioQ.remove(snd);  //TODO: this but safely
			}
		}
		#end
	}
	
	
	/**
	 * Play a sound by its id. Adds the sound to the end of the queue. The sound will override the last element of the queue if the queue is full. 
	 * @param	id		The id of the sound to play, "MY_SOUND"
	 * @param	vol		The volume for the sound to play at, clamped to a range of 0.0 and 1.0
	 */
	//NOTE:	I expect the volume set will be "sticky" for the id, but haven't verified
	public function play( id:String, ?callback:Void -> Void, ?vol:Float = VOL_DEFAULT_SFX, ?bgmduck:Bool = false ):Void
	{
		id = id.toLowerCase();
		var sound = m_audioLoads.get( id );
		
		if ( sound == null )
		{
			if (!HUSH) { Debug.log( "sound '" + id + "' not available - load it first" ); }
			
			if ( callback != null )
			{
				callback();
			}
			
			return;
		}

		if (!HUSH) { Debug.log( "Playing sound " + id + " with volume " + Std.string( vol ) ); }
		
		
		//TODO:	Need a better way of handling this
		//		Suggest breaking this out into separate calls for VO, etc.
		var isSFX:Bool = ( id.indexOf( "sfx" ) > -1 );
		
		if (vol != null)
		{
			// Valid volume is between 0.0 and 1.0
			#if js
			sound.sound.volume( Math.max( 0, Math.min( vol, 1.0 ) ) );
			#else
			sound.transform.volume =  Math.max( 0, Math.min( vol, 1.0 ) );
			#end
		}
				
		if (callback != null)
		{
			#if js
			sound.sound.once("end", callback);
			#else
			function cbwrapper(arg:Dynamic):Void
			{
				callback();
			}
			sound.callbacks.push(cbwrapper);
			#end
		}
		
		if (bgmduck)
		{
			duckBGM();
			#if js
			sound.sound.once("end", unDuckBGM);
			#else
			function unduckWrapper(arg:Dynamic)
			{
				unDuckBGM();
			}
			
			sound.callbacks.push(unduckWrapper);
			#end
		}
		
		if (!isSFX)
		{
			#if js
			sound.sound.once("end", onEnd);
			#else
			sound.callbacks.push(onEnd);
			#end
		}
		
		//if sfx, play now and skip queue
		if (isSFX)
		{
			if (muteSfx)
			{
				#if js
				sound.sound.volume(0);
				#else
				sound.transform.volume = 0;
				#end
			}

			#if js
			sound.sound.play();
			#else
			sound.channel = sound.sound.play(0, 0, sound.transform);
			while (sound.callbacks.length > 0)
			{
				var cb:Dynamic->Void = sound.callbacks.pop();
				sound.channel.safeAddListener( Event.SOUND_COMPLETE, cb );
			}
			#end
			
			return;
		}
		
		//if queue is full, pop last element off
		if ( m_audioQ.length == qLimit )
		{
			m_audioQ.pop();
		}
		
		m_audioQ.push( sound );
		playNext();
	}
	
	/**
	 * Play a VO by through play() but forcing VOL_DEFAULT_VO.
	 * @param	id		The id of the sound to play, "MY_SOUND"
	 * @param	vol		The volume for the sound to play at, clamped to a range of 0.0 and 1.0
	 */
	//NOTE:	I expect the volume set will be "sticky" for the id, but haven't verified
	public function playVO( id:String, ?callback:Void -> Void, ?vol:Float = VOL_DEFAULT_VO, ?bgmduck:Bool = true ):Void
	{
		play( id, callback, vol, bgmduck );
	}
	
	/**
	 * Play a Jingle by through play() but forcing VOL_DEFAULT_JINGLE.
	 * @param	id		The id of the sound to play, "MY_SOUND"
	 * @param	vol		The volume for the sound to play at, clamped to a range of 0.0 and 1.0
	 */
	//NOTE:	I expect the volume set will be "sticky" for the id, but haven't verified
	public function playJingle( id:String, ?callback:Void -> Void, ?vol:Float = VOL_DEFAULT_JINGLE, ?bgmduck:Bool = true ):Void
	{
		play( id, callback, vol, bgmduck );
	}
	
	/**
	 * Checks whether the specified sound is playing.
	 * Note: will NOT currently work for any sound with
	 * the "SFX_" prefix, as these are not tracked.
	 * @param	id - The id of the sound to check. 
	 * 				Do NOT pass an ID that starts with "SFX_"
	 * @return	true, if the sound is playing and its id 
	 * 			does not start with "SFX_"; false, otherwise.
	 */
	public function isSoundPlaying( id:String ):Bool
	{
		#if js
		if ( m_curSnd.isValid() && m_curSnd.id == id && m_curSnd.sound.playing() )
		{
			return true;
		}
		#else
		if (m_curSnd.isValid() && m_curSnd.id == id && m_curSnd.channel != null)
		{
			return true;
		}
		#end
		return false;
	}
	
	/**
	 * Checks whether the currently playing sound starts with "VO_".
	 * @return	true, if m_curSnd.id starts with "VO_"; false, otherwise.
	 */
	public function isVOPlaying():Bool
	{
		if ( isSoundPlaying(m_curSnd.id))
		{
			var lowerId:String = m_curSnd.id.toLowerCase();
			var isVO:Bool = ( lowerId.indexOf( "vo_" ) == 0 );
			if (isVO)
			{
				return true;
			}
		}
		return false;
	}
	
	
	/**
	 * Plays a looping sound as background music; if a different bgm is already playing, that
	 * music will be stopped. 
	 * @param	id - The ID of the bgm to play, eg "BGM_MUSIC1"
	 * @param	restart - Determines whether or not to restart the bgm, if id matches the id
	 * 				of the currently playing music. Defaults to true (music will restart from the beginning). 
	 * @param	vol - The volume for the sound to play at, clamped to a range of 0.0 and 1.0
	 */
	//NOTE:	I expect the volume set will be "sticky" for the id, but haven't verified
	public function playBGM( id:String, ?restart:Bool = true, ?vol:Float ):Void
	{
		id = id.toLowerCase();
		if ( !restart && m_curBgm != null && m_audioLoads.get( id ) == m_curBgm )
		{
			// EARLY RETURN - the requested bgm is already playing, and we don't want to restart it
			return;
		}

		if (vol == null)
		{
			vol = bgmVolume;
		}
		
		stopBGM();
		
		m_curBgm = m_audioLoads.get( id );
		
		if ( m_curBgm == null )
		{
			if (!HUSH) { Debug.warn( "music '" + id + "' not available - load it first" ); }
			// EARLY RETURN
			return;
		}
		
		if (!HUSH) { Debug.log( "play music " + id ); }
		
		#if js
		m_curBgm.sound.volume( Math.max( 0, Math.min( vol, 1.0 ) ) );
		m_curBgmID = m_curBgm.sound.play();
		m_curBgm.sound.loop(true, m_curBgmID);
		#else
		m_curBgm.transform.volume = Math.max( 0, Math.min( vol, 1.0 ) );
		m_curBgm.channel = m_curBgm.sound.play(0, 0, m_curBgm.transform);
		Actuate.stop( m_bgmTimer, null, false, false );
		
		// The length returned by openfl.media.Sound is in milliseconds
		// Actuate expects a duration that is in seconds
		var duration = (m_curBgm.sound.length / 1000);
		
		if ( duration > 0 ) {
			m_bgmTimer = Actuate.timer( duration ).onComplete( loopBGM );
		}
		#end
	}
	
	public function resumeBGMTimer():Void
	{
		#if !js
		if ( m_bgmTimer != null )
		{
			Actuate.resume( m_bgmTimer );
		}
		#end
	}
	
	private function loopBGM():Void
	{
		#if js
		playBGM( m_curBgm.id, true, m_curBgm.sound.volume() );		
		#else
		playBGM( m_curBgm.id, true, m_curBgm.transform.volume );		
		#end
	}
	
	public function stopBGM():Void
	{		
		if ( m_curBgm.isValid() )
		{
			#if js
			m_curBgm.sound.stop();
			#else
			if ( m_bgmTimer != null )
			{
				Actuate.stop( m_bgmTimer, null, false, false );
			}
			
			if (m_curBgm.channel != null)
			{
				m_curBgm.channel.stop();
				m_curBgm.channel = null;
			}
			#end
		}
	}
	
	public function pauseBGM():Void
	{
		//TODO: this won't resume where it left off
		stopBGM();
	}
	
	public function resumeBGM():Void
	{
		if ( m_curBgm.isValid() )
		{
			#if js
			if ( m_curBgm.isValid() )
			{
				m_curBgmID = m_curBgm.sound.play();
				m_curBgm.sound.loop( true, m_curBgmID );
			}
			#else
			m_curBgm.channel = m_curBgm.sound.play(0,0,m_curBgm.transform);
			Actuate.stop( m_bgmTimer, null, false, false );
			m_bgmTimer = Actuate.timer( m_curBgm.sound.length ).onComplete( loopBGM );
			#end
		}
	}

	/**
	  *  @param play (optional) Whether to play or stop the music.  If omitted,
	  *							a true toggle.
	  *  $return	True if we resumed the music, false if we stoipped it.
	  */
	public function toggleBGM(?play:Bool):Bool
	{
		if (m_curBgm == null)
		{
			Debug.log_if(!HUSH, "No BGM to toggle!");
			return false;
		}
		
		if (play == null)
		{
			#if js
			play = !m_curBgm.sound.playing();
			#else
			play = !(m_curBgm.channel == null);
			#end
		}

		if (play)
		{
			resumeBGM();
		}
		else
		{
			stopBGM();
		}

		return play;
	}
	
	public function duckBGM():Void
	{
		#if js
		if (m_curBgm == null || muteBgm )
		{
			Debug.log_if(!HUSH, "No BGM to duck!");
			return; // EARLY RETURN
		}
		
		var volume:Float = bgmVolume;// m_curBgm.sound.volume();
		if (!HUSH) { Debug.log( "Ducking BGM from " + m_curBgm.sound.volume() + " to " + duckedBgmVolume ); }
		m_curBgm.sound.fade( volume, duckedBgmVolume, BGM_DUCK_MS );
		#else
		//TODO: implement for non-js
		#end
	}
	
	public function unDuckBGM():Void
	{
		#if js
		if (m_curBgm == null || muteBgm )
		{
			Debug.log_if(!HUSH, "No BGM to unduck!");
			return; // EARLY RETURN
		}
		
		//Note that the sound.volume() is maintained through the fade so we can return to what it was originally set at
		var volume:Float = bgmVolume;//m_curBgm.sound.volume();
		if (!HUSH) { Debug.log( "Unducking BGM from " + duckedBgmVolume + " to " + m_curBgm.sound.volume() ); }
		m_curBgm.sound.fade( duckedBgmVolume, volume, BGM_UNDUCK_MS );
		#else
		//TODO: implement for non-js
		#end
	}
	
}
