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
package com.firstplayable.hxlib.debug.cheats;
import com.firstplayable.hxlib.debug.tunables.ui.SaveButton;
import com.firstplayable.hxlib.debug.events.RefreshUIEvent;
import com.firstplayable.hxlib.debug.tunables.ui.UIDefs;
import openfl.net.URLRequest;
import openfl.Lib;
import com.firstplayable.hxlib.debug.tunables.ui.InfoButton;
import com.firstplayable.hxlib.debug.tunables.ui.TunablePagingWidget;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.debug.cheats.Cheats;
import com.firstplayable.hxlib.events.PagingEvent;
import com.firstplayable.hxlib.debug.cheats.cheatItems.SearchCheatItem;
import com.firstplayable.hxlib.debug.cheats.cheatItems.CheatItem;
import com.firstplayable.hxlib.debug.cheats.cheatItems.CheatItemColumnLabels;
import haxe.ds.StringMap;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;

/**
 * Creates a debug menu for cheats registered to Cheats.hx
 * Like the tunable menu, they can be paged through, and searched on.
 * The function they represent will be called everytime they're clicked.
 */

class CheatsMenu extends Sprite
{	
	public static var BOTTOM_BAR_HEIGHT(get, null):Float;
	public static function get_BOTTOM_BAR_HEIGHT():Float
	{
		return UIDefs.TUNABLES_UI_ITEM_SIZE * UIDefs.TUNABLES_UI_BOTTOM_BAR_SIZE;
	}
	
	//==================================================================
	// GUI Items
	//==================================================================
	
	//Map of all variable items
	private var m_allCheatItems:StringMap<CheatItem>;
	private var m_filteredItems:Array<CheatItem>;
	
	//Items on display
	private var m_headerItems:List<CheatItem>;
	private var m_cheatItems:List<CheatItem>;
	private var m_footerItems:List<CheatItem>;
	
	//Header Widgets
	private var m_infoButton:Sprite;
	
	//Footer Widgets
	private var m_pagingWidget:TunablePagingWidget;
	
	//==================================================================
	// GUI Properties
	//==================================================================
	
	private static inline var INFO_BUTTON_URL:String = "https://wiki.1stplayable.com/index.php/Web/Haxe/Cheats_Menu";
	
	private var m_startWidth:Float;
	private var m_startHeight:Float;
	
	private var m_init:Bool = false;
	private var m_showing:Bool = false;
	
	private var itemWidth(get, null):Float;
	
	//==================================================================
	// Model Properties
	//==================================================================
	
	public static var NUM_ITEMS_PER_PAGE:Int = 20;
	
	private var m_filter:CheatData;
	
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
		
		//Filter is empty at start
		m_filter =
		{
			name: "",
			tags: [],
			func: null
		};
		
		m_curPage = 0;
		
		m_startWidth = startWidth;
		m_startHeight = startHeight;
		
		//=======================================================
		// Create the items
		//=======================================================
		
		//==============================================
		//Create the Header
		//==============================================
		m_headerItems = new List<CheatItem>();
		
		//construct the header item
		var headerColumns:CheatData = 
		{
			name: "Cheat Names: ",
			tags: ["Tags"],
			func: null
		};
		
		var columnsItem:CheatItemColumnLabels = new CheatItemColumnLabels(itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, headerColumns);
		m_headerItems.add(columnsItem);
		
		//==============================================
		//Create the Cheat Items representing cheats
		//==============================================
		
		m_allCheatItems = new StringMap<CheatItem>();
		m_filteredItems = [];
		m_cheatItems = new List<CheatItem>();
		
		//construct the items
		for (cheat in Cheats.getCheatNames())
		{
			var nextItem:CheatItem = createItemForCheat(Cheats.getCheat(cheat), itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE);
			if (nextItem != null)
			{
				m_filteredItems.push(nextItem);
				m_allCheatItems.set(cheat, nextItem);
			}
		}
		
		//==============================================
		//Create the Footer
		//==============================================
		
		m_footerItems = new List<CheatItem>();
		
