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

package;

import assets.Gamestrings;
import assets.ResourceMap;
import assets.SoundLib;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.app.MainLoop;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.state.StateManager;
import com.firstplayable.hxlib.utils.json.GlobalTable;
import game.DataManager;
import game.cms.QuestionDatabase;
import game.def.CheatDefs;
import game.def.GameState;
import game.init.Display;
import game.init.States;
import game.net.AccountManager;
import game.utils.URLUtils;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Stage;
import openfl.events.Event;
import com.firstplayable.hxlib.loader.AssetBuildingMacro;
import com.firstplayable.hxlib.loader.LibraryLoader;
import game.ui.load.SpeckLoader;

#if js
import js.Browser;
#end

using StringTools;

#if (debug || build_cheats)
import com.firstplayable.hxlib.debug.tunables.LocalTunablesConfigurator;
#end

class Main extends Application
{
	public function new()
	{
		onInitialized = start;
		super();
	}
	
	/**
	 * Game starts here.
	 */
	private function start():Void
	{
		Debug.log( "starting game" );
		
		MainLoop.init();
		GlobalTable.init( new ResourceMap(), new Gamestrings() );
		
		AssetBuildingMacro.addResources();

		States.init();
		initSounds( SoundLib.SOUNDS );
		AccountManager.connect();
		
		if (Tunables.DEBUG_TUNABLES)
		{
			Debug.log("==================================");
			Debug.log("Test tunables: ");
			Debug.log("==================================");
			Debug.log("Displaying Fields: ");
			for (field in Reflect.fields(Tunables))
			{
				Debug.log(field + ": " + Reflect.getProperty(Tunables, field));
			}
			#if (debug || build_cheats)
			Debug.log("Displaying Overrides: ");
			if (LocalTunablesConfigurator.CUSTOM_VALUES != null)
			{
				for (val in LocalTunablesConfigurator.CUSTOM_VALUES)
				{
					Debug.log(val.name + ": " + val.value);
				}
			}
			#end
		}
		
		//================================================
		//Debug and Cheat setup
		//================================================
		
		#if (debug || build_cheats)
		CheatDefs.initCheats();
		#end

		//================================================
		// Start the game!
		//================================================
		
		
		gotoMenu();
	}
	
	private function gotoMenu():Void
	{
		LibraryLoader.loadLibraries( SpeckLoader.commonAssets, null, function()
		{
			LibraryLoader.loadLibraries( SpeckLoader.splashAssets, null, function()
			{
				StateManager.setState(GameState.SPLASH, {args:[SPLASH]});
			});
		});
	}

	private function initSounds( audioList:Array<String>, path:String = "snd/" ):Void
	{
		WebAudio.bgmVolume = 0.3;
		WebAudio.duckedBgmVolume = 0.01;
		
		// Load global BGM
		var audioID:String = "Music/GLOBAL_music";
		var audioSrc = path + audioID;
		WebAudio.instance.multiRegister( [audioSrc + ".ogg", audioSrc + ".mp3"], audioID);
		WebAudio.instance.load( [audioID] );
		
		// Load SFX
		for ( sfxID in SoundLib.SOUNDS )
		{
			if ( StringTools.endsWith( sfxID, "_click" ) )
			{
				var sfxSrc = path + sfxID;
				WebAudio.instance.multiRegister( [ sfxSrc + ".ogg", sfxSrc + ".mp3"], sfxID);
				WebAudio.instance.load( [sfxID] );
			}
		}
	}
	
	override function setSizeForManualScaling():Void 
	{
		// Order matters
		targetSize = Display.targetSize;
		scaleMode = Display.scaleMode;
	}
	
	override function initLayers():Void 
	{
		// Explicitly do not call super
		Display.initLayers();
	}
	
	override public function onResize(e:Event = null):Void
	{
		Display.updateLayers();
	}
	
	//invoked when app gains focus
	override public function activate(e:Event = null):Void 
	{
		// super.activate(e);
		
		// trace( "game activated" );
		
		// WebAudio.mute = Global.isMuted;
		// MainLoop.resume();
		// Actuate.resumeAll();
	}
	
	//invoked when app loses focus
	override public function deactivate(e:Event = null):Void 
	{
		// super.deactivate(e);
		
		// trace( "game suspended" );
		
		// Actuate.pauseAll();
		//WebAudio.instance.resumeBGMTimer();
		
		// MainLoop.pause();
		// Global.isMuted = WebAudio.mute;
		// WebAudio.mute = true;
	}
}
