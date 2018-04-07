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
package com.firstplayable.hxlib.debug.tunables;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableString;
import openfl.events.EventDispatcher;
import com.firstplayable.hxlib.debug.tunables.ui.SaveButton;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableBool;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableFloat;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import com.firstplayable.hxlib.debug.tunables.ui.UIDefs;
import openfl.net.URLRequest;
import openfl.Lib;
import com.firstplayable.hxlib.debug.tunables.ui.InfoButton;
import com.firstplayable.hxlib.debug.tunables.ui.TunablePagingWidget;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesVariable;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesType;
import com.firstplayable.hxlib.debug.tunables.TunableDefs.TunablesFile;
import com.firstplayable.hxlib.events.PagingEvent;
import com.firstplayable.hxlib.debug.tunables.tunableItems.NewTunableItem;
import com.firstplayable.hxlib.debug.tunables.tunableItems.SearchTunableItem;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableInt;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableItem;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableItemColumnLabels;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableMilliseconds;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunablePercent;
import com.firstplayable.hxlib.debug.tunables.tunableItems.TunableSeconds;
import com.firstplayable.hxlib.debug.tunables.ui.AddItemButton;
import haxe.Json;
import haxe.ds.StringMap;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
#if js
import js.html.AnchorElement;
import js.Browser;
#end

/**
 * Creates a debug menu for tunable values defined in Tunables.json.
 * Can also save out a copy of edited values for ease of tuning.
 */

class TunablesMenu extends Sprite
{	
	public static var BOTTOM_BAR_HEIGHT(get, null):Float;
	public static function get_BOTTOM_BAR_HEIGHT():Float
	{
		return UIDefs.TUNABLES_UI_ITEM_SIZE * UIDefs.TUNABLES_UI_BOTTOM_BAR_SIZE;
	}
	
	public static var TunableItemMap:Map<String, Class<Dynamic>> = [
	"Bool" => TunableBool,
	"Int" => TunableInt,
	"Float" => TunableFloat,
	"Milliseconds" => TunableMilliseconds,
	"Seconds" => TunableSeconds,
	"Percent" => TunablePercent,
	"String" => TunableString,
	TunableDefs.PLACEHOLDER_TYPE => TunableItem
	];
	
	//==================================================================
	// GUI Items
	//==================================================================
	
	//Map of all variable items
	private var m_allVariableItems:StringMap<TunableItem>;
	private var m_filteredItems:Array<TunableItem>;
	
	//Items on display
	private var m_headerItems:List<TunableItem>;
	private var m_variableItems:List<TunableItem>;
	private var m_footerItems:List<TunableItem>;
	
	//Header Widgets
	private var m_infoButton:Sprite;
	
	//Footer Widgets
	private var m_pagingWidget:TunablePagingWidget;
	private var m_addButton:Sprite;
	private var m_saveButton:Sprite;
	
	//==================================================================
	// GUI Properties
	//==================================================================
	
	private static inline var INFO_BUTTON_URL:String = "https://wiki.1stplayable.com/index.php/Web/Haxe/Tunables_Menu";
	
	private var m_startWidth:Float;
	private var m_startHeight:Float;
	
	private var m_init:Bool = false;
	private var m_showing:Bool = false;
	
	private var itemWidth(get, null):Float;
	
	//==================================================================
	// Model Properties
	//==================================================================
	
	public static var NUM_ITEMS_PER_PAGE:Int = 20;
	
	private var m_filter:TunablesVariable;
	
	private var m_curPage:Int;
	private var curPage(get, set):Int;
	private var pageCount(get, null):Int;
	
