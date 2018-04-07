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

import com.firstplayable.hxlib.audio.AudioObject.InterruptType;
import com.firstplayable.hxlib.audio.Bus;
import com.firstplayable.hxlib.events.AudioEvent;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.loader.ResMan;
import haxe.ds.StringMap;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.media.Sound;
import openfl.media.SoundChannel;

using com.firstplayable.hxlib.utils.Utils;
using com.firstplayable.hxlib.StdX;
using Std;


// ==============================================================================================================
//		Audio Class
// ==============================================================================================================

/**
 * Haxe implementation of the Audio Sound Manager
 * Refer to MDD for further documentation/missing features: https://wiki.1stplayable.com/index.php/Projects/Ouroboros/AudioImplementationHaxe
 */
class Audio extends EventDispatcher
{
	public static inline var MIN_VOLUME:Float = 0.0;
	public static inline var MAX_VOLUME:Float = 1.0;
	
	@:allow( com.firstplayable.hxlib.audio.VolumeManager ) 
	private var m_pActiveAudioObjects:StringMap<AudioObject>;

	@:allow( com.firstplayable.hxlib.audio.VolumeManager ) 
	private var m_pActiveSoundChannels:Map<SoundChannel,AudioObject>;
	
	@:allow( com.firstplayable.hxlib.audio.VolumeManager ) 
	private var m_pBusses:StringMap<Bus>;
	
	@:allow( com.firstplayable.hxlib.audio.VolumeManager ) 
	private var m_pDuplicates:StringMap<Array<AudioObject>>;
	
	@:allow( com.firstplayable.hxlib.audio.VolumeManager )
	private var m_pAudioObjects:StringMap<AudioObject>;
	
	private var m_pVolumeManager:VolumeManager;
	private var m_numActiveSounds:Int;
	
	public function getDefaultVolume( sfxId:String ):Float{ return m_pVolumeManager.getDefaultVolume( sfxId ); }
	public function getVolume( sfxId:String ):Float{ return m_pVolumeManager.getVolume( sfxId ); }
	
	public function new()
	{
		super();
		
		m_pVolumeManager = new VolumeManager( this );
		m_pBusses = new StringMap<Bus>();
		m_pActiveAudioObjects = new StringMap<AudioObject>();
		m_pActiveSoundChannels = new Map<SoundChannel,AudioObject>();
		m_pDuplicates = new StringMap<Array<AudioObject>>();
		m_pAudioObjects = new StringMap<AudioObject>();
		m_numActiveSounds = 0;
	}
	
	public function initSounds( soundList:StringMap<AudioXmlElement> ):Void
	{
		for ( entry in soundList )
		{
			var sound:Sound = ResMan.getSound( entry.url );
			if ( sound.isValid() )
			{
				log_if ( m_pAudioObjects.exists( entry.soundid ), "We already have an AudioObject with id '" + entry.soundid + "'; overwriting." );
				m_pAudioObjects.set( entry.soundid, new AudioObject( entry.soundid, sound, entry ) );
				
				log ( "Initialized an AudioObject with id '" + entry.soundid + "'." );
			}
		}
	}
	
	public function deinitSounds( soundList:StringMap<AudioXmlElement> ):Void
	{
		for ( entry in soundList )
		{
			m_pAudioObjects.remove( entry.soundid );
			
			log ( "De-initialized an AudioObject with id '" + entry.soundid + "'." );
		}
	}
	
	/**
	 * One time fade effect for a Sound. If the Sound is not currently playing, this will start playing the Sound.
	 */
	public function fade( sfxId:String, length:Int, startVolume:Float, endVolume:Float ):Void
	{
		var obj:AudioObject = m_pAudioObjects.get( sfxId );
		if ( obj.isNull() )
		{
			warn( "Cannot fade " + sfxId + "-- it doesn't exist" );
			
			// ERROR RETURN
			return;
		}
		
		if ( obj.soundChannel.isNull() )
		{
			startPlaying( obj );
		}
		
		startVolume = Math.isNaN( startVolume ) ? m_pVolumeManager.getVolumeToPlay( obj ) : startVolume;
		endVolume = Math.isNaN( endVolume ) ? m_pVolumeManager.getVolumeToPlay( obj ) : endVolume;
		
		obj.fade( startVolume, endVolume, length, this );
	}
	
	public function getPercentSoundComplete( sfxId:String ):Float
	{
		var obj:AudioObject = m_pActiveAudioObjects.get( sfxId );
		if ( obj.isValid() )
		{
			var channel:SoundChannel = obj.soundChannel;
			if ( channel.isValid() )
			{
				return channel.position / obj.sound.length;
			}
		}
		return Math.NaN;
	}
	
