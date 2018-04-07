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
package com.firstplayable.hxlib.debug.menuEdit.menuEditItems;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.debug.menuEdit.Menus.MenuData;
import com.firstplayable.hxlib.debug.menuEdit.Menus.MenuLoadingStatus;
import com.firstplayable.hxlib.debug.menuEdit.Menus.MenuVisibility;
import com.firstplayable.hxlib.debug.menuEdit.menuEditItems.MenuEditItem;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import com.firstplayable.hxlib.debug.tunables.ui.UIDefs;
import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
import openfl.events.MouseEvent;
import com.firstplayable.hxlib.Debug;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
 * The CheatItem for the column headers.
 * Not interactive, just there for reference
 */
class MenuEditItemColumnLabels extends MenuEditItem
{
	//==================================
	// Column Header Defs
	//==================================
	
	/**
	 * The text color for column header menu items
	 */
	public static var MENU_EDIT_UI_HEADER_TEXT_COLOR(get, null):Int;
	public static function get_MENU_EDIT_UI_HEADER_TEXT_COLOR():Int
	{
		if (Reflect.hasField(Tunables, "MENU_EDIT_UI_HEADER_TEXT_COLOR"))
		{
			return Reflect.field(Tunables, "MENU_EDIT_UI_HEADER_TEXT_COLOR");
		}
		else
		{
			return 0x000000;
		}
	}
	
	/**
	 * The fill color for column header menu items
	 */
	public static var MENU_EDIT_UI_HEADER_BG_COLOR(get, null):Int;
	public static function get_MENU_EDIT_UI_HEADER_BG_COLOR():Int
	{
		if (Reflect.hasField(Tunables, "MENU_EDIT_UI_HEADER_BG_COLOR"))
		{
			return Reflect.field(Tunables, "MENU_EDIT_UI_HEADER_BG_COLOR");
		}
		else
		{
			return 0xD1D1D1;
		}
	}
	
	private var m_columnLabels:Map<MenuItemFields, String>;
	
	/**
	 * Construct a column label menu item
	 * @param	startWidth
	 * @param	startHeight
	 * @param	columnLabels
	 */
	public function new(startWidth:Float, startHeight:Float, columnLabels:Map<MenuItemFields, String>) 
	{		
		var dummyData:MenuData = 
		{
			name: "",
			menu: null,
			status: NO_STATUS,
			loadedExternally: false,
			visible: UNSET
		}
		
		m_columnLabels = columnLabels;
		
		super(startWidth, startHeight, dummyData);
	}
	
	/**
	 * Post-construction initialization
	 */
	override public function init():Void
	{	
		super.init();
		
		for (field in m_textFields)
		{
			field.backgroundColor = MENU_EDIT_UI_HEADER_BG_COLOR;
			field.textColor = MENU_EDIT_UI_HEADER_TEXT_COLOR;
		}
			
		//Remove the select button
		if (m_toggleVisibleBtn != null)
		{
			removeChild(m_toggleVisibleBtn);
			m_toggleVisibleBtn.removeEventListener(MouseEvent.CLICK, onToggleVisibleClicked);
			m_toggleVisibleBtn = null;
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
			field.backgroundColor = MENU_EDIT_UI_HEADER_BG_COLOR;
			field.textColor = MENU_EDIT_UI_HEADER_TEXT_COLOR;
		}
	}
	
	/**
	 * Updates the name text field based on current name.
	 */
	override private function updateTextFieldName():Void
	{
		var textField:TunableTextField = getTextField(NAME_FIELD);
		textField.text = m_columnLabels.get(NAME_FIELD);
	}
	
	/**
	 * Updates the status text field based on current status.
	 */
	override private function updateTextFieldStatus():Void
	{
		var textField:TunableTextField = getTextField(STATUS_FIELD);
		textField.text = m_columnLabels.get(STATUS_FIELD);
	}
	
	/**
	 * Updates the visiblity text field based on current visibility.
	 */
	override private function updateTextFieldVisible():Void
	{
		var textField:TunableTextField = getTextField(VISIBLE_FIELD);
		textField.text = m_columnLabels.get(VISIBLE_FIELD);
	}
}
#end
