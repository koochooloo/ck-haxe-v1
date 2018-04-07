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

package game.models;

import game.cms.Answer.CMSAnswer;
import game.models.Answer.ModelAnswer;
import haxe.ds.Option;

using game.utils.OptionExtension;

class AnswerExtension
{
	public static function fromCmsAnswer(cmsAnswer:CMSAnswer):ModelAnswer
	{
		var modelAnswer:ModelAnswer =
		{
			text: null,
			image: null,
			vo: null,
			isCorrect: cmsAnswer.isCorrect
		};
		
		cmsAnswer.text.flatMap(function(text){
			modelAnswer.text = text;
			return Some(text);
		});
		
		cmsAnswer.image.flatMap(function(image){
			modelAnswer.image = image;
			return Some(image);
		});
		
		cmsAnswer.vo.flatMap(function(vo){
			modelAnswer.vo = vo;
			return Some(vo);
		});
		
		return modelAnswer;
	}
}