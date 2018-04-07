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

package com.firstplayable.hxlib.game.badge;
import com.firstplayable.hxlib.events.BadgeEvent;
import com.firstplayable.hxlib.utils.BitFlags;
import haxe.ds.EnumValueMap;
import openfl.events.EventDispatcher;

typedef BadgeEntry = {
	type:BadgeStyle,
	target:Int,
	progress:Int
}

enum BadgeStyle
{
	BADGE_FLAGS;
	//BADGE_FLAGS_REPEATABLE;	// TODO: Not implemented yet
	BADGE_TOTAL;
	BADGE_TOTAL_REPEATABLE;
}

class BadgeRulebook extends EventDispatcher
{
	private static var HUSH( default, null ):Bool = true;
	
	public static var instance( get, null ):BadgeRulebook;
	private var m_badgeTable:EnumValueMap<EnumValue, BadgeEntry>;
	
	private function new()
	{
		super();
		m_badgeTable = new EnumValueMap<EnumValue, BadgeEntry>();
	}
	
	private static function get_instance( ):BadgeRulebook
	{
		//If we need an instance, create one!
		if ( instance == null )
		{
			instance = new BadgeRulebook();
		}
		
		return instance;
	}
	
	/**
	 * 
	 * @param	badgeId		The ID of the badge
	 * @param	type		The badge type
	 * @param	target		Target amount for total badges, number of flags for flag badges
	 * @param	progress	(Optional) starting progress for the badge, defaults to 0	
	 */
	public function addBadgeEntry( badgeId:EnumValue, type:BadgeStyle, target:Int, progress:Int = 0 ):Void
	{
		//Check to make sure we've initilized
		if ( m_badgeTable == null )
		{
			Debug.warn( "Attempted to add a badge entry before BadgeRulebook was initilized!" );
			return;
		}
		
		//Check to make sure we don't already have the badge
		if ( m_badgeTable.exists( badgeId ) )
		{
			Debug.warn( "Attempted to add badge '" + badgeId + "' but that badge already exists!" );
			return;
		}
		
		//If we're a flag badge, we need to convert from number of flags to the target int
		if ( type == BADGE_FLAGS )
		{
			//Build a hex string
			var targetHex:String = "0x";
			for ( i in 0...target )
			{
				targetHex += "1";
			}
			
			//Convert back to an int
			target = Std.parseInt( targetHex );
		}
		
		//Construct the BadgeEntry
		var entry:BadgeEntry = { type:type, target:target, progress:progress };
		m_badgeTable.set( badgeId, entry );
		
		//TODO: For some reason this line is dying on Baobab in Debug Android, even if we .getName() on the enums:
		//	09-08 17:53:19.213 8391-8419/com.firstplayable.baobab E/HXCPP: Called from com.firstplayable.hxlib.game.badge.BadgeRulebook::addBadgeEntry com/firstplayable/hxlib/game/badge/BadgeRulebook.hx line 99
		//	09-08 17:53:19.213 8391-8419/com.firstplayable.baobab E/HXCPP: Called from com.firstplayable.hxlib.Debug::log com/firstplayable/hxlib/Debug.hx line 121
		//	09-08 17:53:19.213 8391-8419/com.firstplayable.baobab E/Exception: Null Object Reference
		//if ( !HUSH ) { Debug.log( "Added badge " + badgeId + " with type " + type ); }
	}
	
