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

package game.ui;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.display.Params;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import com.firstplayable.hxlib.utils.Utils;
import com.firstplayable.hxlib.utils.Version;
import game.cms.Dataset;
import game.cms.Question;
import game.cms.QuestionDatabase;
import game.controllers.FlowController;
import game.def.GameState;
import game.events.ZoomEvent;
import game.ui.states.CountryMenu;
import game.ui.states.MainMenu;
import game.ui.states.TutorialMenu;
import game.utils.URLUtils;
import haxe.ds.Option;
import lime.ui.MouseCursor;
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryDef;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryType;
import com.firstplayable.hxlib.loader.LibraryLoader;
import game.ui.load.SpeckLoader;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

using StringTools;
using game.utils.OptionExtension;

enum HudButtonIDs
{
	// Debug 
	CHEATS;
	
	// Full
	GLOBE;
	FAVORITES;
	RECIPES;
	SETTINGS;
	
	// Simple
	BACK;
	
	// Debug
	PAIST;
	
	// Recipes
	RECIPEBACK;
	RECIPESEARCH;
	RECIPEGLOBE;
	
	// Favorites
	FAVSEARCH;
	FAVGLOBE;
	
	// Gameplay
	GAMEMUSIC;
	GAMEGLOBE;
	GAMEBACK;
	GAMENEXT;
	
	// Settings
	SOUND;
	ABOUT;
	SUPPORT;
	TUTORIAL;
	ALLERGENS;
	FACEBOOK;
	TWITTER;
	GPLUS;
	
	ZOOM; // Full
	
	QUIZ; // Full
	
	PASSPORT; // Full
	
	FLOWMODE; // Full
	
	ASSESSSOUND; // assess
	
	SIMPLESOUND; // simple
	
	NUM_BUTTONS;
}

enum SocialMedia
{
	TWITTER;
	FACEBOOK;
	GPLUS;
}

@:enum
abstract HudMode( Int )
{
	var SIMPLE = 0;
	var GAMEPLAY = 1; // Shown everywhere else without a specific hud case 
	var FULL = 2; // shown on the "Globe" menu
	var RECIPES = 3; // shown on the "All Recipes" menu. 
	var FAVORITES = 4; // shown on the "Favorites" menu
	var ASSESS = 5; // Shown in quizzes and assessments
}

class HudMenu extends SpeckMenu
{
	private static var VISIBLE_ALPHA:Float = 0.5;
	
	public var mainMenuRef:MainMenu;
	
	private var m_curMode:HudMode;
	private var m_debugInfo:TextField;
	private var m_backStack:Array< GameState >;
	
	// Submenus
	private var m_settingsBar:DisplayObject;
	private var m_countryMenu:CountryMenu;
	
	private var m_zooming:Bool = false;
	private var m_zoomYStart:Null<Float> = null;
	
	public function new() 
	{
		super( "Hud" );
				
		m_debugInfo = new TextField();
		m_backStack = new Array();
		
		#if (debug || build_cheats)
		initDebugInfo();
		#end
		
		for (child in __children)
		{
			if (child.name.startsWith("pnl_"))
			{
				for (panelChild in child.__children)
				{
					if (panelChild.name.startsWith("btn_"))
					{
						setCursorForObject(panelChild.name, MouseCursor.POINTER);
					}
				}
			}
		}
			
		m_curMode = SIMPLE;
		m_settingsBar = cast getChildByName( "pnl_settings" );
		
		// Disable search buttons (not used as buttons)
		toggleButtonEnabled( 8, false ); // Recipes
		toggleButtonEnabled( 10, false ); // Favorites
		
		// All favorites states for the hud star should be opaque
		var fav:GraphicButton = getButtonById( 2 );
		fav.upState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
		fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
	}
	
	private function initDebugInfo():Void
	{
		var deviceInfo:String = "";
		deviceInfo += "Game Version:\t" + Version.versionInfo + "\n";

		#if ( js && html5 )
		untyped var ua = detect.parse(navigator.userAgent);
		deviceInfo += "Browser:\t\t\t" + ua.browser.family + "\n";
		deviceInfo += "Browser Version:\t" + ua.browser.major + "." + ua.browser.minor + "\n";
		deviceInfo += "Device:\t\t\t" + ua.device.family;
		#end // #if js && html5
		
		m_debugInfo.text = deviceInfo;
		m_debugInfo.width = m_debugInfo.textWidth;
		positionObjectByRef( m_debugInfo, "ref_debugInfoPos" );
		Utils.removeFromParent( m_debugInfo );
	}
	
