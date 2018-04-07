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
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
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
 * The TunableItem for newly added variables.
 * Allows specifying the variable name, the type, and the tags.
 * Also allows removing it before it has been committed.
 */
class NewTunableItem extends TunableItem
{	
	private var m_parentMenu:TunablesMenu;
	
	private var m_saveButton:AddItemButton;
	private var m_deleteButton:RemoveItemButton;
	
	public function new(menu:TunablesMenu, startWidth:Float, startHeight:Float, variable:TunablesVariable) 
	{
		super(startWidth, startHeight, variable);
		
		m_parentMenu = menu;
		
		m_saveButton = null;
		m_deleteButton = null;
	}
	
	override public function init():Void
	{	
		super.init();
		
		var initialFieldWidth:Float = m_initialWidth - buttonSpace;
		
		//Add the buttons
		var curX:Float = initialFieldWidth + (UIDefs.TUNABLES_UI_OUTLINE_SIZE/2) + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE/2);
		
		//Save button
		m_saveButton = new AddItemButton();
		addChild(m_saveButton);
		m_saveButton.x = curX;
		curX += UIDefs.TUNABLES_UI_BTN_SIZE + TunableItem.TUNABLES_UI_ITEM_BTN_GAP + UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE;
		m_saveButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
		m_saveButton.addEventListener(MouseEvent.CLICK, onSaveClicked);
		
		//Delete button
		m_deleteButton = new RemoveItemButton();
		addChild(m_deleteButton);
		m_deleteButton.x = curX;
		curX += UIDefs.TUNABLES_UI_BTN_SIZE;
		m_deleteButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
		m_deleteButton.addEventListener(MouseEvent.CLICK, onRemoveClicked);
		
		//Remove the reset button.
		if (m_resetButton != null)
		{
			removeChild(m_resetButton);
			m_resetButton.removeEventListener(MouseEvent.CLICK, onResetClicked);
			m_resetButton = null;
		}
	}
	
	override public function release():Void
	{			
		super.release();
		
		m_saveButton.removeEventListener(MouseEvent.CLICK, onSaveClicked);
		m_saveButton = null;
		
		m_deleteButton.removeEventListener(MouseEvent.CLICK, onRemoveClicked);
		m_deleteButton = null;
		
		m_parentMenu = null;
	}
	
	//================================================================
	// Saving and removing
	//================================================================
	
	/**
	 * Save the variable, and convert it to an actual item.
	 * @param	e
	 */
	private function onSaveClicked(e:MouseEvent):Void
	{
		if (e.currentTarget != m_saveButton)
		{
			return;
		}
		
		var newVariable:TunablesVariable = 
		{
			name:   m_name,
			type:   m_type,
			value:  m_value,
			tags:   m_tags
		};
		
		m_parentMenu.saveNewTunable(this, newVariable);
	}
	
	/**
	 * Remove this variable. Only available for newly created tunables.
	 * @param	e
	 */
	private function onRemoveClicked(e:MouseEvent):Void
	{
		if (e.currentTarget != m_deleteButton)
		{
			return;
		}
		
		m_parentMenu.removeNewTunable(this);
	}
	
	/**
	 * Updates appearance
	 * @param	e
	 */
	override public function onRefreshUI(e:RefreshUIEvent):Void
	{
		super.onRefreshUI(e);
		
		//Add the buttons
		var curX:Float = fieldSpace + (UIDefs.TUNABLES_UI_OUTLINE_SIZE/2) + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE/2);
		
		//Save button
		m_saveButton.x = curX;
		curX += UIDefs.TUNABLES_UI_BTN_SIZE + TunableItem.TUNABLES_UI_ITEM_BTN_GAP + UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE;
		m_saveButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
		
		//Delete button
		m_deleteButton.x = curX;
		curX += UIDefs.TUNABLES_UI_BTN_SIZE;
		m_deleteButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
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
		switch(field)
		{
			case NAME_FIELD: 	return true;
			case VALUE_FIELD: 	return true;
			case TYPE_FIELD: 	return true;
			case TAGS_FIELD: 	return true;
		}
	}
	
	/**
	 * Attempts to commit the current entered name, returns to previous if not.
	 * @return
	 */
	override private function attemptToCommitNameField():Void
	{
		var textField:TunableTextField = getTextField(NAME_FIELD);
		
		var variableString:String = textField.text;
		variableString = getCleanedFieldName(variableString);
		if (validateFieldName(variableString))
		{
			variableString = m_parentMenu.getNextAvailableVariableName(variableString);
			m_parentMenu.itemNameChanged(this, m_name, variableString);
			m_name = variableString;
		}
		
		updateTextField(textField);
	}
	
	/**
	 * Attempts to commit the type vield, reverts to previous if not
	 * @return
	 */
	override private function attemptToCommitTypeField():Void
	{
		var textField:TunableTextField = getTextField(TYPE_FIELD);
		
		var typeString:String = textField.text;
		typeString = getCleanedFieldType(typeString);
		
		if (validateFieldType(typeString))
		{
			var prevType:String = m_type;
			m_type = typeString;
			if (prevType != m_type)
			{
				//If we've changed types, change the value to the default value for the new type.
				//If the current value in the field is invalid, we'll fall back on that,
				//otherwise, we'll keep the current entered value!
				m_value = Tunables.getDefaultValueForType(m_type);
				attemptToCommitValueField();
			}
		}
		
		updateTextField(textField);
	}
	
	/**
	 * Returns whether this item passes the provided filter.
	 * @param	filter
	 * @return
	 */
	override public function itemPassesFilter(filter:TunablesVariable):Bool
	{
		//Always show items under construction.
		return true;
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
