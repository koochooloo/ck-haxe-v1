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
import game.ui.states.RecipeServingMenu;
import com.firstplayable.hxlib.audio.WebAudio;


class RecipeServingState extends SpeckBaseState
{
	private var m_countryCode:String;
	
	public function new() 
	{
		super( GameState.RECIPESERVING );
	}
	
	override public function enter( p:GameStateParams )
	{
		m_assets = SpeckLoader.recipeServingAssets;
		super.enter( p );
	}
	
	override public function initMenu()
	{
		if ( m_menu == null )
		{
			m_menu = new RecipeServingMenu( m_params );
		}
		SpeckGlobals.hud.enable( HudMode.GAMEPLAY );
	}
	
	override public function getRegisteredAudio()
	{
		var selectedCountry:Country = FlowController.data.selectedCountry;
		m_countryCode = selectedCountry.code;
		
		var soundID:String = "SFX/Enjoy/" + m_countryCode + "_EnjoyMeal";
		
		if (Tunables.USE_DATABASE_RESOURCES)
		{
			if (selectedCountry.mealAudio != null)
			{
				WebAudio.instance.register( selectedCountry.mealAudio, soundID);
				m_registeredAudio.push( soundID );
			}
		}
		else
		{
			WebAudio.instance.register( "snd/" + soundID + ".ogg", soundID );
			m_registeredAudio.push( soundID );
		}
	}
	
	override public function exit():Void 
	{
		super.exit();

		// Unload VO
		var soundURL:String = "SFX/Hello/" + m_countryCode + "_Hello";
		WebAudio.instance.unload( [soundURL] );
	}
}
