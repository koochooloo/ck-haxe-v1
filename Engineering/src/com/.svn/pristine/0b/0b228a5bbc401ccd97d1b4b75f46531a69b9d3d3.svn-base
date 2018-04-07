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
 * Class that handles updating static Properties tied to tunables.
 */
class PropertyUpdateHandler implements TunableEventHandlers
{
	/**
	 * Class to update static properties for.
	 */
	private var m_classToUpdate:Class<Dynamic>;
	
	/**
	 * Maps tunable names to the fields they modify.
	 */
	private var m_tunablesToFieldNames:Map<String, String>;
	
	/**
	 * Constructor
	 */
	public function new(classToUpdate:Class<Dynamic>, ?tunablesToFields:Map<String, String>)
	{
		m_classToUpdate = classToUpdate;
		m_tunablesToFieldNames = new Map<String, String>();
		if (tunablesToFields != null)
		{
			for (key in tunablesToFields.keys())
			{
				var fieldName:String = tunablesToFields.get(key);
				if (!Reflect.hasField(m_classToUpdate, fieldName))
				{
					var debugMsg:String = "!!!!FAILED: " + key + " to " + Type.getClassName(m_classToUpdate) + " has no field: " + fieldName;
					debugMsg + "\nFields it has: ";
					for (field in Type.getClassFields(m_classToUpdate))
					{
						debugMsg += "\n";
						debugMsg += field;
					}
					Debug.warn(debugMsg);
					continue;
				}
				
				if (m_tunablesToFieldNames.exists(key))
				{
					Debug.warn("already have key: " + key);
					continue;
				}
				
				m_tunablesToFieldNames.set(key, fieldName);
			}
		}
	}
	
	/**
	 * Inits this class and listeners
	 */
	public function init():Void
	{
		updateAllFields();
		
		DebugDefs.debugEventTarget.addEventListener(TunableUpdatedEvent.TUNABLE_UPDATED, onTunableUpdated);
	}
	
	/**
	 * Registers a field name to a tunable.
	 * @param	tunable
	 * @param	field
	 */
	public function registerField(tunable:String, field:String)
	{
		if (Reflect.hasField(m_classToUpdate, field))
		{
			if (m_tunablesToFieldNames.exists(tunable))
			{
				Debug.warn("already have this tunable in our map");
				return;
			}
			
			m_tunablesToFieldNames.set(tunable, field);
		}
		else
		{
			Debug.warn("class has no field called: " + field);
		}
	}
	
	/**
	 * Handles when Tunables update to see if it's one this object cares about.
	 * @param	e
	 */
	private function onTunableUpdated(e:TunableUpdatedEvent)
	{
		if (m_tunablesToFieldNames.exists(e.updatedTunable))
		{
			var field:String = m_tunablesToFieldNames.get(e.updatedTunable);
			updatedField(field, e.newValue);
		}
	}
	
	/**
	 * Update a flag.
	 * @param	fieldName	needs to already be validated.
	 * @param	value
	 */
	private function updatedField(fieldName:String, val:Dynamic):Void
	{
		Reflect.setProperty(m_classToUpdate, fieldName, val);
	}
	
	/**
	 * Updates all flags based on the initial status
	 */
	private function updateAllFields():Void
	{
		for (tunable in m_tunablesToFieldNames.keys())
		{
			var field:String = m_tunablesToFieldNames.get(tunable);
			
			if (Reflect.hasField(Tunables, field))
			{
				var val:Dynamic = Reflect.field(Tunables, field);				
				updatedField(Std.string(field), val);
			}
		}
	}
	
}
#end
