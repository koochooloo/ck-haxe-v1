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
import com.firstplayable.hxlib.debug.tunables.TunableDefs.CustomTunableValue;
import openfl.events.EventDispatcher;
import com.firstplayable.hxlib.debug.events.TunableUpdatedEvent;
import com.firstplayable.hxlib.debug.events.RefreshAudioEvent;
import com.firstplayable.hxlib.audio.VolumeInfo;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import openfl.events.MouseEvent;
import com.firstplayable.hxlib.debug.tunables.ui.UndoButton;
import com.firstplayable.hxlib.debug.tunables.ui.UIDefs;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
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

enum TunableItemFields
{
	NAME_FIELD;
	VALUE_FIELD;
	TYPE_FIELD;
	TAGS_FIELD;
}

/**
 * Defines an item to be shown on the tunable menu.
 * Allows editing of a value at runtime.
 */
class TunableItem extends Sprite
{	
	//==================================
	// UI DEFS
	//==================================
	/**
	 * The ratio of available field space in an item for the Name field.
	 */
	public static var TUNABLES_UI_FIELD_WIDTH_NAME(get, null):Float;
	public static function get_TUNABLES_UI_FIELD_WIDTH_NAME():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_FIELD_WIDTH_NAME", 0.35);
	}
	
	/**
	 * The ratio of available field space in an item for the Value field.
	 */
	public static var TUNABLES_UI_FIELD_WIDTH_VALUE(get, null):Float;
	public static function get_TUNABLES_UI_FIELD_WIDTH_VALUE():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_FIELD_WIDTH_VALUE", 0.1);
	}
	
	/**
	 * The ratio of available field space in an item for the Type field.
	 */
	public static var TUNABLES_UI_FIELD_WIDTH_TYPE(get, null):Float;
	public static function get_TUNABLES_UI_FIELD_WIDTH_TYPE():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_FIELD_WIDTH_TYPE", 0.15);
	}
	
	/**
	 * The ratio of available field space in an item for the Tags field.
	 */
	public static var TUNABLES_UI_FIELD_WIDTH_TAGS(get, null):Float;
	public static function get_TUNABLES_UI_FIELD_WIDTH_TAGS():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_FIELD_WIDTH_TAGS", 0.4);
	}
	
	/**
	 * The minimum gap between buttons on the item
	 */
	public static var TUNABLES_UI_ITEM_BTN_GAP(get, null):Float;
	public static function get_TUNABLES_UI_ITEM_BTN_GAP():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_ITEM_BTN_GAP", 4.0);
	}
	
	//==================================
	// Members and Implementation
	//==================================
	
	//The name of the Tunable variable this item represents.
	private var m_initialWidth:Float;
	private var m_initialHeight:Float;
	private var m_name:String;
	private var m_type:String;
	private var m_value:String;
	private var m_originalValue:String;	//value of this item when the item was created.
	private var m_tags:Array<String>;
	
	//The container that holds the elements in this item.
	private var m_container:Shape;
	
	//The text fields for this item
	private var m_textFields:Array<TunableTextField>;
	
	// undo button to reset value to original state.
	private var m_resetButton:UndoButton;
	
	//================================================================
	// Data Properties
	//================================================================
	public var variableName(get, null):String;
	
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

	/**
	 * The constructor for a tunable item.
	 * @param	startWidth
	 * @param	startHeight
	 * @param	variable
	 */
	public function new(startWidth:Float, startHeight:Float, variable:TunablesVariable) 
	{
		super();
		
		m_initialWidth = startWidth;
		m_initialHeight = startHeight;
		
		m_name = variable.name;
		m_type = variable.type;
		m_value = Std.string(variable.value);
		m_tags = variable.tags;
		
		//Store the starting value
		m_originalValue = variable.value;
		
		m_container = new Shape();
		addChild(m_container);
		
		//Create the text fields
		m_textFields = [];
		var fields:Array<TunableItemFields> = EnumTools.createAll(TunableItemFields);
		for (field in fields)
		{
			var newTextField = new TunableTextField(field.getIndex(), getEditableForField(field));
			m_textFields.push(newTextField);
		}
		
		m_resetButton = null;
		
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
		m_resetButton = new UndoButton();
		addChild(m_resetButton);
		m_resetButton.x = initialFieldWidth + UIDefs.TUNABLES_UI_BTN_SIZE + TunableItem.TUNABLES_UI_ITEM_BTN_GAP + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE * 1.5);
		m_resetButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
		m_resetButton.addEventListener(MouseEvent.CLICK, onResetClicked);
		m_resetButton.visible = (m_value != m_originalValue);
		
		m_inited = true;
	}
	
	/**
	 * Checks to see if we have a local override for this item, and handle it
	 */
	public function checkAndHandleLocalConfiguration():Void
	{
		//Check if we have a local override
		if (LocalTunablesConfigurator.CUSTOM_VALUES != null)
		{
			var customValue:CustomTunableValue = LocalTunablesConfigurator.CUSTOM_VALUES.get(m_name);
			if (customValue != null)
			{
				if (validateFieldValue(customValue.value))
				{
					updateVariableValue(customValue.value);
					
					var textField:TunableTextField = getTextField(VALUE_FIELD);
					updateTextField(textField);
				}
				else
				{
					Debug.warn("local configuration value is invalid: " + m_name + ": " + customValue.value);
				}
			}
		}
	}
	
	/**
	 * Called when this item is deleted.
	 */
	public function release():Void
	{	
		if (m_resetButton != null)
		{
			removeChild(m_resetButton);
			m_resetButton.removeEventListener(MouseEvent.CLICK, onResetClicked);
		}
		m_resetButton = null;
		
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
		
		m_tags = [];
		
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
		if (m_resetButton != null)
		{
			m_resetButton.x = fieldSpace + UIDefs.TUNABLES_UI_BTN_SIZE + TUNABLES_UI_ITEM_BTN_GAP + (UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE * 1.5);
			m_resetButton.y = UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE / 2;
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
	private function onResetClicked(e:MouseEvent):Void
	{
		if (e.currentTarget != m_resetButton)
		{
			return;
		}
		
		if (!validateFieldValue(m_originalValue))
		{
			Debug.warn("somehow original value: " + m_originalValue + " is not valid!");
			return;
		}
		
		updateVariableValue(m_originalValue);
		
		//Set to stored value
		var textField:TunableTextField = getTextField(VALUE_FIELD);
		updateTextField(textField);
	}
	
	/**
	 * Attempt to update this item's value to a new amount.
	 * @param	newValue
	 */
	private function updateVariableValue(newValue:String):Void
	{
		//Don't run processing code if there is no change.
		if (newValue == m_value)
		{
			Debug.log("value not new for " + m_name + ": " + newValue);
			return;
		}
		
		var updateAudio:Bool = false;
		var updateUI:Bool = false;
		
		//Newly added variables won't be a field yet.
		if (Reflect.hasField(Tunables, m_name))
		{
			var parsedValue:Dynamic = getValueFromString(newValue);
			
			Reflect.setProperty(Tunables, m_name, parsedValue);
			
			//If it's an Audio propery, send and event to cause UI refresh.
			if (m_tags.indexOf(TunableDefs.AUDIO_TAG) != -1)
			{
				updateAudio = true;
			}
			
			//If it's a UI propery, send and event to cause UI refresh.
			if (m_tags.indexOf(TunableDefs.UI_TAG) != -1)
			{
				updateUI = true;
			}
			
			//Always send an event that a tunable has changed.
			//Classes can use this to update parameters that might normally
			//only be checked at startup, etc.
			DebugDefs.debugEventTarget.dispatchEvent(new TunableUpdatedEvent(m_name, parsedValue));
		}
		
		m_value = newValue;
		
		if (m_resetButton != null)
		{
			m_resetButton.visible = (m_value != m_originalValue);
		}
		
		//===========================================
		// Send update events.
		//===========================================
		
		if (updateAudio)
		{
			DebugDefs.debugEventTarget.dispatchEvent(new RefreshAudioEvent());
		}
		
		if (updateUI)
		{
			DebugDefs.debugEventTarget.dispatchEvent(new RefreshUIEvent());
		}
	}
	
	//=========================================================
	// Data Property Implementations
	//=========================================================
	
	/**
	 * Returns the property for the provided field ID
	 * @return
	 */
	public function getPropertyForField(field:TunableItemFields):Dynamic
	{
		switch(field)
		{
			case NAME_FIELD: 	return m_name;
			case VALUE_FIELD: 	return m_value;
			case TYPE_FIELD: 	return m_type;
			case TAGS_FIELD: 	return m_tags;
			default: return null;
		}
	}
	
	public function get_variableName():String
	{
		return m_name;
	}
	
	/**
	 * Gets the struct needed to save this value to the json.
	 * Returns null if this item isn't saved.
	 * @return
	 */
	public function getSerializableObject():TunablesVariable
	{
		var toSave:TunablesVariable = 
		{
			name: m_name,
			type: m_type,
			value: Std.string(m_value),
			tags: m_tags
		};
		
		return toSave;
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
		return ((UIDefs.TUNABLES_UI_ITEM_SIZE + TUNABLES_UI_ITEM_BTN_GAP) * UIDefs.TUNABLES_UI_ITEMS_NUM_BUTTONS);
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
	public function getWidthRatioForField(field:TunableItemFields):Float
	{
		switch(field)
		{
			case NAME_FIELD: 	return TUNABLES_UI_FIELD_WIDTH_NAME;
			case VALUE_FIELD: 	return TUNABLES_UI_FIELD_WIDTH_VALUE;
			case TYPE_FIELD: 	return TUNABLES_UI_FIELD_WIDTH_TYPE;
			case TAGS_FIELD: 	return TUNABLES_UI_FIELD_WIDTH_TAGS;
		}
	}
	
	/**
	 * Returns whether the provided field is editable for this item or not
	 * @param	field
	 * @return
	 */
	public function getEditableForField(field:TunableItemFields):Bool
	{
		/**
		 * Locked variables can be seen, but not edited.
		 */
		if (m_tags.indexOf(TunableDefs.LOCKED_TAG) != -1)
		{
			return false;
		}
		
		switch(field)
		{
			case NAME_FIELD: 	return false;
			case VALUE_FIELD: 	return true;
			case TYPE_FIELD: 	return false;
			case TAGS_FIELD: 	
			{
				#if(!debug && build_cheats)
				//Tags are not editable in cheats builds.
				return false;
				#else
				return true;
				#end
			}
		}
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
		var fieldID:TunableItemFields = EnumTools.createByIndex(TunableItemFields, id);
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
		
		var fieldID:TunableItemFields = EnumTools.createByIndex(TunableItemFields, field.fieldID);
		
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
		
		var fieldID:TunableItemFields = EnumTools.createByIndex(TunableItemFields, id);
		switch(fieldID)
		{
			case NAME_FIELD: 	attemptToCommitNameField();
			case VALUE_FIELD: 	attemptToCommitValueField();
			case TYPE_FIELD: 	attemptToCommitTypeField();
			case TAGS_FIELD: 	attemptToCommitTagsField();
		}
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
	public function itemPassesFilter(filter:TunablesVariable):Bool
	{
		#if (!debug && build_cheats)
		//Only cheats items are displayed in cheats builds
		if (m_tags.indexOf(TunableDefs.CHEATS_TAG) == -1)
		{
			return false;
		}
		#end
		
		//Name is exact match
		if ((filter.name != "") && (m_name.indexOf(filter.name) == -1))
		{
			return false;
		}
		
		//Type is exact match
		if ((filter.type != "") && (m_type != filter.type))
		{
			return false;
		}
		
		//Value is exact match
		if (filter.value.length != 0)
		{
			//If we have no type, do exact string match on what's in the field.
			//Otherwise use the value.
			if (filter.type == "")
			{
				if (getTextField(VALUE_FIELD).text != filter.value)
				{
					return false;
				}
			}
			else
			{
				if (Std.string(m_value) != filter.value)
				{
					return false;
				}
			}
		}
		
		//This item has any of the tags in the tag list
		//TODO: this is very confusing, may want to revisit this.
		if (filter.tags.length > 0)
		{
			for (tag in m_tags)
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
	 * Attempts to commit the current entered name.
	 * @return
	 */
	private function attemptToCommitNameField():Void
	{
		//Name is not typically changeable once created, lest havoc be unleashed.
		//Edit the json directly if you must.
	}
	
	/**
	 * Attempts to commit the entered value to the variable.
	 */
	private function attemptToCommitValueField():Void
	{
		var textField:TunableTextField = getTextField(VALUE_FIELD);
		var valueString:String = getValueFromString(textField.text);
		
		if (validateFieldValue(valueString))
		{
			updateVariableValue(valueString);
		}
		
		updateTextField(textField);
	}
	
	/**
	 * Attempts to commit the type vield
	 * @return
	 */
	private function attemptToCommitTypeField():Void
	{
		//Type is not typically changeable once created, lest havoc be unleashed.
		//Edit the json directly if you must.
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
		
		var isCheatTunable:Bool = (m_tags.indexOf(TunableDefs.CHEATS_TAG) != -1);

		m_tags = [];
		if (tagsString.length > 0)
		{
			var tags:Array<String> = tagsString.split(" ");
			for(tag in tags)
			{
				if (validateTag(tag))
				{
					//Adds the tag to the list of tags
					if(!Tunables.ALL_TAGS.exists(tag))
					{
						Tunables.ALL_TAGS.set(tag, true);
					}
					m_tags.push(tag);
				}
			}
		}
		
		#if(!debug && build_cheats)
		if (isCheatTunable)
		{
			m_tags.push(TunableDefs.CHEATS_TAG);
		}
		#end
		
		updateTextField(textField);
	}
	
	private function getTextField(fieldID:TunableItemFields):TunableTextField
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
	 * Returns the class we should use to validate, get, and set the value field.
	 * @return
	 */
	private function getValidatingClass():Class<Dynamic>
	{
		var validatingClass:Class<Dynamic> = TunablesMenu.TunableItemMap.get(m_type);
		if (validatingClass == null)
		{
			validatingClass = TunableItem;
		}
		return validatingClass;
	}
	
	/**
	 * Gets the first static function of the provided name starting at this class.
	 * Goes down to super classes, returning null if the function is never found.
	 * @param	functionName
	 * @return
	 */
	private function getBaseFunction(validatingClass:Class<Dynamic>, functionName:String):Dynamic
	{
		if (validatingClass == null)
		{
			Debug.warn("validating class is null..");
			return null;
		}
		
		var baseFunction:Dynamic = null;
		var nextClass:Class<Dynamic> = validatingClass;
		do
		{		
			baseFunction = Reflect.getProperty(nextClass, functionName);
			if (baseFunction == null)
			{
				nextClass = Type.getSuperClass(nextClass);
			}
		}
		while (nextClass != null && baseFunction == null);
		
		if (baseFunction == null)
		{
			Debug.warn("don't have " + functionName + " for: " + Type.getClassName(validatingClass) );
		}
		
		return baseFunction;
	}
	
	/**
	 * Takes a name string, and attempts to clean it up
	 * so that we can match it easier.
	 * @param	name
	 * @return
	 */
	private function getCleanedFieldName(name:String):String
	{
		var	nameString:String = StringTools.trim(name);
		if (nameString.length > 1)
		{
			//Upper case the name
			nameString = nameString.toUpperCase();

			//Replace anything that isn't a letter, number, or underscore
			//with underscores.
			var regEx:EReg = ~/[^_A-Z0-9]/g;
			nameString = regEx.replace(nameString, "_");
		}
		return nameString;
	}
	
	/**
	 * The regex describing an acceptable tunable name
	 * @return
	 */
	public static var VARIABLE_NAME_REGEX:EReg = ~/^[A-Z]+(_+[A-Z0-9]+)*$/i;
	
	/**
	 * Returns whether the variable name is valid.
	 * @return
	 */
	private function validateFieldName(name:String):Bool
	{
		return (VARIABLE_NAME_REGEX.match(name));
	}
	
	/**
	 * Cleans and returns whether the entered value is valid
	 * @param val
	 * @return valid or not
	 */
	public function validateFieldValue(val:String ):Bool
	{
		var validatingClass:Class<Dynamic> = getValidatingClass();
		//trace("validate: " + val + " using: " + Type.getClassName(validatingClass));
		var validateFunction:Dynamic = getBaseFunction(validatingClass, "ValidateFieldValue");
		if (validateFunction == null)
		{
			return false;
		}
		
		return Reflect.callMethod(Type.getClass(this), validateFunction, [val]);
	}
	
	/**
	 * Takes a type string, and attempts to clean it up
	 * so that we can match it easier.
	 * @param	type
	 * @return
	 */
	private function getCleanedFieldType(type:String):String
	{
		var	typeString:String = StringTools.trim(type);
		if (typeString.length > 1)
		{
			typeString = typeString.toLowerCase();
			var firstChar:String = typeString.charAt(0);
			firstChar = firstChar.toUpperCase();
			var restOfString:String = typeString.substr(1);
			
			typeString = firstChar + restOfString;
		}
		return typeString;
	}
	
	/**
	 * Returns whether the variable type is valid.
	 * @return
	 */
	private function validateFieldType(typeString:String):Bool
	{
		return (TunablesMenu.TunableItemMap.get(typeString) != null);
	}
	
	/**
	 * Gets the value from the provided string representation
	 * @return value
	 */
	public function getValueFromString(str:String):Dynamic
	{
		var validatingClass:Class<Dynamic> = getValidatingClass();
		var valueFunction:Dynamic = getBaseFunction(validatingClass, "GetValueFromString");
		if (valueFunction == null)
		{
			Debug.warn("no value function...");
			return null;
		}
		
		return Reflect.callMethod(Type.getClass(this), valueFunction, [str]);
	}
	
	/**
	 * The regex describing an acceptable tunable name
	 * @return
	 */
	private static var VARIABLE_TAG_REGEX:EReg = ~/^[A-Z][A-Z0-9_]+$/i;
	
	/**
	 * Returns whether the tag string is valid.
	 * @return
	 */
	private function validateTag(tagString:String):Bool
	{
		return (tagString.length > 1) && (VARIABLE_TAG_REGEX.match(tagString));
	}
	
	/**
	 * Sets the value text field string.
	 * @param	val
	 */
	private function updateTextField(field:TunableTextField):Void
	{
		var fieldID:TunableItemFields = EnumTools.createByIndex(TunableItemFields, field.fieldID);
		
		switch(fieldID)
		{
			case NAME_FIELD:
			{
				updateTextFieldName();
			}
			case VALUE_FIELD:
			{
				updateTextFieldValue();
			}
			case TYPE_FIELD:
			{
				updateTextFieldType();
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
		textField.text = m_name;
	}
	
	/**
	 * Updates the value text field based on current value.
	 */
	private function updateTextFieldValue():Void
	{
		var textField:TunableTextField = getTextField(VALUE_FIELD);
		if (textField == null)
		{
			Debug.warn("value text field is null, can't set text...");
			return;
		}
		
		var validatingClass:Class<Dynamic> = getValidatingClass();
		var valueFunction:Dynamic = getBaseFunction(validatingClass, "SetTextFieldFromValue");
		if (valueFunction == null)
		{
			return;
		}
		
		Reflect.callMethod(Type.getClass(this), valueFunction, [textField, m_value]);
	}
	
	/**
	 * Updates the value text field based on current type.
	 */
	private function updateTextFieldType():Void
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
		for (tag in m_tags)
		{
			#if(!debug && build_cheats)
			//On cheats builds, the only items that display are cheats.
			//Do not show this tag since it is redundant.
			if (tag == TunableDefs.CHEATS_TAG)
			{
				continue;
			}
			#end
			fieldTagText += tag;
			fieldTagText += " ";
		}
		textField.text = fieldTagText;
	}
	
	//=============================================================
	//Define these static functions to customize item behavior in child classes.
	//=============================================================
	
	/**
	 * Returns whether the provided value is valid for this item
	 * @param	val
	 * @return
	 */
	public static function ValidateFieldValue(val:String):Bool
	{
		return true;
	}
	
	/**
	 * Returns the value from the string representation
	 * @param	field
	 * @return
	 */
	public static function GetValueFromString(str:String):Dynamic
	{
		return str;
	}
	
	/**
	 * Sets the string representation of the provided value in the provided text field.
	 * @param	field
	 * @param	val
	 */
	public static function SetTextFieldFromValue(field:TextField, val:Dynamic):Void
	{
		if (field == null)
		{
			return;
		}
		
		field.text = Std.string(val);
	}
	
	//=============================================================
	
}
#end
