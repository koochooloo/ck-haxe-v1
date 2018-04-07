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

import haxe.ds.Option;

typedef CMSQuestion = Question;

class Question
{
	public var id(default, null):String;						// The ID column
	
	public var week(default, null):Option<Int>;					// The WEEK column (optional)

	public var questionType(default, null):QuestionType;		// The QUESTION_TYPE column
	
	public var countryFact(default, null):Option<String>;		// The COUNTRY_FACT column
	public var countryFactVO(default, null):Option<String>;		// The COUNTRY_FACT_VO column
	public var countryImage(default, null):Option<String>;		// The COUNTRY_IMAGE column
	
	public var grade(default, null):Grade;						// The GRADE column

	public var curriculum(default, null):Curriculum;			// The CURRICULUM column
	
	public var questionSheet(default, null):QuestionSheet;		// The tab from which this Question originates

	public var questionText(default, null):String;				// The QUESTION column
	public var questionImage(default, null):Option<String>;		// The QUESTION_IMAGE column (optional)
	public var questionVO(default, null):Option<String>;		// The QUESTION_VO column (optional)

	public var answers(get, null):Array<Answer>;
	
	public var recipe(default, null):Option<String>;			// The RECIPE column (optional)
	
	public var country(default, null):Option<String>;			// The COUNTRY column (optional)
	
	public var learningStandard(default, null):String;			// The LEARNING_STANDARD column

	public function new(
		id:String,

		week:Option<Int>,

		questionType:QuestionType,
		
		countryFact:Option<String>,
		countryFactVO:Option<String>,
		countryImage:Option<String>,
		
		grade:Grade,

		curriculum:Curriculum,
		
		questionSheet:QuestionSheet,

		questionText:String,
		questionImage:Option<String>,
		questionVO:Option<String>,

		answers:Array<Answer>,
		
		recipe:Option<String>,
		
		country:Option<String>,
		
		learningStandard:String)
	{
		this.id = id;
		
		this.week = week;
		
		this.questionType = questionType;
		
		this.countryFact = countryFact;
		this.countryFactVO = countryFactVO;
		this.countryImage = countryImage;
		
		this.grade = grade;
		
		this.curriculum = curriculum;
		
		this.questionSheet = questionSheet;
		
		this.questionText = questionText;
		this.questionImage = questionImage;
		this.questionVO = questionVO;
		
		this.answers = answers.copy();
		
		this.recipe = recipe;
		
		this.country = country;
		
		this.learningStandard = learningStandard;
	}
	
	private function get_answers():Array<Answer>
	{
		return answers.copy();
	}
}