	/**
	 * Constructs a TunablesMenu with the provided width and height.
	 * @param	startWidth
	 * @param	startHeight
	 */
	public function new(startWidth:Float, startHeight:Float) 
	{
		super();
		
		m_filter = LocalTunablesConfigurator.DEFAULT_SEARCH;	
		
		m_curPage = 0;
		
		m_startWidth = startWidth;
		m_startHeight = startHeight;
		
		//=======================================================
		// Create the items
		//=======================================================
		
		//==============================================
		//Create the Header
		//==============================================
		m_headerItems = new List<TunableItem>();
		
		//construct the header item
		var columnNames:TunablesVariable =
		{
			name: 	"Variable Name",
			type: 	"Type Name",
			value: 	"Value",
			tags:	["Tags"]
		};
		var columnsItem:TunableItemColumnLabels = new TunableItemColumnLabels(itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, columnNames);
		m_headerItems.add(columnsItem);
		
		//==============================================
		//Create the Tunable Items representing variables
		//==============================================
		
		m_allVariableItems = new StringMap<TunableItem>();
		m_filteredItems = [];
		m_variableItems = new List<TunableItem>();
		
		//construct the items
		for (variable in Tunables.ALL_VARIABLES)
		{
			var nextItem:TunableItem = createItemForVariable(variable, itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE);
			if (nextItem != null)
			{
				m_allVariableItems.set(variable.name, nextItem);
				//TODO: allow defining default filter!
				if (nextItem.itemPassesFilter(m_filter))
				{
					m_filteredItems.push(nextItem);
				}
			}
		}
		
		//==============================================
		//Handle local configurations
		//==============================================
		for (item in m_allVariableItems)
		{
			item.checkAndHandleLocalConfiguration();
		}
		
		//==============================================
		//Create the Footer
		//==============================================
		
		m_footerItems = new List<TunableItem>();
		
		//construct the search header item
		var filterColumnNames:TunablesVariable =
		{
			name: 	"SEARCH:\t"+ String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tVariable Name",
			type: 	"\t" + String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tType",
			value: 	"\t" + String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tValue",
			tags:	[(String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tTags")]
		};
		var filterColumnsItem:TunableItemColumnLabels = new TunableItemColumnLabels(itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, filterColumnNames);
		m_footerItems.add(filterColumnsItem);
		
		//construct the search item
		var searchDefaultValues:TunablesVariable = m_filter;		
		var searchItem:SearchTunableItem = new SearchTunableItem(this, itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, searchDefaultValues);
		m_footerItems.add(searchItem);
		
		m_infoButton = null;
		m_saveButton = null;
		
		m_pagingWidget = null;
		
		m_addButton = null;
		
		m_init = false;
		m_showing = false;
	}
	
	/**
	 * Sets up the window, and all the items
	 */
	private function initWindow():Void
	{		
		//add the info button
		m_infoButton = new InfoButton();
		m_infoButton.addEventListener(MouseEvent.CLICK, onClickedInfo);
		addChild(m_infoButton);
		
		//add the save button
		m_saveButton = new SaveButton();
		m_saveButton.addEventListener(MouseEvent.CLICK, onClickedSave);
		addChild(m_saveButton);
		
		//init the paging widget
		m_pagingWidget = new TunablePagingWidget(itemWidth, BOTTOM_BAR_HEIGHT);
		addChild(m_pagingWidget);
		m_pagingWidget.init();
		m_pagingWidget.curPage = curPage;
		m_pagingWidget.pageCount = pageCount;
		
		//add buttons
		m_addButton = new AddItemButton();
		m_addButton.addEventListener(MouseEvent.CLICK, onClickedAddItem);
		addChild(m_addButton);
		#if(!debug && build_cheats)
		//We can't add new tunables while in cheats.
		m_addButton.visible = false;
		#end
		
		//update items
		refreshItems();
		
		//add listeners
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		DebugDefs.debugEventTarget.addEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onUIRefresh);
		m_pagingWidget.addEventListener(PagingEvent.PAGING_EVENT, onPagingEvent);
	}
	
	/**
	 * Releases the window in preparation for deletion.
	 * In most cases you won't need to do this since the window should
	 * persist in the DEBUG layer, but it's here if you need.
	 */
	public function release():Void
	{
		m_addButton.removeEventListener(MouseEvent.CLICK, onClickedAddItem);
		m_pagingWidget.removeEventListener(PagingEvent.PAGING_EVENT, onPagingEvent);
		m_saveButton.removeEventListener(MouseEvent.CLICK, onClickedSave);
		m_infoButton.removeEventListener(MouseEvent.CLICK, onClickedInfo);
		DebugDefs.debugEventTarget.removeEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onUIRefresh);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		var itemLists:Array<List<TunableItem>> = getItemLists();
		for (list in itemLists)
		{
			for (item in list)
			{
				removeItem(item);
			}
			list.clear();
		}
		m_filteredItems = [];
		m_allVariableItems = null;
		m_headerItems = null;
		m_footerItems = null;

		for (item in m_allVariableItems)
		{
			item.release();
		}
		m_allVariableItems = null;
		
		m_curPage = 0;
		
		removeChild(m_saveButton);
		m_saveButton = null;
		
		removeChild(m_infoButton);
		m_infoButton = null;
		
		m_pagingWidget.release();
		removeChild(m_pagingWidget);
		m_pagingWidget = null;
		
		removeChild(m_addButton);
		m_addButton = null;
	}
	
