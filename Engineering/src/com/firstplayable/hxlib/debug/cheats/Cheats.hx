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

package com.firstplayable.hxlib.debug.cheats;
import haxe.ds.StringMap;

#if (debug || build_cheats)

/**
 * A struct representing a given cheat.
 */
typedef CheatData = 
{
	name:String,
	tags:Array<String>,
	func:Void -> Void
}

/**
 * Collection of cheat functions that are manually callable at runtime.
 * Are registered in code.
 */
class Cheats
{
	private static var ms_cheatsTable:StringMap<CheatData> = new StringMap<CheatData>();
	private static var ms_allTags:StringMap<Bool> = new StringMap<Bool>();
	
	/**
	 * The regex describing an acceptable cheat name
	 * @return
	 */
	private static var CHEAT_NAME_REGEX:EReg = ~/^[A-Z0-9 ]+$/i;
	
	/**
	 * Returns whether the cheat name is valid.
	 * @return
	 */
	public static function validateFieldName(name:String):Bool
	{
		return (CHEAT_NAME_REGEX.match(name));
	}
	
	/**
	 * The regex describing an acceptable tunable name
	 * @return
	 */
	private static var VARIABLE_TAG_REGEX:EReg = ~/^[A-Z][A-Z0-9_]+$/i;
	
	/**
	 * Returns whether the tag string is valid.
	 * @return
	 */
	public static function validateTag(tagString:String):Bool
	{
		return (tagString.length > 1) && (VARIABLE_TAG_REGEX.match(tagString));
	}
	
	public static function getCheatNames():Iterator<String>
	{
		return ms_cheatsTable.keys();
	}
	
	/**
	 * Returns whether a cheat of the specified name exists
	 * @param	cheatName
	 * @return
	 */
	public static function cheatExists(cheatName:String):Bool
	{
		return ms_cheatsTable.exists(cheatName);
	}
	
	/**
	 * Gets the cheat with the given name, returning null if it doesn't exist.
	 * @param	cheatName
	 */
	public static function getCheat(cheatName:String):CheatData
	{
		if (!cheatExists(cheatName))
		{
			return null;
		}
		
		return ms_cheatsTable.get(cheatName);
	}
	
	/**
	 * Calls the cheat with the provided name if it exists.
	 * @param	cheatName
	 */
	public static function callCheat(cheatName:String):Void
	{
		var cheat:CheatData = getCheat(cheatName);
		if (cheat == null)
		{
			Debug.warn("Cheat: " + cheatName + " doesn't exist!");
			return;
		}
		
		cheat.func();
	}
	
	/**
	 * Returns whether the provided tag exists.
	 * @param	tagName
	 * @return
	 */
	public static function tagExists(tagName:String):Bool
	{
		return ms_allTags.exists(tagName);
	}
	
	/**
	 * Tries to register the provided cheat into the table.
	 * @param	newCheat
	 */
	public static function registerCheat(newCheat:CheatData):Void
	{
		if (newCheat == null)
		{
			Debug.warn("trying to register a null cheat...");
			return;
		}
		
		if (newCheat.func == null)
		{
			Debug.warn("trying to register a cheat for a null function...");
			return;
		}
		
		if (ms_cheatsTable.exists(newCheat.name))
		{
			Debug.warn("cheat: " + newCheat.name + " already exists! Skipping...");
			return;
		}
		
		if (!validateFieldName(newCheat.name))
		{
			Debug.warn("Cheat name is invalid, only accepts alpha numeric + spaces");
			return;
		}
		
		var validTags:Array<String> = [];
		for (tag in newCheat.tags)
		{
			if (!validateTag(tag))
			{
				Debug.warn("tag: " + tag + ", is invalid. Skipping.");
				continue;
			}
			validTags.push(tag);
			ms_allTags.set(tag, true);
		}
		
		//Erase all invalid tags.
		newCheat.tags = validTags;
		
		var cleanedCheat:CheatData = 
		{
			name:newCheat.name,
			tags:validTags,
			func:newCheat.func
		};
		
		//Add the new cheat to the 
		ms_cheatsTable.set(cleanedCheat.name, cleanedCheat);
	}
	
	
}
#end
