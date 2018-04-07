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
import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.def.GameState;
import game.ui.HudMenu.HudMode;
import game.ui.load.SpeckLoader;
import game.ui.states.SupportMenu;


class SupportState extends SpeckBaseState
{
	public function new() 
	{
		super( GameState.SUPPORT );
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		m_assets = SpeckLoader.questionAssets;
		super.enter(p);
	}
	
	override public function initMenu()
	{
		if ( m_menu == null )
		{
			m_menu = new SupportMenu();
		}
		SpeckGlobals.hud.enable( HudMode.SIMPLE );
	}
	
	override public function exit():Void 
	{
		super.exit();

		SpeckGlobals.hud.disable();
		
		//Make sure all of the menus are cleaned up on the way out
		GameDisplay.clearLayer( LayerName.PRIMARY );
		m_menu = null;
	}
}
