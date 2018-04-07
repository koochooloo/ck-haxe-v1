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

#if macro
package com.firstplayable.hxlib.debug.tunables;
import com.firstplayable.hxlib.utils.ArrayTools;
import haxe.macro.Expr;
import haxe.ds.StringMap;
import haxe.macro.Expr.Access;
import sys.io.File;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import haxe.macro.Expr.FieldType;
import haxe.Json;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.CustomTunableValue;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.CustomValuesFile;
import sys.FileSystem;
import haxe.macro.Context;
import haxe.macro.Expr.Field;

class BuildLocalTunablesConfigurator
{
	private static inline var PLACEHOLDER_CUSTOM_VALUE_NAME:String = "EXAMPLE_TUNABLE_OVERRIDE";
	private static inline var PLACEHOLDER_CUSTOM_VALUE_VAL:String = "1337";
	
	private static inline var AUTO_BUILD_FLAG:String = "IS_AUTOBUILD";
	
	private static var CUSTOM_VALUES_FILE_FIELDS:StringMap<Dynamic> = [
		"Values" => Array
	];
	
	private static var CUSTOM_VALUE_FIELDS:StringMap<Dynamic> = [
		"name" => String,
		"value" => String
	];
	
	private static var DEFAULT_SEARCH_FIELDS:StringMap<Dynamic> = [
		"name" => String,
		"tags" => Array,
		"type" => String,
		"value" => String
	];
	
	private static function isAutobuild():Bool
	{
		return (Sys.environment().exists(AUTO_BUILD_FLAG) && (Sys.environment().get(AUTO_BUILD_FLAG) != "0"));
	}
	
	/**
	 * Build the local configurator.
	 * @return
	 */
	public static function build():Array<Field>
	{	
		// get existing fields from the context from where build() is called
		var fields = Context.getBuildFields();
				
		//====================================================
		// Build the custom values
		//====================================================
		
		if (!isAutobuild())
		{
			if (!FileSystem.exists(TunableDefs.customValuesPath))
			{
				createDefaultCustomValues();
			}
			else
			{
				var jsonContent = File.getContent(TunableDefs.customValuesPath);
				try
				{
					var contentObject:Dynamic = Json.parse(jsonContent);
					if (!validateCustomValuesFile(contentObject))
					{
						throw("invalid custom file");
					}
				}
				catch (e:String)
				{
					Debug.log("error: " + e);
					createDefaultCustomValues();
				}
			}
		}
		
		var customValueExpressions:Array<Expr> = [];
		
		if (!isAutobuild())
		{
			if (FileSystem.exists(TunableDefs.customValuesPath))
			{
				var jsonContent = File.getContent(TunableDefs.customValuesPath);
				try
				{
					var customValuesFile:CustomValuesFile = Json.parse(jsonContent);
					var customValues:Array<CustomTunableValue> = customValuesFile.Values;
				
					for (val in customValues)
					{
						customValueExpressions.push(macro $v{val.name} => $v{val});
					}
				}
				catch (error:String)
				{
					trace("error: " + error);
					
					var position = Std.parseInt(error.split("position").pop());
					var pos = haxe.macro.Context.makePosition({
						min:position,
						max:position + 1,
						file:TunableDefs.customValuesPath
					});
					haxe.macro.Context.error(TunableDefs.customValuesPath + " is not valid Json. " + error, pos);
				}
			}
			else
			{
				Debug.warn("no file: " + TunableDefs.customValuesPath + " and failed to create!");
			}
		}
		
		var customValueExpMacro:Expr = null;
		if (customValueExpressions.length > 0)
		{
			customValueExpMacro = macro $a{customValueExpressions};
		}
		fields.push({
			name:  "CUSTOM_VALUES",
			doc: "Collection of values to set on Tunables at game start.",
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FVar(macro:StringMap<CustomTunableValue>, customValueExpMacro), 
			pos: Context.currentPos(),
		});
		
		//====================================================
		// Build the default search
		//====================================================		
		
		if (!isAutobuild())
		{
			if (!FileSystem.exists(TunableDefs.defaultSearchPath))
			{
				createDefaultSearch();
			}
			else
			{
				var jsonContent = File.getContent(TunableDefs.defaultSearchPath);
				try
				{
					var rawSearchObj:Dynamic = Json.parse(jsonContent);
					if (!validateDefaultSearchFile(rawSearchObj))
					{
						throw("invalid search file");
					}
				}
				catch (e:String)
				{
					Debug.log("error: " + e);
					createDefaultSearch();
				}
			}
		}
		
		var defaultSearch:TunablesVariable = 
		{
			name:"",
			type:"",
			value:"",
			tags:[]
		};
		
		if (!isAutobuild())
		{
			if (FileSystem.exists(TunableDefs.defaultSearchPath))
			{
				var jsonContent = File.getContent(TunableDefs.defaultSearchPath);
				try
				{
					defaultSearch = Json.parse(jsonContent);
				}
				catch (error:String)
				{
					trace("error: " + error);
					
					var position = Std.parseInt(error.split("position").pop());
					var pos = haxe.macro.Context.makePosition({
						min:position,
						max:position + 1,
						file:TunableDefs.defaultSearchPath
					});
					haxe.macro.Context.error(TunableDefs.defaultSearchPath + " is not valid Json. " + error, pos);
				}
			}
			else
			{
				Debug.warn("no file: " + TunableDefs.defaultSearchPath + " and failed to create!");
			}
		}
		
		fields.push({
			name:  "DEFAULT_SEARCH",
			doc: "Search to put in the Tunables menu search bar at start of game",
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FVar(macro:TunablesVariable, macro $v{defaultSearch}), 
			pos: Context.currentPos(),
		});
		
		return fields;
	}
	
