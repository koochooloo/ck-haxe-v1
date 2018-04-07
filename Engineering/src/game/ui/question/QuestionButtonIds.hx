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

@:enum
abstract QuestionButtonIds(Int) from Int to Int
{
	var ANSWER_ONE = 0;
	var ANSWER_TWO = 1;
	var ANSWER_THREE = 2;
	
	var ANSWER_VO = 3;
	
	var QUESTION_VO = 4;
	
	var DEBUG_PREVIOUS_QUESTION = 5;
	var DEBUG_NEXT_QUESTION = 6;
	var DEBUG_PREVIOUS_WEEK = 7;
	var DEBUG_NEXT_WEEK = 8;
	var DEBUG_PREVIOUS_TAB = 9;
	var DEBUG_NEXT_TAB = 10;
	var DEBUG_PREVIOUS_GRADE = 11;
	var DEBUG_NEXT_GRADE = 12;
	
	var NEXT_QUESTION = 13;
	
	var EXPAND_STORY = 14;
	var CLOSE_STORY = 15;
	
	var STORY_VO = 16;
}