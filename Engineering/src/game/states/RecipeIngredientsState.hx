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
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.Country;
import game.controllers.FlowController;
import game.def.GameState;
import game.ui.HudMenu.HudMode;
import game.ui.load.SpeckLoader;
import game.ui.states.RecipeIngredientsMenu;
import assets.SoundLib;
import com.firstplayable.hxlib.audio.WebAudio;


class RecipeIngredientsState extends SpeckBaseState
{
	public function new() 
	{
		super( GameState.RECIPEINGREDIENTS );
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		m_assets = SpeckLoader.recipeIngredientAssets;
		
		super.enter(p);
	}
	
	override public function initMenu()
	{
		if ( m_menu == null )
		{
			m_menu = new RecipeIngredientsMenu( m_params );
		}
		SpeckGlobals.hud.enable( HudMode.GAMEPLAY );
	}
	
	override public function getRegisteredAudio()
	{
		// Load & Play country music (if available)
		var selectedCountry:Country = FlowController.data.selectedCountry;
		m_bgmURL = "Music/" + selectedCountry.code + "_music";
		if (Tunables.USE_DATABASE_RESOURCES)
		{
			if (selectedCountry.music != null)
			{
				WebAudio.instance.register( selectedCountry.music, m_bgmURL);
				m_registeredAudio.push( m_bgmURL );
			}
		}
		else
		{
			WebAudio.instance.register( "snd/" + m_bgmURL + ".ogg", m_bgmURL);
			m_registeredAudio.push( m_bgmURL );
		}
	}
}
