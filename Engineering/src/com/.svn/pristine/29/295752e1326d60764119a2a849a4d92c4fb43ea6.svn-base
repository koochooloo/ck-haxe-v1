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
 * The TunableItem for filtering through existing tunable items
 * Allows specifying the variable name, the type, and the tags.
 * On commit will trigger the owning menu to filter.
 */
class SearchTunableItem extends TunableItem
{	
	private var m_parentMenu:TunablesMenu;
	
	public function new(menu:TunablesMenu, startWidth:Float, startHeight:Float, variable:TunablesVariable) 
	{
		super(startWidth, startHeight, variable);
		
		m_parentMenu = menu;
	}
	
	override public function release():Void
	{			
		super.release();
		
		m_parentMenu = null;
	}
	
	/**
	 * Creates a filter based on current settings, and passes it to the menu
	 */
	private function updateFilter():Void
	{
		var newFilter:TunablesVariable = 
		{
			name: m_name,
			type: m_type,
			value: m_value,
			tags: m_tags
		}
		
		m_parentMenu.updateFilter(newFilter);
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
			m_name = variableString;
		}
		else
		{
			m_name = "";
		}
		
		updateTextField(textField);
		updateFilter();
	}
	
	/**
	 * Attempts to commit the entered value to the variable.
	 */
	override private function attemptToCommitValueField():Void
	{
		var textField:TunableTextField = getTextField(VALUE_FIELD);
		var valueString:String = textField.text;

		if (valueString.length != 0)
		{
			if (m_type != "")
			{
				m_value = Std.string(getValueFromString(textField.text));
			}
			else
			{
				m_value = valueString;
			}
		}
		else
		{
			m_value = "";
		}
		
		updateTextField(textField);
		updateFilter();
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
			
			//if type changed, update the entry in the value field
			//to be the new type if there is an entry.
			if (m_type != prevType)
			{
				var valueField:TunableTextField = getTextField(VALUE_FIELD);
				if (valueField.text.length != 0)
				{
					//Update the value to match the type.
					m_value = Std.string(getValueFromString(valueField.text));
				
					//Makes sure display is in proper format for type.
					updateTextField(valueField);
				}
			}
		}
		else
		{
			m_type = "";
		}
		
		updateTextField(textField);
		updateFilter();
	}
	
	/**
	 * Returns whether the tag string is valid.
	 * @return
	 */
	override private function validateTag(tagString:String):Bool
	{
		return super.validateTag(tagString) && Tunables.ALL_TAGS.exists(tagString);
	}
	
	/**
	 * Attempts to commit the tags, return to previous if not
	 * @return
	 */
	override private function attemptToCommitTagsField():Void
	{
		var textField:TunableTextField = getTextField(TAGS_FIELD);
		var tagsString:String = textField.text;
		tagsString = StringTools.trim(tagsString);

		m_tags = [];
		if (tagsString.length > 0)
		{
			var tags:Array<String> = tagsString.split(" ");
			for(tag in tags)
			{
				if (validateTag(tag))
				{
					m_tags.push(tag);
				}
			}
		}
		
		updateTextField(textField);
		updateFilter();
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
