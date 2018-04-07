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

import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.text.TextField;

class TextAnswer extends Answer
{
	public static inline var LARGE_LAYOUT:String = "LargeTextAnswer";
	public static inline var SMALL_LAYOUT:String = "SmallTextAnswer";
	
	private static inline var ANSWER_LABEL:String = "lbl_answer";
	private static inline var DEFAULT_BUTTON:String = "btn_answer_default";
	private static inline var CORRECT_BUTTON:String = "btn_answer_correct";
	private static inline var WRONG_BUTTON:String = "btn_answer_wrong";
	private static inline var CORRECT_IMAGE:String = "spr_correct_answer";
	private static inline var WRONG_IMAGE:String = "spr_wrong_answer";
	
	public var answer(get, set):String;
	
	private var m_answerLabel:TextField;
	
	private function new(layout:String)
	{
		super(layout);
		
		m_answerLabel = getChildAs(ANSWER_LABEL, TextField);
	}
	
	override public function showMenu():Void
	{
		var children:Array<String> = [DEFAULT_BUTTON, WRONG_BUTTON, CORRECT_BUTTON, ANSWER_LABEL, CORRECT_IMAGE, WRONG_IMAGE];
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			if (obj.visible)
			{
				Actuate.tween(obj, UIElement.FADE_DURATION, {alpha: 1});
			}
		}
	}
	
	override public function hideMenu():Void
	{
		var children:Array<String> = [DEFAULT_BUTTON, WRONG_BUTTON, CORRECT_BUTTON, ANSWER_LABEL, CORRECT_IMAGE, WRONG_IMAGE];
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			if (obj.visible)
			{
				obj.alpha = 0;
			}
		}
	}
	
	override public function fadeOut():Void
	{
		var children:Array<String> = [DEFAULT_BUTTON, WRONG_BUTTON, CORRECT_BUTTON, ANSWER_LABEL, CORRECT_IMAGE, WRONG_IMAGE];
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			
			Actuate.tween(obj, UIElement.FADE_DURATION, {alpha: 0});
		}
	}
	
	override public function markCorrect():Void
	{
		hideObject(DEFAULT_BUTTON);
		showObject(CORRECT_BUTTON);
		showObject(CORRECT_IMAGE);
	}
	
	override public function markWrong():Void
	{
		hideObject(DEFAULT_BUTTON);
		showObject(WRONG_BUTTON);
		showObject(WRONG_IMAGE);
	}
	
	public static function makeLarge():TextAnswer
	{
		return new TextAnswer(LARGE_LAYOUT);
	}
	
	public static function makeSmall():TextAnswer
	{
		return new TextAnswer(SMALL_LAYOUT);
	}
	
	private function get_answer():String
	{
		return m_answerLabel.text;
	}
	
	private function set_answer(value:String):String
	{
		m_answerLabel.text = value;
		
		return m_answerLabel.text;
	}
}