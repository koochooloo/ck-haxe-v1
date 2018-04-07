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

class TunablePercent extends TunableItem
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
	 * @param	val
	 * @return
	 */
	public static function ValidateFieldValue(val:String):Bool
	{
		var floatVal:Float = Std.parseFloat(val);
		if (Math.isNaN(floatVal))
		{
			//We do not accept NaN as a parameter.
			return false;
		}
		
		return (floatVal >= 0) && (floatVal <= 100);
	}
	
	/**
	 * Returns the value from the string representation
	 * @param	str
	 * @return
	 */
	public static function GetValueFromString(str:String):Dynamic
	{
		var val:Float = Std.parseFloat(str);
		return val;
	}
	
	/**
	 * Sets the string representation of the provided value in the provided text field.
	 * @param	field
	 * @param	val
	 */
	public static function SetTextFieldFromValue(field:TextField, val:Dynamic):Void
	{
		if (field == null)
		{
			return;
		}
		
		field.text = "" + val + "%";
	}
	
	//=============================================================
	
}
#end