	public function enable( ?mode:HudMode = SIMPLE, ?state:GameState):Void
	{
		m_curMode = mode;
		
		toggleObjectVisibility( "pnl_simpleHud", (mode == SIMPLE) );
		toggleObjectVisibility( "pnl_gameplayHud", (mode == GAMEPLAY) );
		toggleObjectVisibility( "pnl_fullHud", (mode == FULL) );
		toggleObjectVisibility( "pnl_allRecipeHud", (mode == RECIPES) );
		toggleObjectVisibility( "pnl_favHud", (mode == FAVORITES) );
		toggleObjectVisibility( "pnl_assessHud", (mode == ASSESS) );
		toggleObjectVisibility( "btn_passport", SpeckGlobals.saveProfile.hasUnlockedPassport() );
		#if (debug || build_cheats)
			showObject( "btn_cheats" );
			showObject( "btn_paist" );
		#end
		
		if ( mode == FULL ) 
		{
			// Load country submenu
			LibraryLoader.loadLibraries( SpeckLoader.countryMenuAssets, null, onCountryAssetsLoaded );
		}
		else
		{
			setupCoreHudAssets();
		}
	}
	
	/**
	 * Set up full hud assets
	 */ 
	private function onCountryAssetsLoaded()
	{
		LibraryLoader.loadLibraries( SpeckLoader.hudFullAssets, null, setupCoreHudAssets );
	}
	
	/**
	 * Set up core hud assets
	 */
	private function setupCoreHudAssets()
	{
		LibraryLoader.loadLibraries( SpeckLoader.hudCoreAssets, null, setupHud );
	}
	