	//==================================================================
	// Window Maintenance
	//==================================================================
	
	/**
	 * Toggles between showing and hiding the debug menu.
	 */
	public function toggleShow():Void
	{
		show(!m_showing);
	}
	
	/**
	 * Shows or hide the window, initing it if it hasn't been shown yet.
	 * @param	show
	 */
	public function show( show:Bool = true ):Void
	{
		if (show && !m_showing)
		{
			GameDisplay.attach( LayerName.DEBUG, this );
			if (!m_init)
			{
				initWindow();
				m_init = true;
			}
			
			m_showing = true;
		}
		else if(!show && m_showing)
		{
			GameDisplay.remove( LayerName.DEBUG, this );
			m_showing = false;
		}
	}
	
	private function updateWindow(leftX:Float, topY:Float, rightX:Float, bottomY:Float):Void
	{		
		//Debug.log('Drawing window: ($leftX,$topY)-($rightX,$bottomY)');
		
		graphics.clear();
		blendMode = BlendMode.NORMAL;
		graphics.lineStyle(UIDefs.TUNABLES_UI_OUTLINE_SIZE, UIDefs.TUNABLES_UI_OUTLINE_COLOR);
		graphics.beginFill(UIDefs.TUNABLES_UI_BG_COLOR);
		
		graphics.drawRoundRect(leftX, topY, rightX, bottomY, UIDefs.TUNABLES_UI_ROUND_RECT_CORNER_SIZE);
		graphics.endFill();
	}
	
	//==================================================================
	// Item Maintenance
	//==================================================================
	
	/**
	 * Gets a list of all tunable items that should be visible on the menu
	 * @return
	 */
	private function getItemLists():Array<List<TunableItem>>
	{
		return [m_headerItems, m_variableItems, m_footerItems];
	}
	
	/**
	 * Redraw all the tunable items based on the current m_items list
	 */
	private function refreshItems():Void
	{
		var itemLists:Array<List<TunableItem>> = getItemLists();
		
		//Remove all items from self
		for (list in itemLists)
		{
			for (item in list)
			{
				if (getChildIndex(item) != -1)
				{
					removeChild(item);
				}
			}
		}
		m_variableItems.clear();
		
		//Re-add all header items
		for (item in m_headerItems)
		{
			addChild(item);
			if (!item.m_inited)
			{
				item.init();
			}
		}
		
		//Add only items for the current page
		var curItem:Int = 0;
		var firstItemOfPage:Int = curPage * NUM_ITEMS_PER_PAGE;
		var endOfPage:Int = (curPage + 1) * NUM_ITEMS_PER_PAGE;
		
		for (i in firstItemOfPage...endOfPage)
		{
			if (i >= m_filteredItems.length)
			{
				break;
			}
			
			var item:TunableItem = m_filteredItems[i];
			addChild(item);
			if (!item.m_inited)
			{
				item.init();
			}
			
			m_variableItems.add(item);
		}
		
		//Re-add all footer items
		for (item in m_footerItems)
		{
			addChild(item);
			if (!item.m_inited)
			{
				item.init();
			}
		}
		
		//Position the items
		updateItemPositions();
	}
	
