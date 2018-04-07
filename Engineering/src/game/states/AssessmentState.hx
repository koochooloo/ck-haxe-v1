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

import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.controllers.AssessmentController;
import game.ui.load.SpeckLoader;
import game.ui.question.AssessmentButtonIds;
import game.def.GameState;
import game.ui.HudMenu.HudMode;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryDef;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryType;
import com.firstplayable.hxlib.loader.LibraryLoader;
import game.ui.load.SpeckLoader;

class AssessmentState extends SpeckBaseState
{
	private var m_controller:AssessmentController;
	
	public function new() 
	{
		super(GameState.ASSESSMENT);
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		m_assets = SpeckLoader.questionAssets;
		
		// In debug mode, need to load navigation UI
		#if debug
		for (item in SpeckLoader.hudCoreAssets)
		{
			m_assets.add(item);
		}
		#end
		
		super.enter(p);
	}
	
	override public function initMenu()
	{
		if (SpeckGlobals.hud != null )
		{
			SpeckGlobals.hud.enable( HudMode.ASSESS );
		}
		
		m_controller = new AssessmentController();
		m_controller.start();
	}
	
	override public function exit():Void 
	{
		super.exit();
		
		m_controller.stop();
		m_controller = null;
	}
}
