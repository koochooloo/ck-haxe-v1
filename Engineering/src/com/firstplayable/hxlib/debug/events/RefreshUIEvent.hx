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
 * An event sent when UI display parameters have changed, and interested GUIs
 * should update themselves accordingly. 
 */
class RefreshUIEvent extends Event
{
	public static inline var REFRESH_UI_EVENT:String = "REFRESH UI";
	
	/**
	 * Construct a RefreshUIEvent
	 */
	public function new()
	{
		super(REFRESH_UI_EVENT);
	}
	
}
#end
