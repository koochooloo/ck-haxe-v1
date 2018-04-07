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
import game.ui.states.CountryIntroMenu;
import assets.SoundLib;
import com.firstplayable.hxlib.audio.WebAudio;

using StringTools;

class CountryIntroState extends SpeckBaseState
{
	private var m_countryCode:String;
	
	public function new() 
	{
		super( GameState.COUNTRYINTRO );
	}
	
	override public function enter(p:GameStateParams)
	{
		m_assets = SpeckLoader.countryDisplayAssets;
		super.enter(p);
	}
	
	// Grab and register country music and greeting
	override public function getRegisteredAudio():Void
	{

		var selectedCountry:Country = FlowController.data.selectedCountry;
		m_countryCode = selectedCountry.code;
		m_bgmURL = "Music/" + m_countryCode + "_music";
		
		var helloURL:String = "SFX/Hello/" + m_countryCode + "_Hello";
		
		if (Tunables.USE_DATABASE_RESOURCES)
		{
			if ( SoundLib.SOUNDS.indexOf( m_bgmURL ) >= 0 )
			{
				WebAudio.instance.register( "snd/" + m_bgmURL + ".ogg", m_bgmURL);
				m_registeredAudio.push( m_bgmURL );
			}
			else if (selectedCountry.music != null)
			{
				var sndUrl = selectedCountry.music;
				WebAudio.instance.multiRegister([sndUrl, sndUrl.replace(".ogg", ".mp3")], m_bgmURL);
				m_registeredAudio.push(m_bgmURL);
			}
			
			if (selectedCountry.greetingAudio != null)
			{
				var sndUrl = selectedCountry.greetingAudio;
				WebAudio.instance.multiRegister([sndUrl, sndUrl.replace(".ogg", ".mp3")], helloURL);
				m_registeredAudio.push(helloURL);
			}
		}
		else
		{	
			WebAudio.instance.register( "snd/" + m_bgmURL + ".ogg", m_bgmURL);
			m_registeredAudio.push(m_bgmURL);
			WebAudio.instance.register( "snd/" + helloURL + ".ogg", helloURL );
			m_registeredAudio.push(helloURL);
		}
	}
	
	override public function initMenu()
	{
		if ( m_menu == null )
		{
			m_menu = new CountryIntroMenu(m_params);
		}
		SpeckGlobals.hud.enable( HudMode.GAMEPLAY );

	}
	
	override public function exit():Void 
	{
		super.exit();

		// Unload VO
		var soundURL:String = "SFX/Hello/" + m_countryCode + "_Hello";
		WebAudio.instance.unload( [soundURL] );
	}
}