		//construct the search header item
		var filterColumnNames:CheatData = 
		{
			name: "SEARCH:\t"+ String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tCheat Name",
			tags: [(String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tTags")],
			func: null
		};
		
		var filterColumnsItem:CheatItemColumnLabels = new CheatItemColumnLabels(itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, filterColumnNames);
		m_footerItems.add(filterColumnsItem);
		
		//construct the search item
		var searchDefaultValues:CheatData =
		{
			name: 	"",
			tags:	[],
			func:   null
		};
		var searchItem:SearchCheatItem = new SearchCheatItem(this, itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, searchDefaultValues);
		m_footerItems.add(searchItem);
		
		m_infoButton = null;
		
		m_pagingWidget = null;
		
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
		
		//init the paging widget
		m_pagingWidget = new TunablePagingWidget(itemWidth, BOTTOM_BAR_HEIGHT);
		addChild(m_pagingWidget);
		m_pagingWidget.init();
		m_pagingWidget.curPage = curPage;
		m_pagingWidget.pageCount = pageCount;
		
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
		m_pagingWidget.removeEventListener(PagingEvent.PAGING_EVENT, onPagingEvent);
		m_infoButton.removeEventListener(MouseEvent.CLICK, onClickedInfo);
		DebugDefs.debugEventTarget.removeEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onUIRefresh);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		var itemLists:Array<List<CheatItem>> = getItemLists();
		for (list in itemLists)
		{
			for (item in list)
			{
				removeItem(item);
			}
			list.clear();
		}
		m_filteredItems = [];
		m_allCheatItems = null;
		m_headerItems = null;
		m_footerItems = null;

		for (item in m_allCheatItems)
		{
			item.release();
		}
		m_allCheatItems = null;
		
		m_curPage = 0;
		
		removeChild(m_infoButton);
		m_infoButton = null;
		
		m_pagingWidget.release();
		removeChild(m_pagingWidget);
		m_pagingWidget = null;
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
	private function getItemLists():Array<List<CheatItem>>
	{
		return [m_headerItems, m_cheatItems, m_footerItems];
	}
	
	/**
	 * Redraw all the tunable items based on the current m_items list
	 */
	private function refreshItems():Void
	{
		var itemLists:Array<List<CheatItem>> = getItemLists();
		
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
		m_cheatItems.clear();
		
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
			
			var item:CheatItem = m_filteredItems[i];
			addChild(item);
			if (!item.m_inited)
			{
				item.init();
			}
			
			m_cheatItems.add(item);
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
		var itemLists:Array<List<CheatItem>> = getItemLists();
		
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
					var numPaddingItems:Int = NUM_ITEMS_PER_PAGE - m_cheatItems.length;
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
		var firstItem:CheatItem = m_headerItems.first();
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
	private function removeItem(item:CheatItem):Void
	{
		if (item == null)
		{
			Debug.warn("Can't remove null item");
			return;
		}
		
		if (m_allCheatItems.exists(item.cheatName))
		{
			m_allCheatItems.remove(item.cheatName);
		}
		//Removal is almost always from near the end of the list
		//so this should be relatively fast.
		m_filteredItems.remove(item);
		m_cheatItems.remove(item);
		
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
	 * Updates the filter
	 * @param	e
	 */
	public function updateFilter(newFilter:CheatData):Void
	{
		if (filterChanged(newFilter))
		{
			m_filter = newFilter;
			
			m_filteredItems = [];
			for (item in m_allCheatItems)
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
		if (e.keyCode == Keyboard.PAGE_UP)
		{
			toggleShow();
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
		for (item in m_allCheatItems)
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
	 * Returns whether the provided filter is different from the current one.
	 * @param	newFilter
	 * @return
	 */
	private function filterChanged(newFilter:CheatData):Bool
	{
		if (m_filter.name != newFilter.name)
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
	 * Creates a cheat item with the provided info.
	 * TODO: may want different cheat item types later.
	 * @param	cheat
	 * @param	startWidth
	 * @param	startHeight
	 * @return
	 */
	private static function createItemForCheat(cheat:CheatData, startWidth:Float, startHeight:Float):CheatItem
	{
		var newItem:CheatItem = new CheatItem(startWidth, startHeight, cheat);		
		return newItem;
	}
}
#end