	public function getBusForSound( sfxId:String ):String
	{
		var obj:AudioObject = m_pAudioObjects.get( sfxId );
		if ( obj.isValid() )
		{
			return obj.bus;
		}
		return "UNKNOWN";
	}
	
	public function getActiveSoundIdsByBus( busId:String ):Array<String>
	{
		var ids:Array<String> = [];
		var bus:Bus = m_pBusses.get( busId );
		if ( bus.isValid() && bus.activeSounds.length > 0 )
		{
			for ( obj in bus.activeSounds )
			{
				ids.push( obj.id );
			}
		}
		return ids;
	}
	
	public function getActiveSoundIds():Array<String>
	{
		var ids:Array<String> = [];
		for ( obj in m_pActiveAudioObjects )
		{
			ids.push( obj.id );
		}
		return ids;
	}
	
	/**
	 * Only allows one sound to play at a time on the specified bus.
	 * If you attempt to play a sound on a limited bus that already has a sound playing,
	 * that sound's interruptType will define whether or not the new sound interrupts 
	 * the current sound or is queued up.
	 * 
	 * Note: this is intended to be called *before* sounds start playing; if multiple
	 * 	sounds are already playing when this is called, they will all continue to play.
	 * 
	 * @param	busName - the bus that will be limited to one sound playing at a time
	 */
	public function limitBusSize( busName:String ):Void
	{
		if ( !m_pBusses.exists( busName ) )
		{
			m_pBusses.set( busName, new Bus( busName ) );
		}
		var bus:Bus = m_pBusses.get( busName );
		
		bus.limit = 1;
	}
	
	/**
	 * Allows an unlimited number of sounds to play on the same bus simultaneously
	 * @param	busName - the bus that will be set to unlimited
	 */
	public function removeBusSizeLimit( busName:String ):Void
	{
		if ( !m_pBusses.exists( busName ) )
		{
			m_pBusses.set( busName, new Bus( busName ) );
		}
		var bus:Bus = m_pBusses.get( busName );
		
		bus.limit = 0;
	}
	
	public function setNumLoops( sfxId:String, numLoops:Int ):Void
	{
		var obj:AudioObject = m_pActiveAudioObjects.get( sfxId );
		if ( obj.isValid() )
		{
			obj.numLoops = numLoops;
			
			pauseSound( sfxId );
			unpauseSound( sfxId );
		}
	}
	
	private function pause( obj:AudioObject ):Void
	{
		if ( obj.isValid() )
		{
			var channel:SoundChannel = obj.soundChannel;
			if ( channel.isValid() )
			{
				obj.setPausePos();
				channel.stop();
				channel.safeRemoveListener( Event.SOUND_COMPLETE, onSoundComplete );
				channel = null;
				obj.soundChannel = null;
			}
		}
	}
	
	private function unpause( obj:AudioObject ):Void
	{
		if ( obj.isValid() )
		{
			startPlaying( obj, obj.pausePos, true );
			obj.resetPausePos();
		}
	}
	
	/**
	 * Tries to play a Sound, uses the volume, etc configured in the XLS Sound list.
	 * @param	sfxId		The Sound id
	 * @param	position	The position within the Sound to start playing
	 * @return	true if the Sound was played, false otherwise
	 */
	public function play( sfxId:String, position:Float = 0.0 ):Bool
	{
		var obj:AudioObject = m_pAudioObjects.get( sfxId );
		if ( !obj.isValid() )
		{
			warn( "No sound exists with ID '" + sfxId + "'." );
			return false;
		}
		
		var busName:String = obj.bus;
		if ( !m_pBusses.exists( busName ) )
		{
			m_pBusses.set( busName, new Bus( busName ) );
		}
		var bus:Bus = m_pBusses.get( busName );
		
		// Check whether we're already playing the max number of sounds
		if ( bus.isFull() )
		{
			// TODO: we may actually want to search for an interruptable sound instead
			var activeSnd:AudioObject = bus.activeSounds[ 0 ]; // note that we may have more than one active; just pic the first
			var canInterrupt:Bool = activeSnd.interruptType == InterruptType.INTERRUPTABLE;
			if ( canInterrupt )
			{
				stopSound( activeSnd.id );
				startPlaying( obj, position );
				return true;
			}
			else // Wait for the current sound to finish before we can play
			{
				warn_if( position != 0.0, "Custom playback positions are not yet supported for queued sounds." );
				bus.queueSound( obj );
				return false;
			}
		}
		else
		{
			startPlaying( obj, position );
			return true;
		}
	}
	
