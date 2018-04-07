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
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;

class DecisionState extends SpeckBaseState
{
	private var m_callback:DecisionCallback;
	
	public function new(state:GameState, callback:DecisionCallback) 
	{
		super(state);
		
		m_callback = callback;
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		super.enter(p);
		
		var decision:Decision = m_callback(p);
		StateManager.setState(decision.state, decision.params);
	}
}
