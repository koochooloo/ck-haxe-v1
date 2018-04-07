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
import haxe.ds.StringMap;

#if (macro || debug || build_cheats)

/**
 * Represents the definition of a tunable type.
 * Name: The name of the type.
 * defaultValue: An initial value to give to the variable.
 * haxeType: The actual haxe type that corresponds to this tunable type
 */
typedef TunablesType = 
{
	name:String,
	defaultValue:String,
	haxeType:String
};

/**
 * Represents a Tunable variable, and is used to generate the Tunables static fields.
 * name:  The name of the variable. What the generated Field will be called.
 * type:  The tunable type name of this variable. Used to generate the haxe type of the field.
 * value: The value of the variable. Used to set the value of the field.
 * tags:  Tags associated with this variable. Used in the menu for filtering purposes.
 */
typedef TunablesVariable = {
	 name: String,
	 type: String,
	 value: String,
	 tags: Array<String>
};

/**
 * Represents the Tunables definition file.
 * Type: 		escriptions of all the defined tunable types.
 * Tags:	 	List of all current existing tags.
 * Variables: 	List of all tunable variables.
 */
typedef TunablesFile = {
	Tags: Array<String>,
	Variables: Array<TunablesVariable>
};

/**
 * Represents a local override for a Tunable value
 * name:	The name of the Tunable to override
 * value:	The value to set the Tunable to at startup.
 */
typedef CustomTunableValue = {
	name:String,
	value:String
};

/**
 * Represents the local Tunables values file
 * Values:	Array of CustomTunableValue
 */
typedef CustomValuesFile = {
	Values:Array<CustomTunableValue>
};

class TunableDefs
{
	/**
	 * The path and filename of the Tunables json.
	 * This system expects this file to exist as named, and will create a new one
	 * if it can't find one.
	 */
	#if ios
	public static inline var tunablesFilePath:String = "../../../../lib/data/Tunables.json";
	public static inline var customValuesPath:String = "../../../../lib/data/CustomTunablesValues.json";
	public static inline var defaultSearchPath:String = "../../../../lib/data/DefaultTunablesSearch.json";
	#else
	public static inline var tunablesFilePath:String = "lib/data/Tunables.json";
	public static inline var customValuesPath:String = "lib/data/CustomTunablesValues.json";
	public static inline var defaultSearchPath:String = "lib/data/DefaultTunablesSearch.json";
	#end
	
	/**
	 * The tag given to variables tied to audio settings.
	 * Changing values with this tag sends a RefreshAudioEvent
	 * which will cause updates to WebAudio, and other classes
	 * related to audio.
	 */
	public static inline var AUDIO_TAG:String = "audio__";
	
	/**
	 * The tag given to tunables that are accessible in cheats builds.
	 * If a tunable doesn't have this tag, it will only be available in debug.
	 * This is here to allow us to differentiate between things we tune internally,
	 * versus values that we want to be able to use while testing or demoing.
	 */
	public static inline var CHEATS_TAG:String = "cheats__";
	
	/**
	 * The tag given to variables you want to delete. 
	 * Variables marked with this tag will not be saved out.
	 * WARNING: This can break the build if there are still places in code
	 * using this value. Use with caution.
	 */
	public static inline var DELETION_TAG:String = "delete__";
	
	/**
	 * The tag given to variables you want to protect.
	 * Variables marked with this tag will have all fields locked at startup.
	 * Requires manual editing of the json to remove.
	 */
	public static inline var LOCKED_TAG:String = "locked__";
	
	/**
	 * The tag given to variables tied to UI settings.
	 * Changing values with this tag sends a RefreshUIEvent
	 * which will cause subscribed UI elements to change.
	 */
	public static inline var UI_TAG:String = "ui__";
	
	/**
	 * Collection of tags always included in tunables.
	 * Have special handling associated with them.
	 */
	public static var BUILTIN_TAGS:Array<String> = [
		AUDIO_TAG,
		CHEATS_TAG,
		DELETION_TAG,
		LOCKED_TAG,
		UI_TAG
	];
	
	/**
	 * Type used by code for debugging and other purposes. Disables editing of fields.
	 */
	public static inline var PLACEHOLDER_TYPE:String = "PLACEHOLDER";
	
	/**
	 * The collection of all supported tunable types.
	 */
	public static var tunableTypes:StringMap<TunablesType> = 
	[
		"Bool" =>
		{
			name: 			"Bool",
			haxeType : 		"Bool",
			defaultValue: 	"False"
		},
		"Int" =>
		{
			name: 			"Int",
			haxeType : 		"Int",
			defaultValue: 	"0"
		},
		"Float" => 
		{
			name: 			"Float",
			haxeType : 		"Float",
			defaultValue: 	"0"
		},
		"Milliseconds" =>
		{
			name: 			"Milliseconds",
			haxeType : 		"Float",
			defaultValue: 	"1000"
		},
		"Seconds" =>
		{
			name: 			"Seconds",
			haxeType : 		"Float",
			defaultValue: 	"1"
		},
		"Percent" =>
		{
			name: 			"Percent",
			haxeType : 		"Float",
			defaultValue: 	"50"
		},
		"String" =>
		{
			name: 			"String",
			haxeType : 		"String",
			defaultValue: 	""
		},
		PLACEHOLDER_TYPE =>
		{
			name:			PLACEHOLDER_TYPE,
			haxeType :		"Int",
			defaultValue:	"1337"
		}
	];
}
#end
