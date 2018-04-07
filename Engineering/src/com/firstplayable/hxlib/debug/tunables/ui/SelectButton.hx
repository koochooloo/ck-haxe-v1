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
 * Button representing selection of something.
 */
class SelectButton extends SymbolButton
{
	//===============================
	// Defs
	//===============================
	/**
	 * The symbol color for select Symbols
	 */
	public static var TUNABLES_UI_BTN_SELECT_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_SELECT_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_SELECT_COLOR", 0);
	}
	
	/**
	 * The fill color for select Symbols
	 */
	public static var TUNABLES_UI_BTN_SELECT_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_SELECT_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_SELECT_BG_COLOR", 0);
	}
	
	/**
	 * The unicode for select Symbols
	 */
	public static var TUNABLES_UI_BTN_SELECT_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_SELECT_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_SELECT_SYMBOL", 0x2705);
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
		var getSymbol:Void -> Int = function():Int { return TUNABLES_UI_BTN_SELECT_SYMBOL; };
		var getSymColor:Void -> Int = function():Int { return TUNABLES_UI_BTN_SELECT_COLOR; };
		var getFillColor:Void -> Int = function():Int { return TUNABLES_UI_BTN_SELECT_BG_COLOR; };
		var getShape:Void -> SymbolButtonShape = function():SymbolButtonShape { return BOX; };
		
		super(getSymbol, getButtonSize, getSymColor, getFillColor, getShape);
	}
	
}
#end
