//
// Copyright (C) 2006-2016, 1st Playable Productions, LLC. All rights reserved.
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
package com.firstplayable.hxlib.activity.quiz.question;
import com.firstplayable.hxlib.activity.quiz.QuizEvent;

class SubjectiveQuestion extends QuizQuestion
{
	public var submittedAnswer(default, null):Dynamic;
	
	/**
	 * Creates an open question; ie "What is your name?"
	 * @param	prompt		The question prompt/request, ie "What is your name?"
	 */
	public function new( prompt:String )
	{
		super( prompt );
	}
	
	/**
	 * Submits a user response.
	 * @param	response	User's response to question.
	 */
	override public function submit( ?response:Dynamic ):Void
	{
		super.submit();
		submittedAnswer = response;
	}
}