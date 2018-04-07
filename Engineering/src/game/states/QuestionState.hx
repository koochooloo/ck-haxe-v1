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

import game.cms.Dataset;
import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.cms.Curriculum;
import game.cms.Question;
import game.cms.QuestionDatabase;
import game.controllers.FlowController;
import game.controllers.QuestionController;
import game.def.GameState;
import game.events.GenericEvent;
import game.events.QuestionEvents;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.audio.WebAudio;
import game.ui.HudMenu.HudMode;
import game.ui.load.SpeckLoader;

using game.utils.OptionExtension;

class QuestionState extends SpeckBaseState
{
	private var m_controller:QuestionController;
	
	public function new() 
	{
		super(GameState.QUESTION);
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		m_assets = SpeckLoader.questionAssets;
		
		super.enter(p);
		
		if (SpeckGlobals.hud != null)
		{
			SpeckGlobals.hud.enable( HudMode.ASSESS );
		}
	}
	
	override public function initMenu()
	{
		SpeckGlobals.event.addEventListener(QuestionEvents.COMPLETE, onComplete);
		
		var data:Dataset<CMSQuestion> = cast m_params.args[0];
		m_controller = new QuestionController(data);
		m_controller.start();
	}
	
	override public function exit():Void 
	{
		super.exit();

		SpeckGlobals.event.removeEventListener(QuestionEvents.COMPLETE, onComplete);

		m_controller.stop();
		m_controller = null;
	}
	
	private function onComplete(event:GenericEvent<QuestionController>):Void
	{
		// Accessed via the PILOT flow
		if (FlowController.data.selectedCountry != null)
		{
			FlowController.goToNext();
		}
		// Accessed via the ASSESSMENT flow
		// Accessed via the template button (Should be sent somewhere else?)
		else
		{
			StateManager.setState(GameState.ASSESSMENT_COMPLETED);
		}
	}
}
