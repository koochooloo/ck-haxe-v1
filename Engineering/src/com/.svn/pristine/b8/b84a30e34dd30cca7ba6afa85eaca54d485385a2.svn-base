//
// Copyright (C) 2016, 1st Playable Productions, LLC. All rights reserved.
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
package com.firstplayable.hxlib.debug.menuEdit;
import com.firstplayable.hxlib.debug.menuEdit.Menus;
import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;
import haxe.ds.StringMap;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GenericMenu;
import com.firstplayable.hxlib.display.GraphicButton;
import motion.Actuate;
import openfl.events.Event;

/*
 * Class that loads provided pastes menus allowing you to view them without
 * interferring game logic, and make limited edits.
 */
class EditableMenu extends GenericMenu 
{

	public function new(menuName:String) 
	{
		super(menuName);
		
		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
	}
	
	/**
	 * Functionality for whenever a menu is added to the stage
	 * @param e Event
	 */
	private function onAddedToStage( e:Event ):Void
	{
		removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
		
		//add functionality here
	}
	
	/**
	 * Functionality for whenever a menu is removed from the stage
	 * @param e Event
	 */
	private function onRemovedFromStage( e:Event ):Void
	{
		removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		
		//add functionality here
	}
	
	/**
	 * Prepare menu for deletion
	 */
	public function release():Void
	{
		removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
	}
	
	/**
	 * Gets a map of all the named children of this menu by name
	 * @return
	 */
	public function getNamedChildrenMap():StringMap<DisplayObject>
	{
		var childrenMap:StringMap<DisplayObject> = new StringMap<DisplayObject>();
		for (childName in m_objectMap.keys())
		{
			var child:DisplayObject = m_objectMap.get(childName);
			if (child != null)
			{
				childrenMap.set(childName, child);
			}
			
		}
		
		return childrenMap;
	}
	
	/**
	 * Gets a map of all the children not marked (get by name) of this menu.
	 * @return
	 */
	public function getNamelessChildrenMap():StringMap<DisplayObject>
	{
		var childrenMap:StringMap<DisplayObject> = getNamelessChildrenHelper(this);
		
		return childrenMap;
	}
	
	/**
	 * Recursively gets all nameless children of the target object
	 * @param	targetObject
	 * @return
	 */
	public function getNamelessChildrenHelper(targetObject:DisplayObjectContainer):StringMap<DisplayObject>
	{
		var childrenMap:StringMap<DisplayObject> = new StringMap<DisplayObject>();
		
		for (i in 0...targetObject.numChildren)
		{
			var nextChild:DisplayObject = targetObject.getChildAt(i);
			
			//======================================
			// Check if child should be added to the map.
			//======================================
			if (!m_objectMap.exists(nextChild.name) 
				&& Menus.isPaistObject(nextChild))
			{
				childrenMap.set(nextChild.name, nextChild);
			}
			
			//======================================
			// Check if child has its own children 
			// that should be added to the map
			//======================================
			var childChildrenMap:StringMap<DisplayObject> = new StringMap<DisplayObject>();
			if (Std.is(nextChild, DisplayObjectContainer))
			{
				var nextChildDoc:DisplayObjectContainer = cast nextChild;
				if (nextChildDoc.numChildren > 0)
				{
					childChildrenMap = getNamelessChildrenHelper(nextChildDoc);
				}
			}
			
			for (grandChild in childChildrenMap)
			{
				childrenMap.set(grandChild.name, grandChild);
			}
		}
		
		return childrenMap;
	}
}
#end
