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
import openfl.events.MouseEvent;
import openfl.events.Event;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import openfl.display.Shape;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextField;

import openfl.display.BlendMode;
import openfl.display.Sprite;

enum SymbolButtonShape
{
	BOX;
	CIRCLE;
}

/**
 * A button that allows specifying a character to display as its icon
 * with size and color parameters
 */
class SymbolButton extends Sprite
{	
	//===============================
	// Defs
	//===============================
	/**
	 * The highlight color for symbol buttons
	 */
	public static var TUNABLES_UI_BTN_HIGHLIGHT_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_HIGHLIGHT_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_HIGHLIGHT_COLOR", 0x000000);
	}
	
	/**
	 * The highlight alpha for symbol buttons
	 */
	public static var TUNABLES_UI_BTN_HIGHLIGHT_ALPHA(get, null):Float;
	public static function get_TUNABLES_UI_BTN_HIGHLIGHT_ALPHA():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_BTN_HIGHLIGHT_ALPHA", 0.4);
	}
	
	
	//===============================
	//initial args
	//===============================
	private var m_getButtonSize:Void -> Float;
	private var m_getSymbolCode:Void -> Int;
	private var m_getSymbolColor:Void -> Int;
	private var m_getFillColor:Void -> Int;
	private var m_getShape:Void -> SymbolButtonShape;
	
	private var m_highlight:Shape;
	
	/**
	 * Constructs a symbol box
	 * @param	getSymbolCode: Unicode of the symbol to draw.
	 * @param	opt: getButtonSize
	 * @param	opt: getSymbolColor
	 * @param	opt: getFillColor
	 * @param	opt: getShape
	 */
	public function new( getSymbolCode:Void -> Int, 
		?getButtonSize: Void -> Float,
		?getSymbolColor:Void -> Int,
		?getFillColor:Void -> Int,
		?getShape:Void -> SymbolButtonShape) 
	{
		super();
		
		m_getButtonSize = getButtonSize;
		m_getSymbolCode = getSymbolCode;
		m_getSymbolColor = getSymbolColor;
		m_getFillColor = getFillColor;
		m_getShape = getShape;
		
		m_highlight = null;
		
		createButton();
		
		buttonMode = true;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	public function release():Void
	{
		clearHighlight();
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
	}
	
	/**
	 * If the highlight it active, clear it.
	 */
	private function clearHighlight():Void
	{
		if (m_highlight != null)
		{
			removeChild(m_highlight);
			m_highlight = null;
		}
	}
	
	/**
	 * Creates the button based on member parameters
	 */
	public function createButton():Void
	{
		if (m_getButtonSize == null)
		{
			m_getButtonSize = function():Float{ return UIDefs.TUNABLES_UI_BTN_SIZE; };
		}
		
		if (m_getSymbolColor == null)
		{
			m_getSymbolColor = function():Int{ return UIDefs.TUNABLES_UI_BTN_COLOR; };
		}
		
		if (m_getFillColor == null)
		{
			m_getFillColor = function():Int{ return UIDefs.TUNABLES_UI_BTN_BG_COLOR; };
		}
		
		if (m_getShape == null)
		{
			m_getShape = function():SymbolButtonShape{ return BOX; };
		}
		
		var btnSize:Float = m_getButtonSize();
		var symCode:Int = m_getSymbolCode();
		var symColor:Int = m_getSymbolColor();
		var fillColor:Int = m_getFillColor();
		var shapeType:SymbolButtonShape = m_getShape();
		
		graphics.clear();
		blendMode = BlendMode.NORMAL;
		
		//Draw Shape
		var buttonShape:Shape = new Shape();
		buttonShape.graphics.lineStyle(UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE, UIDefs.TUNABLES_UI_OUTLINE_COLOR);
		buttonShape.graphics.beginFill(fillColor);
		
		switch(shapeType)
		{
			case BOX:
			{
				buttonShape.graphics.drawRoundRect(0, 0, btnSize, btnSize, UIDefs.TUNABLES_UI_ROUND_RECT_CORNER_SIZE);
			}
			case CIRCLE:
			{
				var radius:Float = btnSize / 2;
				buttonShape.graphics.drawCircle(radius, radius, radius);
			}
		}

		buttonShape.graphics.endFill();
		addChild(buttonShape);
		
		//add symbol field
		var symbolField:TextField = new TextField();
		var symbolFormat:TextFormat = new TextFormat();
		symbolFormat.align = TextFormatAlign.CENTER;
		symbolFormat.color = symColor;
		symbolFormat.bold = false;
		symbolField.setTextFormat(symbolFormat);
		symbolField.width = btnSize;
		symbolField.height = btnSize;
		symbolField.text = String.fromCharCode(symCode);
		symbolField.selectable = false;
		
		addChild(symbolField);
	}
	
	//=========================================================
	// Event Callbacks
	//=========================================================
	
	private function onAddedToStage(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		
		DebugDefs.debugEventTarget.addEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onRefreshUI);
	}
	
	private function onRemovedFromStage(e:Event):Void
	{
		removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		DebugDefs.debugEventTarget.removeEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onRefreshUI);
	}
	
	/**
	 * Handles the visual feedback of clicking the button
	 * @param	e
	 */
	private function onMouseDown(e:MouseEvent):Void
	{
		if (e.currentTarget != this)
		{
			return;
		}
		
		clearHighlight();
		
		//====================================
		//Highlight the btn.
		//====================================
		
		var btnSize:Float = m_getButtonSize();
		var fillColor:Int = TUNABLES_UI_BTN_HIGHLIGHT_COLOR;
		var fillAlpha:Float = TUNABLES_UI_BTN_HIGHLIGHT_ALPHA;
		var shapeType:SymbolButtonShape = m_getShape();
		
		//Draw Shape
		m_highlight = new Shape();
		m_highlight.graphics.lineStyle(UIDefs.TUNABLES_UI_BTN_OUTLINE_SIZE, UIDefs.TUNABLES_UI_OUTLINE_COLOR);
		m_highlight.graphics.beginFill(fillColor, fillAlpha);
		
		switch(shapeType)
		{
			case BOX:
			{
				m_highlight.graphics.drawRoundRect(0, 0, btnSize, btnSize, UIDefs.TUNABLES_UI_ROUND_RECT_CORNER_SIZE);
			}
			case CIRCLE:
			{
				var radius:Float = btnSize / 2;
				m_highlight.graphics.drawCircle(radius, radius, radius);
			}
		}

		m_highlight.graphics.endFill();
		addChild(m_highlight);
	}
	
	private function onMouseUp(e:MouseEvent):Void
	{
		clearHighlight();
	}
	
	private function onMouseOut(e:MouseEvent):Void
	{
		clearHighlight();
	}
	
	/**
	 * Handles change of UI parameters
	 * @param	e
	 */
	private function onRefreshUI(e:RefreshUIEvent):Void
	{
		refreshButton();
	}
	
	/**
	 * Updates appearance
	 */
	private function refreshButton():Void
	{
		//Remove the old button
		removeChildren();
		
		//create button based on potentially updated parameters
		createButton();
	}
	
}
#end
