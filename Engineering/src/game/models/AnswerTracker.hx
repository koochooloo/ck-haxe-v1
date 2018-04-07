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

import com.firstplayable.hxlib.Debug;
import haxe.Json;
import haxe.ds.Option;

class AnswerTracker
{
	private var m_choices:Array<PlayerChoice>;

	private function new(choices:Array<PlayerChoice>)
	{
		m_choices = choices.copy();
	}

	public function recordChoice(choice:PlayerChoice):Void
	{
		m_choices.push(choice);
	}

	public function toJson():String
	{
		return Json.stringify(m_choices);
	}
	
	public static function fromJson(json:String):AnswerTracker
	{
		var arr:Array<PlayerChoice> = [];
		
		try
		{
			arr = Json.parse(json);
		}
		catch (err:String)
		{
			Debug.log('Error: ${err}!');
		}
		
		return new AnswerTracker(arr);
	}
}