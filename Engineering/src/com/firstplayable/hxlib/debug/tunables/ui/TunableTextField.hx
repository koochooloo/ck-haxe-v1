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
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;

import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;

enum TunableFieldModes
{
	READ;	//Field is read only.
	WRITE;	//Field can be edited.
	EDIT;	//Field is current being edited.
}

/**
 * TextField class for tunable items that stores a fieldID
 * as well as a mode.
 */
class TunableTextField extends TextField
{
	//READ mode
	
	/**
	 * The text color for read only TunableTextFields.
	 */
	public static var TUNABLES_UI_READ_TEXT_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_READ_TEXT_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_READ_TEXT_COLOR", UIDefs.TUNABLES_UI_TEXT_COLOR);
	}
	
	/**
	 * The border color for read only TunableTextFields.
	 */
	public static var TUNABLES_UI_READ_BORDER_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_READ_BORDER_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_READ_BORDER_COLOR", UIDefs.TUNABLES_UI_OUTLINE_COLOR);
	}
	
	/**
	 * The fill color for read only TunableTextFields.
	 */
	public static var TUNABLES_UI_READ_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_READ_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_READ_BG_COLOR", UIDefs.TUNABLES_UI_BG_COLOR);
	}
	
	//WRITE mode
	
	/**
	 * The text color for editable TunableTextFields.
	 */
	public static var TUNABLES_UI_WRITE_TEXT_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_WRITE_TEXT_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_WRITE_TEXT_COLOR", 0xFFFFFF);
	}
	
	/**
	 * The border color for editable TunableTextFields.
	 */
	public static var TUNABLES_UI_WRITE_BORDER_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_WRITE_BORDER_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_WRITE_BORDER_COLOR", 0xFFFFFF);
	}
	
	/**
	 * The fill color for editable TunableTextFields.
	 */
	public static var TUNABLES_UI_WRITE_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_WRITE_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_WRITE_BG_COLOR", 0x646464);
	}
	
	//EDIT mode
	
	/**
	 * The text color for editable TunableTextFields with focus.
	 */
	public static var TUNABLES_UI_EDIT_TEXT_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_EDIT_TEXT_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_EDIT_TEXT_COLOR", 0x000000);
	}
	
	/**
	 * The border color for editable TunableTextFields with focus.
	 */
	public static var TUNABLES_UI_EDIT_BORDER_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_EDIT_BORDER_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_EDIT_BORDER_COLOR", 0xFFFFFF);
	}
	
	/**
	 * The fill color for editable TunableTextFields with focus.
	 */
	public static var TUNABLES_UI_EDIT_BG_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_EDIT_BG_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_EDIT_BG_COLOR", 0xFFFFFF);
	}
	
	/**
	 * Field ID, constructed with this value.
	 */
	private var m_fieldID:Int;
	public var fieldID(get, null):Int;
	public function get_fieldID():Int
	{
		return m_fieldID;
	}
	
	/**
	 * Whether or not this field is editable.
	 */
	public var editable(get, set):Bool;
	public function get_editable():Bool
	{
		return type == TextFieldType.INPUT;
	}
	
	private function set_editable(newEditable:Bool):Bool
	{
		if (newEditable)
		{
			type = TextFieldType.INPUT;
			modeID = WRITE;
			selectable = true;
		}
		else
		{
			type = TextFieldType.DYNAMIC;
			modeID = READ;
			selectable = false;
		}
		
		return newEditable;
	}
	
	/**
	 * Mode ID
	 */
	private var m_modeID:TunableFieldModes;
	private var modeID(get, set):TunableFieldModes;
	private function get_modeID():TunableFieldModes
	{
		return m_modeID;
	}
	
	public function set_modeID(newMode:TunableFieldModes):TunableFieldModes
	{
		switch(newMode)
		{
			case READ:
			{
				backgroundColor = TUNABLES_UI_READ_BG_COLOR;
				borderColor = TUNABLES_UI_READ_BORDER_COLOR;
				textColor = TUNABLES_UI_READ_TEXT_COLOR;
			}
			case WRITE:
			{
				backgroundColor = TUNABLES_UI_WRITE_BG_COLOR;
				borderColor = TUNABLES_UI_WRITE_BORDER_COLOR;
				textColor = TUNABLES_UI_WRITE_TEXT_COLOR;
			}
			case EDIT:
			{
				backgroundColor = TUNABLES_UI_EDIT_BG_COLOR;
				borderColor = TUNABLES_UI_EDIT_BORDER_COLOR;
				textColor = TUNABLES_UI_EDIT_TEXT_COLOR;
			}
		}
		
		return (m_modeID = newMode);
	}
	
	/**
	 * Constructs a TunableTextField
	 * @param	startingFieldID
	 * @param	startEditable
	 */
	public function new(startingFieldID:Int, startEditable:Bool)
	{
		super();
		
		var textFormat = getTextFormat();
		textFormat.size = UIDefs.TUNABLES_UI_TEXT_SIZE;
		setTextFormat(textFormat);
		
		border = true;
		background = true;
		
		m_fieldID = startingFieldID;
		editable = startEditable;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	/**
	 * Post construction initialization
	 */
	public function init():Void
	{
		
	}
	
	/**
	 * Call to when trying to release this text field.
	 */
	public function release():Void
	{
		removeEventListener(FocusEvent.FOCUS_IN, onFocus);
		removeEventListener(FocusEvent.FOCUS_OUT, onDefocus);
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}
	
	//=========================================================
	// Event Callbacks
	//=========================================================
	
	private function onAddedToStage(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		
		addEventListener(FocusEvent.FOCUS_IN, onFocus);
		addEventListener(FocusEvent.FOCUS_OUT, onDefocus);
	}
	
	private function onRemovedFromStage(e:Event):Void
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		removeEventListener(FocusEvent.FOCUS_IN, onFocus);
		removeEventListener(FocusEvent.FOCUS_OUT, onDefocus);
	}
	
	private function onFocus(e:FocusEvent):Void
	{
		if (e.target != this)
		{
			return;
		}
		
		if (editable)
		{
			if (modeID != EDIT)
			{
				modeID = EDIT;
			}
		}
	}
	
	private function onDefocus(e:FocusEvent):Void
	{
		if (e.target != this)
		{
			return;
		}
		
		if (editable)
		{
			if (modeID != WRITE)
			{
				modeID = WRITE;
			}
		}
		else
		{
			if (modeID != READ)
			{
				modeID = READ;
			}
		}
	}
	
	/**
	 * Update the UI to reflect current parameters
	 * @param	e
	 */
	public function onRefreshUI(e:RefreshUIEvent):Void
	{
		var textFormat = getTextFormat();
		textFormat.size = UIDefs.TUNABLES_UI_TEXT_SIZE;
		setTextFormat(textFormat);
		
		//Reset the mode to its current mode to bring in new params
		modeID = m_modeID;
	}
	
}
#end
