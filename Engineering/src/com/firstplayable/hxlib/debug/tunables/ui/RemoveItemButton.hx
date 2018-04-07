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
 * Button associated with removal of an element
 */
class RemoveItemButton extends SymbolButton
{
	//===============================
	// Defs
	//===============================
	/**
	 * The fill color for Delete Symbols
	 */
	public static var TUNABLES_UI_BTN_DELETE_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_DELETE_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_DELETE_COLOR", 0xFF0000);
	}
	
	/**
	 * The unicode for Delete Symbols
	 */
	public static var TUNABLES_UI_BTN_DELETE_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_DELETE_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_DELETE_SYMBOL", 0x268A);
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
		var getSymbol:Void -> Int = function():Int { return TUNABLES_UI_BTN_DELETE_SYMBOL; };
		var getColor:Void -> Int = function():Int { return TUNABLES_UI_BTN_DELETE_COLOR; };
		
		super(getSymbol, getButtonSize, getColor);
	}
	
}
#end
