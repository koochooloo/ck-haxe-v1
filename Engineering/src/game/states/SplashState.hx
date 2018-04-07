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

import assets.SoundLib;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import game.controllers.FlowController;
import game.def.PassportDefs;
import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import game.events.DataLoadedEvent;
import game.net.DatabaseInterface;
import game.ui.HudMenu.HudMode;
import game.ui.SkyBackground;
import game.ui.SpeckMenu;
import game.ui.load.SpeckLoader;
import game.ui.states.MainMenu;
import game.ui.states.SplashMenu;
#if (debug || build_cheats)
import com.firstplayable.hxlib.debug.cheats.CheatsMenu;
import com.firstplayable.hxlib.debug.tunables.TunablesMenu;
#end
import game.ui.states.TutorialMenu;
import game.utils.GeoJsonUtils;
import game.utils.URLUtils;
import haxe.ds.Option;
import openfl.events.Event;
import haxe.io.Path;
import com.firstplayable.hxlib.loader.LibraryLoader;
import game.cms.QuestionDatabase;

#if (js && html5)
import js.html.Element;
import js.Browser;
#end

class SplashState extends SpeckBaseState
{
	private var ids:Array<String> = [];
	private var m_loadStage:Int;
	private var m_splashMenu:SplashMenu;
	
	private static var m_loadStages:Array<String> = [
		"Hud"
	];
	
	public function new() 
	{
		super( GameState.SPLASH );
	}
	
	override public function init():Void 
	{
		super.init();
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		m_assets = SpeckLoader.splashAssets;
		
		if (m_splashMenu == null)
		{
			m_splashMenu = new SplashMenu();
		}
		
		m_menu = m_splashMenu;
		
		super.enter(p);
		
		m_loadStage = 0;
		// if already loaded, this will jump to onLoadComplete
	}
	
	private function loadMenu():Void 
	{
		onLoadStageComplete();
	}
	
	override public function showMenu()
	{
		super.showMenu();
		
		#if (js && html5)
		var element:Element = Browser.window.document.getElementById('bg');
		if (element != null)
		{
			element.hidden = true;
		}
		#end
		
		onLoadSplashMenu();
	}
	
	private function onLoadSplashMenu():Void
	{
		onLoadStageComplete();
	}
	
	private function onLoadStageComplete():Void
	{
		var curStage:Int = m_loadStage;
		
		//Calculate progress
		var progressStage:Float = cast(curStage + 1, Float);
		
		//Extra 1 stage for the splash menu
		//Extra 1 stage for the sounds
		var progressNumStages:Float = cast(m_loadStages.length + 2, Float);
		var progress:Float = progressStage / progressNumStages;
		
		if (m_splashMenu != null)
		{
			m_splashMenu.onLoadProgress(progress);
		}
		
		if (m_loadStage >= m_loadStages.length)
		{
			postAssetLoadInitialiation();
		}
		else
		{
			++m_loadStage;			
			ResMan.instance.load(m_loadStages[curStage], onLoadStageComplete);
		}
	}
	
	private function postAssetLoadInitialiation()
	{
		// Init database pull when we are not in assessments or admin mode
		if ( !(URLUtils.didProvideAssessment() || URLUtils.didProvideAdmin()) )
		{
			DatabaseInterface.initFromBackend();
		}
		
		QuestionDatabase.instance.loadFromS3(postDatabaseInitialization);
	}
	
	private function postDatabaseInitialization():Void
	{	
		SpeckGlobals.initManagers();
		
		//================================================
		//Populate assessment audio
		//================================================
		var SOUND_PREFIX:String = "snd/";
		var QUESTION_PREFIX:String = "Questions/";
	
		for (id in SoundLib.SOUNDS)
		{
			var isQuestionVO:Bool = (id.indexOf(QUESTION_PREFIX) != -1);
			if (isQuestionVO)
			{
				var filename:String = '${id}.ogg';
				var fullPath:String = Path.join([SOUND_PREFIX, filename]);
				WebAudio.instance.register(fullPath, filename);
				
				ids.push(filename);
			}
		}
		
		WebAudio.instance.load(ids, initializationComplete);
	}
	
	private function initializationComplete( ):Void
	{		
		//==========================================
		// Init Debug
		//==========================================	
		#if (debug || build_cheats)
		if (SpeckGlobals.debugMenu == null)
		{
			SpeckGlobals.debugMenu = new TunablesMenu(600.0, 360.0);
		}
		//Inits the menu, then immediately hides it so it's out of the way
		SpeckGlobals.debugMenu.x = 0;
		SpeckGlobals.debugMenu.y = 0;
		SpeckGlobals.debugMenu.show();
		SpeckGlobals.debugMenu.show(false);
		
		if (SpeckGlobals.cheatsMenu == null)
		{
			SpeckGlobals.cheatsMenu = new CheatsMenu(300, 360.0);
		}
		//Inits the menu, then immediately hides it so it's out of the way
		SpeckGlobals.cheatsMenu.x = 604;
		SpeckGlobals.cheatsMenu.y = 0;
		SpeckGlobals.cheatsMenu.show();
		SpeckGlobals.cheatsMenu.show(false);
		#end
		
		//==========================================
		// Init UI
		//==========================================	
		SpeckGlobals.initUI();
		
		//==========================================
		// Indicate loading is complete
		//==========================================
		if (m_splashMenu != null)
		{
			m_splashMenu.onLoadProgress(1);
		}
		
		var id:Option<String> = URLUtils.getTeacherId();
		
		if ( URLUtils.didProvideAssessment() )
		{
			FlowController.initPilot();
			StateManager.setState( GameState.TEACHER_ID_LOGIN, {args: [id]});
		}
		else if (URLUtils.didProvideAdmin())
		{
			StateManager.setState(GameState.ADMIN, {args:[id]});
		}
		else
		{
			StateManager.setState(GameState.MODESELECT,  {args: [id]});
		}
	}
	
	override public function exit():Void 
	{
		super.exit();
		
		//Make sure all of the menus are cleaned up on the way out
		m_splashMenu.dispose();
		m_splashMenu = null;
		
		SkyBackground.showBackground();
	}
}
