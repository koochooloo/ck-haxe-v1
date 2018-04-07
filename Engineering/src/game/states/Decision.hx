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

import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.def.GameState;

class Decision
{
	public var state(default, null):GameState;
	public var params(default, null):Null<GameStateParams>;
	
	public function new(state:GameState, params:GameStateParams = null)
	{
		this.state = state;
		this.params = params;
	}
}