	/**
	 * Updates all visible tunable items to their correct positions.
	 */
	private function updateItemPositions():Void
	{
		var itemLists:Array<List<TunableItem>> = getItemLists();
		
		var topY:Float = UIDefs.TUNABLES_UI_OUTLINE_SIZE;
		var itemY:Float = topY;
		
		//Add all items back
		for (list in itemLists)
		{
			if (list == m_footerItems)
			{				
				//IF we have multiple pages, the footer should always be at the same place.
				if (pageCount > 1)
				{
					var numPaddingItems:Int = NUM_ITEMS_PER_PAGE - m_variableItems.length;
					var padding:Float = numPaddingItems * (UIDefs.TUNABLES_UI_ITEM_SIZE + UIDefs.TUNABLES_UI_OUTLINE_SIZE);
					itemY += padding;
				}
			}
			
			for (nextItem in list)
			{
				nextItem.x = UIDefs.TUNABLES_UI_OUTLINE_SIZE;
				nextItem.y = itemY;
				
				itemY += (UIDefs.TUNABLES_UI_ITEM_SIZE + UIDefs.TUNABLES_UI_OUTLINE_SIZE);
			}
		}
		
		//Grab the first item for positioning and size reference
		var firstItem:TunableItem = m_headerItems.first();
		if (firstItem == null)
		{
			Debug.warn("Somehow we have no header items. Something has gone horribly wrong...");
			return;
		}
		var firstItemRect:Rectangle = firstItem.getBounds(this);
		
		//=================================================
		//Header buttons
		//=================================================
		//Reposition the Help Button
		removeChild(m_infoButton);
		m_infoButton.x = firstItem.fieldSpace + (firstItem.buttonSpace / 3);
		m_infoButton.y = topY + 1;
		addChild(m_infoButton);
		
		//=================================================
		//Footer buttons
		//=================================================
		var leftOverSpace:Float = BOTTOM_BAR_HEIGHT - UIDefs.TUNABLES_UI_ITEM_SIZE;
		
		//Reposition the Save Button
		removeChild(m_saveButton);
		m_saveButton.x = (UIDefs.TUNABLES_UI_BTN_SIZE) + (UIDefs.TUNABLES_UI_OUTLINE_SIZE);
		m_saveButton.y = itemY + (leftOverSpace / 2) + 1;
		addChild(m_saveButton);
		
		//Reposition the add button		
		m_addButton.x = itemWidth - (UIDefs.TUNABLES_UI_BTN_SIZE * 2) + (UIDefs.TUNABLES_UI_OUTLINE_SIZE) + 1;
		m_addButton.y = itemY + (leftOverSpace / 2) + 1;
		
		//Reposition the paging widget
		m_pagingWidget.x = UIDefs.TUNABLES_UI_OUTLINE_SIZE + ((itemWidth - m_pagingWidget.width) / 2);
		m_pagingWidget.y = itemY;
		
		m_pagingWidget.visible = (pageCount > 1);
		m_pagingWidget.pageCount = pageCount;
		
		itemY += BOTTOM_BAR_HEIGHT;
		
		//=================================================
		//Determine window size
		//=================================================
		
		var leftX:Float = firstItemRect.left;
		var topY:Float = firstItemRect.top;
		var rightX:Float = leftX + itemWidth;
		var bottomY:Float = itemY;
		
		updateWindow(leftX, topY, rightX, bottomY);
	}
	
	/**
	 * Removes an item
	 * @param	item
	 */
	private function removeItem(item:TunableItem):Void
	{
		if (item == null)
		{
			Debug.warn("Can't remove null item");
			return;
		}
		
		if (m_allVariableItems.exists(item.variableName))
		{
			m_allVariableItems.remove(item.variableName);
		}
		//Removal is almost always from near the end of the list
		//so this should be relatively fast.
		m_filteredItems.remove(item);
		m_variableItems.remove(item);
		
		removeChild(item);
		item.release();
	}
	
	//=================================================================
	// GUI Property Implementations
	//=================================================================
	
	/**
	 * Returns the width that items should be.
	 * @return
	 */
	private function get_itemWidth():Float
	{
		return m_startWidth;
	}
	
	//==================================================================
	// Model Property Implementations
	//==================================================================
	
	/**
	 * Gets the current page number
	 * @return
	 */
	private function get_curPage():Int
	{
		return m_curPage;
	}
	
	/**
	 * Attempts to set the current page number to the specified page.
	 * @param	newPage
	 * @return
	 */
	private function set_curPage(newPage:Int):Int
	{
		if (newPage < 0 || newPage >= pageCount)
		{
			return m_curPage;
		}
		
		m_curPage = newPage;
		m_pagingWidget.curPage = newPage;
		refreshItems();
		
		return m_curPage;
	}
	
	/**
	 * Returns the number of pages needed to display all the filtered items.
	 * @return
	 */
	private function get_pageCount():Int
	{
		return Std.int(Math.ceil(m_filteredItems.length / NUM_ITEMS_PER_PAGE));
	}
	
	//==================================================================
	// User Input Handling
	//==================================================================
	
	/**
	 * Handles clicking the help button
	 * @param	e
	 */
	private function onClickedInfo(e:MouseEvent):Void
	{
		if (e.currentTarget != m_infoButton)
		{
			return;
		}
		
		openfl.Lib.getURL(new URLRequest(INFO_BUTTON_URL));
	}
	
	/**
	 * Handles clicking the save button to update the tunables.
	 * @param	e
	 */
	private function onClickedSave(e:MouseEvent):Void
	{
		if (e.currentTarget != m_saveButton)
		{
			return;
		}
		
		saveValues();
	}
	
