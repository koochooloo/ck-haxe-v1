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
import haxe.EnumTools;
import com.firstplayable.hxlib.debug.cheats.CheatsMenu;
import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
import com.firstplayable.hxlib.debug.tunables.TunablesMenu;
import openfl.events.MouseEvent;
import com.firstplayable.hxlib.debug.cheats.Cheats;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.cheats.cheatItems.CheatItem;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
 * The CheatItem for filtering through existing cheat items
 * Allows specifying the cheat name, and the tags.
 * On commit will trigger the owning menu to filter.
 */
class SearchCheatItem extends CheatItem
{	
	private var m_parentMenu:CheatsMenu;
	
	public function new(menu:CheatsMenu, startWidth:Float, startHeight:Float, cheat:CheatData)
	{
		super(startWidth, startHeight, cheat);
		
		m_parentMenu = menu;
	}
	
	/**
	 * Post-construction initialization
	 */
	override public function init():Void
	{	
		super.init();
		
		//Remove the select button.
		if (m_selectButton != null)
		{
			removeChild(m_selectButton);
			m_selectButton.removeEventListener(MouseEvent.CLICK, onSelectClicked);
			m_selectButton = null;
		}
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
		m_parentMenu.updateFilter(m_cheat);
	}
	
	//================================================================
	// Validation
	//================================================================
	
	/**
	 * Returns whether the provided field is editable for this item or not
	 * @param	field
	 * @return
	 */
	override public function getEditableForField(field:CheatItemFields):Bool
	{
		switch(field)
		{
			case NAME_FIELD: 	return true;
			case TAGS_FIELD: 	return true;
		}
	}
	
	/**
	 * CB for when the value field of this item loses the focus
	 * @param	e
	 */
	override private function onDefocusTextField(e:FocusEvent):Void
	{
		if (e.target == null)
		{
			return;
		}
		
		if (!myFocusEvent(e))
		{
			return;
		}
		
		var textField:TunableTextField = cast e.target;
		var id:Int = textField.fieldID;
		
		var fieldID:CheatItemFields = EnumTools.createByIndex(CheatItemFields, id);
		switch(fieldID)
		{
			case NAME_FIELD: 	attemptToCommitNameField();
			case TAGS_FIELD: 	attemptToCommitTagsField();
		}
	}
	
	/**
	 * Attempts to commit the current entered name, returns to previous if not.
	 * @return
	 */
	private function attemptToCommitNameField():Void
	{
		var textField:TunableTextField = getTextField(NAME_FIELD);
		
		var variableString:String = textField.text;
		if (Cheats.validateFieldName(variableString))
		{
			m_cheat.name = variableString;
		}
		else
		{
			m_cheat.name = "";
		}
		
		updateTextField(textField);
		updateFilter();
	}
	
	/**
	 * Attempts to commit the tags, return to previous if not
	 * @return
	 */
	private function attemptToCommitTagsField():Void
	{
		var textField:TunableTextField = getTextField(TAGS_FIELD);
		var tagsString:String = textField.text;
		tagsString = StringTools.trim(tagsString);

		m_cheat.tags = [];
	
		if (tagsString.length > 0)
		{
			var tags:Array<String> = tagsString.split(" ");
			for(tag in tags)
			{
				if (Cheats.tagExists(tag))
				{
					m_cheat.tags.push(tag);
				}
			}
		}
		
		updateTextField(textField);
		updateFilter();
	}
	
}
#end
