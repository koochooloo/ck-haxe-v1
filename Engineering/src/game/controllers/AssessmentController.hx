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

import com.firstplayable.hxlib.state.StateManager;
import game.cms.Dataset;
import game.cms.Grade;
import game.cms.Question.CMSQuestion;
import game.cms.QuestionDatabase;
import game.cms.QuestionQuery;
import game.cms.QuestionSheet;
import game.def.GameState;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import game.ui.question.Assessment;
import game.ui.question.AssessmentButtonIds;
import com.firstplayable.hxlib.audio.WebAudio;

using game.utils.OptionExtension;

class AssessmentController
{
	private var m_view:Assessment;

	public function new()
	{
		m_view = new Assessment();
	}

	public function start():Void
	{
		m_view.show();

		SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onButtonClicked);
	}

	public function stop():Void
	{
		m_view.hide();

		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onButtonClicked);
	}

	private function onButtonClicked(event:GenericEvent<AssessmentButtonIds>):Void
	{
		WebAudio.instance.play( "SFX/button_click" );
		
		switch (event.item)
		{
			case AssessmentButtonIds.BEFORE:
				{
					SpeckGlobals.teacher.flatMap(function(teacher){
						var questions:Array<CMSQuestion> = 
							QuestionDatabase.instance.query()
								.inSheet(QuestionSheet.ZERO_WEEK_ASSESSMENT)
								.forGrade(teacher.grade)
								.forWeek(1)
								.finish();
								
						return Dataset.make(questions).flatMap(function(dataset){
							StateManager.setState(GameState.QUESTION, {args: [dataset]});
							return Some(dataset);
						});
					});
				}
			case AssessmentButtonIds.MIDDLE:
				{
					SpeckGlobals.teacher.flatMap(function(teacher){
						var questions:Array<CMSQuestion> = 
							QuestionDatabase.instance.query()
								.inSheet(QuestionSheet.FIVE_WEEK_ASSESSMENT)
								.forGrade(teacher.grade)
								.forWeek(5)
								.finish();
								
						return Dataset.make(questions).flatMap(function(dataset){
							StateManager.setState(GameState.QUESTION, {args: [dataset]});
							return Some(dataset);
						});
					});
				}
			case AssessmentButtonIds.END:
				{
					SpeckGlobals.teacher.flatMap(function(teacher){
						var questions:Array<CMSQuestion> = 
							QuestionDatabase.instance.query()
								.inSheet(QuestionSheet.TEN_WEEK_ASSESSMENT)
								.forGrade(teacher.grade)
								.forWeek(10)
								.finish();
								
						return Dataset.make(questions).flatMap(function(dataset){
							StateManager.setState(GameState.QUESTION, {args: [dataset]});
							return Some(dataset);
						});
					});
				}
		}
	}
}