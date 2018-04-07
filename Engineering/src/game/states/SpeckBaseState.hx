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
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.state.BaseGameState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.def.GameState;
import game.net.NetAssets;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryDef;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryType;
import com.firstplayable.hxlib.loader.LibraryLoader;
import game.ui.SpeckMenu;
import game.ui.load.SpeckLoader;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import haxe.ds.Option;
import com.firstplayable.hxlib.audio.WebAudio;
import motion.Actuate;

/**
 * Base game state of all speck states
 */
class SpeckBaseState extends BaseGameState
{
	private var m_assets:List<LibraryDef>;
	private var m_menu:SpeckMenu;
	private var m_id:GameState;
	private var m_registeredAudio:Array<String>;
	private var m_bgmURL:String;
	private var m_params:GameStateParams;
	
	public function new(stateId:EnumValue) 
	{
		super(stateId);
		
		m_id = cast ( stateId, GameState );
		m_registeredAudio = new Array<String>();
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		m_params = p;
		
		// Prepare audio needed for this menu; set bgmID as necessary
		getRegisteredAudio();
		
		if  ( m_assets != null && !m_assets.isEmpty())
		{
			LibraryLoader.loadLibraries( m_assets, onLoadUpdate, initSounds );
		}
		else
		{
			// Skip menu display if no assets; not every state necessarily has an associated menu
			Debug.log( "Menu has no assets listed; skipping display." );
		}
	}
	
	/**
	 *  Sets m_registeredAudio - misc. sfx, vo, etc. used for the menu
	 */
	public function getRegisteredAudio():Void
	{
	}
	
	public function onLoadUpdate( loadPercent:Float ):Void
	{
	}
	
	public function onLoadComplete():Void
	{
		if ( m_bgmURL != null )
		{
			// Play bg sound
			SpeckGlobals.BgmID = m_bgmURL;
			WebAudio.instance.playBGM( m_bgmURL, false ); 
		}
		
		initMenu();
		showMenu();
	}
	
	public function initSounds():Void
	{
		
		if (m_registeredAudio != null && m_registeredAudio.length > 0)
		{
			WebAudio.instance.load( m_registeredAudio, onLoadComplete );
		}
		else
		{
			onLoadComplete();
		}
	}

	public function showMenu():Void
	{
		if ( m_menu != null )
		{
			GameDisplay.attach( LayerName.PRIMARY, m_menu );
			
			if ( SpeckGlobals.saveProfile != null )
			{
				SpeckGlobals.saveProfile.saveGameStateEntry( m_menu.menuName );
			}
		}
		else
		{
			Debug.log( "No menu instantiated for this state." );
		}
	}
	
	public function initMenu()
	{
	}
	
	/**
	 * Individual menus still need to be sure to clean up event listeners with dispose()
	 */
	override public function exit():Void 
	{
		super.exit();
		
		//Callbacks for NetAsset loading never make sense if they haven't
		//been called by the time the state transitions.
		NetAssets.instance.cancelCallbacks();
		
		// Unload & clear assets
		if  ( m_assets != null && !m_assets.isEmpty())
		{
			LibraryLoader.unloadLibraries( m_assets );
			m_assets.clear();
		}
		
		// Clear layer
		GameDisplay.clearLayer( LayerName.PRIMARY );
		
		// Clear menu
		if ( m_menu != null )
		{
			m_menu.dispose();
			m_menu = null;			
		}
		
		// Stop audio 
		WebAudio.instance.stop();
		
		// Disable hud 
		if (SpeckGlobals.hud != null)
		{
			SpeckGlobals.hud.disable();
		}
		
		// Stop tweens
		Actuate.reset();
		
		// Clear bgm id 
		m_bgmURL = null;
	}
}