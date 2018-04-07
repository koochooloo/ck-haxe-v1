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

#if macro
import com.firstplayable.hxlib.Debug;

import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunableDefs;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesFile;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesType;

import sys.FileSystem;
import sys.io.File;
import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroType;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import haxe.Json;

/**
 * Builds the list of Tunable values from the Tunables.json file.
 */
class BuildTunables 
{
	/**
	 * Variables used when initializing Tunables.json for the project.
	 */
	private static inline var placeholderName:String = "Create a Tunable by pressing the [+]";
	
	public static function build():Array<Field>
	{	
		// get existing fields from the context from where build() is called
		var fields = Context.getBuildFields();
		//trace("BuildTunables CWD");
		//trace(Sys.getCwd());
		if (!FileSystem.exists(TunableDefs.tunablesFilePath))
		{
			Debug.log("TunableDefs.tunablesFilePath didn't exist, making a fresh one!");
			
			var defaultTags:Array<String> = [for(tag in TunableDefs.BUILTIN_TAGS) tag];
			var defaultVariable:TunablesVariable = 
			{
				name: placeholderName,
				type: TunableDefs.PLACEHOLDER_TYPE,
				value: TunableDefs.tunableTypes.get(TunableDefs.PLACEHOLDER_TYPE).defaultValue,
				tags: [TunableDefs.DELETION_TAG, TunableDefs.LOCKED_TAG]
			}
			var defaultVariables:Array<TunablesVariable> = [defaultVariable];
			
			var freshTunablesFile:TunablesFile = 
			{
				Tags: defaultTags,
				Variables: defaultVariables
			}
			
			var newContent:String = Json.stringify(freshTunablesFile);
			
			File.saveContent(TunableDefs.tunablesFilePath, newContent);
		}
		
		if (FileSystem.exists(TunableDefs.tunablesFilePath))
		{
			var jsonContent = File.getContent(TunableDefs.tunablesFilePath);
			try
			{
				var tunableJson = Json.parse(jsonContent);
				
				//=================================================
				//Get Tags
				//=================================================
				var allTags:Array<String> = tunableJson.Tags;
				var allTagsMap:StringMap<Bool> = new StringMap<Bool>();
				var allTagsMapExpr:Array<Expr> = [];
				
				for (tag in allTags)
				{
					allTagsMap.set(tag, true);
					allTagsMapExpr.push(macro $v{tag} => $v{true});
				}
				
				//Add all builtin tags we are missing to the tags list.
				for (tag in TunableDefs.BUILTIN_TAGS)
				{
					if (!allTagsMap.exists(tag))
					{
						allTagsMap.set(tag, true);
						allTagsMapExpr.push(macro $v{tag} => $v{true});
					}
				}
				
				#if (debug || build_cheats)
				// append a field
				fields.push({
					name:  "ALL_TAGS",
					doc: "Tunable tag from Tunables json",
					access:  [Access.APublic, Access.AStatic],
					kind: FieldType.FVar(macro:StringMap<Bool>, macro $a{allTagsMapExpr}),
					pos: Context.currentPos(),
				});
				#end
				
				//=================================================
				//Get Values
				//=================================================
				var allVariables:Array<TunablesVariable> = tunableJson.Variables;
				var allVariablesMap:StringMap<TunablesVariable> = new StringMap<TunablesVariable>();
				var allVariablesMapExpr:Array<Expr> = [];
				
				for (variable in allVariables)
				{
					if (!validateTunableVariable(variable, allVariablesMap, allTagsMap))
					{
						continue;
					}
					
					allVariablesMap.set(variable.name, variable);
					
					allVariablesMapExpr.push(macro $v{variable.name} => $v{variable});
					
					var nextValue:Dynamic = getValueFromString(variable.type, variable.value);
					
					fields.push({
						name:  variable.name,
						doc: "Tunable value from Tunables json",
						//Tunable values are only editable at runtime for debug builds
						#if (debug || build_cheats)
						access: [Access.APublic, Access.AStatic],
						#else
						access: [Access.APublic, Access.AStatic, Access.AInline],
						#end
						kind: FieldType.FVar(getComplexTypeFromString(variable.type), macro $v{nextValue}), 
						pos: Context.currentPos(),
					});
				}
				
				#if (debug || build_cheats)
					fields.push({
						name:  "ALL_VARIABLES",
						doc: "Collection of all variable names from Tunables json",
						access:  [Access.APublic, Access.AStatic],
						kind: FieldType.FVar(macro:StringMap<TunablesVariable>, macro $a{allVariablesMapExpr}),
						pos: Context.currentPos(),
					});
				#end
			}
			catch (error:String)
			{
				trace("error: " + error);
				
				var position = Std.parseInt(error.split("position").pop());
				var pos = haxe.macro.Context.makePosition({
					min:position,
					max:position + 1,
					file:TunableDefs.tunablesFilePath
				});
				haxe.macro.Context.error(TunableDefs.tunablesFilePath + " is not valid Json. " + error, pos);
			}
		}
		else
		{
			Debug.warn("Tunables file is missing, and failed to create!");
		}
	
		return fields;
	}
	
	public static function getComplexTypeFromString(typeString:String):ComplexType
	{
		if (!TunableDefs.tunableTypes.exists(typeString))
		{
			trace("Unhandled getTypeFromString type: " + typeString);
			return null;
		}
		
		var tunableType:TunablesType = TunableDefs.tunableTypes.get(typeString);
		var name:String = tunableType.haxeType;
		
		return TypeTools.toComplexType(Context.getType(name));
	}
	
	/**
	 * This is neccessary because we needed the variable definition to have string as the value.
	 * The string map could not handle maping to anonymous structures.
	 * @param	typeString
	 * @param	value
	 * @return
	 */
	public static function getValueFromString(typeString:String, value:String):Dynamic
	{
		if (!TunableDefs.tunableTypes.exists(typeString))
		{
			trace("Unhandled getTypeFromString type: " + typeString);
			return null;
		}
		
		var tunableType:TunablesType = TunableDefs.tunableTypes.get(typeString);
		var name:String = tunableType.haxeType;
		
		if (name == "Int")
		{
			return Std.parseInt(value);
		}
		if (name == "Float")
		{
			return Std.parseFloat(value);
		}
		if (name == "Bool")
		{
			return (value == "true");
		}
		if (name == "String")
		{
			return value;
		}
		
		trace("Unhandled getTypeFromString type: " + typeString);
		return null;
	}
	
	/**
	 * Returns whether the provided tunable variable struct is valid.
	 * @param	variable
	 * @return
	 */
	public static function validateTunableVariable(variable:TunablesVariable, allVariables:StringMap<TunablesVariable>, allTags:StringMap<Bool>):Bool
	{
		//test name
		if (allVariables.exists(variable.name))
		{
			trace('Invalid name: $variable.name already exists!');
			return false;
		}
		
		//test type
		if (!TunableDefs.tunableTypes.exists(variable.type))
		{
			trace('invalid type for $variable.name: $variable.type, known types: $TunableDefs.tunableTypes');
			return false;
		}
		
		//test tags
		var variableTags:Array<String> = variable.tags;
		for (tag in variableTags)
		{
			if (!allTags.exists(tag))
			{
				trace('invalid tag for $variable.name: $tag, known tags: $allTags');
				return false;
			}
		}
		
		return true;
	}
}
#end