	/**
	 * Manage hud setup
	 */ 
	private function setupHud()
	{	
		// Attach hud to gamedisplay 
		GameDisplay.attach( LayerName.HUD, this );
				
		var musicButton:GraphicButton = null; 
		var upState:Bitmap = null;
		var downState:Bitmap = null;
		var downOverState:Bitmap = null;
		var upOverState:Bitmap = null;
		
		// Make sure country submenus are visible, while the menu itself is not
		if ( m_curMode == FULL)
		{
			if ( m_countryMenu == null )
			{
				m_countryMenu = new CountryMenu();
			}
			
			m_countryMenu.visible = false ;
			GameDisplay.attach( LayerName.HUD, m_countryMenu );
		}
		
		// Get reference to sound button for setting (see below)
		musicButton = getButtonById( 16 ); // Hud settings mute
		upState = ResMan.instance.getImage( "2d/Buttons/btn_sound_up" );
		upOverState = ResMan.instance.getImage( "2d/Buttons/btn_sound_upover" );
		downState = ResMan.instance.getImage( "2d/Buttons/btn_sound_down" );
		downOverState = ResMan.instance.getImage( "2d/Buttons/btn_sound_downover" );
		
		// Set music buttons to reflect current bgm state (if applicable)
		if ( SpeckGlobals.isGloballyMuted )
		{
			updateButtonStates( musicButton, downState, downState, downOverState, downOverState );
		}
		else
		{
			updateButtonStates( musicButton, upState, upState, upOverState, downOverState );
		}
		
		// Hide templates and mode toggle if not viewing on demos
		#if (debug || build_cheats)
		if ( URLUtils.didProvideURL( "demos.1stplayable.com" ) )
		{
			toggleButtonVisibility( HudButtonIDs.QUIZ.getIndex(), true );
			toggleButtonVisibility( HudButtonIDs.FLOWMODE.getIndex(), true );	
			toggleObjectVisibility( "lbl_quiz", true );
			toggleObjectVisibility( "lbl_flow", true );
		}
		#end
	
		if ( m_curMode == GAMEPLAY || m_curMode == ASSESS || m_curMode == SIMPLE )
		{
			// Get reference to sound button for setting
			upState = ResMan.instance.getImage( "2d/Buttons/btn_music_up" );
			downState = ResMan.instance.getImage( "2d/Buttons/btn_music_down" );
			upOverState = ResMan.instance.getImage( "2d/Buttons/btn_music_upover" );
			downOverState = ResMan.instance.getImage( "2d/Buttons/btn_music_downover") ;
			
			if ( m_curMode == GAMEPLAY ) musicButton = getButtonById( 12 ); // Gameplay hud mute	
			if ( m_curMode == ASSESS ) musicButton = getButtonById( 28 ); // Gameplay hud mute	
			if ( m_curMode == SIMPLE ) musicButton = getButtonById( 29 ); // Gameplay hud mute	

			// Set music buttons to reflect current bgm state (if applicable)
			if ( SpeckGlobals.isBGMMuted )
			{
				updateButtonStates( musicButton, downState, downState, downOverState, downOverState );
			}
			else
			{
				updateButtonStates( musicButton, upState, upState, upOverState, downOverState );
			}
		}
			
		//=============================================
		// Event listeneres
		//=============================================
		if ( m_curMode == FULL ) 
		{
			Utils.safeAddListener(stage, MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		else
		{
			Utils.safeRemoveListener(stage, MouseEvent.MOUSE_MOVE, onMouseMove);
		}
	}
	
	public function disable():Void
	{
		Utils.safeRemoveListener(stage, MouseEvent.MOUSE_MOVE, onMouseMove);
		
		if (m_curMode == FULL && m_countryMenu != null)
		{
			LibraryLoader.unloadLibraries( SpeckLoader.countryMenuAssets );
			GameDisplay.remove(LayerName.HUD, m_countryMenu);
			m_countryMenu.dispose();
			m_countryMenu = null;
			m_settingsBar.visible = false;
		}
		
		
		GameDisplay.remove( LayerName.HUD, this );
	}

	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		WebAudio.instance.play( "SFX/button_click" );
		
		var buttonId = Type.createEnumIndex( HudButtonIDs, caller.id );
		
		// Hide country menu when entering other states from the root menu ( or displaying settings )
		if ( m_curMode == FULL && buttonId != HudButtonIDs.GLOBE && buttonId != HudButtonIDs.ZOOM )
		{
			toggleSubMenu( m_countryMenu, false );
		}
		
		// Hide settings menu when entering other states from the root menu (or displaying countries)
		if ( m_curMode == FULL && buttonId != HudButtonIDs.SETTINGS && buttonId != HudButtonIDs.SOUND )
		{
			toggleSubMenu( m_settingsBar, false );
		}

		switch( buttonId )
		{
			// Simple
			case BACK:
			{
				FlowController.goToPrev();
			}
			
			// Gameplay
			case GAMEMUSIC:		
			{
				toggleBGM( caller );
			}
			case GAMEGLOBE:		
			{
				StateManager.setState( GameState.GLOBE );
			}
			case GAMEBACK:		
			{
				FlowController.goToPrev();
			}
			case GAMENEXT:		
			{
				FlowController.goToNext();
			}

			// Full
			case FAVORITES:		
			{
				// Only accessible in consumer flow
				FlowController.setPath( FlowPath.CONSUMER_FAVORITES );
				FlowController.goToNext();
			}
			case SETTINGS:		
			{
				toggleSubMenu( m_settingsBar );
			}
			case GLOBE: 		
			{
				// Set appropriate consumer path if we are in the consumer flow mode.
				if ( FlowController.currentMode == FlowMode.CONSUMER )
				{
					FlowController.setPath( FlowPath.CONSUMER_COUNTRY );
				}
				
				toggleSubMenu( m_countryMenu );
			}
			case RECIPES:		
			{
				// Only accessible in consumer flow
				FlowController.setPath( FlowPath.CONSUMER_RECIPE );
				FlowController.goToNext();
			}
			
			// Recipes
			case RECIPEGLOBE: 	
			{
				StateManager.setState( GameState.GLOBE );
			}
			case RECIPEBACK: 	
			{
				FlowController.goToPrev();
			}
			case RECIPESEARCH:	
			{
				// DISABLED: SEE RECIPES MENU FOR SEARCH FUNCTIONALITY
			}
			
			// Favorites
			case FAVSEARCH: 	
			{
				// DISABLED: SEE FAVORITES MENU FOR SEARCH FUNCTIONALITY
			}
			case FAVGLOBE:		
			{
				StateManager.setState( GameState.GLOBE );
			}	
			
			// Debug 
			case CHEATS:
			{
				#if (debug || build_cheats)
				SpeckGlobals.debugMenu.toggleShow();
				SpeckGlobals.cheatsMenu.toggleShow();
				toggleDeviceInfo();
				#end
			}
			case PAIST:
			{
				#if (debug || build_cheats)
				StateManager.setState( GameState.MENU_TEST); // Paist view menu
				#end
			}
			
			// Settings
			case SOUND:	
			{
				toggleGlobalSound( caller );
			}
			case ABOUT:		
			{
				StateManager.setState( GameState.ABOUT );
			}
			case SUPPORT:	
			{
				StateManager.setState( GameState.SUPPORT );
			}
			case TUTORIAL:  
			{
				setupTutorial();
			}
			case ALLERGENS: 
			{
				StateManager.setState( GameState.ALLERGIES );
			}
			case FACEBOOK:	
			{
				goToWebsite( SocialMedia.FACEBOOK );
			}
			case TWITTER:	
			{
				goToWebsite( SocialMedia.TWITTER );
			}
			case GPLUS:	
			{
				goToWebsite( SocialMedia.GPLUS );
			}
			
			case ZOOM: //NOTHING
			
			case QUIZ:
			{
				var allQuestions:Array<CMSQuestion> = 
					QuestionDatabase.instance.query()
						.finish();
						
				Dataset.make(allQuestions).flatMap(function(dataset){
					StateManager.setState(GameState.QUESTION, {args: [dataset]});
					return Some(dataset);
				});
			}
			
			case PASSPORT:
			{
				StateManager.setState( GameState.PASSPORT ); 
			}
			
			case FLOWMODE:
			{
				toggleFlowMode();
			}
			
			case ASSESSSOUND:
			{
				toggleBGM( caller );
			}
			
			case SIMPLESOUND:
			{
				toggleBGM( caller );
			}
			
			case NUM_BUTTONS: // Illegal value / TODOs
		}
		
	}
	
	// Flip sound on/off and set sound button states (persistent up/down)
	private function toggleGlobalSound( caller:GraphicButton ):Bool
	{
		var musicButton:GraphicButton; 
		var upState:Bitmap;
		var downState:Bitmap;
		var upOverState:Bitmap;
		var downOverState:Bitmap;
		
		SpeckGlobals.isGloballyMuted = !SpeckGlobals.isGloballyMuted;
		WebAudio.mute = SpeckGlobals.isGloballyMuted;
		
		musicButton = getButtonById( 16 ); // Hud settings mute
		upState = ResMan.instance.getImage( "2d/Buttons/btn_sound_up" );
		downState = ResMan.instance.getImage( "2d/Buttons/btn_sound_down" );
		upOverState = ResMan.instance.getImage( "2d/Buttons/btn_sound_upover" );
		downOverState = ResMan.instance.getImage( "2d/Buttons/btn_sound_downover" );
		
		// Flip the music button image
		if ( SpeckGlobals.isGloballyMuted )
		{
			musicButton.upState = downState;
			musicButton.overState = downOverState;
			musicButton.disabledState = downState;
			musicButton.downState = downState;
		}
		else
		{
			musicButton.upState = upState;
			musicButton.overState = upOverState;
			musicButton.downState = upState;
			musicButton.disabledState = upState;
		}
			
		return SpeckGlobals.isGloballyMuted;
	}
	
	private function toggleBGM( caller:GraphicButton ):Bool
	{
		var musicButton:GraphicButton; 
		var upState:Bitmap;
		var downState:Bitmap;
		var upOverState:Bitmap;
		var downOverState:Bitmap;

		SpeckGlobals.isBGMMuted = !SpeckGlobals.isBGMMuted;
		WebAudio.muteBgm = SpeckGlobals.isBGMMuted;
		
		musicButton = caller;
		upState = ResMan.instance.getImage( "2d/Buttons/btn_music_up" );
		downState = ResMan.instance.getImage( "2d/Buttons/btn_music_down" );
		upOverState = ResMan.instance.getImage( "2d/Buttons/btn_music_upover" );
		downOverState = ResMan.instance.getImage( "2d/Buttons/btn_music_downover" );
		
		// Flip the music button image
		if ( SpeckGlobals.isBGMMuted )
		{
			updateButtonStates( musicButton, downState, downState, downOverState, downOverState );
		}
		else
		{
			updateButtonStates( musicButton, upState, upState, upOverState, downOverState );
		}
			
		return SpeckGlobals.isBGMMuted;
	}
	
	private function goToWebsite( site:SocialMedia ):Void
	{
		var URL:String = switch ( site )
		{
			case FACEBOOK:	SpeckGlobals.gameStrings.get( "SOCIALMEDIA_FACEBOOK" );
			case TWITTER:	SpeckGlobals.gameStrings.get( "SOCIALMEDIA_TWITTER" );
			case GPLUS:		SpeckGlobals.gameStrings.get( "SOCIALMEDIA_GOOGLEPLUS" );
		}
		
		StateManager.setState( GameState.PARENTAL, { args: [ GameState.GLOBE, URL] } );
	}

	//=============================================
	// Managing menu item visibility/interactivity
	//=============================================
	
	// SUBMENU MGMT -------------------------------
	// (used for handling settings, country, and tutorial menus) 
	
	public function setupTutorial():Void
	{
		// User should not be able to interact with the game during the tutorial
		disableButtons();
		
		// Load tutorial assets
		LibraryLoader.loadLibraries( SpeckLoader.tutorialBubbleAssets, null, showTutorial );
	}
	
	public function showTutorial()
	{
		// Add tutorial to current scene
		var tutorialMenu:TutorialMenu = new TutorialMenu();
		GameDisplay.attach( LayerName.HUD, tutorialMenu );
		SpeckGlobals.saveProfile.saveGameStateEntry( tutorialMenu.menuName );
	}
	
	// Flip or explicitly set the visiblity of a display object submenu
	//		NOTE: Submenu items fade with Actuate, see show/hudeSubMenu()
	public function toggleSubMenu( menu:DisplayObject, ?visible:Bool ):Void
	{		
		if ( visible != null )
		{
			if ( visible )
			{
				showSubMenu( menu );
			}
			else 
			{
				hideSubMenu( menu );
			}
		}
		else if ( !menu.visible || menu.alpha < VISIBLE_ALPHA )
		{
			showSubMenu( menu );
		}
		else
		{
			hideSubMenu( menu );
		}
	}
	
	public function showSubMenu( menu:DisplayObject )
	{
		// Stop existing fade tween in favor of new action
		Actuate.stop( menu );
		
		// Set menu as visible for toggle handling but keep it hidden so it can tween fade in
		menu.visible = true;
		menu.alpha = 0;
		Actuate.tween( menu, SpeckGlobals.FADE_TIME, { alpha: 1 });
	}
	
	public function hideSubMenu( menu:DisplayObject )
	{
		// Stop existing fade tween in favor of new action
		Actuate.stop( menu );
		
		// Tween fade out
		Actuate.tween( menu, SpeckGlobals.FADE_TIME, { alpha: 0 } );
	}
	
	public function showChefPopup()
	{
		toggleSubMenu( m_countryMenu, true );
		toggleSubMenu( m_settingsBar, false );
		m_countryMenu.displayPopupFromGlobe();
	}
	
	private function toggleFlowMode()
	{
		if ( FlowController.currentMode == CONSUMER )
		{
			FlowController.initPilot();
			
			// Hide All Recipe and Favorites buttons if we are using the pilot flow
			toggleButtonVisibility( 2, false );
			toggleButtonVisibility( 3, false );
		}
		else
		{
			FlowController.initConsumer();

			toggleButtonVisibility( 2, true );
			toggleButtonVisibility( 3, true );
		}
		
		var panel:DisplayObjectContainer = cast getChildByName( "pnl_fullHud" );
		var label:TextField = cast panel.getChildByName( "lbl_flow" );
		label.text = FlowController.currentMode;
	}
	
	// BUTTONS -------------------------------
	public function toggleButtonVisibility( buttonId:Int, visible:Bool ):Bool
	{
		var button:GraphicButton = getButtonById( buttonId );
		button.visible = visible; 
		toggleButtonEnabled( buttonId, visible );
				
		return button.visible;
	}
	
	private function toggleButtonEnabled( btnID:Int, enabled:Bool ):Void
	{
		var btn:GraphicButton = getButtonById( btnID );
		if ( btn != null )
		{
			btn.enabled = enabled;
		}
	}
	
	public function enableButtons()
	{
		if (getButtonById(0) == null || getButtonById(0).enabled == true)
		{
			return;
		}
		
		for (i in 0...NUM_BUTTONS.getIndex())
		{
			toggleButtonEnabled( i, true );
		}
		
		// Enable hand cursor when hovering
		for (child in __children)
		{
			if (child.name.startsWith("pnl_"))
			{
				for (panelChild in child.__children)
				{
					if (panelChild.name.startsWith("btn_"))
					{
						setCursorForObject(panelChild.name, MouseCursor.POINTER);
					}
				}
			}
		}
	}
	
	public function disableButtons()
	{
		for (i in 0...NUM_BUTTONS.getIndex())
		{
			toggleButtonEnabled( i, false );
		}
		
		// Disable hand cursor when hovering
		for (child in __children)
		{
			if (child.name.startsWith("pnl_"))
			{
				for (panelChild in child.__children)
				{
					if (panelChild.name.startsWith("btn_"))
					{
						setCursorForObject(panelChild.name, MouseCursor.ARROW);
					}
				}
			}
		}
	}
	
	private function updateButtonStates( button:GraphicButton, upState:Bitmap, downState:Bitmap, overState:Bitmap, disabledState:Bitmap )
	{
		button.upState = upState;
		button.overState = overState;
		button.disabledState = disabledState;
		button.downState = downState;
	}
	
	
	// DEBUG -------------------------------
	private function toggleDeviceInfo():Void
	{
		if ( m_debugInfo.parent == null )
		{
			GameDisplay.attach( LayerName.DEBUG, m_debugInfo );
		}
		else
		{
			GameDisplay.remove( LayerName.DEBUG, m_debugInfo );
		}
	}
	
	//============================================
	// Globe zoom mgmt
	//============================================
	
	private function onMouseMove(e:MouseEvent):Void
	{
		if (!m_zooming)
		{
			return;
		}
		
		var fullPanel:DisplayObject = getChildByName("pnl_fullHud");
		var panelBounds:Rectangle = fullPanel.getBounds(stage);
		var effectiveY:Float = e.stageY - panelBounds.top;
		
		var zoomButton:GraphicButton = getButtonById(ZOOM.getIndex());
		var buttonBounds:Rectangle = zoomButton.getBounds(fullPanel);
		
		var zoomBar:OPSprite = getChildAs("spr_zoomBar", OPSprite);
		var zoomBounds:Rectangle = zoomBar.getBounds(fullPanel);
		
		var effectiveBottom = zoomBounds.bottom - (buttonBounds.height / 2);
		var effectiveTop = zoomBounds.top + (buttonBounds.height / 2);
		var effectiveHeight = zoomBounds.height - buttonBounds.height;
		
		if (m_zoomYStart == null)
		{
			m_zoomYStart = effectiveY - zoomButton.y;
		}
		
		effectiveY = effectiveY - m_zoomYStart;
		
		var zoomY = effectiveY - effectiveBottom;
		if (zoomY > 0)
		{
			zoomY = 0;
		}
		if (zoomY < -effectiveHeight)
		{
			zoomY = -effectiveHeight;
		}
		
		//move the zoom button
		zoomButton.y = effectiveBottom + zoomY;
		
		//throw zoom event
		var zoomRatio:Float = -zoomY / effectiveHeight;
		SpeckGlobals.event.dispatchEvent(new ZoomEvent(zoomRatio));
	}
	
	public function resetZoomButton():Void
	{
		var fullPanel:DisplayObject = getChildByName("pnl_fullHud");
		var zoomButton:GraphicButton = getButtonById(ZOOM.getIndex());
		var buttonBounds:Rectangle = zoomButton.getBounds(fullPanel);
		var zoomBar:OPSprite = getChildAs("spr_zoomBar", OPSprite);
		var zoomBounds:Rectangle = zoomBar.getBounds(fullPanel);
		var effectiveBottom = zoomBounds.bottom - (buttonBounds.height / 2);
		
		zoomButton.y = effectiveBottom; 
	}
	
	override public function onButtonDown( ?caller:GraphicButton ):Void
	{
		super.onButtonDown(caller);
		
		if (caller.id == ZOOM.getIndex())
		{
			m_zooming = true;
		}
	}
	
	override public function onButtonUp( ?caller:GraphicButton ):Void
	{
		super.onButtonUp(caller);
		
		if (caller.id == ZOOM.getIndex())
		{
			m_zooming = false;
			m_zoomYStart = null;
		}
	}
	
	public function hideConsumerButtons()
	{
		// Hide All Recipe and Favorites buttons if we are using the pilot flow
		toggleButtonVisibility( 2, false );
		toggleButtonVisibility( 3, false );
	}
}