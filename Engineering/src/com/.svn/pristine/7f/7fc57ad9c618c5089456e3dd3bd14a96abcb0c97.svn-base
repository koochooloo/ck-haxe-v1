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
package com.firstplayable.hxlib.debug.tunables.eventHandlers;
import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;
import openfl.Lib;
import openfl.display.Stage;
import com.firstplayable.hxlib.display.OPSprite;
import haxe.EnumTools;
import com.firstplayable.hxlib.display.OPSprite.DebugDrawingFlag;
import com.firstplayable.hxlib.debug.events.TunableUpdatedEvent;

/**
 * Class that handles updating OPSprite settings when appropriate Tunables change.
 */
class OPSpriteUpdateHandler implements TunableEventHandlers
{
	/**
	 * Debug Draw Flags by name
	 */
	private var m_drawFlagNames:Array<String>;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		m_drawFlagNames = [];
	}
	
	/**
	 * Inits this class and listeners
	 */
	public function init():Void
	{
		var drawFlags:Array<DebugDrawingFlag> = EnumTools.createAll(DebugDrawingFlag);
		drawFlags.remove(INVALID_FLAG);
		
		m_drawFlagNames = [];
		for (flag in drawFlags)
		{
			m_drawFlagNames.push(Std.string(flag));
		}
		
		updateAllFlags();
		
		DebugDefs.debugEventTarget.addEventListener(TunableUpdatedEvent.TUNABLE_UPDATED, onTunableUpdated);
	}
	
	/**
	 * Handles when Tunables update to see if it's one this object cares about.
	 * @param	e
	 */
	private function onTunableUpdated(e:TunableUpdatedEvent)
	{
		if (m_drawFlagNames.indexOf(e.updatedTunable) != -1)
		{
			var enable:Bool = false;
			if (Std.is(e.newValue, Bool))
			{
				enable = cast e.newValue;
			}
			updatedFlag(e.updatedTunable, enable, true);
		}
	}
	
	/**
	 * Update a flag.
	 * @param	flagName	needs to already be validated.
	 * @param	enable
	 * @param	forceUpdate	whether debugDrawing should be updated on all sprites.
	 */
	private function updatedFlag(flagName:String, enable:Bool, forceUpdate:Bool = false):Void
	{
		var flag:DebugDrawingFlag = EnumTools.createByName(DebugDrawingFlag, flagName);
		if (enable)
		{
			OPSprite.enableDebugDrawFlag(flag);
		}
		else
		{
			OPSprite.disableDebugDrawFlag(flag);
		}
		
		if (forceUpdate)
		{
			updateDebugDrawing(Lib.current.stage);
		}
	}
	
	/**
	 * Updates all flags based on the initial status
	 */
	private function updateAllFlags():Void
	{
		for (flag in m_drawFlagNames)
		{
			if (Reflect.hasField(Tunables, flag))
			{
				var enable:Bool = false;
				
				var val:Dynamic = Reflect.field(Tunables, flag);
				if (Std.is(val, Bool))
				{
					enable = cast val;
				}
				
				updatedFlag(Std.string(flag), enable);
			}
		}
		
		if (Lib.current != null)
		{
			updateDebugDrawing(Lib.current.stage);
		}
	}
	
	/**
	 * Forces all sprites in the stage to update their debug drawing.
	 * Note: needed access OPSprite in order to get at OPSprite.updateDebugDrawing
	 */
	@:access(com.firstplayable.hxlib.display.OPSprite)
	private function updateDebugDrawing(parent:DisplayObjectContainer):Void
	{
		if (parent == null)
		{
			return;
		}
		
		for (i in 0...parent.numChildren)
		{
			var nextChild:DisplayObject = parent.getChildAt(i);
			
			if (Std.is(nextChild, OPSprite))
			{
				var nextSprite:OPSprite = cast nextChild;
				nextSprite.updateDebugDrawing();
			}
			
			if (Std.is(nextChild, DisplayObjectContainer))
			{
				var nextContainer:DisplayObjectContainer = cast nextChild;
				if (nextContainer.numChildren > 0)
				{
					updateDebugDrawing(nextContainer);
				}
			}
		}
	}
	
}
#end
