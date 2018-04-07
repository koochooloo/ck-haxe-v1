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
import game.controllers.FlowController;
import game.def.GameState;
import game.ui.HudMenu;
import game.ui.HudMenu.HudMode;
import game.ui.states.RecipesMenu;
import assets.SoundLib;
import com.firstplayable.hxlib.audio.WebAudio;


class RecipesState extends SpeckBaseState
{	
	public function new() 
	{
		super( GameState.RECIPES );
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		super.enter(p);
	}
	
	override public function getRegisteredAudio()
	{
		if ( m_params != null && m_params.args[1] != null ) 
		{	
			// If this menu was passed params (AKA came from countrymenu) 
			// Load & Play country music

			var country:Country = FlowController.data.selectedCountry;
			m_bgmURL = "Music/" + country.code + "_music";
			WebAudio.instance.register( "snd/" + m_bgmURL + ".ogg", m_bgmURL);
			m_registeredAudio.push( m_bgmURL );
		}
		else 
		{
			// If we didn't come from the country menu, we're not changing the music.
			// Make sure we play global music
			if ( SpeckGlobals.BgmID != "Music/GLOBAL_music" )
			{
				WebAudio.instance.unload( [SpeckGlobals.BgmID] );
				SpeckGlobals.BgmID = "Music/GLOBAL_music"; 
				WebAudio.instance.playBGM( SpeckGlobals.BgmID, false );
			}
		}
	}
	
	override public function initMenu()
	{
		if ( m_menu == null )
		{
			m_menu = new RecipesMenu(m_params);
		}
		SpeckGlobals.hud.enable( HudMode.RECIPES );
	}
}
