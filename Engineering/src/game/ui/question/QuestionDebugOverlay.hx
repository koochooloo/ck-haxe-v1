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

import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import openfl.text.TextField;

class QuestionDebugOverlay extends UIElement
{
	public static inline var LAYOUT:String = "QuestionTemplateMenuDebugOverlay";
	
	private static inline var LABEL_CURRENT_WEEK:String = "lbl_current_week";
	private static inline var LABEL_CURRENT_GRADE:String = "lbl_current_grade";
	private static inline var LABEL_CURRENT_CURRICULUM:String = "lbl_current_curriculum";
	private static inline var LABEL_CURRENT_QUESTION:String = "lbl_current_question";
	
	public var currentWeek(default, set):String;
	public var currentGrade(default, set):String;
	public var currentQuestion(default, set):String;
	public var currentCurriculum(default, set):String;
	
	private var m_currentWeek:TextField;
	private var m_currentGrade:TextField;
	private var m_currentQuestion:TextField;
	private var m_currentCurriculum:TextField;
	
	public function new()
	{
		super(LAYOUT);
		
		m_currentWeek = getChildAs(LABEL_CURRENT_WEEK, TextField);
		m_currentGrade = getChildAs(LABEL_CURRENT_GRADE, TextField);
		m_currentQuestion = getChildAs(LABEL_CURRENT_QUESTION, TextField);
		m_currentCurriculum = getChildAs(LABEL_CURRENT_CURRICULUM, TextField);
	}
	
	override public function show():Void
	{
		GameDisplay.attach(LayerName.FOREGROUND, this);
		
		var event = new GenericEvent(this, GenericMenuEvents.SHOWN);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	override public function hide():Void
	{
		GameDisplay.remove(LayerName.FOREGROUND, this);
		
		var event = new GenericEvent(this, GenericMenuEvents.HIDDEN);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	private function set_currentWeek(value:String):String
	{
		currentWeek = value;
		
		m_currentWeek.text = value;
		
		return currentWeek;
	}
	
	private function set_currentGrade(value:String):String
	{
		currentGrade = value;
		
		m_currentGrade.text = value;
		
		return currentGrade;
	}
	
	private function set_currentQuestion(value:String):String
	{
		currentQuestion = value;
		
		m_currentQuestion.text = value;
		
		return currentQuestion;
	}
	
	private function set_currentCurriculum(value:String):String
	{
		currentCurriculum = value;
		
		m_currentCurriculum.text = value;
		
		return currentCurriculum;
	}
}