	/**
	 * 
	 * @param	badgeId		The badge to progress
	 * @param	progress	The amount to progress the badge, or the flag to set
	 */
	public function progressBadge( badgeId:EnumValue, progress:Int ):Void
	{
		//Grab the entry
		var entry:BadgeEntry = m_badgeTable.get( badgeId );
		
		//Check to make sure that we have a BadgeEntry to progress
		if ( entry == null )
		{
			Debug.warn( "Attempted to progress badge '" + badgeId + "' but that badge doesn't exist!" );
			return;
		}
		
		//Check if we have already completed the badge
		if ( entry.progress >= entry.target && entry.type != BADGE_TOTAL_REPEATABLE )
		{
			//If so, return early, we're done!
			if ( !HUSH ) { Debug.log( "Attempted to progress badge " + badgeId + ", but badge is already completed! Skipping..." ); }
			return;
		}
		
		//Increment the progress depending on the type of badge
		//Note: If we are going to expand the badge system, then this should be restructured into something more modular
		//However since we have gotten by with two badge types for so long, I went with simpler for now - Josh
		if ( entry.type == BADGE_FLAGS )
		{
			//Converts to BitFlags object, set flag, then convert back
			var targetHex:String = "0x1";
			for ( i in 0...progress )
			{
				targetHex += "0";
			}
			var flags:BitFlags = new BitFlags( entry.progress );
			flags.add( Std.parseInt( targetHex ) );
			entry.progress = flags.int();
		}
		else if ( entry.type == BADGE_TOTAL || entry.type == BADGE_TOTAL_REPEATABLE )
		{
			//Increment the progress by the amount
			entry.progress += progress;
		}
		else
		{
			//If someone in the future implements a new type of badge and doesn't support progression, yell loudly...
			Debug.warn( "Attempting to progress a badge with unsupported progression type " + entry.type + "! Skipping..." );
			return;
		}
		
		//Log the progress if not hushed
		if ( !HUSH ) { 
			Debug.log( "Progressing badge " + badgeId + " by " + progress + "!" );
			Debug.log( "Current progress of badge is " + entry.progress + "/" + entry.target );
		}
		
		//Dispatch a BADGE_PROGRESS event
		var progressEvent:BadgeEvent = new BadgeEvent( badgeId, BadgeEvent.BADGE_PROGRESS );
		progressEvent.progress = entry.progress;
		this.dispatchEvent( progressEvent );
		
		//Finally, check if we have now completed the badge
		if ( entry.progress >= entry.target )
		{
			//If complete, we dispatch a BADGE_COMPLETE event
			var completeEvent:BadgeEvent = new BadgeEvent( badgeId, BadgeEvent.BADGE_COMPLETE );
			completeEvent.progress = entry.progress;
			this.dispatchEvent( completeEvent );
			
			//Reset the badge if it's repeatable
			if ( entry.type == BADGE_TOTAL_REPEATABLE )
			{
				resetBadgeProgress( badgeId );
			}
		}
	}
	
	/**
	 * Resets the progress of a given badge back to 0
	 * @param	badgeId		The id of the badge to reset
	 */
	public function resetBadgeProgress( badgeId:EnumValue ):Void
	{
		//Grab the entry
		var entry:BadgeEntry = m_badgeTable.get( badgeId );
		
		//Check to make sure that we have a BadgeEntry to progress
		if ( entry == null )
		{
			Debug.warn( "Attempted to reset badge '" + badgeId + "' but that badge doesn't exist!" );
			return;
		}
		
		//Reset the progress
		entry.progress = 0;
		
		//Dispatch a BADGE_PROGRESS event
		var progressEvent:BadgeEvent = new BadgeEvent( badgeId, BadgeEvent.BADGE_PROGRESS );
		progressEvent.progress = entry.progress;
		this.dispatchEvent( progressEvent );
	}
	
	/**
	 * Checks to see if a badge is complete
	 * @param	badgeId		The id of the badge to check
	 * @return				The status of the badge
	 */
	public function getBadgeComplete( badgeId:EnumValue ):Bool
	{
		//Grab the entry from the table
		var entry:BadgeEntry = m_badgeTable.get( badgeId );
		
		//Check to make sure that we have badge data
		if ( entry == null )
		{
			Debug.log( "Attempting to get status of badge " + badgeId + " but no data was found!" );
			return false;
		}
		
		//Return the status
		return entry.progress >= entry.target;
	}
	
	/**
	 * Gets the progress of a particular badge; useful for saving 
	 * @param	badgeId		The id of the badge
	 * @return				The progress of the badge with corresponding badgeID
	 */
	public function getBadgesProgress( badgeId:EnumValue ):Int
	{
		var entry:BadgeEntry = m_badgeTable.get( badgeId );
		if ( entry == null )
		{
			Debug.log( "Attempting to get progress of badge " + badgeId + " but no data was found!" );
			return 0;
		}
		
		return entry.progress;
	}
	
	/**
	 * Re-populates the badge table based on data from a save game.
	 * This must be called after addEntry().
	 * @param	badgeId		The badge to progress.
	 * @param	progress	A value returned from getBadgesProgress().
	 */
	public function setBadgeProgressFromSave( badgeId:EnumValue, progress:Int ):Void
	{
		//Grab the entry
		var entry:BadgeEntry = m_badgeTable.get( badgeId );
		
		//Check to make sure that we have a BadgeEntry to progress
		if ( entry == null )
		{
			Debug.warn( "Attempted to progress badge '" + badgeId + "' but that badge doesn't exist!" );
			return;
		}
		
		// Ensure valid progress was passed
		if ( progress > entry.target )
		{
			progress = entry.target;
			Debug.warn( "Invalid value passed for badge '" + badgeId + "; clamping to " + progress );
		}
		
		entry.progress = progress;
	}
}