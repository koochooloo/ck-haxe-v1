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
import game.cms.QuestionSheet;

class FeedbackControllerFactory
{
	@:access(game.controllers.CorrectIncorrectFeedbackController)
	@:access(game.controllers.NoFeedbackController)
	public static function make(sheet:QuestionSheet):IFeedbackController
	{
		switch (sheet)
		{
			case QuestionSheet.MATH_AND_SCIENCE | QuestionSheet.SOCIAL_STUDIES:
				{
					return new CorrectIncorrectFeedbackController();
				}
			case QuestionSheet.ZERO_WEEK_ASSESSMENT | QuestionSheet.FIVE_WEEK_ASSESSMENT | QuestionSheet.TEN_WEEK_ASSESSMENT:
				{
					return new NoFeedbackController();
				}
		}
	}
}