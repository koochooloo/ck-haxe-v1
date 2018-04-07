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
import com.firstplayable.hxlib.debug.events.ShowMenuEvent;
import com.firstplayable.hxlib.debug.events.MenuLoadedEvent;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.display.GameDisplay;
import openfl.display.DisplayObject;
import openfl.text.TextField;
import openfl.display.DisplayObjectContainer;
import com.firstplayable.hxlib.display.anim.SpritesheetAnim;
import com.firstplayable.hxlib.display.OPSprite;
import haxe.ds.StringMap;

enum MenuLoadingStatus
{
	UNLOADED;
	LOADING;
	LOADED;
	NO_STATUS;
}

enum MenuVisibility
{
	HIDDEN;
	SHOWN;
	UNSET;
}

/**
 * A struct representing a given menu.
 */
typedef MenuData = 
{
	name:String,
	menu:EditableMenu,
	status:MenuLoadingStatus,
	loadedExternally:Bool,
	visible:MenuVisibility
}

/**
 * Collection of data about Editable menus made for each of the json menu files.
 */
@:build(com.firstplayable.hxlib.debug.menuEdit.BuildMenus.build())
class Menus
{
	public static var ms_paistObjectTypes:Array<Dynamic> = [
		OPSprite,
		SpritesheetAnim,
		DisplayObjectContainer,
		TextField
	];
	
	/**
	 * Returns whether the provided DisplayObject is a type that is handled
	 * by paist, and it so, the class name. Null on failure
	 * @param	var
	 * @return
	 */
	public static function getPaistObjectTypeName(object:DisplayObject):String
	{
		if (object == null)
		{
			return null;
		}
		
		for (type in ms_paistObjectTypes)
		{
			if (Std.is(object, type))
			{
				return Type.getClassName(type);
			}
		}
		
		return null;
	}
	
	/**
	 * Returns if the provided DisplayObject is a type handled by paist.
	 * @param	object
	 * @return
	 */
	public static function isPaistObject(object:DisplayObject):Bool
	{
		var paistObjectTypeName:String = getPaistObjectTypeName(object);
		if ((paistObjectTypeName == null) || (paistObjectTypeName == ""))
		{
			return false;
		}
		
		return true;
	}
	
	/**
	 * Table of all data about menus
	 */
	private static var ms_menuTable:StringMap<MenuData> = new StringMap<MenuData>();
	
	/**
	 * Gets the names of all known menus
	 * @return
	 */
	public static function getMenuNames():Iterator<String>
	{
		return ms_menuTable.keys();
	}
	
	/**
	 * Returns whether a menu of the specified name exists
	 * @param	cheatName
	 * @return
	 */
	public static function menuExists(menuName:String):Bool
	{
		return ms_menuTable.exists(menuName);
	}
	
