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
package com.firstplayable.hxlib.debug.menuEdit;
import com.firstplayable.hxlib.debug.events.MenuLoadedEvent;
import com.firstplayable.hxlib.debug.events.ShowMenuEvent;
import com.firstplayable.hxlib.debug.tunables.Tunables;
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
import com.firstplayable.hxlib.events.PagingEvent;
import com.firstplayable.hxlib.debug.menuEdit.Menus;
import com.firstplayable.hxlib.debug.menuEdit.menuEditItems.MenuEditItem;
import com.firstplayable.hxlib.debug.menuEdit.menuEditItems.MenuEditItemColumnLabels;
import com.firstplayable.hxlib.debug.menuEdit.menuEditItems.SearchMenuEditItem;
import haxe.ds.StringMap;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;

/**
 * Creates a menu that displays all paist menus the game knows about,
 * and lets you pick between them.
 */
class MenuViewer extends Sprite
{	
	public static var MENU_WIDTH(get, null):Float;
	public static function get_MENU_WIDTH():Float
	{
		return Tunables.getFloatField("MENU_VIEWER_WIDTH", 640);
	}
	
	public static var MENU_HEIGHT(get, null):Float;
	public static function get_MENU_HEIGHT():Float
	{
		return Tunables.getFloatField("MENU_VIEWER_HEIGHT", 480);
	}
	
	public static var BOTTOM_BAR_HEIGHT(get, null):Float;
	public static function get_BOTTOM_BAR_HEIGHT():Float
	{
		return UIDefs.TUNABLES_UI_ITEM_SIZE * UIDefs.TUNABLES_UI_BOTTOM_BAR_SIZE;
	}
	
	//==================================================================
	// GUI Items
	//==================================================================
	
	//Map of all variable items
	private var m_allMenuItems:StringMap<MenuEditItem>;
	private var m_filteredItems:Array<MenuEditItem>;
	
	//Items on display
	private var m_headerItems:List<MenuEditItem>;
	private var m_menuItems:List<MenuEditItem>;
	private var m_footerItems:List<MenuEditItem>;
	
	//Header Widgets
	private var m_infoButton:Sprite;
	
	//Footer Widgets
	private var m_pagingWidget:TunablePagingWidget;
	
	//==================================================================
	// GUI Properties
	//==================================================================
	
	private static inline var INFO_BUTTON_URL:String = "https://wiki.1stplayable.com/index.php/Web/Haxe/Menu_Viewer";
	
	private var m_startWidth:Float;
	private var m_startHeight:Float;
	
	private var m_init:Bool = false;
	private var m_showing:Bool = false;
	
	private var itemWidth(get, null):Float;
	
	//==================================================================
	// Model Properties
	//==================================================================
	
	public static var NUM_ITEMS_PER_PAGE:Int = 20;
	
	private var m_filter:MenuData;
	
	private var m_curPage:Int;
	private var curPage(get, set):Int;
	private var pageCount(get, null):Int;
	
	/**
	 * Constructs a TunablesMenu with the provided width and height.
	 * @param	startWidth
	 * @param	startHeight
	 */
	public function new() 
	{
		super();
		
		//Filter is empty at start
		m_filter =
		{
			name:"",
			menu:null,
			status:NO_STATUS,
			loadedExternally:false,
			visible:UNSET
		};
		
		m_curPage = 0;
		
		m_startWidth = MENU_WIDTH;
		m_startHeight = MENU_HEIGHT;
		
		//=======================================================
		// Create the items
		//=======================================================
		
		//==============================================
		//Create the Header
		//==============================================
		m_headerItems = new List<MenuEditItem>();
		
		var headerColumns:Map<MenuItemFields, String> = [
			NAME_FIELD 		=> "Menu Names: ",
			STATUS_FIELD 	=> "Load Status: ",
			VISIBLE_FIELD 	=> "Visbility"
		];
		
		var columnsItem:MenuEditItemColumnLabels = 
			new MenuEditItemColumnLabels(itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, headerColumns);
		m_headerItems.add(columnsItem);
		
		//==============================================
		//Create the Cheat Items representing cheats
		//==============================================
		
		m_allMenuItems = new StringMap<MenuEditItem>();
		m_filteredItems = [];
		m_menuItems = new List<MenuEditItem>();
		
		//construct the items
		for (menu in Menus.getMenuNames())
		{
			var nextItem:MenuEditItem = createItemForMenu(Menus.getMenuData(menu), itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE);
			if (nextItem != null)
			{
				m_filteredItems.push(nextItem);
				m_allMenuItems.set(menu, nextItem);
			}
		}
		
		//==============================================
		//Create the Footer
		//==============================================
		
		m_footerItems = new List<MenuEditItem>();
		
		//construct the search header item		
		var filterColumnNames:Map<MenuItemFields, String> = [
			NAME_FIELD 		=> "SEARCH:\t"+ String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tMenu Name",
			STATUS_FIELD 	=> String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tLoad Status",
			VISIBLE_FIELD 	=> String.fromCharCode(UIDefs.TUNABLES_UI_BTN_SEARCH_SYMBOL) + "\tVisibility",
		];
		
		var filterColumnsItem:MenuEditItemColumnLabels 
			= new MenuEditItemColumnLabels(itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, filterColumnNames);
		m_footerItems.add(filterColumnsItem);
		
		//construct the search item
		var defaultSearchFilter:MenuData = {
			name:m_filter.name,
			menu:m_filter.menu,
			status:m_filter.status,
			loadedExternally:m_filter.loadedExternally,
			visible:m_filter.visible
		}
		
		var searchItem:SearchMenuEditItem = new SearchMenuEditItem(this, itemWidth, UIDefs.TUNABLES_UI_ITEM_SIZE, defaultSearchFilter);
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
		Lib.current.stage.doubleClickEnabled = true;
		Lib.current.stage.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		DebugDefs.debugEventTarget.addEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onUIRefresh);
		DebugDefs.debugEventTarget.addEventListener(ShowMenuEvent.SHOW_MENU, onShowMenu);
		DebugDefs.debugEventTarget.addEventListener(MenuLoadedEvent.MENU_LOADED, onLoadMenu);
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
		
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
		DebugDefs.debugEventTarget.removeEventListener(MenuLoadedEvent.MENU_LOADED, onLoadMenu);
		DebugDefs.debugEventTarget.removeEventListener(ShowMenuEvent.SHOW_MENU, onShowMenu);
		DebugDefs.debugEventTarget.removeEventListener(RefreshUIEvent.REFRESH_UI_EVENT, onUIRefresh);
		
