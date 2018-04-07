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
import com.firstplayable.hxlib.debug.menuEdit.Menus.MenuLoadingStatus;
import openfl.events.Event;

/**
 * An event to be sent when an unloaded menu has been loaded.
 */
class MenuLoadedEvent extends Event
{
	public static inline var MENU_LOADED:String = "DEBUG Menu Loaded";
	
	/**
	 * The menu that was loaded
	 */
	public var loadedMenu(default, null):String;
	
	/**
	 * The loading status of the menu
	 */
	public var status(default, null):MenuLoadingStatus;
	
	/**
	 * Construct a MenuLoadedEvent
	 * @param	menuName
	 * @param	visible
	 */
	public function new(menuName:String, newStatus:MenuLoadingStatus)
	{
		super(MENU_LOADED);
		
		loadedMenu = menuName;
		status = newStatus;
	}
	
}
#end
