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
import haxe.EnumTools;
import com.firstplayable.hxlib.debug.menuEdit.MenuViewer;
import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
import com.firstplayable.hxlib.debug.tunables.TunablesMenu;
import openfl.events.MouseEvent;
import com.firstplayable.hxlib.debug.menuEdit.Menus;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.menuEdit.menuEditItems.MenuEditItem;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

/**
 * The MenuEditItem for filtering through existing menu items
 * Allows specifying the menu name, status, and visibility
 * On commit will trigger the owning menu to filter.
 */
class SearchMenuEditItem extends MenuEditItem
{	
	private var m_parentMenu:MenuViewer;
	
	public function new(menu:MenuViewer, startWidth:Float, startHeight:Float, menuData:MenuData)
	{
		super(startWidth, startHeight, menuData);
		
		m_parentMenu = menu;
	}
	
	/**
	 * Post-construction initialization
	 */
	override public function init():Void
	{	
		super.init();
		
		//Remove the select button.
		if (m_toggleVisibleBtn != null)
		{
			removeChild(m_toggleVisibleBtn);
			m_toggleVisibleBtn.removeEventListener(MouseEvent.CLICK, onToggleVisibleClicked);
			m_toggleVisibleBtn = null;
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
		Debug.log("update filter: " + m_menu);
		m_parentMenu.updateFilter(m_menu);
	}
	
	//================================================================
	// Validation
	//================================================================
	
	/**
	 * Returns whether the provided field is editable for this item or not
	 * @param	field
	 * @return
	 */
	override public function getEditableForField(field:MenuItemFields):Bool
	{
		switch(field)
		{
			case NAME_FIELD: 		return true;
			case STATUS_FIELD: 		return true;
			case VISIBLE_FIELD: 	return true;
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
		
		var fieldID:MenuItemFields = EnumTools.createByIndex(MenuItemFields, id);
		switch(fieldID)
		{
			case NAME_FIELD: 	attemptToCommitNameField();
			case STATUS_FIELD: 	attemptToCommitStatusField();
			case VISIBLE_FIELD: attemptToCommitVisibleField();
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
		m_menu.name = variableString;
		
		updateTextField(textField);
		updateFilter();
	}
	
	/**
	 * Attempts to commit the current entered name, returns to previous if not.
	 * @return
	 */
	private function attemptToCommitStatusField():Void
	{
		var textField:TunableTextField = getTextField(STATUS_FIELD);
		
		var statusString:String = StringTools.trim(textField.text.toLowerCase());
		
		if (statusString == "")
		{
			m_menu.status = NO_STATUS;
		}
		else
		{
			var allStatuses:Array<MenuLoadingStatus> = EnumTools.createAll(MenuLoadingStatus);
			for (status in allStatuses)
			{
				var testStatusString:String = StringTools.trim(Std.string(status).toLowerCase());
				if (statusString == testStatusString)
				{
					m_menu.status = status;
					break;
				}
			}
		}
		
		updateTextField(textField);
		updateFilter();
	}
	
	/**
	 * Attempts to commit the current entered visbility, returns to previous if not.
	 * @return
	 */
	private function attemptToCommitVisibleField():Void
	{
		var textField:TunableTextField = getTextField(VISIBLE_FIELD);
		
		var visibilityString:String = StringTools.trim(textField.text.toLowerCase());
		
		if (visibilityString == "")
		{
			m_menu.visible = UNSET;
		}
		else
		{
			var allVisibilities:Array<MenuVisibility> = EnumTools.createAll(MenuVisibility);
			for (visibility in allVisibilities)
			{
				var testVisibilityString:String = StringTools.trim(Std.string(visibility).toLowerCase());
				if (visibilityString == testVisibilityString)
				{
					m_menu.visible = visibility;
					break;
				}
			}
		}

		updateTextField(textField);
		updateFilter();
	}
	

	
}
#end
