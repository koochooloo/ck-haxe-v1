//
// Copyright (C) 2006-2016, 1st Playable Productions, LLC. All rights reserved.
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

import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.AudioXmlElement;
import com.firstplayable.hxlib.audio.Audio;
import openfl.events.TimerEvent;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.utils.Timer;

using com.firstplayable.hxlib.StdX;
using com.firstplayable.hxlib.utils.Utils;

/**
 * Specifies what happens to this AudioObject if we try to play a new sound on the same bus
 */
enum InterruptType
{
	INTERRUPTABLE;	// New sounds on the same bus will interrupt this AudioObject (this AudioObject will stop)
	SEQUENTIAL;		// New sounds on the same bus will be queued (this AudioObject will keep playing)
}

class AudioObject
{
	private static inline var DEFAULT_FADE_SPEED:Int = 50;
	private static inline var MAX_VALUE:Int = 0x7FFFFFFF; // Max value for 32-bit signed integer
	
	private var m_pAudioManager:Audio;
	private var m_pFadeTimer:Timer;
	private var m_fadeEndVolume:Float;
	private var m_fadePerTimer:Float;
	private var m_isDuplicate:Bool;
	
	public var data( default, null ):AudioXmlElement;
	public var id( default, null ):String;
	public var sound( default, null ):Sound;
	public var soundChannel( default, set ):SoundChannel;
	public var bus( default, null ):String;
	public var maxInstances( default, null ):Int;
	public var defaultVolume( default, null ):Float;
	public var currentVolume( default, set ):Float;
	public var numLoops( default, set ):Int;
	public var pausePos( default, null ):Float;
	public var interruptType( default, set ):InterruptType;
	
	public function set_soundChannel( channel:SoundChannel ):SoundChannel { return soundChannel = channel; }
	public function set_currentVolume( currentVolume:Float ):Float { return this.currentVolume = currentVolume; } 
	public function set_numLoops( numLoops:Int ):Int { return this.numLoops = numLoops; }
	public function setPausePos():Void { pausePos = soundChannel.position; }
	public function resetCurrentVolume():Void{ currentVolume = defaultVolume; }
	public function resetPausePos():Void { pausePos = 0; }
	public function set_interruptType( type:InterruptType ):InterruptType
	{
		// TODO: we only want this msg to fire when called from outside the ctor (if we're changing the value)
		//log( "AudioObject '" + id + "' is changing its InterruptType from " + interruptType + " to " + type );
		return interruptType = type;
	}
	
	public function new( sfxId:String, snd:Sound, data:AudioXmlElement, isDuplicate:Bool = false ) 
	{
		this.id = sfxId;
		this.data = data;
		this.sound = snd;
		this.bus = data.bus;
		this.maxInstances = Std.parseInt( data.maxinstances );
		this.defaultVolume = Std.parseFloat( data.volume );
		this.numLoops = Std.parseInt( data.repeat );
		this.numLoops = ( numLoops == 0 ) ? MAX_VALUE : numLoops - 1; // ( numLoops - 1 ) because delay between repeat is perceivable on HTML5
		this.m_isDuplicate = isDuplicate;
		this.interruptType = data.interrupt;
		
		if ( Math.isNaN( defaultVolume ) || defaultVolume < Audio.MIN_VOLUME || defaultVolume > Audio.MAX_VOLUME )
		{
			defaultVolume = Audio.MAX_VOLUME;
		}
	}
	
	@:allow( com.firstplayable.hxlib.audio.Audio.startPlaying )
	private function play( position:Float, volume:Float ):SoundChannel
	{
		if ( soundChannel.isNull() )
		{
			var xForm:SoundTransform = new SoundTransform( volume );
			currentVolume = volume;
			
			if ( sound.isValid() )
			{
				soundChannel = sound.play( position, numLoops, xForm );
			}
		}
		else
		{
			warn( "AudioObject.play() called, even though it already had a SoundChannel." );
		}
		
		return soundChannel;
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function fade( startVolume:Float, endVolume:Float, length:Int, caller:Audio ):Void
	{
		if ( soundChannel.isNull() )
		{
			// EARLY RETURN
			return;
		}
		
		m_fadeEndVolume =  endVolume;
		
		var numIterations:Int = Std.int( length / DEFAULT_FADE_SPEED );
		m_fadePerTimer = ( m_fadeEndVolume - startVolume ) / numIterations;
		
		currentVolume = startVolume;
		soundChannel.soundTransform = new SoundTransform( startVolume );
		
		m_pAudioManager = caller;
		
		m_pFadeTimer = new Timer( DEFAULT_FADE_SPEED, numIterations );
		m_pFadeTimer.safeAddListener( TimerEvent.TIMER, onTimerFade );
		m_pFadeTimer.safeAddListener( TimerEvent.TIMER_COMPLETE, onFadeComplete );
		m_pFadeTimer.start();
	}
	
	@:allow( com.firstplayable.hxlib.audio )
	private function duplicate():AudioObject
	{
		return new AudioObject( id, sound, data, true );
	}
	
	private function onTimerFade( e:TimerEvent ):Void
	{
		var newVolume:Float = soundChannel.soundTransform.volume + m_fadePerTimer;
		currentVolume = newVolume;
		soundChannel.soundTransform = new SoundTransform( newVolume );
	}
	
	private function onFadeComplete( e:TimerEvent ):Void
	{
		m_pFadeTimer.safeRemoveListener( TimerEvent.TIMER, onTimerFade );
		m_pFadeTimer.safeRemoveListener( TimerEvent.TIMER_COMPLETE, onFadeComplete );
		
		soundChannel.soundTransform = new SoundTransform( m_fadeEndVolume );
		currentVolume = m_fadeEndVolume;
		
		if ( m_fadeEndVolume == 0 )
		{
			if ( m_pAudioManager.isNull() )
			{
				// ERROR RETURN
				return;
			}
			m_pAudioManager.stopSound( id );
		}
	}
}