	/**
	 * Returns whether the provided object has the expected fields.
	 * @param	obj
	 * @param	expectedFields
	 * @return
	 */
	private static function validateObject(obj:Dynamic, expectedFields:StringMap<Dynamic>):Bool
	{
		if (obj == null)
		{
			return false;
		}
		
		if (expectedFields == null)
		{
			return false;
		}
		
		var objFields:Array<String> = Reflect.fields(obj);
		
		var foundFields:StringMap<Bool> = new StringMap<Bool>();
		for (field in objFields)
		{
			var expectedType:Dynamic = expectedFields.get(field);
			if (expectedType == null)
			{
				return false;
			}
			
			var realVal:Dynamic = Reflect.field(obj, field);
			if (!Std.is(realVal, expectedType))
			{
				return false;
			}
			
			foundFields.set(field, true);
		}
		
		for (expectedField in expectedFields.keys())
		{
			if (!foundFields.exists(expectedField))
			{
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Validates whether the provided customValues file is valid.
	 * @param	file
	 * @return
	 */
	private static function validateCustomValuesFile(file:Dynamic):Bool
	{
		if (!validateObject(file, CUSTOM_VALUES_FILE_FIELDS))
		{
			return false;
		}
		
		var rawValuesArray:Array<Dynamic> = Reflect.field(file, "Values");
		for (value in rawValuesArray)
		{
			if (!validateObject(value, CUSTOM_VALUE_FIELDS))
			{
				return false;
			}
		}

		return true;
	}
	
	/**
	 * Creates a default CustomTunablesValues.json
	 */
	private static function createDefaultCustomValues():Void
	{
		// Having this logging here will emit to stderr (we think)
		// and may cause the make for "Build Haxe" target on the iOS build to
		// think it failed?  Attempting without.
		// (There's still a race condition here between the parallel 32 and 64-bit builds.)
		// DISABLED FOR AUTOBUILD // Debug.log("Valid " + TunableDefs.customValuesPath + " didn't exist, making a fresh one!");
			
		var defaultValue:CustomTunableValue = 
		{
			name:PLACEHOLDER_CUSTOM_VALUE_NAME,
			value:PLACEHOLDER_CUSTOM_VALUE_VAL
		};
		var defaultCustomValues:Array<CustomTunableValue> = [defaultValue];
		
		var freshCustomValuesFile:CustomValuesFile = 
		{
			Values: defaultCustomValues
		};
		
		var newContent:String = Json.stringify(freshCustomValuesFile, "   ");
		
		try
		{
			File.saveContent(TunableDefs.customValuesPath, newContent);
		}
		catch (error:String)
		{
			trace("error: " + error);
		}
	}
	
	/**
	 * creates a default DefaultTunablesSearch.json
	 */
	public static function createDefaultSearch():Void
	{
		// See above for rationale.
		// DISABLED FOR AUTOBUILD // Debug.log("Valid " + TunableDefs.defaultSearchPath + " didn't exist, making a fresh one!");
		
		var defaultSearch:TunablesVariable = 
		{
			name:"",
			type:"",
			value:"",
			tags:[]
		};
		
		var newContent:String = Json.stringify(defaultSearch, "   ");
		try
		{
			File.saveContent(TunableDefs.defaultSearchPath, newContent);
		}
		catch (error:String)
		{
			trace("error: " + error);
		}
	}
	
	/**
	 * Validates whether the provided default Search file is valid.
	 * @param	file
	 * @return
	 */
	private static function validateDefaultSearchFile(file:Dynamic):Bool
	{
		if (!validateObject(file, DEFAULT_SEARCH_FIELDS))
		{
			return false;
		}
		
		var rawTagsArray:Array<Dynamic> = Reflect.field(file, "tags");
		for (value in rawTagsArray)
		{
			if (!Std.is(value, String))
			{
				return false;
			}
		}

		return true;
	}
	
}
#end
