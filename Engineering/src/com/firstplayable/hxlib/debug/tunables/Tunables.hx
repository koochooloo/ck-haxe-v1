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

package com.firstplayable.hxlib.debug.tunables;

#if (macro || debug || build_cheats)
import com.firstplayable.hxlib.Debug;

import com.firstplayable.hxlib.debug.tunables.BuildTunables;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunableDefs;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesFile;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesType;

import haxe.ds.StringMap;
#end

/**
 * Collection of values that are tunable at run time.
 * Are defined in Tunables json, but edited can be edited via debug menu.
 */
@:build(com.firstplayable.hxlib.debug.tunables.BuildTunables.build())
class Tunables
{
	#if (debug || build_cheats)
	/**
	 * Returns whether a type of the specified name exists
	 * @param	typeName
	 * @return
	 */
	public static function tunableTypeExists(typeName:String):Bool
	{
		return TunableDefs.tunableTypes.exists(typeName);
	}
	
	/**
	 * Gets the type definition for the provided type name
	 * @param	typeName
	 * @return
	 */
	public static function getTunablesType(typeName:String):TunablesType
	{
		return TunableDefs.tunableTypes.get(typeName);
	}
	
	/**
	 * Gets the default value for the provided tunable type string
	 * @param	typeName
	 * @return
	 */
	public static function getDefaultValueForType(typeName:String):Dynamic
	{
		var typeDef:TunablesType = TunableDefs.tunableTypes.get(typeName);
		if (typeDef == null)
		{
			return null;
		}
		return typeDef.defaultValue;
	}
	
	#end
	
	#if (!macro && (debug || build_cheats))
	
	/**
	 * Returns whether the provided tunable variable struct is valid.
	 * @param	variable
	 * @return
	 */
	public static function validateTunableVariable(variable:TunablesVariable, customVariableMap:StringMap<TunablesVariable> = null):Bool
	{
		//test name
		var variableMap:StringMap<TunablesVariable> = null;
		if (customVariableMap == null)
		{
			variableMap = ALL_VARIABLES;
		}
		else
		{
			variableMap = customVariableMap;
		}
		
		if (variableMap.exists(variable.name))
		{
			Debug.warn('Invalid name: $variable.name already exists!');
			return false;
		}
		
		//test type
		if (!Tunables.tunableTypeExists(variable.type))
		{
			Debug.warn('invalid type for $variable.name: $variable.type');
			return false;
		}
		
		//test tags
		var variableTags:Array<String> = variable.tags;
		for (tag in variableTags)
		{
			if (!ALL_TAGS.exists(tag))
			{
				Debug.warn('invalid tag for $variable.name: $tag, known tags: $ALL_TAGS');
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Tries to grab the provided float field, returning a default on a failure.
	 * @param	fieldName
	 * @param	defaultVal
	 * @return
	 */
	public static function getFloatField(fieldName:String, defaultVal:Float = 0):Float
	{
		if (Reflect.hasField(Tunables, fieldName))
		{
			var valueString:String = Std.string(Reflect.field(Tunables, fieldName));
			if (valueString.length != 0)
			{
				var valueFloat:Float = Std.parseFloat(valueString);
				if (!Math.isNaN(valueFloat))
				{
					return valueFloat;
				}
			}
		}
		return defaultVal;
	}
	
	/**
	 * Tries to grab the provided int field, returning a default on a failure.
	 * @param	fieldName
	 * @param	defaultVal
	 * @return
	 */
	public static function getIntField(fieldName:String, defaultVal:Int = 0):Int
	{
		if (Reflect.hasField(Tunables, fieldName))
		{
			var valueString:String = Std.string(Reflect.field(Tunables, fieldName));
			if (valueString.length != 0)
			{
				var valueInt:Null<Int> = Std.parseInt(valueString);
				if (valueInt == null)
				{
					Debug.warn("Int was null from valueString: " + valueString);
				}
				else
				{
					return valueInt;
				}				
			}
		}
		return defaultVal;
	}
	
	#end
	
}