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

class ObjectiveQuestion extends SubjectiveQuestion
{
	public var isCorrect(default, null):Bool;
	public var isOutOfAttempts(default, null):Bool;
	public var attempt(default, null):Int;
	public var allowedAttempts:Int;
	public var correctAnswer( default, null ):Dynamic;
	
	/**
	 * Creates a question with a possible correct answer, ie "What is 2+2?"
	 * @param	prompt		The question prompt/request, ie "What is 2+2?"
	 * @param	correct		The value of the correct answer; ie "4"
	 */
	public function new( prompt:String, correct:Dynamic ) 
	{
		super( prompt );
		correctAnswer = correct;
		attempt = 0;
		allowedAttempts = 2;
		isCorrect = false;
		isOutOfAttempts = false;
	}
	
	/**
	 * Submits a user response.
	 * @param	response	User's response to question.
	 */
	override public function submit( ?response:Dynamic ):Void 
	{
		super.submit( response );
		evaluate();
	}
	
	/**
	 * Evaluates the user's response as correct or incorrect.
	 */
	private function evaluate():Void 
	{
		++attempt;
		
		isOutOfAttempts = ( attempt >= allowedAttempts );
		isCorrect = ( submittedAnswer == correctAnswer );
		
		//TODO: evaluate possible array of answers -jm
		
		if( isCorrect )
			score = 1 / attempt;
	}
}