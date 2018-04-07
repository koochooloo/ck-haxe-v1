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
import com.firstplayable.hxlib.debug.events.MenuLoadedEvent;
import com.firstplayable.hxlib.debug.events.ShowMenuEvent;
import com.firstplayable.hxlib.debug.tunables.ui.ToggleButton;
import com.firstplayable.hxlib.debug.menuEdit.menuEditItems.MenuEditItem.MenuItemFields;
import com.firstplayable.hxlib.debug.tunables.ui.SelectButton;
import com.firstplayable.hxlib.debug.menuEdit.Menus.MenuData;
import com.firstplayable.hxlib.debug.menuEdit.Menus.MenuLoadingStatus;
import com.firstplayable.hxlib.debug.menuEdit.Menus.MenuVisibility;
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

enum MenuItemFields
{
	NAME_FIELD;
	STATUS_FIELD;
	VISIBLE_FIELD;
}

/**
 * Defines an item to be shown on the menu edit menu.
 */
class MenuEditItem extends Sprite
{	
	//==================================
	// UI DEFS
	//==================================
	/**
	 * The ratio of available field space in an item for the Name field.
	 */
	public static var MENU_EDIT_UI_FIELD_WIDTH_NAME(get, null):Float;
	public static function get_MENU_EDIT_UI_FIELD_WIDTH_NAME():Float
	{
		return Tunables.getFloatField("MENU_EDIT_UI_FIELD_WIDTH_NAME", 0.6);
	}
	
	/**
	 * The ratio of available field space in an item for the status field.
	 */
	public static var MENU_EDIT_FIELD_WIDTH_STATUS(get, null):Float;
	public static function get_MENU_EDIT_FIELD_WIDTH_STATUS():Float
	{
		return Tunables.getFloatField("MENU_EDIT_FIELD_WIDTH_STATUS", 0.2);
	}
	
	/**
	 * The ratio of available field space in an item for the visible field.
	 */
	public static var MENU_EDIT_FIELD_WIDTH_VISIBLE(get, null):Float;
	public static function get_MENU_EDIT_FIELD_WIDTH_VISIBLE():Float
	{
		return Tunables.getFloatField("MENU_EDIT_FIELD_WIDTH_VISIBLE", 0.2);
	}
	
	/**
	 * The minimum gap between buttons on the item in pixels
	 */
	public static var MENU_EDIT_UI_ITEM_BTN_GAP(get, null):Float;
	public static function get_MENU_EDIT_UI_ITEM_BTN_GAP():Float
	{
		return Tunables.getFloatField("MENU_EDIT_UI_ITEM_BTN_GAP", 4.0);
	}
	
	//==================================
	// Members and Implementation
	//==================================
	
	private var m_initialWidth:Float;
	private var m_initialHeight:Float;
	private var m_menu:MenuData;
	
	//The container that holds the elements in this item.
	private var m_container:Shape;
	
	//The text fields for this item
	private var m_textFields:Array<TunableTextField>;
	
	// button to toggle the visibility of the menu
	private var m_toggleVisibleBtn:ToggleButton;
	
	//================================================================
	// Data Properties
	//================================================================
	public var menuName(get, null):String;
	
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

	public function new(startWidth:Float, startHeight:Float, menu:MenuData) 
	{
		super();
		
		m_initialWidth = startWidth;
		m_initialHeight = startHeight;
		
		m_menu = menu;
		
		//setup the UI
		
		m_container = new Shape();
		addChild(m_container);
		
		//Create the text fields
		m_textFields = [];
		var fields:Array<MenuItemFields> = EnumTools.createAll(MenuItemFields);
		for (field in fields)
		{
			var newTextField = new TunableTextField(field.getIndex(), getEditableForField(field));
			m_textFields.push(newTextField);
		}
		
		m_toggleVisibleBtn = null;
		
		m_inited = false;
	
		//Create the container
		updateContainer();
		
		DebugDefs.debugEventTarget.addEventListener(ShowMenuEvent.SHOW_MENU, onShowMenu);
		DebugDefs.debugEventTarget.addEventListener(MenuLoadedEvent.MENU_LOADED, onLoadMenu);
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
		m_toggleVisibleBtn = new ToggleButton();
		addChild(m_toggleVisibleBtn);
		m_toggleVisibleBtn.x = initialFieldWidth + (UIDefs.TUNABLES_UI_BTN_SIZE/2) + MENU_EDIT_UI_ITEM_BTN_GAP + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE * 1.5);
		m_toggleVisibleBtn.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
		m_toggleVisibleBtn.addEventListener(MouseEvent.CLICK, onToggleVisibleClicked);
		
