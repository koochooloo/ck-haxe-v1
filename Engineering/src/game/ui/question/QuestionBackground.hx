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

package game.ui.question;

import openfl.text.TextField;

class QuestionBackground extends UIElement
{
	public static inline var LAYOUT:String = "Question";
	
	private static inline var NEXT_QUESTION_BUTTON:String = "btn_next_question";
	
	public function new()
	{
		super(LAYOUT);
	}
	
	override public function tweenable():Bool
	{
		return false;
	}
	
	public function showNextQuestionButton():Void
	{
		showObject(NEXT_QUESTION_BUTTON);
	}
	
	public function hideNextQuestionButton():Void
	{
		hideObject(NEXT_QUESTION_BUTTON);
	}
}