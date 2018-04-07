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
import game.controllers.AssessmentCompletedController;
import game.def.GameState;

class AssessmentCompletedState extends SpeckBaseState
{
	private var m_controller:AssessmentCompletedController;
	
	public function new() 
	{
		super(GameState.ASSESSMENT_COMPLETED);
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		super.enter(p);
		
		m_controller = new AssessmentCompletedController();
		m_controller.start();
	}
	
	override public function exit():Void 
	{
		super.exit();
		
		m_controller.stop();
		m_controller = null;
	}
}
