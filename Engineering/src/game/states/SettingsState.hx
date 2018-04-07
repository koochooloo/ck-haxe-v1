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
import game.ui.SettingsMenu;


class SettingsState extends SpeckBaseState
{
	private var m_menu:SettingsMenu;
	
	public function new() 
	{
		super( GameState.SETTINGS );
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		super.enter(p);
		
		if ( m_menu == null )
		{
			m_menu = new SettingsMenu();
		}
		
		GameDisplay.attach( LayerName.PRIMARY, m_menu );
		SpeckGlobals.hud.enable( HudMode.FULL );
		SpeckGlobals.saveProfile.saveGameStateEntry( m_menu.menuName );
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
