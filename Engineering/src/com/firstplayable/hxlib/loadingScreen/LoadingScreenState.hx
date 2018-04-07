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

package com.firstplayable.hxlib.loadingScreen;

import com.firstplayable.hxlib.loadingScreen.LoadingScreenDefs.LoadingScreenFactory;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.state.StateManager;

import com.firstplayable.hxlib.loader.LibraryLoader;
import com.firstplayable.hxlib.state.BaseGameState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;

/**
 * Params that are required by this state.
 */
typedef LoadingScreenParams =
{
	var targetState:EnumValue;	//State that will be entered when loading completes.
	var librariesToLoad:List<LibraryDef>;	//List of libraries to be loaded.
	var loadingScreenFactory:LoadingScreenFactory; 	//Function that will construct the loading screen menu.
	@:optional var targetStateParams:GameStateParams;	//Params to pass through to the next state.
}

/**
 * State that handles loading a provided list of libraries needed
 * before transitioning to a provided game state.
 * Displays progress via a customizable loading screen.
 * Will handle passing game state parameters through to the
 * destination state.
 */
class LoadingScreenState extends BaseGameState
{	
	/**
	 * The menu for a single visit to the loading screen.
	 */
	private var m_loadingScreen:LoadingScreenMenu;
	
	/**
	 * Parameters for a single visit to the loading screen.
	 */
	private var m_params:LoadingScreenParams;
	
	/**
	 * Constructor. Will need to specify specific enum value per project.
	 * @param	gameState
	 */
	public function new(gameState:EnumValue) 
	{
		super( gameState );
	}
	
	override public function enter( p:GameStateParams ):Void 
	{
		super.enter(p);
		
		if (m_params != null)
		{
			m_params = null;
		}
		
		if (m_loadingScreen != null)
		{
			m_loadingScreen.release();
			m_loadingScreen = null;
		}
		
		if (p.args == null)
		{
			Debug.warn("GameStateParams were null. Need LoadingScreenParams as element 0");
			return;
		}
		
		if (p.args.length == 0)
		{
			Debug.warn("GameStateParams were empty. Need LoadingScreenParams as element 0");
			return;
		}
		
		var loadParams:LoadingScreenParams = cast p.args[0];
		
		if (loadParams.loadingScreenFactory == null)
		{
			Debug.warn("provided loadingScreenFactory was null");
			return;
		}
		
		m_loadingScreen = loadParams.loadingScreenFactory();
		if (m_loadingScreen == null)
		{
			Debug.warn("m_loadingScreenFactory returned a null menu!");
			return;
		}
		else
		{
			GameDisplay.attach( LayerName.PRIMARY, m_loadingScreen );
		}
		
		m_params = loadParams;
		
		LibraryLoader.loadLibraries(m_params.librariesToLoad, onLoadProgress, onLoadComplete);
	}
	
	/**
	 * Callback for LibraryLoader: called whenever a library is loaded
	 * @param	progress
	 */
	private function onLoadProgress(progress:Float):Void
	{
		if (m_loadingScreen.onLoadProgress != null)
		{
			m_loadingScreen.onLoadProgress(m_loadingScreen, progress);
		}
	}
	
	/**
	 * Callback for LibraryLoader: called when all provided libraries are loaded.
	 * @param	progress
	 */
	private function onLoadComplete():Void
	{
		if (m_loadingScreen.onLoadComplete != null)
		{
			m_loadingScreen.onLoadComplete(m_loadingScreen);
		}
		
		StateManager.setState(m_params.targetState, m_params.targetStateParams);
	}
	
	override public function exit():Void 
	{
		m_params = null;
		
		GameDisplay.remove( LayerName.PRIMARY, m_loadingScreen );
		m_loadingScreen.release();
		m_loadingScreen = null;
		
		super.exit();
	}
}
