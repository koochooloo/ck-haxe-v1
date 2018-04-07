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
package com.firstplayable.hxlib.debug.cheats.cheatItems;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.debug.cheats.Cheats.CheatData;
import com.firstplayable.hxlib.debug.cheats.cheatItems.CheatItem;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import com.firstplayable.hxlib.debug.tunables.ui.UIDefs;
import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
import openfl.events.MouseEvent;
import com.firstplayable.hxlib.debug.tunables.ui.RemoveItemButton;
import com.firstplayable.hxlib.debug.tunables.ui.AddItemButton;
import com.firstplayable.hxlib.Debug;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
 * The CheatItem for the column headers.
 * Not interactive, just there for reference
 */
class CheatItemColumnLabels extends CheatItem
{
	//==================================
	// Column Header Defs
	//==================================
	
	/**
	 * The text color for column header cheat items
	 */
	public static var CHEAT_UI_HEADER_TEXT_COLOR(get, null):Int;
	public static function get_CHEAT_UI_HEADER_TEXT_COLOR():Int
	{
		if (Reflect.hasField(Tunables, "CHEAT_UI_HEADER_TEXT_COLOR"))
		{
			return Reflect.field(Tunables, "CHEAT_UI_HEADER_TEXT_COLOR");
		}
		else
		{
			return 0x000000;
		}
	}
	
	/**
	 * The fill color for column header tunable items
	 */
	public static var CHEAT_UI_HEADER_BG_COLOR(get, null):Int;
	public static function get_CHEAT_UI_HEADER_BG_COLOR():Int
	{
		if (Reflect.hasField(Tunables, "CHEAT_UI_HEADER_BG_COLOR"))
		{
			return Reflect.field(Tunables, "CHEAT_UI_HEADER_BG_COLOR");
		}
		else
		{
			return 0xD1D1D1;
		}
	}
	
	/**
	 * Construct a column label tunable item
	 * @param	startWidth
	 * @param	startHeight
	 * @param	variable
	 */
	public function new(startWidth:Float, startHeight:Float, columnLabels:CheatData) 
	{		
		super(startWidth, startHeight, columnLabels);
	}
	
	/**
	 * Post-construction initialization
	 */
	override public function init():Void
	{	
		super.init();
		
		for (field in m_textFields)
		{
			field.backgroundColor = CHEAT_UI_HEADER_BG_COLOR;
			field.textColor = CHEAT_UI_HEADER_TEXT_COLOR;
		}
		
		//Remove the select button.
		if (m_selectButton != null)
		{
			removeChild(m_selectButton);
			m_selectButton.removeEventListener(MouseEvent.CLICK, onSelectClicked);
			m_selectButton = null;
		}
	}
	
	/**
	 * Updates appearance
	 * @param	e
	 */
	override public function onRefreshUI(e:RefreshUIEvent):Void
	{
		super.onRefreshUI(e);
		
		for (field in m_textFields)
		{
			field.backgroundColor = CHEAT_UI_HEADER_BG_COLOR;
			field.textColor = CHEAT_UI_HEADER_TEXT_COLOR;
		}
	}
}
#end
