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
import com.firstplayable.hxlib.debug.tunables.ui.SelectButton;
import com.firstplayable.hxlib.debug.cheats.Cheats.CheatData;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import openfl.events.MouseEvent;
import com.firstplayable.hxlib.debug.tunables.ui.UIDefs;
import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
import haxe.EnumTools;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import openfl.events.FocusEvent;
import openfl.text.TextFieldType;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.events.Event;
import com.firstplayable.hxlib.Debug;

import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;

enum CheatItemFields
{
	NAME_FIELD;
	TAGS_FIELD;
}

/**
 * Defines an item to be shown on the cheat menu.
 * Allows calling the cheat at runtime.
 */
class CheatItem extends Sprite
{	
	//==================================
	// UI DEFS
	//==================================
	/**
	 * The ratio of available field space in an item for the Name field.
	 */
	public static var CHEATS_UI_FIELD_WIDTH_NAME(get, null):Float;
	public static function get_CHEATS_UI_FIELD_WIDTH_NAME():Float
	{
		return Tunables.getFloatField("CHEATS_UI_FIELD_WIDTH_NAME", 0.6);
	}
	
	/**
	 * The ratio of available field space in an item for the Tags field.
	 */
	public static var CHEATS_UI_FIELD_WIDTH_TAGS(get, null):Float;
	public static function get_CHEATS_UI_FIELD_WIDTH_TAGS():Float
	{
		return Tunables.getFloatField("CHEATS_UI_FIELD_WIDTH_TAGS", 0.4);
	}
	
	/**
	 * The minimum gap between buttons on the item
	 */
	public static var CHEATS_UI_ITEM_BTN_GAP(get, null):Float;
	public static function get_CHEATS_UI_ITEM_BTN_GAP():Float
	{
		return Tunables.getFloatField("CHEATS_UI_ITEM_BTN_GAP", 4.0);
	}
	
	//==================================
	// Members and Implementation
	//==================================
	
	private var m_initialWidth:Float;
	private var m_initialHeight:Float;
	private var m_cheat:CheatData;
	
	//The container that holds the elements in this item.
	private var m_container:Shape;
	
	//The text fields for this item
	private var m_textFields:Array<TunableTextField>;
	
	// button to activate the cheat.
	private var m_selectButton:SelectButton;
	
	//================================================================
	// Data Properties
	//================================================================
	public var cheatName(get, null):String;
	
	//================================================================
	// GUI Property Declarations
	//================================================================
	
	/**
	 * How much horizontal space is available for all the buttons
	 */
	public var buttonSpace(get, null):Float;
	
	/**
	 * How much horizontal space is available for all the text fields.
	 */
	public var fieldSpace(get, null):Float;
	
	/**
	 * Whether this item has been inited yet.
	 */
	public var m_inited:Bool;
	
	//=================================================================

	public function new(startWidth:Float, startHeight:Float, cheat:CheatData) 
	{
		super();
		
		m_initialWidth = startWidth;
		m_initialHeight = startHeight;
		
		m_cheat = cheat;
		
		//setup the UI
		
		m_container = new Shape();
		addChild(m_container);
		
		//Create the text fields
		m_textFields = [];
		var fields:Array<CheatItemFields> = EnumTools.createAll(CheatItemFields);
		for (field in fields)
		{
			//No cheat fields are editable.
			var newTextField = new TunableTextField(field.getIndex(), getEditableForField(field));
			m_textFields.push(newTextField);
		}
		
		m_selectButton = null;
		
		m_inited = false;
	
		//Create the container
		updateContainer();
	}
	
	public function init():Void
	{	
		updateContainer();
		
		var initialFieldWidth:Float = m_initialWidth - buttonSpace;
		
		//position the fields
		var curX:Float = 0;
		for (field in m_textFields)
		{
			initField(field, initialFieldWidth, curX);
			curX += field.width;
		}
		
		//Create the reset button
		m_selectButton = new SelectButton();
		addChild(m_selectButton);
		m_selectButton.x = initialFieldWidth + UIDefs.TUNABLES_UI_BTN_SIZE + CHEATS_UI_ITEM_BTN_GAP + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE * 1.5);
		m_selectButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
		m_selectButton.addEventListener(MouseEvent.CLICK, onSelectClicked);
		
