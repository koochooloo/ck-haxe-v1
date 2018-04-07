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

package game.controllers;

import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;

using game.utils.OptionExtension;

class CorrectIncorrectFeedbackController implements IFeedbackController
{
	private function new()
	{
	}
	
	public function evaluate(params:FeedbackParams):Bool
	{
		if (!params.cmsAnswer.isCorrect)
		{
			WebAudio.instance.play("SFX/quiz_false_click");
			
			params.bundle.answerPanel.flatMap(function(answerPanel){
				answerPanel.disableButtonById(params.id);
				answerPanel.markAnswerWrong(params.id);
				return Some(answerPanel);
			});
		}
		else
		{
			WebAudio.instance.play("SFX/quiz_true_click");
			
			params.bundle.answerPanel.flatMap(function(answerPanel){
				answerPanel.disableButtonsForCA(params.id);
				answerPanel.markAnswerCorrect(params.id);
				return Some(answerPanel);
			});
			
			params.bundle.questionBackground.flatMap(function(questionBackground){
				questionBackground.showNextQuestionButton();
				return Some(questionBackground);
			});
		}
		
		return false;
	}
}