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

// Represents the tabs in the CMS
@:enum
abstract QuestionSheet(String) to String
{
	var MATH_AND_SCIENCE = "cms/MathAndScience.json";
	var SOCIAL_STUDIES = "cms/SocialStudies.json";
	var ZERO_WEEK_ASSESSMENT = "cms/ZeroWeekAssessment.json";
	var FIVE_WEEK_ASSESSMENT = "cms/FiveWeekAssessment.json";
	var TEN_WEEK_ASSESSMENT = "cms/TenWeekAssessment.json";
}