		m_inited = true;
	}
	
	/**
	 * Called when this item is deleted.
	 */
	public function release():Void
	{	
		if (m_selectButton != null)
		{
			removeChild(m_selectButton);
			m_selectButton.removeEventListener(MouseEvent.CLICK, onSelectClicked);
		}
		m_selectButton = null;
		
		for (field in m_textFields)
		{
			field.removeEventListener(FocusEvent.FOCUS_OUT, onDefocusTextField);
			
			field.release();
			removeChild(field);
			field = null;
		}
		m_textFields = [];
		
		removeChild(m_container);
		m_container = null;
		
		m_cheat = null;
		
		m_inited = false;
	}
	
	/**
	 * Updates appearance
	 * @param	e
	 */
	public function onRefreshUI(e:RefreshUIEvent):Void
	{
		updateContainer();
		
		//position the fields
		var curX:Float = 0;
		for (field in m_textFields)
		{
			field.onRefreshUI(e);
			positionField(field, fieldSpace, curX);
			curX += field.width;
		}
		
		//update the reset button
		if (m_selectButton != null)
		{
			m_selectButton.x = fieldSpace + UIDefs.TUNABLES_UI_BTN_SIZE + CHEATS_UI_ITEM_BTN_GAP + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE * 1.5);
			m_selectButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
		}
	}
	
	/**
	 * Updates the container that represents the whole item.
	 */
	public function updateContainer():Void
	{		
		m_container.graphics.clear();
		m_container.blendMode = BlendMode.NORMAL;
		m_container.graphics.lineStyle(UIDefs.TUNABLES_UI_OUTLINE_SIZE, UIDefs.TUNABLES_UI_OUTLINE_COLOR);
		m_container.graphics.beginFill(UIDefs.TUNABLES_UI_BG_COLOR);
		
		m_container.graphics.drawRoundRect(0, 0, m_initialWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, UIDefs.TUNABLES_UI_ROUND_RECT_CORNER_SIZE);
		m_container.graphics.endFill();
	}
	
	//========================================================
	// Event Callbacks
	//========================================================
	
	/**
	 * Resets the value to field to its original value.
	 * @param	e
	 */
	private function onSelectClicked(e:MouseEvent):Void
	{
		e.stopPropagation();
		
		if (e.currentTarget != m_selectButton)
		{
			return;
		}
		
		if (m_cheat.func == null)
		{
			Debug.warn("cheat: " + m_cheat.name + "is null!");
			return;
		}
		
		m_cheat.func();
	}
	
	//=========================================================
	// Data Property Implementations
	//=========================================================
	
	/**
	 * Returns the property for the provided field ID
	 * @return
	 */
	public function getPropertyForField(field:CheatItemFields):Dynamic
	{
		switch(field)
		{
			case NAME_FIELD: 			return m_cheat.name;
			case TAGS_FIELD: 			return m_cheat.tags;
			default: return null;
		}
	}
	
	/**
	 * Gets the name of the cheat that this item represents.
	 * @return
	 */
	public function get_cheatName():String
	{
		return m_cheat.name;
	}
	
	//=========================================================
	// GUI Property Implementations
	//=========================================================
	
	/**
	 * Gets the outline color to use for this item
	 * @return
	 */
	public function getOutlineColor():Int
	{
		return UIDefs.TUNABLES_UI_OUTLINE_COLOR;
	}
	
	/**
	 * The amount of width in the item available for buttons
	 * @return
	 */
	public function get_buttonSpace():Float
	{
		return ((UIDefs.TUNABLES_UI_ITEM_SIZE + CHEATS_UI_ITEM_BTN_GAP) * UIDefs.TUNABLES_UI_ITEMS_NUM_BUTTONS);
	}
	
	/**
	 * The amount of width in the item available for text fields
	 * @return
	 */
	public function get_fieldSpace():Float
	{
		return m_initialWidth - buttonSpace;
	}
	
	//=================================================================================
	// Text Field Code
	//=================================================================================
	
	/**
	 * Gets the fraction of the available width for fields to use for this field.
	 * @param	field
	 * @return
	 */
	public function getWidthRatioForField(field:CheatItemFields):Float
	{
		switch(field)
		{
			case NAME_FIELD: 				return CHEATS_UI_FIELD_WIDTH_NAME;
			case TAGS_FIELD: 				return CHEATS_UI_FIELD_WIDTH_TAGS;
		}
	}
	
	/**
	 * Returns whether the provided field is editable for this item or not
	 * @param	field
	 * @return
	 */
	public function getEditableForField(field:CheatItemFields):Bool
	{
		return false;
	}
	
	/**
	 * Inits the field with the provided ID.
	 * @param	fieldID
	 */
	private function initField(field:TunableTextField, initialFieldSpace:Float, curX:Float):Void
	{		
		if (field == null)
		{
			Debug.log("Don't init the null field");
			return;
		}
		
		var id:Int = field.fieldID;
		var fieldID:CheatItemFields = EnumTools.createByIndex(CheatItemFields, id);
		var textToShow:String = Std.string(getPropertyForField(fieldID));
		
		positionField(field, initialFieldSpace, curX);
		
		field.addEventListener(FocusEvent.FOCUS_OUT, onDefocusTextField);

		updateTextField(field);
		addChild(field);
	}
	
	/**
	 * Positions the field in the item based on parameters.
	 * @param	field
	 * @param	initialFieldSpace
	 * @param	curX
	 */
	private function positionField(field:TunableTextField, initialFieldSpace:Float, curX:Float):Void
	{
		if (field == null)
		{
			return;
		}
		
		var fieldID:CheatItemFields = EnumTools.createByIndex(CheatItemFields, field.fieldID);
		
		field.x = curX;
		field.y = 0;
		var targetFieldWidth:Float = Math.floor(initialFieldSpace * getWidthRatioForField(fieldID));
		field.width = Math.floor(initialFieldSpace * getWidthRatioForField(fieldID));
		field.height = UIDefs.TUNABLES_UI_ITEM_SIZE;
	}
	
	/**
	 * CB for when the value field of this item loses the focus
	 * @param	e
	 */
	private function onDefocusTextField(e:FocusEvent):Void
	{
		//Nothing by default.
		return;
	}
	
	/**
	 * If the focus event is for one of the fields belonging to this item
	 * @param	e
	 * @return
	 */
	private function myFocusEvent(e:FocusEvent):Bool
	{
		if (e.target == null)
		{
			return false;
		}
		
		if (!Std.is(e.target, TunableTextField))
		{
			return false;
		}
		
		return (m_textFields.indexOf(cast(e.target, TunableTextField)) != -1);
	}
	
	/**
	 * Returns whether this item passes the provided filter.
	 * @param	filter
	 * @return
	 */
	public function itemPassesFilter(filter:CheatData):Bool
	{
		//Name is exact match
		if ((filter.name != "") && (m_cheat.name.indexOf(filter.name) == -1))
		{
			return false;
		}
		
		//This item has any of the tags in the tag list
		//TODO: this is very confusing, may want to revisit this.
		if (filter.tags.length > 0)
		{
			for (tag in m_cheat.tags)
			{
				if (filter.tags.indexOf(tag) != -1)
				{
					return true;
				}
			}
		}
		else
		{
			return true;
		}
		
		//Didn't pass any filters
		return false;
	}
	
	/**
	 * Returns a text field by field id.
	 * @param	fieldID
	 * @return
	 */
	private function getTextField(fieldID:CheatItemFields):TunableTextField
	{
		var fieldIdx:Int = fieldID.getIndex();
		if (fieldIdx >= m_textFields.length)
		{
			Debug.warn("no text field for: " + fieldID);
		}
		return m_textFields[fieldIdx];
	}
	
	//=========================================================
	// Data validation, and comitting
	// Generally don't want to override these functions.
	// Instead look at the static versions in the next section.
	//=========================================================
	
	/**
	 * Sets the value text field string.
	 * @param	val
	 */
	private function updateTextField(field:TunableTextField):Void
	{
		var fieldID:CheatItemFields = EnumTools.createByIndex(CheatItemFields, field.fieldID);
		
		switch(fieldID)
		{
			case NAME_FIELD:
			{
				updateTextFieldName();
			}
			case TAGS_FIELD:
			{
				updateTextFieldTags();
			}
		}
	}
	
	/**
	 * Updates the value text field based on current type.
	 */
	private function updateTextFieldName():Void
	{
		var textField:TunableTextField = getTextField(NAME_FIELD);
		if (textField == null)
		{
			Debug.warn("name text field is null, can't set text...");
			return;
		}
		textField.text = m_cheat.name;
	}
	
	/**
	 * Sets the tags text field text based on current tags.
	 * This shouldn't change per item.
	 * @param	tagsString
	 */
	private function updateTextFieldTags():Void
	{
		var textField:TunableTextField = getTextField(TAGS_FIELD);
		if (textField == null)
		{
			Debug.warn("tag text field is null, can't set text...");
			return;
		}
		
		var fieldTagText:String = "";
		for (tag in m_cheat.tags)
		{
			fieldTagText += tag;
			fieldTagText += " ";
		}
		textField.text = fieldTagText;
	}
	
	//=============================================================
	
}
#end
