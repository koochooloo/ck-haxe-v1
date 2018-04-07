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
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import com.firstplayable.hxlib.debug.tunables.ui.UIDefs;
import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import com.firstplayable.hxlib.debug.tunables.TunablesMenu;
import openfl.events.MouseEvent;
import com.firstplayable.hxlib.debug.tunables.ui.RemoveItemButton;
import com.firstplayable.hxlib.debug.tunables.ui.AddItemButton;
import com.firstplayable.hxlib.debug.tunables.Tunables;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableItem;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
 * The TunableItem for the column headers.
 * Not editable, just there for reference
 */
class TunableItemColumnLabels extends TunableItem
{
	//==================================
	// Column Header Defs
	//==================================
	
	/**
	 * The text color for column header tunable items
	 */
	public static var TUNABLES_UI_HEADER_TEXT_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_HEADER_TEXT_COLOR():Int
	{
		if (Reflect.hasField(Tunables, "TUNABLES_UI_HEADER_TEXT_COLOR"))
		{
			return Reflect.field(Tunables, "TUNABLES_UI_HEADER_TEXT_COLOR");
		}
		else
		{
			return 0x000000;
		}
	}
	
	/**
	 * The fill color for column header tunable items
	 */
	public static var TUNABLES_UI_HEADER_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_HEADER_BG_COLOR():Int
	{
		if (Reflect.hasField(Tunables, "TUNABLES_UI_HEADER_BG_COLOR"))
		{
			return Reflect.field(Tunables, "TUNABLES_UI_HEADER_BG_COLOR");
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
	public function new(startWidth:Float, startHeight:Float, variable:TunablesVariable) 
	{
		super(startWidth, startHeight, variable);
		m_type = variable.type;
	}
	
	/**
	 * Post-construction initialization
	 */
	override public function init():Void
	{	
		super.init();
		
		for (field in m_textFields)
		{
			field.backgroundColor = TUNABLES_UI_HEADER_BG_COLOR;
			field.textColor = TUNABLES_UI_HEADER_TEXT_COLOR;
		}
		
		//Remove the reset button.
		if (m_resetButton != null)
		{
			removeChild(m_resetButton);
			m_resetButton.removeEventListener(MouseEvent.CLICK, onResetClicked);
			m_resetButton = null;
		}
	}
	
	/**
	 * CB for when the value field of this item loses the focus
	 * @param	e
	 */
	override private function onDefocusTextField(e:FocusEvent):Void
	{
		return;
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
			field.backgroundColor = TUNABLES_UI_HEADER_BG_COLOR;
			field.textColor = TUNABLES_UI_HEADER_TEXT_COLOR;
		}
	}
	
	//================================================================
	// Validation
	//================================================================
	
	/**
	 * Returns whether the provided field is editable for this item or not
	 * @param	field
	 * @return
	 */
	override public function getEditableForField(field:TunableItemFields):Bool
	{
		//No editable fields
		return false;
	}
	
	/**
	 * Updates the value text field based on current type.
	 */
	override private function updateTextFieldValue():Void
	{
		var textField:TunableTextField = getTextField(VALUE_FIELD);
		if (textField == null)
		{
			Debug.warn("value text field is null, can't set text...");
			return;
		}
		textField.text = Std.string(m_value);
	}
	
	/**
	 * Updates the value text field based on current type.
	 */
	override private function updateTextFieldType():Void
	{
		var textField:TunableTextField = getTextField(TYPE_FIELD);
		if (textField == null)
		{
			Debug.warn("type text field is null, can't set text...");
			return;
		}
		textField.text = m_type;
	}
	
	/**
	 * Gets the struct needed to save this value to the json.
	 * Returns null if this item isn't saved.
	 * @return
	 */
	override public function getSerializableObject():TunablesVariable
	{
		return null;
	}
}
#end
