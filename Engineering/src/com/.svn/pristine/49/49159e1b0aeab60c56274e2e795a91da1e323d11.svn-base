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
 * An event to be sent when a menu's visbility is changed during menu debugging..
 */
class ShowMenuEvent extends Event
{
	public static inline var SHOW_MENU:String = "DEBUG Menu Shown";
	
	/**
	 * The menu that was shown
	 */
	public var shownMenu(default, null):String;
	
	/**
	 * Whether the chosen menu is now visible or not
	 */
	public var visible(default, null):Bool;
	
	/**
	 * Construct a ShowMenuEvent
	 * @param	menuName
	 * @param	visible
	 */
	public function new(menuName:String, newVisible:Bool)
	{
		super(SHOW_MENU);
		
		shownMenu = menuName;
		visible = newVisible;
	}
	
}
#end
