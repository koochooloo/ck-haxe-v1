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

package game.utils;

import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.def.GameState;
import game.states.Decision;

class StateUtils
{
	public static function assessmentOrGlobe(params:GameStateParams):Decision
	{
		var state:GameState =
			if (URLUtils.didProvideAssessment())
			{
				GameState.ASSESSMENT;
			}
			else
			{
				GameState.GLOBE;
			}
			
		return new Decision(state, params);
	}
}