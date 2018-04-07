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

import com.firstplayable.hxlib.audio.AudioObject;


/**
 * Groups together sounds, eg SFX, VO, BGM
 * 
 * TODO: Audio performs actions directly on activeSounds; should add functions to do that here insteaed
 */
class Bus
{
	public var id( default, null ):String;
	public var limit( default, set ):Int;						    // The max number of sounds that can play on this bus at once
	public var queueLimit( default, set ):Int;					    // The max number of sounds allowed in the queue
	public var activeSounds( default, null ):Array<AudioObject>;	// Sounds currently playing on this bus
	public var queuedSounds( default, null ):Array<AudioObject>;	// Sounds slated to play on this bus
	
	public function new ( id:String )
	{
		this.id = id;
		limit = 0;			// Unlimited
		queueLimit = 0;		// Unlimited
		activeSounds = new Array<AudioObject>();
		queuedSounds = new Array<AudioObject>();
	}
	
	// -----------------------------------------------------------------------------
	// We don't explicitly constrain either limit (because it shouldn't break anything, and I don't know what future use cases may be needed), 
	// but initial use case expects only 0 (unlimited) and 1 will be passed as limits
	
	public function set_limit( limit:Int ):Int { return this.limit = limit; }
	public function set_queueLimit( limit:Int ):Int { return queueLimit = limit; }
	
	// -----------------------------------------------------------------------------
	/**
	 * Checks whether this bus is already playing the max number of sounds
	 */
	public function isFull():Bool
	{
		return ( limit != 0 && activeSounds.length >= limit );
	}
	
	// -----------------------------------------------------------------------------
	/**
	 * Adds a sound to this bus's queue; will overwrite the last item in the queue if we are already at our limit
	 * @param	snd - the sound to queue
	 */
	public function queueSound( snd:AudioObject ):Void
	{
		if ( queueLimit == 0 || queuedSounds.length < queueLimit )
		{
			queuedSounds.push( snd );
		}
		else
		{
			queuedSounds[ queuedSounds.length - 1 ] = snd;
		}
	}
	
	public function clearQueue():Void
	{
		queuedSounds = [];
	}
	
	// -----------------------------------------------------------------------------
	/**
	 * Checks whether any sounds are queued up for this bus.
	 */
	public function hasQueuedSounds():Bool
	{
		return queuedSounds.length > 0;
	}
	
	// -----------------------------------------------------------------------------
	/**
	 * Returns the next sound queued on this bus for playing
	 */
	public function getQueuedSound():AudioObject
	{
		if ( !hasQueuedSounds() )
		{
			return null;
		}
		
		return queuedSounds.shift();
	}
}