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

package com.firstplayable.hxlib.debug.events;
import openfl.events.Event;

/**
 * Event that is thrown when a message that a paist menu has been
 * updated.
 */
class MenuUpdatedEvent extends Event
{
	public static inline var MENU_UPDATED_EVENT:String = "PAIST MENU UPDATED";

	public var m_layout:String;
	public var m_data:Dynamic;
	
	public function new(layout:String, newData:Dynamic) 
	{
		super(MENU_UPDATED_EVENT);
		
		m_layout = layout;
		m_data = newData;
	}
	
}