	/**
	 * Gets the cheat with the given name, returning null if it doesn't exist.
	 * @param	cheatName
	 */
	public static function getMenuData(menuName:String):MenuData
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return null;
		}
		
		return ms_menuTable.get(menuName);
	}
	
	/**
	 * Returns whether the menu with the provided name has been
	 * constructed.
	 * @param	menuName
	 * @return
	 */
	public static function getMenuConstructed(menuName:String):Null<Bool>
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return null;
		}
		
		var menuData:MenuData = getMenuData(menuName);
		return (menuData.menu != null);
	}
	
	/**
	 * Deconstructs menu with provided name.
	 * @param	menuName
	 */
	public static function deconstructMenu(menuName:String):Void
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return;
		}
		
		if (!getMenuConstructed(menuName))
		{
			Debug.log("menu " + menuName + " already unconstructed!");
			return;
		}
		
		var menuData:MenuData = getMenuData(menuName);
		var menu:EditableMenu = menuData.menu;
		
		//Hide the menu
		GameDisplay.remove( LayerName.PRIMARY, menu );
		menuData.visible = HIDDEN;
		DebugDefs.debugEventTarget.dispatchEvent(new ShowMenuEvent(menuName, false));
		
		//Deconstruct
		menu.release();
		menuData.menu = null;
	}
	
	/**
	 * Returns whether the menu with the provided name has been loaded.
	 * @param	menuName
	 * @return
	 */
	public static function getMenuLoaded(menuName:String):Bool
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return false;
		}
		
		var menuData:MenuData = getMenuData(menuName);
		return menuData.status == LOADED;
	}
	
	/**
	 * Unloads menu with the provided name.
	 * If already constructed will deconstruct it first.
	 * @param	menuName
	 */
	public static function unloadMenu(menuName:String):Void
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return;
		}
		
		if (!getMenuLoaded(menuName))
		{
			Debug.log("menu " + menuName + " already not loaded!");
			return;
		}
		
		var menuData:MenuData = getMenuData(menuName);
		
		//Desconstruct menu first if it is constructed.
		if (getMenuConstructed(menuName))
		{
			deconstructMenu(menuName);
		}
		
		//Unload menu
		// TODO: This clears the baked JSON making it impossible to return
		// on most games.
		// It is safe on the smokescreen architecture.
		//ResMan.instance.unload(menuName);
		menuData.status = UNLOADED;	
		menuData.menu = null;
		
		DebugDefs.debugEventTarget.dispatchEvent(new MenuLoadedEvent(menuName, UNLOADED));
	}
	
	/**
	 * Returns whether the menu with the provided name is visible or not
	 * @param	menuName
	 * @return
	 */
	public static function getMenuVisible(menuName:String):Bool
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return false;
		}
		
		var menuData:MenuData = getMenuData(menuName);
		
		//Menu hasn't been constructed yet.
		if (menuData.menu == null)
		{
			return false;
		}
		
		return menuData.menu.visible;
	}
	
	/**
	 * Sets the visibility of the menu with the provided name.
	 * If this is the first time showing this menu we will:
	 * Load it if unloaded.
	 * Constructed it if unconstructed.
	 * @param	menuName
	 * @param	visible
	 */
	public static function setMenuVisible(menuName:String, visible:Bool):Void
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return;
		}
		
		if (visible)
		{
			showMenu(menuName);
		}
		else
		{
			hideMenu(menuName);
		}
	}
	
	/**
	 * Hides the menu with the provided name
	 * @param	menuName
	 */
	public static function hideMenu(menuName:String):Void
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return;
		}
		
		if (!getMenuConstructed(menuName))
		{
			return;
		}
		
		//Guaranteed to exist by this point.
		var menuData:MenuData = getMenuData(menuName);
		menuData.menu.visible = false;
		menuData.visible = HIDDEN;
		DebugDefs.debugEventTarget.dispatchEvent(new ShowMenuEvent(menuName, false));
	}
	
	/**
	 * Shows the menu with the provided name,
	 * loading it first if unloaded,
	 * and constructing it.
	 * @param	menuName
	 */
	public static function showMenu(menuName:String):Void
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return;
		}
		
		//Guaranteed to exist by this point.
		var menuData:MenuData = getMenuData(menuName);
		
		switch(menuData.status)
		{
			case UNLOADED:
			{
				menuData.status = LOADING;
				loadMenuOnShow(menuName);
				
				//Loading is asynchronous.
				//Need to return;
				return;
			}
			case LOADING:
			{
				Debug.log("menu " + menuName + " in middle of loading... can't show yet!");
				return;
			}
			case LOADED:
			{
				//If we don't have a menu yet, construct it!
				if (menuData.menu == null)
				{
					menuData.menu = new EditableMenu(menuName);
					GameDisplay.attach(LayerName.PRIMARY, menuData.menu);
				}
				menuData.menu.visible = true;
				menuData.visible = SHOWN;
				
				//Send the shown event once all the state has been updated.
				DebugDefs.debugEventTarget.dispatchEvent(new ShowMenuEvent(menuName, true));
				
				return;
			}
			case NO_STATUS:
			{
				Debug.log("menu " + menuName + " has no loading status! Can't show...");
				return;
			}
		}

	}
	
	/**
	 * Starts loading the menu. If you call this function
	 * you probably should return right afterwards.
	 * @param	menuName
	 */
	private static function loadMenuOnShow(menuName:String):Void
	{
		if (!menuExists(menuName))
		{
			Debug.warn("no menu of name: " + menuName);
			return;
		}
		
		if (ResMan.instance.isLibLoaded(menuName))
		{
			Debug.log("menu is already loaded: " + menuName);
			onLoadedMenuOnShowComplete(menuName);
			return;
		}
		
		//Since loading is asynchronous we need to send this event first so the rest of the
		//UI can lock down appropriate pieces before we kick off the load.
		DebugDefs.debugEventTarget.dispatchEvent(new MenuLoadedEvent(menuName, LOADING));
		ResMan.instance.load(menuName, function(){
			onLoadedMenuOnShowComplete(menuName);
		});
	}
	
	/**
	 * Callback for when a menu has finished loading for show.
	 * @param	menuName
	 */
	private static function onLoadedMenuOnShowComplete(menuName:String):Void
	{
		var menu:MenuData = getMenuData(menuName);
		menu.status = LOADED;
		
		showMenu(menuName);
		//Send an event at the end once all the state has been configured
		DebugDefs.debugEventTarget.dispatchEvent(new MenuLoadedEvent(menuName, LOADED));
	}
	
	/**
	 * Tries to register the menu if the specific name into our table
	 * @param	menuName
	 */
	public static function registerMenu(menuName:String):Void
	{
		if ((menuName == null) || (menuName == ""))
		{
			return;
		}
		
		if (ms_menuTable.exists(menuName))
		{
			Debug.warn("already have menu: " + menuName);
			return;
		}
		
		var initialLoadStatus:MenuLoadingStatus = UNLOADED;
		var loadedAlready:Bool = false;
		if (ResMan.instance.isLibLoaded(menuName))
		{
			initialLoadStatus = LOADED;
			loadedAlready = true;
		}
		
		var newMenu:MenuData = 
		{
			name:menuName,
			menu:null,
			status:initialLoadStatus,
			loadedExternally:(loadedAlready),
			visible:HIDDEN
		};
		ms_menuTable.set(menuName, newMenu);
	}
	
	/**
	 * Deconstructs, Unloads, and unregisters the menu with the provided name.
	 * @param	menuName
	 */
	public static function unregisterMenu(menuName:String):Void
	{
		if ((menuName == null) || (menuName == ""))
		{
			return;
		}
		
		if (!ms_menuTable.exists(menuName))
		{
			Debug.warn("no menu named: " + menuName + " to unregister...");
			return;
		}
		
		//If the menu is currently constructed, get rid of it
		if (getMenuConstructed(menuName))
		{
			deconstructMenu(menuName);
		}
		
		//If the menu was loaded by this class, unload it.
		var menuData:MenuData = getMenuData(menuName);
		if (!menuData.loadedExternally)
		{
			if (getMenuLoaded(menuName))
			{
				unloadMenu(menuName);
			}
		}
		
		menuData.menu = null;
		ms_menuTable.remove(menuName);
	}
	
}
#end
