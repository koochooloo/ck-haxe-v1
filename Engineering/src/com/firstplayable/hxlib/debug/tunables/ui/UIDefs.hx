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
import com.firstplayable.hxlib.debug.tunables.Tunables;

/**
 * Defs for Debug UI elements.
 * All in one place for ease of editing.
 * All look to see if a TUNABLES_UI property has been set for them,
 * and if not returns a default.
 */
class UIDefs
{
	//====================================================================
	// General UI Definitions
	//====================================================================
	
	/**
	 * The background color of the tunables window, items, etc.
	 */
	public static var TUNABLES_UI_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BG_COLOR", 0x000000);
	}
	
	/**
	 * The outline color of the tunables window, items, etc.
	 */
	public static var TUNABLES_UI_OUTLINE_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_OUTLINE_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_OUTLINE_COLOR", 0xFFFFFF);
	}
	
	/**
	 * The outline size of the tunables window, items, etc.
	 * NOTE: does not apply to the TextField borders.
	 */
	public static var TUNABLES_UI_OUTLINE_SIZE(get, null):Float;
	public static function get_TUNABLES_UI_OUTLINE_SIZE():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_OUTLINE_SIZE", 2.0);
	}
	
	/**
	 * The ratio to normal item sizes that the bottom bar takes up.
	 */
	public static var TUNABLES_UI_BOTTOM_BAR_SIZE(get, null):Float;
	public static function get_TUNABLES_UI_BOTTOM_BAR_SIZE():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_BOTTOM_BAR_SIZE", 1.6);
	}
	
	/**
	 * The width of the ellipse used to generate the corners of a round rect.
	 */
	public static var TUNABLES_UI_ROUND_RECT_CORNER_SIZE(get, null):Float;
	public static function get_TUNABLES_UI_ROUND_RECT_CORNER_SIZE():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_ROUND_RECT_CORNER_SIZE", 5.0);
	}
	
	//====================================================================
	// Item Definitions
	//====================================================================
	
	/**
	 * The general size of UI elements. Specifies height of items, and dimmensions of buttons.
	 */
	public static var TUNABLES_UI_ITEM_SIZE(get, null):Float;
	public static function get_TUNABLES_UI_ITEM_SIZE():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_ITEM_SIZE", 20);
	}
	
	/**
	 * How many variable tunable items are displayed per page.
	 * Note: if this is too large, the UI may become unusable.
	 */
	public static var TUNABLES_UI_ITEMS_PER_PAGE(get, null):Int;
	public static function get_TUNABLES_UI_ITEMS_PER_PAGE():Int
	{
		return Tunables.getIntField("TUNABLES_UI_ITEMS_PER_PAGE", 20);
	}
	
	/**
	 * The max number of buttons per item. Not tunable.
	 */
	public static inline var TUNABLES_UI_ITEMS_NUM_BUTTONS:Int = 2;
	
	//====================================================================
	// Text Definitions
	//====================================================================
	
	/**
	 * The general text color for text fields in the UI.
	 * Note: For changing TunableTextField colors, look at the
	 * Text Field section of this file.
	 */
	public static var TUNABLES_UI_TEXT_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_TEXT_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_ITEMS_PER_PAGE", 0xFFFFFF);
	}
	
	/**
	 * The font size of text fields in the UI.
	 */
	public static var TUNABLES_UI_TEXT_SIZE(get, null):Int;
	public static function get_TUNABLES_UI_TEXT_SIZE():Int
	{
		return Tunables.getIntField("TUNABLES_UI_TEXT_SIZE", 12);
	}
	
	//====================================================================
	// Button Definitions
	//====================================================================
	
	/**
	 * Get the size of of standard buttons.
	 */
	public static var TUNABLES_UI_BTN_SIZE(get, null):Float;
	public static function get_TUNABLES_UI_BTN_SIZE():Float
	{
		return UIDefs.TUNABLES_UI_ITEM_SIZE - UIDefs.TUNABLES_UI_OUTLINE_SIZE;
	}
	
	/**
	 * The fill color for generic button symbols
	 */
	public static var TUNABLES_UI_BTN_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_BG_COLOR", TUNABLES_UI_BG_COLOR);
	}
	
	/**
	 * The color for generic button symbols
	 */
	public static var TUNABLES_UI_BTN_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_BG_COLOR", 0x00FF00);
	}
	
	/**
	 * The outline size for buttons
	 */
	public static var TUNABLES_UI_BTN_OUTLINE_SIZE(get, null):Float;
	public static function get_TUNABLES_UI_BTN_OUTLINE_SIZE():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_BTN_OUTLINE_SIZE", 2.0);
	}
	
	/**
	 * The unicode for Add Symbols
	 */
	public static var TUNABLES_UI_BTN_SEARCH_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_SEARCH_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_SEARCH_SYMBOL", 0x2315);
	}
	
}
#end
