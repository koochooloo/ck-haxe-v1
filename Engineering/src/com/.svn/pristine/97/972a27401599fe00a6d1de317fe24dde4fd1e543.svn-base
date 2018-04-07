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
import openfl.events.EventDispatcher;

/**
 * Create a test from an array of questions.
 */
class Quiz extends EventDispatcher
{
	/**
	 * The number of questions contained in this quiz.
	 */
	public var numQuestions(default, null):Int;
	
	/**
	 * The number of correct responses.
	 */
	public var numCorrect(default, null):Int;
	
	/**
	 * The number of incorrect responses.
	 */
	public var numIncorrect(default, null):Int;
	
	/**
	 * The current score of this quiz.
	 */
	public var score(get, null):Float;
	public var curQuestion(default, null):QuizQuestion;
	public var curQuestionId(default,null):Int;
	
	//TODO:abstract questions into a history
	public var questions(default, null):Array<QuizQuestion>;
	
	/**
	 * Create a new quiz with an array of questions. Call nextQuestion() to start the quiz.
	 * @param	questionList
	 */
	public function new( questionList:Array<QuizQuestion> )
	{
		super();
		
		numQuestions = questionList.length;
		numCorrect = 0;
		numIncorrect = 0;
		curQuestionId = -1;
		questions = questionList;
	}
	
	/**
	 * getter for score
	 * @return
	 */
	private function get_score():Float
	{
		return numCorrect / numQuestions;
	}
	
	/**
	 * Go to the previous question.
	 */
	public function prevQuestion():Void
	{
		--curQuestionId;
		
		if ( curQuestionId < -1 )
		{
			curQuestionId = -1;
		}
		
		onChange();
	}
	
	/**
	 * Go to the next question.
	 */
	public function nextQuestion():Void
	{
		++curQuestionId;
		
		if ( curQuestionId > numQuestions - 1 )
		{
			curQuestionId = numQuestions - 1;
		}
		
		onChange();
	}
	
	/**
	 * Question change behavior.
	 */
	private function onChange():Void
	{
		curQuestion = questions[ curQuestionId ];
		curQuestion.shown();
		
		var e:QuizEvent = new QuizEvent( QuizEvent.QUEST_CHANGE );
		e.question = curQuestion;
		dispatchEvent( e );
		
		//if every question has been answered
		for ( quest in questions )
		{
			if ( quest.status != QuestionStatus.ANSWERED )
			{
				return;
			}
		}
		
		//done with quiz
		complete();
	}
	
	/**
	 * Call submit when the current question has been answered.
	 * @param	answer	The submitted answer to the current question.
	 */
	public function submit( ?answer:Dynamic ):Void
	{
		curQuestion.submit( answer );
		
		numCorrect = 0;
		numIncorrect = 0;
		
		//update correct & incorrect count
		for ( quest in questions )
		{
			if ( quest.score > 0 )
				++numCorrect;
			else
				++numIncorrect;
		}
		
		var e:QuizEvent = new QuizEvent( QuizEvent.QUEST_ANSWERED );
		e.question = curQuestion;
		dispatchEvent( e );
	}
	
	/**
	 * Answer question out of natural quiz order while maintaining ordering.
	 * @param	answer
	 * @param	question
	 */
	public function submitSpecial( ?answer:Dynamic, question:QuizQuestion ):Void
	{
		var temp:QuizQuestion = curQuestion;
		curQuestion = question;
		submit( answer );
		curQuestion = temp;
	}
	
	/**
	 * Called when quiz is complete.
	 */
	private function complete():Void
	{
		var e:QuizEvent = new QuizEvent( QuizEvent.QUIZ_FINISHED );
		e.question = curQuestion;
		dispatchEvent( e );
	}
}