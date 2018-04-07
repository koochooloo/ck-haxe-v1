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

package com.firstplayable.hxlib.loadingScreen;
import com.firstplayable.hxlib.loader.LibraryLoader;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryDef;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryType;
import com.firstplayable.hxlib.loadingScreen.LoadingScreenDefs.LoadingScreenFactory;
import com.firstplayable.hxlib.loadingScreen.LoadingScreenState.LoadingScreenParams;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;

/**
 * Wrapper around StateManager and LoadingScreenState that directs calls
 * to StateManager.SetState to be easily swapped out for LoadingScreenState.SetState.
 */
class LoadingStateManager
{
	private static var loadingScreenState:EnumValue;
	private static var loadingScreenFactory:LoadingScreenFactory;
	
	private static var ms_configured:Bool = false;
	
	/**
	 * Sets LoadingStateManager properties that define how it will handle setting up
	 * the loading screen.
	 */
	public static function configure(state:EnumValue, factory:LoadingScreenFactory):Void
	{
		if (state == null)
		{
			Debug.warn("provided loading screen state was null!");
			return;
		}
		
		if (factory == null)
		{
			Debug.warn("provided loading screen factory was null!");
			return;
		}
		
		loadingScreenState = state;
		loadingScreenFactory = factory;
		
		ms_configured = true;
	}
	
	/**
     * Exits the current state, if one exists, and enters the loading state, before
	 * transitioning to the provided state being managed by StateManager.
     * @param    stateId     The ID of the state to enter()
     * @param    args        Any arguments that need to be passed to enter()
     */
    public static function setState( stateId:EnumValue, args:GameStateParams = null ):Void
	{
		if (!ms_configured)
		{
			Debug.warn("LoadingStateManager has not been configured. Defaulting to direct state transition!");
			StateManager.setState(stateId, args);
			return;
		}
		
		/**
		 * If no arguments provided, assume standard state transition.
		 */
		if (args == null)
		{
			Debug.log("No args provided. Using direct state transition.");
			StateManager.setState(stateId, args);
			return;
		}
		
		if ((args.args == null) || (args.args.length == 0) )
		{
			Debug.warn("Args provided, but were null or empty. Defaulting to direct state transition!");
			StateManager.setState(stateId, args);
			return;
		}
		
		var libraryList:List<LibraryDef> = null;
		for (arg in args.args)
		{
			if(LibraryLoader.isLibraryList(arg))
			{
				libraryList = cast arg;
				break;
			}
		}
		
		if (libraryList == null)
		{
			Debug.log("no library list supplied, Using direct state transition with params");
			StateManager.setState(stateId, args);
			return;
		}
		
		args.args.remove(libraryList);
		var remainingParams:Array<Dynamic> = args.args;
		var newParams:GameStateParams = {args:remainingParams};
		
		var loadingParams:LoadingScreenParams =
		{
			targetState:stateId,
			librariesToLoad:libraryList,
			loadingScreenFactory:loadingScreenFactory,
			targetStateParams:newParams
		};
		
		Debug.log("Transition to loading screen with params: " + Std.string(loadingParams));
		StateManager.setState(loadingScreenState, {args:[loadingParams]});
	}
}