		var itemLists:Array<List<MenuEditItem>> = getItemLists();
		for (list in itemLists)
		{
			for (item in list)
			{
				removeItem(item);
			}
			list.clear();
		}
		m_filteredItems = [];
		m_headerItems = null;
		m_footerItems = null;
		
		for (item in m_allMenuItems)
		{
			item.release();
		}
		m_allMenuItems = null;
		
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
	 * Gets a list of all menu items that should be visible on the menu
	 * @return
	 */
	private function getItemLists():Array<List<MenuEditItem>>
	{
		return [m_headerItems, m_menuItems, m_footerItems];
	}
	
	/**
	 * Redraw all the menu items based on the current m_items list
	 */
	private function refreshItems():Void
	{
		var itemLists:Array<List<MenuEditItem>> = getItemLists();
		
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
		m_menuItems.clear();
		
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
			
			var item:MenuEditItem = m_filteredItems[i];
			addChild(item);
			if (!item.m_inited)
			{
				item.init();
			}
			
			m_menuItems.add(item);
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
		var itemLists:Array<List<MenuEditItem>> = getItemLists();
		
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
					var numPaddingItems:Int = NUM_ITEMS_PER_PAGE - m_menuItems.length;
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
		var firstItem:MenuEditItem = m_headerItems.first();
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
	private function removeItem(item:MenuEditItem):Void
	{
		if (item == null)
		{
			Debug.warn("Can't remove null item");
			return;
		}
		
		if (m_allMenuItems.exists(item.menuName))
		{
			m_allMenuItems.remove(item.menuName);
		}
		//Removal is almost always from near the end of the list
		//so this should be relatively fast.
		m_filteredItems.remove(item);
		m_menuItems.remove(item);
		m_headerItems.remove(item);
		m_footerItems.remove(item);
		
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
	public function updateFilter(newFilter:MenuData):Void
	{
		if (filterChanged(newFilter))
		{			
			//Copy all field values from the filter.
			for (field in Reflect.fields(newFilter))
			{
				var fieldVal:Dynamic = Reflect.field(newFilter, field);
				Reflect.setField(m_filter, field, fieldVal);
			}
			
			filterAllItems();
		}
	}
	
	/**
	 * Filters items based on current filter.
	 */
	private function filterAllItems():Void
	{
		m_filteredItems = [];
		for (item in m_allMenuItems)
		{
			if (item.itemPassesFilter(m_filter))
			{
				m_filteredItems.push(item);
			}
		}
		
		curPage = 0;
		
		refreshItems();
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
	 * Handles doubleClick
	 * @param	e
	 */
	private function onDoubleClick(e:MouseEvent):Void
	{
		toggleShow();
	}
	
	/**
	 * Handles keyboard presses.
	 * @param	e
	 */
	private function onKeyDown(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.M)
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
		for (item in m_allMenuItems)
		{
			item.onRefreshUI(e);
		}
		
		//Do standard item updating
		refreshItems();
	}
	
	/**
	 * When a visibility status changes, we need to make sure
	 * that the proper items are still visible
	 * @param	e
	 */
	private function onShowMenu(e:ShowMenuEvent):Void
	{
		if (m_filter.visible != UNSET)
		{
			filterAllItems();
		}
	}
	
	/**
	 * When a loaded status changes, we need to make sure
	 * that the proper items are still visible
	 * @param	e
	 */
	private function onLoadMenu(e:MenuLoadedEvent):Void
	{
		if (m_filter.status != NO_STATUS)
		{
			filterAllItems();
		}
		
		for (item in m_allMenuItems)
		{
			item.onMenuLoaded(e);
		}
	}
	
	//==================================================================
	// Helper Functions
	//==================================================================
	
	/**
	 * Returns whether the provided filter is different from the current one.
	 * @param	newFilter
	 * @return
	 */
	private function filterChanged(newFilter:MenuData):Bool
	{
		if (m_filter.name != newFilter.name)
		{
			return true;
		}
		
		if (m_filter.status != newFilter.status)
		{
			return true;
		}
		
		if (m_filter.visible != newFilter.visible)
		{
			return true;
		}
		
		return false;
	}

	/**
	 * Creates a menu item with the provided info.
	 * TODO: may want different cheat item types later.
	 * @param	menu
	 * @param	startWidth
	 * @param	startHeight
	 * @return
	 */
	private static function createItemForMenu(menu:MenuData, startWidth:Float, startHeight:Float):MenuEditItem
	{
		var newItem:MenuEditItem = new MenuEditItem(startWidth, startHeight, menu);		
		return newItem;
	}
}
#end
