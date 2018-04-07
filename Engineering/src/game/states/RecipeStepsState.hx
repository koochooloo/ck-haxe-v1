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
import game.ui.states.RecipeStepsMenu;
import game.ui.load.SpeckLoader;

class RecipeStepsState extends SpeckBaseState
{
	public function new() 
	{
		super( GameState.RECIPESTEPS );
	}
	
	override public function enter( p:GameStateParams )
	{
		m_assets = SpeckLoader.recipeStepsAssets;
		super.enter( p );
	}
	
	override public function initMenu():Void
	{
		if ( m_menu == null )
		{
			m_menu = new RecipeStepsMenu({args:[]}); // TODO - remove args
		}

		SpeckGlobals.hud.enable( HudMode.GAMEPLAY );

	}
}