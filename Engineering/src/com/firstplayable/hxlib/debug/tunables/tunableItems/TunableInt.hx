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
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import com.firstplayable.hxlib.Debug;
import openfl.text.TextField;

class TunableInt extends TunableItem
{

	public function new(startWidth:Float, startHeight:Float, variable:TunablesVariable) 
	{
		super(startWidth, startHeight, variable);
		
	}
	
	//=========================================================
	// Custom Handling
	//=========================================================

	/**
	 * Returns whether the provided value is valid for this item
	 * Assuming Milliseconds will be a positve value
	 * @param	val
	 * @return
	 */
	public static function ValidateFieldValue(val:String):Bool
	{
		if (val == null)
		{
			return false;
		}
		
		//Length 0 strings blow up on parse int
		if (val.length == 0)
		{
			return false;
		}
		
		//There is a bug with parse int for the string "0". 
		//It will fail, so we do the direct check here.
		//Probably due to how awful JS is.
		if (val == "0")
		{
			return true;
		}
		
		return Std.parseInt(val) != null;
	}
	
	/**
	 * Returns the value from the string representation
	 * @param	str
	 * @return
	 */
	public static function GetValueFromString(str:String):Dynamic
	{
		//There is a bug with parse int for the string "0". 
		//It will fail, so we do the direct check here.
		//Probably due to how awful JS is.
		if (str == "0")
		{
			return 0;
		}
		
		var val:Null<Int> = Std.parseInt(str);
		return val;
	}
	
	//=============================================================
	
}
#end
