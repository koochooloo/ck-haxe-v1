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

import haxe.ds.Option;

class UIBundle
{
	public var answerPanel(default, null):Option<AnswerPanel>;
	public var compactStory(default, null):Option<SocialStudiesStory>;
	public var expandedStory(default, null):Option<SocialStudiesStory>;
	public var imageQuestion(default, null):Option<ImageQuestion>;
	public var questionBackground(default, null):Option<QuestionBackground>;
	public var questionHeader(default, null):Option<QuestionHeader>;
	public var textQuestion(default, null):Option<TextQuestion>;
	
	private function new(params:UIBundleParams)
	{
		answerPanel = params.answerPanel;
		compactStory = params.compactStory;
		expandedStory = params.expandedStory;
		imageQuestion = params.imageQuestion;
		questionBackground = params.questionBackground;
		questionHeader = params.questionHeader;
		textQuestion = params.textQuestion;
	}
}