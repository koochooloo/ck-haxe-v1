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

package game.cms;

import game.cms.Curriculum;
import game.cms.Question;
import game.cms.QuestionSheet;
import haxe.ds.Option;

using Lambda;
using game.utils.OptionExtension;

class QuestionQuery
{
	private var m_questions:Array<Question>;	// The initial Question list to be further filtered
	
	private function new(questions:Array<Question>)
	{
		m_questions = questions;
	}
	
	// Filters the list to Questions in the specified sheet
	public function inSheet(sheet:QuestionSheet):QuestionQuery
	{
		m_questions = m_questions.filter(function(question){return (question.questionSheet == sheet); });
		
		return this;
	}
	
	// Filters the list to Questions with the specified Curriculum
	public function withCurriculum(curriculum:Curriculum):QuestionQuery
	{
		m_questions = m_questions.filter(function(question){return (question.curriculum == curriculum); });
		
		return this;
	}
	
	public function forGrade(grade:Grade):QuestionQuery
	{
		m_questions = m_questions.filter(function(question){return (question.grade == grade); });
		
		return this;
	}
	
	// Filters the list to Questions for the specified week
	public function forWeek(week:Int):QuestionQuery
	{
		function isSameWeek(questionWeek:Int):Option<Bool>{
			return Some(questionWeek == week);
		}
		
		function questionHasSameWeek(question:Question):Bool{
			return switch (question.week.flatMap(isSameWeek)) {
					case Some(boolean):
						{
							return boolean;
						}
					case None:
						{
							return false;
						}
				}
		}
		
		m_questions = m_questions.filter(questionHasSameWeek);
		
		return this;
	}
	
	// Filters the list for Questions about the specified country
	public function aboutCountry(country:String):QuestionQuery
	{
		function isSameCountry(questionCountry:String):Option<Bool>{
			return Some(questionCountry.toLowerCase() == country.toLowerCase() );
		}
		
		function questionHasSameCountry(question:Question):Bool{
			return switch (question.country.flatMap(isSameCountry)) {
				case Some(boolean):
					{
						return boolean;
					}
				case None:
					{
						return false;
					}
			}
		}
		
		m_questions = m_questions.filter(questionHasSameCountry);
		
		return this;
	}
	
	// Filters the list for Questions about the specified recipe
	public function aboutRecipe(recipe:String):QuestionQuery
	{
		function isSameRecipe(questionRecipe:String):Option<Bool>{
			return Some(questionRecipe.toLowerCase() == recipe.toLowerCase());
		}
		
		function questionHasSameRecipe(question:Question):Bool{
			return switch (question.recipe.flatMap(isSameRecipe)) {
				case Some(boolean):
					{
						return boolean;
					}
				case None:
					{
						return false;
					}
			}
		}
		
		m_questions = m_questions.filter(questionHasSameRecipe);
		
		return this;
	}
	
	// Termintes the query yielding the list of Questions that meet the specified criteria
	public function finish():Array<Question>
	{
		return m_questions.copy();
	}
}