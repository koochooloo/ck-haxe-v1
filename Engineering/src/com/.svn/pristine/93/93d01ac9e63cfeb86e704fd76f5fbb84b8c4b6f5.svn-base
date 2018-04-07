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
package com.firstplayable.hxlib.debug.tunables.ui;
import com.firstplayable.hxlib.debug.tunables.ui.SymbolButton;

/**
 * Button associated with addition of a new element
 */
class AddItemButton extends SymbolButton
{
	//===============================
	// Defs
	//===============================
	/**
	 * The fill color for Add Symbols
	 */
	public static var TUNABLES_UI_BTN_ADD_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_ADD_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_ADD_COLOR", 0x00FF00);
	}
	
	/**
	 * The unicode for Add Symbols
	 */
	public static var TUNABLES_UI_BTN_ADD_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_ADD_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_ADD_SYMBOL", 0x254B);
	}
	
	//==================================
	// Set the parameters
	//==================================

	/**
	 * 
	 * @param	buttonSize
	 */
	public function new(?getButtonSize:Void -> Float) 
	{
		var getAddSymbol:Void -> Int = function():Int { return TUNABLES_UI_BTN_ADD_SYMBOL; };
		var getAddColor:Void -> Int = function():Int { return TUNABLES_UI_BTN_ADD_COLOR; };
		
		super(getAddSymbol, getButtonSize, getAddColor);
	}
	
}
#end