		m_inited = true;
	}
	
	/**
	 * Called when the menu this owns is updated.
	 * @param	newMenu
	 */
	public function updateMenu(newMenu:MenuData):Void
	{
		m_menu = newMenu;
		
		for (field in m_textFields)
		{
			updateTextField(field);
		}
		
		updateToggleStatus();
	}
	
	/**
	 * Called when this item is deleted.
	 */
	public function release():Void
	{
		DebugDefs.debugEventTarget.removeEventListener(MenuLoadedEvent.MENU_LOADED, onLoadMenu);
		DebugDefs.debugEventTarget.removeEventListener(ShowMenuEvent.SHOW_MENU, onShowMenu);
		
		if (m_toggleVisibleBtn != null)
		{
			removeChild(m_toggleVisibleBtn);
			m_toggleVisibleBtn.removeEventListener(MouseEvent.CLICK, onToggleVisibleClicked);
		}
		m_toggleVisibleBtn = null;
		
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
		
		m_menu = null;
		
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
		if (m_toggleVisibleBtn != null)
		{
			m_toggleVisibleBtn.x = fieldSpace + (UIDefs.TUNABLES_UI_BTN_SIZE/2) + MENU_EDIT_UI_ITEM_BTN_GAP + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE * 1.5);
			m_toggleVisibleBtn.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
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
	 * Toggles the visibility of the menu
	 * @param	e
	 */
	private function onToggleVisibleClicked(e:MouseEvent):Void
	{
		e.stopPropagation();
		
		if (e.currentTarget != m_toggleVisibleBtn)
		{
			return;
		}
		
		//Don't muck with a menu that is in the middle of loading!
		if (m_menu.status == LOADING)
		{
			return;
		}
		
		if (m_menu.visible == SHOWN)
		{
			Menus.hideMenu(m_menu.name);
			m_toggleVisibleBtn.toggleState = false;
		}
		else if (m_menu.visible == HIDDEN)
		{
			Menus.showMenu(m_menu.name);
			m_toggleVisibleBtn.toggleState = true;
		}
	}
	
	public function onMenuLoaded(e:MenuLoadedEvent):Void
	{
		if (e.loadedMenu == m_menu.name)
		{
			var currentMenuData:MenuData = Menus.getMenuData(e.loadedMenu);
			
			if ((currentMenuData.status == UNLOADED) && (currentMenuData.menu == null))
			{
				updateMenu(currentMenuData);
			}
			else if(m_menu.menu != currentMenuData.menu)
			{
				updateMenu(currentMenuData);
			}
			else
			{
				updateToggleStatus();
			}
		}
	}
	
	/**
	 * Updates the toggle state to reflect the current status of the menu
	 */
	private function updateToggleStatus():Void
	{
		if (m_menu.status == UNLOADED)
		{
			m_toggleVisibleBtn.toggleState = false;
		}
		else
		{
			m_toggleVisibleBtn.toggleState = true;
		}
	}
	
	/**
	 * Updates the visibility of the item
	 * @param	e
	 */
	private function onShowMenu(e:ShowMenuEvent):Void
	{
		if (e.shownMenu == menuName)
		{
			updateTextFieldVisible();
		}
	}
	
	/**
	 * Updates the loaded status of the item
	 * @param	e
	 */
	private function onLoadMenu(e:MenuLoadedEvent):Void
	{
		if (e.loadedMenu == menuName)
		{
			updateTextFieldStatus();
		}
		
		if (m_toggleVisibleBtn != null)
		{
			if (e.status == LOADING)
			{
				m_toggleVisibleBtn.mouseEnabled = false;
				m_toggleVisibleBtn.mouseChildren = false;
			}
			else if (e.status == LOADED)
			{
				m_toggleVisibleBtn.mouseEnabled = true;
				m_toggleVisibleBtn.mouseChildren = true;
			}
		}
	}
	
	//=========================================================
	// Data Property Implementations
	//=========================================================
	
	/**
	 * Returns the property for the provided field ID
	 * @return
	 */
	public function getPropertyForField(field:MenuItemFields):Dynamic
	{
		switch(field)
		{
			case NAME_FIELD: 			return m_menu.name;
			case STATUS_FIELD: 			return m_menu.status;
			case VISIBLE_FIELD:			return m_menu.visible;
			default: return null;
		}
	}
	
	/**
	 * Gets the name of the menu that this item represents.
	 * @return
	 */
	public function get_menuName():String
	{
		return m_menu.name;
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
		return ((UIDefs.TUNABLES_UI_ITEM_SIZE + MENU_EDIT_UI_ITEM_BTN_GAP) * UIDefs.TUNABLES_UI_ITEMS_NUM_BUTTONS);
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
	public function getWidthRatioForField(field:MenuItemFields):Float
	{
		switch(field)
		{
			case NAME_FIELD: 			return MENU_EDIT_UI_FIELD_WIDTH_NAME;
			case STATUS_FIELD: 			return MENU_EDIT_FIELD_WIDTH_STATUS;
			case VISIBLE_FIELD:			return MENU_EDIT_FIELD_WIDTH_VISIBLE;
		}
	}
	
	/**
	 * Returns whether the provided field is editable for this item or not
	 * @param	field
	 * @return
	 */
	public function getEditableForField(field:MenuItemFields):Bool
	{
		return false;
	}
	
	/**
	 * Inits the field with the provided ID.
	 * @param	fieldID
	 * @param	initialFieldSpace
	 * @param	x
	 */
	private function initField(field:TunableTextField, initialFieldSpace:Float, x:Float):Void
	{		
		if (field == null)
		{
			Debug.log("Don't init the null field");
			return;
		}
		
		var id:Int = field.fieldID;
		var fieldID:MenuItemFields = EnumTools.createByIndex(MenuItemFields, id);
		var textToShow:String = Std.string(getPropertyForField(fieldID));
		
		positionField(field, initialFieldSpace, x);
		
		field.addEventListener(FocusEvent.FOCUS_OUT, onDefocusTextField);

		updateTextField(field);
		addChild(field);
	}
	
	/**
	 * Positions the field in the item based on parameters.
	 * @param	field
	 * @param	initialFieldSpace
	 * @param	x
	 */
	private function positionField(field:TunableTextField, initialFieldSpace:Float, x:Float):Void
	{
		if (field == null)
		{
			return;
		}
		
		var fieldID:MenuItemFields = EnumTools.createByIndex(MenuItemFields, field.fieldID);
		
		field.x = x;
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
	public function itemPassesFilter(filter:MenuData):Bool
	{
		//Name contains filter name
		if ((filter.name != "") && (m_menu.name.indexOf(filter.name) == -1))
		{
			return false;
		}
		
		//Status is exact match
		if ((filter.status != NO_STATUS) && (m_menu.status != filter.status))
		{
			return false;
		}
		
		//visbility is exact match
		if ((filter.visible != UNSET) && (m_menu.visible != filter.visible))
		{
			return false;
		}
		
		//Passes all filters!
		return true;
	}
	
	/**
	 * Returns a text field by field id.
	 * @param	fieldID
	 * @return
	 */
	private function getTextField(fieldID:MenuItemFields):TunableTextField
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
		var fieldID:MenuItemFields = EnumTools.createByIndex(MenuItemFields, field.fieldID);
		
		switch(fieldID)
		{
			case NAME_FIELD:
			{
				updateTextFieldName();
			}
			case STATUS_FIELD:
			{
				updateTextFieldStatus();
			}
			case VISIBLE_FIELD:
			{
				updateTextFieldVisible();
			}
		}
	}
	
	/**
	 * Updates the name text field based on current name.
	 */
	private function updateTextFieldName():Void
	{
		var textField:TunableTextField = getTextField(NAME_FIELD);
		if (textField == null)
		{
			Debug.warn("name text field is null, can't set text...");
			return;
		}
		textField.text = m_menu.name;
	}
	
	/**
	 * Updates the status text field based on current status.
	 */
	private function updateTextFieldStatus():Void
	{
		var textField:TunableTextField = getTextField(STATUS_FIELD);
		if (textField == null)
		{
			Debug.warn("status text field is null, can't set text...");
			return;
		}
		
		if (m_menu.status == NO_STATUS)
		{
			textField.text = "";
		}
		else
		{
			textField.text = Std.string(m_menu.status);
		}
	}
	
	/**
	 * Updates the visiblity text field based on current visibility.
	 */
	private function updateTextFieldVisible():Void
	{
		var textField:TunableTextField = getTextField(VISIBLE_FIELD);
		if (textField == null)
		{
			Debug.warn("visibility text field is null, can't set text...");
			return;
		}
		switch(m_menu.visible)
		{
			case HIDDEN: textField.text = Std.string(HIDDEN);
			case SHOWN:  textField.text = Std.string(SHOWN);
			case UNSET:	 textField.text = "";
		}
		
	}

	
	//=============================================================
	
}
#end
