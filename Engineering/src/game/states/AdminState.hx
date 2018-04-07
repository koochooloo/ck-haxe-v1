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

package game.states;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.loader.ResMan;
import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.def.GameState;
import game.ui.HudMenu.HudMode;
import game.ui.load.SpeckLoader;
import game.ui.states.AdminMenu;

#if js
import js.html.Element;
import js.Browser;
#end

class AdminState extends SpeckBaseState
{
	public function new() 
	{
		super( GameState.ADMIN );
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		m_assets = SpeckLoader.loginAssets;
		
		super.enter(p);
	}

	override public function initMenu():Void
	{
		if ( m_menu == null )
		{
			m_menu = new AdminMenu();
		}
		
		#if js 
		var element:Element = Browser.window.document.getElementById('bg');
		if (element != null)
		{
			element.hidden = true;
		}
		#end
	}
}
