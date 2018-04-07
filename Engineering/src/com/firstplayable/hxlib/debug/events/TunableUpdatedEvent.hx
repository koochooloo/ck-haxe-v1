//
// Copyright (C) 2017, 1st Playable Productions, LLC. All rights reserved.
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

#if (debug || build_cheats)
package com.firstplayable.hxlib.debug.events;
import openfl.events.Event;

/**
 * An event to be sent when a Tunable value has been updated.
 * Objects can subscribe to these changes and update themselves accordingly.
 */
class TunableUpdatedEvent extends Event
{
	public static inline var TUNABLE_UPDATED:String = "Tunable Updated";
	
	/**
	 * The updated tunable that threw this event.
	 */
	public var updatedTunable(default, null):String;
	
	/**
	 * The value the tunable was updated to.
	 */
	public var newValue(default, null):Dynamic;
	
	/**
	 * Construct a TunableUpdatedEvent
	 * @param	tunableID
	 * @param	newVal 
	 * @param	eventType (optional)
	 */
	public function new(tunableID:String, newVal:Dynamic)
	{
		super(TUNABLE_UPDATED);
		
		updatedTunable = tunableID;
		newValue = newVal;
	}
	
}
#end
