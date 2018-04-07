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

typedef UIBundleParams =
{
	var answerPanel:Option<AnswerPanel>;
	var compactStory:Option<SocialStudiesStory>;
	var expandedStory:Option<SocialStudiesStory>;
	var imageQuestion:Option<ImageQuestion>;
	var questionBackground:Option<QuestionBackground>;
	var questionHeader:Option<QuestionHeader>;
	var textQuestion:Option<TextQuestion>;
}