	/**
	 * Handles adding a NewTunableItem for a new variable
	 * @param	e
	 */
	private function onClickedAddItem(e:MouseEvent):Void
	{
		#if(!debug && build_cheats)
		//Can't add new tunables in a cheats build
		return;
		#end
		
		if (e.currentTarget != m_addButton)
		{
			return;
		}
		
		var newVarName:String = "NEW_VARIABLE";
		newVarName = getNextAvailableVariableName(newVarName);
		
		var newVar:TunablesVariable = 
		{
			name: newVarName,
			type: "Percent",
			value: "0",
			tags: []
		}
		
		var newItem:NewTunableItem = new NewTunableItem( this, itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, newVar);
		newItem.init();
		
		m_allVariableItems.set(newItem.variableName, newItem);
		
		//See the new item, even if filters say otherwise
		m_filteredItems.push(newItem);
		
		//If we aren't on the last page, go there so we can see the new item
		if (curPage < pageCount - 1)
		{
			curPage = pageCount - 1;
		}
		
		refreshItems();
	}
	
	/**
	 * Saves a NewTunableItem as an actuable tunable item.
	 * @param	item
	 */
	public function saveNewTunable(item:NewTunableItem, newVariable:TunablesVariable):Void
	{
		if (Tunables.validateTunableVariable(newVariable))
		{
			var classType:Class<Dynamic> = TunableItemMap.get(newVariable.type);
			if (classType == null)
			{
				Debug.warn("no class entry for: " + newVariable.type);
				return null;
			}
			
			//Remove the NewTunableItem
			removeItem(item);
		
			//Create the actual item to represent the variable
			var newItem:TunableItem = Type.createInstance(classType, [itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, newVariable]);
			newItem.init();
			m_allVariableItems.set(newItem.variableName, newItem);
			m_filteredItems.push(newItem);
			
			//Add the variable to tunables
			Tunables.ALL_VARIABLES.set(newVariable.name, newVariable);
			
			//Redraw the list
			refreshItems();
		}
		else
		{
			Debug.warn("variable is invalid: " + newVariable + "\n Please fix before trying to save.");
		}
	}
	
	/**
	 * Removes a pending NewTunableItem
	 * @param	item
	 */
	public function removeNewTunable(item:NewTunableItem):Void
	{
		removeItem(item);
		
		if (curPage >= pageCount)
		{
			curPage = pageCount - 1;
		}		
		
		refreshItems();
	}
	
	/**
	 * Updates the filter
	 * @param	e
	 */
	public function updateFilter(newFilter:TunablesVariable):Void
	{
		if (filterChanged(newFilter))
		{
			m_filter = newFilter;
			
			m_filteredItems = [];
			for (item in m_allVariableItems)
			{
				if (item.itemPassesFilter(m_filter))
				{
					m_filteredItems.push(item);
				}
			}
			
			curPage = 0;
			
			refreshItems();
		}
	}
	
	/**
	 * Updates the page
	 * @param	e
	 */
	private function onPagingEvent(e:PagingEvent):Void
	{
		m_pagingWidget.curPage = curPage = e.page;
	}
	