	/**
	 * Central point for playing a Sound. Only function from which AudioObject::play can be called.
	 * @param	obj			The AudioObject for the Sound that should play
	 * @param	position	What position the Sound should start playing at
	 * @param	isPaused	Determines whether we are playing a new Sound, or resuming a paused Sound
	 */
	private function startPlaying( obj:AudioObject, position:Float = 0.0, isPaused:Bool = false ):Void
	{
		if ( obj.isNull() )
		{
			warn( "Invalid AudioObject was passed to startPlaying()" );
			return;
		}
		
		// Check whether this Sound is a duplicate
		var isDuplicate:Bool = false;
		if ( m_pActiveAudioObjects.exists( obj.id ) )
		{
			// Ensure we haven't already reached the max # of instances
			var dupe:AudioObject = checkAndAddDupe( obj );
			if ( dupe == obj )
			{
				// EARLY RETURN
				return;
			}
			
			obj = dupe;
			isDuplicate = true;
		}
		
		// Check if we should the Sound at non-default value
		var volume:Float = m_pVolumeManager.getVolumeToPlay( obj );
		
		// Actually play the Sound
		var channel:SoundChannel = obj.play( position, volume );
		if ( channel.isNull() )
		{
			warn( "Sound.play() returned null -- looks like you are out of SoundChannels" );
			
			// ERROR RETURN
			return;
		}
		
		// Resuming is not the same as starting -- only do the following if this is a new Sound
		if ( !isPaused )
		{
			dispatchEvent( new AudioEvent( AudioEvent.STARTED, obj ) );
			addNewSoundToLists( obj, isDuplicate );
		}
		
		channel.safeAddListener( Event.SOUND_COMPLETE, onSoundComplete );
	}
	
	/**
	 * Helper function for startPlaying() that checks whether the max # of instances has been reached;
	 * if it hasn't, create the duplicate, add it to the list, and return it.
	 * @param	obj		The AudioObject to potentially duplicate
	 * @return	The duplicate, if we are allowed to duplicate. Otherwise, returns obj.
	 */
	private function checkAndAddDupe( obj:AudioObject ):AudioObject
	{
		var dupes:Array<AudioObject> = m_pDuplicates.get( obj.id );
		if ( dupes.isNull() )
		{
			dupes = new Array<AudioObject>();
			m_pDuplicates.set( obj.id, dupes );
		}
		
		var maxInstances:Int = obj.maxInstances;
		var currentInstances:Int = dupes.length + 1;	// Add one because there is an instance that is not a dupe
		if ( maxInstances == 0 || currentInstances < maxInstances )
		{
			var newDupe:AudioObject = obj.duplicate();
			dupes.push( newDupe );
			
			// NORMAL RETURN
			return newDupe;
		}
		
		return obj;
	}
	
	/**
	 * Helper for startPlaying() that increments the number of active Sounds and adds the AudioObject to the necessary lists.
	 * @param	obj			The newly playing AudioObject
	 * @param	isDupe		Whether or not the AudioObject is a duplicate
	 */
	private function addNewSoundToLists( obj:AudioObject, isDuplicate:Bool ):Void
	{
		++m_numActiveSounds;
		
		if ( !isDuplicate )
		{
			m_pActiveAudioObjects.set( obj.id, obj );
		}
		m_pActiveSoundChannels.set( obj.soundChannel, obj );
		
		var busName:String = obj.bus;
		if ( !m_pBusses.exists( busName ) )
		{
			m_pBusses.set( busName, new Bus( busName ) );
		}
		var bus:Bus = m_pBusses.get( busName );
		bus.activeSounds.push( obj );
	}
	
	/**
	 * Called when a Sound has finished playing
	 * NOTE: If a Sound shouldn't loop, this will be called when the Sound finshes looping, NOT each time the Sound completes.
	 */
	private function onSoundComplete( e:Event ):Void
	{
		// TODO: For infinitely looping Sound, play again
		var channel:SoundChannel = e.currentTarget.as( SoundChannel );
		var obj:AudioObject = m_pActiveSoundChannels.get( channel );
		
		m_pActiveSoundChannels.remove( channel );
		
		var bus:Bus = m_pBusses.get( obj.bus );
		bus.activeSounds.remove( obj );
		
		channel.safeRemoveListener( Event.SOUND_COMPLETE, onSoundComplete );
		obj.soundChannel = null;
		channel = null;
		
		--m_numActiveSounds;
		if ( m_numActiveSounds < 0 )
		{
			warn( "We have completed more sounds than we've played" );
			m_numActiveSounds = 0;
		}
		
		dispatchEvent( new AudioEvent( AudioEvent.COMPLETE, obj ) );
		
		var dupes:Array<AudioObject> = m_pDuplicates.get( obj.id );
		if ( dupes.isNull() || dupes.length == 0 )
		{
			m_pActiveAudioObjects.remove( obj.id );
		}
		else
		{
			dupes.remove( obj );
			obj = null;
		}
		
		// Check the queue for more sounds to play
		if ( bus.hasQueuedSounds() )
		{
			play( bus.getQueuedSound().id );
		}
	}
	
