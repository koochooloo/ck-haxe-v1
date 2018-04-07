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
 * Button representing toggling of something.
 */
class ToggleButton extends SymbolButton
{
	//===============================
	// Defs
	//===============================
	/**
	 * The symbol color for toggle Symbols in the "On" state.
	 */
	public static var TUNABLES_UI_BTN_TOGGLE_ON_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_TOGGLE_ON_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_TOGGLE_ON_COLOR", 0);
	}
	
	/**
	 * The fill color for toggle Symbols in the "On" state.
	 */
	public static var TUNABLES_UI_BTN_TOGGLE_ON_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_TOGGLE_ON_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_TOGGLE_ON_BG_COLOR", 0xFFFFFF);
	}
	
	/**
	 * The unicode for toggle Symbols in the "On" state.
	 */
	public static var TUNABLES_UI_BTN_TOGGLE_ON_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_TOGGLE_ON_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_TOGGLE_ON_SYMBOL", 0x2611);
	}
	
	/**
	 * The symbol color for toggle Symbols in the "Off" state.
	 */
	public static var TUNABLES_UI_BTN_TOGGLE_OFF_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_TOGGLE_OFF_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_TOGGLE_OFF_COLOR", 0xFFFFFF);
	}
	
	/**
	 * The fill color for toggle Symbols in the "Off" state.
	 */
	public static var TUNABLES_UI_BTN_TOGGLE_OFF_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_TOGGLE_OFF_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_TOGGLE_OFF_BG_COLOR", 0);
	}
	
	/**
	 * The unicode for toggle Symbols in the "Off" state.
	 */
	public static var TUNABLES_UI_BTN_TOGGLE_OFF_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_TOGGLE_OFF_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_TOGGLE_OFF_SYMBOL", 0x2610);
	}
	
	//==================================
	// Unique Properties
	//==================================
	public var toggleState(default, set):Bool;
	
	/**
	 * 
	 * @param	buttonSize
	 */
	public function new(?getButtonSize:Void -> Float) 
	{
		var getSymbol:Void -> Int = function():Int { return TUNABLES_UI_BTN_TOGGLE_OFF_SYMBOL; };
		var getSymColor:Void -> Int = function():Int { return TUNABLES_UI_BTN_TOGGLE_OFF_COLOR; };
		var getFillColor:Void -> Int = function():Int { return TUNABLES_UI_BTN_TOGGLE_OFF_BG_COLOR; };
		var getShape:Void -> SymbolButtonShape = function():SymbolButtonShape { return BOX; };
		
		super(getSymbol, getButtonSize, getSymColor, getFillColor, getShape);
		
		//Buttons always start off.
		toggleState = false;
	}
	
	/**
	 * Sets the toggle state of this button.
	 * @param	newState
	 * @return
	 */
	public function set_toggleState(newState:Bool):Bool
	{
		if (newState)
		{
			m_getSymbolCode  = function():Int { return TUNABLES_UI_BTN_TOGGLE_ON_SYMBOL; };
			m_getSymbolColor = function():Int { return TUNABLES_UI_BTN_TOGGLE_ON_COLOR; };
			m_getFillColor   = function():Int { return TUNABLES_UI_BTN_TOGGLE_ON_BG_COLOR; };
		}
		else
		{
			m_getSymbolCode  = function():Int { return TUNABLES_UI_BTN_TOGGLE_OFF_SYMBOL; };
			m_getSymbolColor = function():Int { return TUNABLES_UI_BTN_TOGGLE_OFF_COLOR; };
			m_getFillColor   = function():Int { return TUNABLES_UI_BTN_TOGGLE_OFF_BG_COLOR; };
		}
		
		//Update the button's appearence
		refreshButton();
		
		toggleState = newState;
		return newState;
	}
	
}
#end
