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

package com.firstplayable.hxlib.debug.tunables.tunableItems;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import openfl.text.TextField;

class TunableBool extends TunableItem
{

	public function new(startWidth:Float, startHeight:Float, variable:TunablesVariable) 
	{
		super(startWidth, startHeight, variable);
	}
	
	//=========================================================
	// Custom Handling
	//=========================================================
	
	/**
	 * The regex describing an acceptable tunable name
	 * @return
	 */
	private static var TRUE_REGEX:EReg = ~/((^T$))|(^TRUE$)|(^[1-9][0-9]*$)/i;
	private static var FALSE_REGEX:EReg = ~/((^F$))|(^False$)|(^[0]+$)/i;

	/**
	 * Returns whether the provided value is valid for this item
	 * @param	val
	 * @return
	 */
	public static function ValidateFieldValue(val:String):Bool
	{
		return TRUE_REGEX.match(val) || FALSE_REGEX.match(val);
	}
	
	/**
	 * Returns the value from the string representation
	 * @param	field
	 * @return
	 */
	public static function GetValueFromString(str:String):Dynamic
	{
		if (TRUE_REGEX.match(str))
		{
			return true;
		}
		else if (FALSE_REGEX.match(str))
		{
			return false;
		}
		return null;
	}
	
	//=============================================================
	
}
#end
