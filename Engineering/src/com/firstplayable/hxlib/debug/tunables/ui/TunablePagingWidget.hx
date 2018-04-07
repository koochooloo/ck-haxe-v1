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

import openfl.text.TextFormat;
import flash.display.DisplayObject;
import com.firstplayable.hxlib.Debug;
import openfl.events.FocusEvent;
import openfl.text.TextFormatAlign;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import haxe.EnumTools;

import openfl.display.BlendMode;
import openfl.display.Sprite;

import com.firstplayable.hxlib.debug.tunables.ui.TunableTextField;
import com.firstplayable.hxlib.events.PagingEvent;

enum PagingTextFields
{
	CURRENT_PAGE;
	SEPARATOR;
	PAGE_COUNT;
}

enum PagingButtons
{
	FIRST_PAGE;
	PREV_PAGE;
	NEXT_PAGE;
	LAST_PAGE;
}

/**
 * Button that allows the addition of a new Tunable
 */
class TunablePagingWidget extends Sprite
{	
	//====================================================================
	// Paging Field Defs
	//====================================================================
	/**
	 * The ratio of available field space in an item for the Tags field.
	 */
	public static var TUNABLES_UI_PAGE_WIDTH_FIELD(get, null):Float;
	public static function get_TUNABLES_UI_PAGE_WIDTH_FIELD():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_PAGE_WIDTH_FIELD", 1/16);
	}
	
	/**
	 * The ratio of available field space in an item for the Tags field.
	 */
	public static var TUNABLES_UI_PAGE_WIDTH_SEPARATOR(get, null):Float;
	public static function get_TUNABLES_UI_PAGE_WIDTH_SEPARATOR():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_PAGE_WIDTH_SEPARATOR", 1/32);
	}
	
	/**
	 * The ratio of available field space in an item for the Tags field.
	 */
	public static var TUNABLES_UI_PAGE_WIDTH_GAP(get, null):Float;
	public static function get_TUNABLES_UI_PAGE_WIDTH_GAP():Float
	{
		return Tunables.getFloatField("TUNABLES_UI_PAGE_WIDTH_GAP", 1/32);
	}
	
	//===============================
	// Paging
	//===============================
	/**
	 * The fill color for Paging symbols
	 */
	public static var TUNABLES_UI_BTN_PAGING_COLOR(get, null):Int;
	public static function get_TUNABLES_UI_BTN_PAGING_COLOR():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_PAGING_COLOR", UIDefs.TUNABLES_UI_BTN_COLOR);
	}
	
	/**
	 * The unicode for First Page symbol
	 */
	public static var TUNABLES_UI_BTN_PAGE_FIRST_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_PAGE_FIRST_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_PAGE_FIRST_SYMBOL", 0x23EE);
	}
	
	/**
	 * The unicode for Previous Page symbol
	 */
	public static var TUNABLES_UI_BTN_PAGE_PREV_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_PAGE_PREV_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_PAGE_PREV_SYMBOL", 0x23F4);
	}
	
	/**
	 * The unicode for Next Page symbol
	 */
	public static var TUNABLES_UI_BTN_PAGE_NEXT_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_PAGE_NEXT_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_PAGE_NEXT_SYMBOL", 0x23F5);
	}
	
	/**
	 * The unicode for Next Page symbol
	 */
	public static var TUNABLES_UI_BTN_PAGE_LAST_SYMBOL(get, null):Int;
	public static function get_TUNABLES_UI_BTN_PAGE_LAST_SYMBOL():Int
	{
		return Tunables.getIntField("TUNABLES_UI_BTN_PAGE_LAST_SYMBOL", 0x23ED);
	}
	
	/**
	 * Gets the symbol to use for the button
	 * @param	buttonID
	 */
	public static function getSymbol(buttonID:PagingButtons):Int
	{
		switch(buttonID)
		{
			case FIRST_PAGE: 	return TUNABLES_UI_BTN_PAGE_FIRST_SYMBOL;
			case PREV_PAGE: 	return TUNABLES_UI_BTN_PAGE_PREV_SYMBOL;
			case NEXT_PAGE:		return TUNABLES_UI_BTN_PAGE_NEXT_SYMBOL;
			case LAST_PAGE:		return TUNABLES_UI_BTN_PAGE_LAST_SYMBOL;
		}
	}
	
	//==================================================
	// Members
	//==================================================
	
	private var m_textFields:Array<TunableTextField>;
	private var m_pagingButtons:Array<Sprite>;
	
	public var curPage(get, set):Int;
	public var pageCount(get, set):Int;
	
	private var m_width:Float = 0;
	private var m_height:Float = 0;

	public function new(startWidth:Float, startHeight:Float) 
	{
		super();
		
		m_width = startWidth;
		m_height = startHeight;
		
		//Add the container
		graphics.clear();
		blendMode = BlendMode.NORMAL;
		graphics.beginFill(UIDefs.TUNABLES_UI_BG_COLOR, 0);
		graphics.drawRect(x, y, m_width -1, m_height);
		graphics.endFill();
		
		//Add fields
		var textFormat:TextFormat = new TextFormat();
		textFormat.align = TextFormatAlign.CENTER;
		textFormat.size = UIDefs.TUNABLES_UI_TEXT_SIZE;
		
		var currentPageField = new TunableTextField(CURRENT_PAGE.getIndex(), true);
		currentPageField.setTextFormat(textFormat);
		currentPageField.text = "-1";
		currentPageField.addEventListener(FocusEvent.FOCUS_OUT, onDefocusCurrentPage);
		
		var separatorField 	 = new TunableTextField(SEPARATOR.getIndex(), false);
		separatorField.setTextFormat(textFormat);
		separatorField.text = "of";
		separatorField.border = false;
		
		var numPagesField 	 = new TunableTextField(PAGE_COUNT.getIndex(), false);
		numPagesField.setTextFormat(textFormat);
		numPagesField.text = "-1";
		
		m_textFields = [currentPageField, separatorField, numPagesField];
		
		//Add buttons
		m_pagingButtons = [];
		var allButtonIDs:Array<PagingButtons> = EnumTools.createAll(PagingButtons);
		for (id in allButtonIDs)
		{
			var nextButton:SymbolButton = new SymbolButton(function():Int { return getSymbol(id); });		
			nextButton.visible = false;
			
			m_pagingButtons.push(nextButton);
		}
	}
	
	public function init()
	{
		//Position elements
		
		var pageFieldWidth:Float = m_width * TUNABLES_UI_PAGE_WIDTH_FIELD;
		var separatorWidth:Float = m_width * TUNABLES_UI_PAGE_WIDTH_SEPARATOR;
		var gapWidth:Float = m_width * TUNABLES_UI_PAGE_WIDTH_GAP;
		
		var numElements:Int = m_pagingButtons.length + m_textFields.length;
		var numGaps = numElements - 1;
		
		var unusedWidth:Float = m_width - ( 4 * UIDefs.TUNABLES_UI_ITEM_SIZE ) - ( 2 * pageFieldWidth) - ( separatorWidth) - ( numGaps * gapWidth);
		if (unusedWidth < 0)
		{
			Debug.warn("Not enough space for TunablePageWidget: " + unusedWidth);
			return;
		}
		
		//Add and position all the elements
		var totalHeight = m_height;
		var itemHeight = UIDefs.TUNABLES_UI_ITEM_SIZE;
		var curY = (totalHeight - itemHeight) / 2; 
		
		var curX = unusedWidth / 2;
		var nextElement:DisplayObject = null;
		
		Debug.log("position first page button");
		nextElement = m_pagingButtons[FIRST_PAGE.getIndex()];
		nextElement.x = curX;
		nextElement.y = curY;
		addChild(nextElement);
		curX += UIDefs.TUNABLES_UI_ITEM_SIZE + gapWidth;
		
		//Debug.log("position PREV_PAGE");
		nextElement = m_pagingButtons[PREV_PAGE.getIndex()];
		nextElement.x = curX;
		nextElement.y = curY;
		addChild(nextElement);
		curX += UIDefs.TUNABLES_UI_ITEM_SIZE + gapWidth;
		
		//Debug.log("position CURRENT_PAGE");
		nextElement = m_textFields[CURRENT_PAGE.getIndex()];
		nextElement.x = curX;
		nextElement.y = curY;
		nextElement.height = itemHeight - 2;
		nextElement.width = pageFieldWidth;
		addChild(nextElement);
		curX += pageFieldWidth;
		
		//Debug.log("position SEPARATOR");
		nextElement = m_textFields[SEPARATOR.getIndex()];
		nextElement.x = curX;
		nextElement.y = curY;
		nextElement.height = itemHeight - 2;
		nextElement.width = separatorWidth;
		addChild(nextElement);
		curX += separatorWidth;
		
		//Debug.log("position PAGE_COUNT");
		nextElement = m_textFields[PAGE_COUNT.getIndex()];
		nextElement.x = curX;
		nextElement.y = curY;
		nextElement.height = itemHeight - 2;
		nextElement.width = pageFieldWidth;
		addChild(nextElement);
		curX += pageFieldWidth + gapWidth;
		
		//Debug.log("position NEXT_PAGE");
		nextElement = m_pagingButtons[NEXT_PAGE.getIndex()];
		nextElement.x = curX;
		nextElement.y = curY;
		addChild(nextElement);
		curX += UIDefs.TUNABLES_UI_ITEM_SIZE + gapWidth;
		
		//Debug.log("position LAST_PAGE button");
		nextElement = m_pagingButtons[LAST_PAGE.getIndex()];
		nextElement.x = curX;
		nextElement.y = curY;
		addChild(nextElement);
		curX += UIDefs.TUNABLES_UI_ITEM_SIZE + gapWidth;
		
		//Add Listenvers
		m_pagingButtons[FIRST_PAGE.getIndex()].addEventListener(MouseEvent.CLICK, onFirstPressed);
		m_pagingButtons[PREV_PAGE.getIndex()].addEventListener(MouseEvent.CLICK, onPrevPressed);
		m_pagingButtons[NEXT_PAGE.getIndex()].addEventListener(MouseEvent.CLICK, onNextPressed);
		m_pagingButtons[LAST_PAGE.getIndex()].addEventListener(MouseEvent.CLICK, onLastPressed);
	}
	
	/**
	 * Prepares the object for removal
	 */
	public function release():Void
	{
		m_pagingButtons[FIRST_PAGE.getIndex()].removeEventListener(MouseEvent.CLICK, onFirstPressed);
		m_pagingButtons[PREV_PAGE.getIndex()].removeEventListener(MouseEvent.CLICK, onPrevPressed);
		m_pagingButtons[NEXT_PAGE.getIndex()].removeEventListener(MouseEvent.CLICK, onNextPressed);
		m_pagingButtons[LAST_PAGE.getIndex()].removeEventListener(MouseEvent.CLICK, onLastPressed);
		
		for (button in m_pagingButtons)
		{
			button.removeChildren();
			removeChild(button);
		}
		m_pagingButtons = [];
		
		m_textFields[CURRENT_PAGE.getIndex()].removeEventListener(FocusEvent.FOCUS_OUT, onDefocusCurrentPage);
		for (field in m_textFields)
		{
			if (getChildIndex(field) != -1)
			{
				removeChild(field);
				field.release();
			}
		}
		
		m_textFields = [];
	}

	
	public function updateDisplay()
	{		
		//If the pages aren't defined, bail.
		if (curPage == -1 || pageCount == -1)
		{
			for (button in m_pagingButtons)
			{
				button.visible = false;
			}
			return;
		}
		
		m_pagingButtons[FIRST_PAGE.getIndex()].visible = curPage != 0;
		m_pagingButtons[PREV_PAGE.getIndex()].visible = curPage > 0;
		m_pagingButtons[NEXT_PAGE.getIndex()].visible = curPage < pageCount - 1;
		m_pagingButtons[LAST_PAGE.getIndex()].visible = curPage != pageCount - 1;
	}
	
	//=========================================================
	// User Interaction
	//=========================================================
	
	/**
	 * Paging button was pressed, update the menu.
	 */
	private function onFirstPressed(e:MouseEvent):Void
	{
		dispatchEvent(new PagingEvent(0));
	}

	/**
	 * Paging button was pressed, update the menu.
	 */
	private function onPrevPressed(e:MouseEvent):Void
	{
		dispatchEvent(new PagingEvent(curPage - 1));
	}
	
	/**
	 * Paging button was pressed, update the menu.
	 */
	private function onNextPressed(e:MouseEvent):Void
	{
		dispatchEvent(new PagingEvent(curPage + 1));
	}
	
	/**
	 * Paging button was pressed, update the menu.
	 */
	private function onLastPressed(e:MouseEvent):Void
	{
		dispatchEvent(new PagingEvent(pageCount - 1));
	}
	
	/**
	 * Current page value comitted
	 * @return
	 */
	private function onDefocusCurrentPage(e:FocusEvent):Void
	{
		if (e.target != m_textFields[CURRENT_PAGE.getIndex()])
		{
			return;
		}
		
		dispatchEvent(new PagingEvent(curPage));
	}
	
	//=========================================================
	// Page Management
	//=========================================================
	
	private function get_curPage():Int
	{
		var page:Null<Int> = Std.parseInt(m_textFields[CURRENT_PAGE.getIndex()].text);
		if (page == null)
		{
			return - 1;
		}
		
		//Text is 1 indexed, we're 0 indexed.
		return page - 1;
	}
	
	private function set_curPage(page:Int):Int
	{
		var displayPage:Int = page + 1;
		m_textFields[CURRENT_PAGE.getIndex()].text = Std.string(displayPage);
		
		updateDisplay();
		
		return page;
	}
	
	private function get_pageCount():Int
	{		
		var page:Null<Int> = Std.parseInt(m_textFields[PAGE_COUNT.getIndex()].text);
		if (page == null)
		{
			return - 1;
		}
		
		return page;
	}
	
	private function set_pageCount(page:Int):Int
	{		
		var displayPage:Int = page;
		m_textFields[PAGE_COUNT.getIndex()].text = Std.string(displayPage);
		
		updateDisplay();
		
		return page;
	}
	
}
#end