	private function stopChannel( channel:SoundChannel ):Void
	{
		if ( channel.isValid() )
		{
			channel.stop();
			channel.dispatchEvent( new Event( Event.SOUND_COMPLETE ) );
		}
	}
	
    // ----- Sound functions -----------------------------------------
	
	public function isPlayingSound( sfxId:String ):Bool{ return m_pActiveAudioObjects.exists( sfxId ); }
	public function doesSoundExist( sfxId:String ):Bool{ return m_pAudioObjects.exists( sfxId ); }
	public function isMutedSound( sfxId:String ):Bool { return m_pVolumeManager.isMutedSound( sfxId ); }
	
	/**
	 * Changes the volume for a particular Sound. Sound must be active ( paused counts as active, unless onlyActive is set to true )
	 * @param	sfxId				The ID for the Sound whose volume you want to change
	 * @param	volume				The new volume to use ( 0.0 - 1.0 )
	 * @param	onlyActive			Whether or not future instances should be affected
	 * @param	isOverridable		Whether or not changing the volume of a bus or "ALL" changes the volume for this Sound.
	 */
	public function setVolumeForSound( sfxId:String, volume:Float, onlyActive:Bool = false, isOverridable:Bool = true ):Void
	{
		m_pVolumeManager.setVolumeForSound( sfxId, volume, onlyActive, isOverridable );
	}
	
	/**
	 * Mutes a Sound; the Sound will continue to play, but with the volume set to 0
	 * @param	sfxId				The ID of the Sound to mute
	 * @param	onlyActive			Whether or not future instances should be affected
	 * @param	isOverridable		Whether or not muting/unmuting a bus or "ALL" affects the muting for this Sound
	 */
	public function muteSound( sfxId:String, onlyActive:Bool = false, isOverridable:Bool = true ):Void
	{
		m_pVolumeManager.muteSound( sfxId, onlyActive, isOverridable );
	}
	
	/**
	 * Unmutes a Sound; the Sound will resume its default volume
	 * @param	sfxId				The ID of the Sound to unmute
	 * @param	onlyActive			Whether to only unmute currently active Sounds
	 */
	public function unmuteSound( sfxId:String, onlyActive:Bool = false ):Void
	{
		m_pVolumeManager.unmuteSound( sfxId, onlyActive );
	}
	
	public function pauseSound( sfxId:String ):Void
	{
		pause( m_pActiveAudioObjects.get( sfxId ) );
		
		var duplicates:Array<AudioObject> = m_pDuplicates.get( sfxId );
		if ( duplicates.isValid() && duplicates.length > 0 )
		{
			for ( obj in duplicates )
			{
				pause( obj );
			}
		}
	}
	
	public function unpauseSound( sfxId:String ):Void
	{
		unpause( m_pActiveAudioObjects.get( sfxId ) );
		
		var duplicates:Array<AudioObject> = m_pDuplicates.get( sfxId );
		if ( duplicates.isValid() && duplicates.length > 0 )
		{
			for ( obj in duplicates )
			{
				unpause( obj );
			}
		}
	}
	
	public function stopSound( sfxId:String, shouldStopAll:Bool = false ):Void
	{
		var duplicates:Array<AudioObject> = m_pDuplicates.get( sfxId );
		if ( duplicates.isValid() && duplicates.length > 0 )
		{
			for ( obj in duplicates ) 
			{
				stopChannel( obj.soundChannel );
				
				if ( !shouldStopAll )
				{
					return;
				}
			}
		}
		
		var obj:AudioObject = m_pActiveAudioObjects.get( sfxId );
		if ( obj.isValid() )
		{
			stopChannel( obj.soundChannel );
		}
	}
	
    // ----- Bus functions -----------------------------------------
	
	/**
	 * Checks if a Sound is playing on a given bus
	 */
	public function isPlayingBus( busId:String ):Bool
	{
		var bus:Bus = m_pBusses.get( busId );
		if ( bus.isValid() )
		{
			return bus.activeSounds.length > 0;
		}
		return false;
	}
	
