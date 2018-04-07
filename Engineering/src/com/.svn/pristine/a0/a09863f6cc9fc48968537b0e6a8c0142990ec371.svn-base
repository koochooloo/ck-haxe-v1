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

import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GenericMenu;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import motion.Actuate;
import motion.easing.Linear;
import openfl.events.Event;
import openfl.text.TextField;

/**
 * Class used to display a loading screen during loading screen state.
 * Prefer to pass callbacks for customized functionality over extending.
 */
class LoadingScreenMenu extends GenericMenu
{
	/**
	 * The paist menu name to use for this loading screen.
	 */
	public var layoutName(default, null):String;
	
	/**
	 * Called when the menu is added to the screen and ready
	 * to begin displaying loading progress.
	 */
	public var onLoadScreenReady(default, null):LoadingScreenMenu -> Void;
	
	/**
	 * Called whenever the game finishes loading a resource.
	 * The float argument will be a completion ratio in the range [0,1]
	 */
	public var onLoadProgress(default, null):LoadingScreenMenu -> Float -> Void;
	
	/**
	 * Called when the game finishes loading all specified resources
	 * for this given loading screen.
	 */
	public var onLoadComplete(default, null):LoadingScreenMenu -> Void;
	
	/**
	 * Constructor for the LoadingMenu. All arguments map to member properties 1-1
	 * @param	layoutName
	 * @param	onLoadScreenReady
	 * @param	onLoadProgress
	 * @param	onLoadComplete
	 */
	public function new( layoutName:String, 
		?onLoadScreenReady:LoadingScreenMenu->Void, 
		?onLoadProgress:LoadingScreenMenu->Float->Void, 
		?onLoadComplete:LoadingScreenMenu->Void) 
	{
		super( layoutName );
		
		this.onLoadScreenReady = onLoadScreenReady;
		this.onLoadProgress = onLoadProgress;
		this.onLoadComplete = onLoadComplete;
		
		this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
	}
	
	/**
	 * Prepare this menu for the garbage collector.
	 */
	public function release()
	{
		this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		
		onLoadScreenReady = null;
		onLoadProgress = null;
		onLoadComplete = null;
	}
	
	/**
	 * Standard callback for Event.ADDED_TO_STAGE
	 * @param	e
	 */
	private function onAddedToStage( e:Event = null ):Void
	{
		this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		
		if (onLoadScreenReady != null)
		{
			onLoadScreenReady(this);
		}
	}
	
}