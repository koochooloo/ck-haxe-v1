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
package com.firstplayable.hxlib.debug;
import com.firstplayable.hxlib.debug.tunables.eventHandlers.WebAudioUpdateHandler;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.eventHandlers.TunableEventHandlers;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.debug.tunables.eventHandlers.OPSpriteUpdateHandler;
import haxe.ds.StringMap;
import com.firstplayable.hxlib.debug.events.TunableUpdatedEvent;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import com.firstplayable.hxlib.debug.events.RefreshAudioEvent;
import openfl.Lib;
import openfl.events.EventDispatcher;

/**
 * Definitions shared across various debugging capability.
 */
class DebugDefs
{
	//=========================================
	// Event Target
	//=========================================
	private static var ms_debugEventTarget:EventDispatcher = null;
	/**
	 * The event target of events related to debug functionality.
	 */
	public static var debugEventTarget(get, never):EventDispatcher;
	
	/**
	 * Returns the event target. Defaults to the main stage.
	 * @param	newTarget
	 * @return
	 */
	public static function get_debugEventTarget():EventDispatcher
	{
		if (ms_debugEventTarget == null)
		{
			ms_debugEventTarget = new EventDispatcher();
			initEventHandlers();
		}
		
		return ms_debugEventTarget;
	}
	
	//=========================================
	// Event Handlers
	//=========================================
	/**
	 * Collection of event handlers for various classes
	 */
	public static var eventHandlers:StringMap<TunableEventHandlers> = [
		Type.getClassName(OPSprite) => new OPSpriteUpdateHandler(),
		Type.getClassName(WebAudio) => new WebAudioUpdateHandler()
	];
	
	private static var eventHandlersInitied:Bool = false;
	
	/**
	 * Initializes all the eventHandlers
	 */
	public static function initEventHandlers():Void
	{
		if (eventHandlersInitied)
		{
			return;
		}
		
		for (handler in eventHandlers)
		{
			handler.init();
		}
		
		eventHandlersInitied = true;
	}
}
#end