	/**
	 * Checks whether ALL playing Sounds on a bus are muted
	 */
	public function isMutedBus( busId:String ):Bool
	{
		return m_pVolumeManager.isMutedBus( busId );
	}
	
	/**
	 * Changes the volume for all Sounds on a particular bus
	 */
	public function setVolumeForBus( busId:String, volume:Float, onlyActive:Bool = false, isOverridable:Bool = true ):Void
	{
		m_pVolumeManager.setVolumeForBus( busId, volume, onlyActive, isOverridable );
	}
	
	/**
	 * Mutes all Sounds on a bus; the Sounds will continue to play, but with volume set to 0
	 * @param	busId				The name of the bus to mute
	 * @param	onlyActive			Whether or not future instances should be affected.
	 * @param	isOverridable		Whether or not muting/unmuting a Sound or "ALL" affects muting for this Sound
	 */
	public function muteBus( busId:String, onlyActive:Bool = false, isOverridable:Bool = true ):Void
	{
		m_pVolumeManager.muteBus( busId, onlyActive, isOverridable );
	}
	
	/**
	 * Unmutes all Sounds on a bus; the Sounds will resume their default volumes
	 */
	public function unmuteBus( busId:String, onlyActive:Bool = false ):Void
	{
		m_pVolumeManager.unmuteBus( busId, onlyActive );
	}
	
	public function pauseBus( busId:String ):Void
	{
		var bus:Bus = m_pBusses.get( busId );
		if ( bus.isValid() )
		{
			for ( obj in bus.activeSounds )
			{
				pause( obj );
			}
		}
	}
	
	public function unpauseBus( busId:String ):Void
	{
		var bus:Bus = m_pBusses.get( busId );
		if ( bus.isValid() )
		{
			for ( obj in bus.activeSounds )
			{
				unpause( obj );
			}
		}
	}
	
	public function stopBus( busId:String ):Void
	{
		var bus:Bus = m_pBusses.get( busId );
		if ( bus.isValid() )
		{
			for ( obj in bus.activeSounds )
			{
				stopChannel( obj.soundChannel );
			}
		}
	}
	
    // ----- ALL functions -----------------------------------------
	
	public function isPlayingAny():Bool{ return m_numActiveSounds > 0; }
	public function isMutedAll():Bool { return m_pVolumeManager.isMutedAll(); }
	
	/**
	 * Mutes all Sounds currently playing; the Sounds will continue to play, but with volume set to 0.
	 */
	public function muteAll( onlyActive:Bool = false, isOverridable:Bool = false ):Void
	{
		m_pVolumeManager.muteAll( onlyActive, isOverridable );
	}
	
	/**
	 * Unmutes all Sounds currently playing; the Sounds will resume their default volumes.
	 */
	public function unmuteAll( onlyActive:Bool = false ):Void
	{
		m_pVolumeManager.unmuteAll( onlyActive );
	}
	
	public function pauseAll():Void
	{
		for ( obj in m_pActiveAudioObjects )
		{
			pause( obj );
			
			var duplicates:Array<AudioObject> = m_pDuplicates.get( obj.id );
			if ( duplicates.isValid() && duplicates.length > 0 )
			{
				for ( duplicatedObj in duplicates )
				{
					pause( duplicatedObj );
				}
			}
		}
	}
	
	public function unpauseAll():Void
	{
		for ( obj in m_pActiveAudioObjects )
		{
			unpause( obj );
			var duplicates:Array<AudioObject> = m_pDuplicates.get( obj.id );
			if ( duplicates.isValid() && duplicates.length > 0 )
			{
				for ( duplicatedObj in duplicates )
				{
					unpause( duplicatedObj );
				}
			}
		}
	}
	
	public function stopAll():Void
	{
		for ( obj in m_pActiveAudioObjects )
		{
			stopHelper( obj );
		}
	}
	
	private function stopHelper( obj:AudioObject ):Void
	{
		stopChannel( obj.soundChannel );
		
		var duplicates:Array<AudioObject> = m_pDuplicates.get( obj.id );
		if ( duplicates.isValid() && duplicates.length > 0 )
		{
			for ( duplicatedObj in duplicates )
			{
				stopChannel( duplicatedObj.soundChannel );
			}
		}
	}
	
	/**
	 * Stop all sounds and discontinue the current queue.
	 */
	public function interrupt():Void
	{
		for ( obj in m_pActiveAudioObjects )
		{
			var bus:Bus = m_pBusses.get( obj.bus );
			if ( bus.isValid() )
			{
				bus.clearQueue();
			}
			
			stopHelper( obj );
		}
	}
}