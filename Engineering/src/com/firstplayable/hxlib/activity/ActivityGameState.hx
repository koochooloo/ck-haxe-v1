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
package com.firstplayable.hxlib.activity;
import com.firstplayable.hxlib.activity.quiz.Quiz;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.state.BaseGameState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import motion.Actuate;
import motion.actuators.GenericActuator;
import openfl.display.Bitmap;

class ActivityGameState extends BaseGameState
{
	//round and question logic vars
	private var NUM_ROUNDS:Int = 1;
	private var NUM_ROUND_QUESTIONS:Int = 1;
	private var m_curRound:Int;
	private var m_curQuestion:Int;
	
	//wait time between inactivity prompts, in seconds
	private var m_inactivityWait:Float = 20.0;
	//inactivity timer
	private var m_inactivityTimer:GenericActuator<Dynamic>;
	
	private var m_questions:Quiz;
	
	//instantiate these in implementation
	private var m_background:Bitmap;
	private var m_backBtn:GraphicButton;
	private var m_helpBtn:GraphicButton;
	
	public function new( stateId:EnumValue ) 
	{
		super( stateId );
	}
	
	override public function init():Void 
	{
		super.init();
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		super.enter(p);
		GameDisplay.attach( LayerName.BACKGROUND, m_background );
		m_curRound = 0;
	}
	
	override public function exit():Void 
	{
		Actuate.reset();
		
		GameDisplay.clearLayer( LayerName.BACKGROUND );
		GameDisplay.clearLayer( LayerName.PRIMARY );
		GameDisplay.clearLayer( LayerName.FOREGROUND );
		
		super.exit();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		
		Actuate.stop( m_inactivityTimer, null, false, false );
		m_inactivityTimer = null;
	}
	
	/**
	 * Resets the inactivity prompt timer.
	 */
	private function resetInactivityTimer():Void
	{
		//launch timeout timer
		Actuate.stop( m_inactivityTimer, null, false, false );
		m_inactivityTimer =
			Actuate.timer( m_inactivityWait )
				.onComplete( playHint );
	}
	
	/**
	 * Override this to play instruction VO.
	 */
	private function playInstruction():Void
	{
		resetInactivityTimer();
	}
	
	/**
	 * Override this to play hint VO.
	 */
	private function playHint():Void
	{
		resetInactivityTimer();
	}
	
	/**
	 * Reset anything needed for next round.
	 */
	private function resetRound():Void
	{
		m_curQuestion = 0;
		nextQuestion();
		onResetRound();
	}
	
	/**
	 * Override this for onResetRound logic
	 */
	private function onResetRound():Void {}
	
	/**
	 * Called when question list is exhausted.
	 */
	private function nextRound():Void
	{
		if ( m_curRound >= NUM_ROUNDS )
		{
			showResults();
			return;
		}
		
		++m_curRound;
		resetRound();
	}
	
	/**
	 * Triggers next question.
	 */
	private function nextQuestion():Void
	{
		if ( m_curQuestion >= NUM_ROUND_QUESTIONS )
		{
			nextRound();
			return;
		}
		
		++m_curQuestion;
		m_questions.nextQuestion();
		
		onNextQuestion();
	}
	
	/**
	 * Override this for onNextQuestion logic
	 */
	private function onNextQuestion():Void {}
	
	/**
	 * Register this to your quit button.
	 */
	private function onQuit( g:GraphicButton ):Void
	{
		//show quit modal
		//TODO: pause inactivity timer
	}
	
	/**
	 * Register this to your help button.
	 */
	private function onHelp( g:GraphicButton ):Void
	{
		playHint();
	}
	
	/**
	 * Shows results modal.
	 */
	private function showResults():Void
	{
		Debug.log( "showing results" );
		Actuate.stop( m_inactivityTimer, null, false, false );
	}
	
	/**
	 * Override this for shared answer logic.
	 */
	private function onAnswer():Void
	{
		resetInactivityTimer();
	}
	
	/**
	 * Override this for correct answer logic.
	 */
	private function answerCorrect():Void {}
	
	/**
	 * Override this for incorrect answer logic.
	 */
	private function answerIncorrect():Void {}
}