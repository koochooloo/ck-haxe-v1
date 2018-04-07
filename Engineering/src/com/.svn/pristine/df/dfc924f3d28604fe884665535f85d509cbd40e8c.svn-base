//
// Copyright (C) 2016, 1st Playable Productions, LLC. All rights reserved.
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
import com.firstplayable.hxlib.debug.events.MenuUpdatedEvent;

import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GenericMenu;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.BaseGameState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;

/**
 * A State that holds tools for previewing and editing paist menus.
 */
class MenuEditState extends BaseGameState
{	
	var m_menuViewer:MenuViewer;
	
	public function new(gameState:EnumValue) 
	{
		super( gameState );
	}
	
	override public function init():Void 
	{
		super.init();
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		super.enter(p);
		
		MenuUpdateClient.connect();
		MenuUpdateClient.addEventListenerToActiveClient(MenuUpdatedEvent.MENU_UPDATED_EVENT, onMenuUpdated);
		
		if (Menus.ALL_LAYOUTS == null)
		{
			Debug.warn("no menu list!");
		}
		for (layout in Menus.ALL_LAYOUTS)
		{
			Menus.registerMenu(layout);
		}
		
		//Inits the menu, then shows it
		m_menuViewer = new MenuViewer();
		m_menuViewer.x = 0;
		m_menuViewer.y = 0;
		m_menuViewer.show();
	}
	
	override public function exit():Void 
	{
		MenuUpdateClient.removeEventListenerFromActiveClient(MenuUpdatedEvent.MENU_UPDATED_EVENT, onMenuUpdated);
		MenuUpdateClient.close();
		
		m_menuViewer.show(false);
		m_menuViewer.release();
		m_menuViewer = null;
		
		for (layout in Menus.ALL_LAYOUTS)
		{
			Menus.unregisterMenu(layout);
		}
		
		super.exit();
	}
	
	/**
	 * Handles a menu being updated.
	 * @param	e
	 */
	private function onMenuUpdated(e:MenuUpdatedEvent):Void
	{
		if (!Menus.menuExists(e.m_layout))
		{
			Debug.log("menu updated that Menus doesn't know about: " + e.m_layout);
			return;
		}
		
		var shouldReshowMenu:Bool = Menus.getMenuVisible(e.m_layout);
		
		Menus.unloadMenu(e.m_layout);
		
		var paistMenuFileURL:String = ResMan.instance.getPaistFileByName(e.m_layout);
		
		var menuResource:ResContext = {
			src:paistMenuFileURL,
			content:e.m_data
		};
		
		ResMan.instance.updateRes(e.m_layout, menuResource);
		
		if (shouldReshowMenu)
		{
			Menus.showMenu(e.m_layout);
		}
	}
}
#end
