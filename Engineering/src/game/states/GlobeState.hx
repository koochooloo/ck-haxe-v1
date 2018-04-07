//
// Copyright (C) 2017, 1st Playable Productions, LLC. All rights reserved.
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

import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.state.BaseGameState;
import game.controllers.FlowController;
import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.def.GameState;
import game.ui.HudMenu;
import game.ui.HudMenu.HudMode;
import game.ui.SkyBackground;
import game.ui.states.MainMenu;
import game.events.DataLoadedEvent;
import game.ui.states.SplashMenu;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import game.net.NetAssets;
import openfl.display.Bitmap;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryDef;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryType;
import com.firstplayable.hxlib.loader.LibraryLoader;
import game.ui.load.SpeckLoader;
import com.firstplayable.hxlib.loader.ResMan;
import game.utils.GeoJsonUtils;

class GlobeState extends SpeckBaseState
{
	private var m_mainMenu:MainMenu;
	private var m_loadingScreen:SplashMenu;
	private var flagsLoaded:Int = 0;
	private var numCountries:Int = 0;
	
	public function new() 
	{
		super(GameState.GLOBE);
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		//super.enter(p); Skip super - do not init library loading until we finish database setup ( and manage it ourselves ) 
		
		// Set flow to base
		FlowController.resetData();
		
		// Hide the persistent background
		SkyBackground.hideBackground();
		
		// Play main menu music
		WebAudio.instance.playBGM("Music/GLOBAL_music", false);
		
		// Reset the globe/set up the menu if the MainMenu already exists
		if (m_mainMenu != null)
		{
			m_mainMenu.resetGlobe();
			GameDisplay.attach(LayerName.PRIMARY, m_mainMenu);
			SpeckGlobals.hud.enable( HudMode.FULL );
		}
		// If db load is finished, load flags
		else if ( SpeckGlobals.databaseCMSLoaded )
		{
			postDatabaseInitialization();
		}
		// If flags are already loaded, skip to menu init 
		else if ( SpeckGlobals.databaseCMSLoaded && SpeckGlobals.databaseFlagsLoaded )
		{
			loadMainMenuAssets();
		}
		// Hold off on menu creation/display until loading finishes
		else
		{
			setupLoadScreen();
		}
	}
	
	private function setupLoadScreen():Void
	{
		// Load splash assets
		m_loadingScreen = new SplashMenu();
		LibraryLoader.loadLibraries( SpeckLoader.splashAssets, null, displayLoadScreen );
	}
	
	private function displayLoadScreen()
	{	
		// Display splash menu while we wait for db to finish loading
		GameDisplay.attach( LayerName.PRIMARY, m_loadingScreen );
		
		// Add event listener so splash can update on load progress
		SpeckGlobals.event.addEventListener( DataLoadedEvent.DATABASE_DATA_PROGRESS, downloadDatabaseProgress );

		// Add event listener so we can wait to load the menu until the recipe data is loaded
		SpeckGlobals.event.addEventListener( DataLoadedEvent.DATABASE_DATA_LOADED, postDatabaseInitialization );
	}
	
	/**
	 * Update loading screen as download progresses
	 */
	private function downloadDatabaseProgress(?e:DataLoadedEvent):Void
	{
		if (m_loadingScreen != null)
		{
			m_loadingScreen.onLoadProgress(0);
		}
	}
	
	/**
	 * Menu/game setup after we have all of the game data
	 */
	private function postDatabaseInitialization(?e:DataLoadedEvent)
	{	
		// Remove database event listeners
		SpeckGlobals.event.removeEventListener( DataLoadedEvent.DATABASE_DATA_LOADED, postDatabaseInitialization );
		SpeckGlobals.event.removeEventListener( DataLoadedEvent.DATABASE_DATA_PROGRESS, downloadDatabaseProgress );
		
		// Load data 
		SpeckGlobals.event.addEventListener( DataLoadedEvent.DATA_LOADED, preloadFlagImages );
		
		// Populate local CMS data
		SpeckGlobals.initDatabaseCMS();
	}
	
	private function preloadFlagImages(?e:DataLoadedEvent)
	{
		if (Tunables.USE_DATABASE_RESOURCES)
		{
			for ( country in SpeckGlobals.dataManager.allCountries )
			{
				numCountries++;
				NetAssets.instance.getImage(country.flagImage, tallyFlagLoad );
			}
		}
		else
		{
			loadMainMenuAssets();
		}
	}
	
	private function tallyFlagLoad( ?bit:Bitmap )
	{		
		flagsLoaded++;
		if ( flagsLoaded == numCountries )
		{
			SpeckGlobals.databaseFlagsLoaded = true;
			loadMainMenuAssets();
		}
	}
	
	private function loadMainMenuAssets():Void
	{
		LibraryLoader.loadLibraries( SpeckLoader.globeAssets, null, function(){
				LibraryLoader.loadLibraries(SpeckLoader.countryMenuAssets, null, function(){
						LibraryLoader.loadLibraries(SpeckLoader.hudFullAssets, null, function(){
								LibraryLoader.loadLibraries(SpeckLoader.hudCoreAssets, null, setUpMainMenu);
						});
				});
		});
	}
	
	private function setUpMainMenu():Void
	{	
		ResMan.instance.addRes( "Globe", { src : MainMenu.GLOBE_MODEL } );
		ResMan.instance.addRes( "Globe", { src : MainMenu.GLOBE_TEXTURE } );
		ResMan.instance.load( "Globe", function()
		{
			// Create the main menu
			m_mainMenu = new MainMenu();
		
			// Load and parse GeoJson
			GeoJsonUtils.loadGeoJson();
			
			// Attach the MainMenu to the PRIMARY layer
			GameDisplay.remove(LayerName.PRIMARY, m_loadingScreen);
			GameDisplay.attach(LayerName.PRIMARY, m_mainMenu);
			
			// Initialize PlayerProfile
			SpeckGlobals.saveProfile.saveGameStateEntry(m_mainMenu.menuName);
			
			SpeckGlobals.hud = new HudMenu();
			SpeckGlobals.hud.enable(HudMode.FULL);
			SpeckGlobals.hud.mainMenuRef = m_mainMenu;
			
			if (FlowController.currentMode == FlowMode.PILOT)
			{
				SpeckGlobals.hud.hideConsumerButtons();
			}
			
			// Show the tutorial if the player hasn't seen it yet
			if (!SpeckGlobals.saveProfile.hasSeenTutorial)
			{
				SpeckGlobals.hud.setupTutorial();
				SpeckGlobals.saveProfile.setHasSeenTutorial(true);
			}
		});
	}
	
	/**
	 * Overriding SpeckBaseState menu display because we are doing custom setup in setUpMainMenu()
	 */
	override public function showMenu()
	{
		// DO NOTHING
	}
	
	override public function exit():Void 
	{
		super.exit();
		
		// Show the persistent background
		SkyBackground.showBackground();
	}
}
