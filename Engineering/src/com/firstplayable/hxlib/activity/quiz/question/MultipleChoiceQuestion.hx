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
import com.firstplayable.hxlib.activity.quiz.question.ObjectiveQuestion;
using com.firstplayable.hxlib.utils.LambdaX;

class MultipleChoiceQuestion extends ObjectiveQuestion
{
	// List of all options.
	public var answerOptions(default, null):Array<String>;
	
	/**
	 * Creates a multiple choice question; ie "Choose one of the following:"
	 * @param	prompt		The question prompt/request, ie "Choose one of the following:"
	 * @param	correct		The expected correct response.
	 * @param	options		Answer options available to select from. Correct answer is automatically included, so don't add it here.
	 * @param	doShuffle	If true, shuffle the answer order.
	 */
	public function new( prompt:String, correctChoice:String, wrongChoices:Array<String>, doShuffle:Bool = true ) 
	{
		super( prompt, correctChoice );
		answerOptions = wrongChoices;
		answerOptions.unshift( correctChoice );
		
		if ( doShuffle )
			answerOptions.shuffle();
	}
}