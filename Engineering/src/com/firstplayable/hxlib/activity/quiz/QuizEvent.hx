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
package com.firstplayable.hxlib.activity.quiz;
import com.firstplayable.hxlib.activity.quiz.question.QuizQuestion;
import openfl.events.Event;

class QuizEvent extends Event
{
	/**
	 * Dispatched when the quiz changes to a new question.
	 */
	public static inline var QUEST_CHANGE:String = "quizchange";
	
	/**
	 * Dispatched when a question is finished.
	 */
	public static inline var QUEST_ANSWERED:String = "quizanswered";
	
	/**
	 * Dispatched when a question is evaluated as incorrect.
	 */
	public static inline var QUIZ_FINISHED:String = "quizfinished";
	
	/**
	 * The quiz question in question.
	 */
	public var question:QuizQuestion;
	
	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
	}
}