	/**
	 * Handles keyboard presses.
	 * @param	e
	 */
	private function onKeyDown(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.ESCAPE)
		{
			toggleShow();
		}
		else if (e.keyCode == Keyboard.BACKQUOTE)
		{
			saveValues();
		}
		else if (e.keyCode == Keyboard.ENTER)
		{
			if (stage != null)
			{
				stage.focus = this;
			}
		}
	}
	
	/**
	 * Saves the values out to the Tunables.json file
	 */
	private function saveValues():Void
	{
		stage.focus = this;
		
		var tags:Array<String> = [];
		for (tag in Tunables.ALL_TAGS.keys())
		{
			tags.push(tag);
		}

		var variables:Array<TunablesVariable> = [];
		var savedVariableNames:StringMap<TunablesVariable> = new StringMap<TunablesVariable>();
		for (item in m_allVariableItems)
		{
			if (Std.is(item, NewTunableItem))
			{
				var itemName:String = item.variableName;
				Debug.warn('$itemName not saved, need to press add button first.');
				continue;
			}
			
			var nextObject:TunablesVariable = item.getSerializableObject();
			if (nextObject == null)
			{
				var itemName:String = item.variableName;
				Debug.warn('$itemName failed to return a serialized object...');
				continue;
			}
			
			if (nextObject.tags.indexOf(TunableDefs.DELETION_TAG) != -1)
			{
				Debug.log(nextObject.name + " was marked for deletion. Not saving...");
				continue;
			}
			
			if (!Tunables.validateTunableVariable(nextObject, savedVariableNames))
			{
				Debug.warn("couldn't save, invalid variable: " + nextObject);
				continue;
			}
			
			//Success! Save the variable...
			variables.push(nextObject);
			savedVariableNames.set(nextObject.name, nextObject);
		}
		
		var toSaveStruct:TunablesFile = 
		{
			Tags: tags,
			Variables: variables
		};
		
		var toSaveString:String = Json.stringify(toSaveStruct, "   ");
		
		#if js
			var dataStr:String = "data:text/json;charset=utf-8," + StringTools.urlEncode(toSaveString);
			var tempAnchor:AnchorElement = cast Browser.document.createAnchorElement();
			
			tempAnchor.download = 'Tunables.json';
			tempAnchor.href = dataStr;
			
			Browser.document.body.appendChild(tempAnchor);
			tempAnchor.click();
		#else
		Debug.warn("NOT IMPLEMENTED YET: PLEASE WRITE THE SAVE FUNCTION FOR YOUR PLATFORM");
		//TODO: we actually have file system, should be easier...
		#end
	}
	
	/**
	 * UI Parameters have changed, redraw items.
	 * @param	e
	 */
	private function onUIRefresh(e:RefreshUIEvent):Void
	{
		//Refresh UI
		for (list in getItemLists())
		{
			for ( item in list)
			{
				item.onRefreshUI(e);
			}
		}
		
		//TODO: We should really not have to do this.
		//Items not currently visible should really just be data and not have UI.
		//Need to break this out into a model and view.
		//Refresh all variable items
		for (item in m_allVariableItems)
		{
			item.onRefreshUI(e);
		}
		
		//Do standard item updating
		refreshItems();
	}
	
	//==================================================================
	// Helper Functions
	//==================================================================
	
	/**
	 * Validates if the name of a new item is already taken.
	 * @param	varName
	 * @return
	 */
	public function validateNewItemName(varName:String):Bool
	{
		//See if any of the items have a matching name
		return !m_allVariableItems.exists(varName);
	}
	
	/**
	 * Gets the next legal name, that isn't a duplicate of any existing item.
	 * @param	varName
	 * @return
	 */
	public function getNextAvailableVariableName(varName:String):String
	{
		var baseName:String = varName;
		
		var returnName:String = baseName;
		var suffixIdx:Int = 1;
		while (!validateNewItemName(returnName))
		{
			returnName = baseName + "_" + suffixIdx;
			++suffixIdx;
		}
		
		return returnName;
	}
	
	/**
	 * Tunable item name changed. Update the map!
	 * @param	newFilter
	 * @param 	oldName
	 * @param 	newName
	 * @return
	 */
	public function itemNameChanged(item:NewTunableItem, oldName:String, newName:String):Void
	{
		if (item == null)
		{
			return;
		}
		
		m_allVariableItems.remove(oldName);
		m_allVariableItems.set(newName, item);
	}
	
	/**
	 * Returns whether the provided filter is different from the current one.
	 * @param	newFilter
	 * @return
	 */
	private function filterChanged(newFilter:TunablesVariable):Bool
	{
		if (m_filter.name != newFilter.name)
		{
			return true;
		}
		
		if (m_filter.type != newFilter.type)
		{
			return true;
		}
		
		if ((m_filter.value.length != newFilter.value.length) 
			|| m_filter.value != newFilter.value)
		{
			return true;
		}
		
		if (m_filter.tags.toString() != newFilter.tags.toString())
		{
			return true;
		}
		
		return false;
	}
	
	/**
	 * Creates and returns the tunable item for the provided tunable variable
	 * @param	variable
	 * @param	startWidth
	 * @param	startHeight
	 * @param	evTarget (optional)
	 * @return
	 */
	private static function createItemForVariable(variable:TunablesVariable, startWidth:Float, startHeight:Float):TunableItem
	{
		var classType:Class<Dynamic> = TunableItemMap.get(variable.type);
		if (classType == null)
		{
			Debug.warn("no TunableItem entry for: " + variable.type);
			return null;
		}
		
		//Try to get correct value
		
		
		var newItem:TunableItem = Type.createInstance(classType, [startWidth, startHeight, variable]);
		if (!newItem.validateFieldValue(variable.value))
		{
			Debug.warn("Value is invalid for: " + variable);
			newItem.release();
			return null;
		}
		
		return newItem;
	}
}
#end
