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

enum QuestionStatus
{
	NOT_VIEWED;	//question not seen/reached by user
	VIEWED;		//question seen but not answered/skipped
	ANSWERED;	//question answered, but not evaluated
}

class QuizQuestion
{
	/**
	 * The status of the this question, see enum QuestionStatus.
	 */
	public var status(default, null):QuestionStatus;
	public var score(default, null):Float;
	public var prompt(default, null):String;
	
	/**
	 * A posed question with no expected response.
	 * @param	quest	The question prompt, ie "What is your name?"
	 */
	public function new( quest:String )
	{
		status = NOT_VIEWED;
		prompt = quest;
		score = 0;
	}
	
	/**
	 * Notes that the question has been seen by the user.
	 */
	public function shown():Void
	{
		status = VIEWED;
	}
	
	/**
	 * Submits a user response.
	 * @param	response	User's response to question.
	 */
	public function submit( ?response:Dynamic ):Void
	{
		status = ANSWERED;
		score = 1;
	}
}