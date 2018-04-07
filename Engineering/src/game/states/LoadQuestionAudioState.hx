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

import assets.SoundLib;
import com.firstplayable.hxlib.audio.WebAudio;
import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import haxe.io.Path;


class LoadQuestionAudioState extends SpeckBaseState
{
	private static inline var SOUND_PREFIX:String = "snd/";
	private static inline var QUESTION_PREFIX:String = "Questions/";
	
	public function new() 
	{
		super(GameState.LOAD_QUESTION_AUDIO);
	}
	
	override public function enter(params:GameStateParams):Void 
	{
		super.enter(params);

		var ids:Array<String> = [];
		
		for (id in SoundLib.SOUNDS)
		{
			var isQuestionVO:Bool = (id.indexOf(QUESTION_PREFIX) != -1);
			if (isQuestionVO)
			{
				var filename:String = '${id}.ogg';
				var fullPath:String = Path.join([SOUND_PREFIX, filename]);
				WebAudio.instance.register(fullPath, filename);
				
				ids.push(filename);
			}
		}
		
		WebAudio.instance.load(ids, function(){
			StateManager.setState(GameState.TEACHER_ID_LOGIN, params);
		});
	}
}
