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

typedef CMSAnswer = Answer;

class Answer
{
	public var text(default, null):Option<String>;
	public var image(default, null):Option<String>;
	public var vo(default, null):Option<String>;
	public var isCorrect(default, null):Bool;
	
	public function new(text:Option<String>, image:Option<String>, vo:Option<String>, isCorrect:Bool)
	{
		this.text = text;
		this.image = image;
		this.vo = vo;
		this.isCorrect = isCorrect;
	}
}