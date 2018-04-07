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

import game.utils.TextParser;
import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.text.TextField;

class TextQuestion extends UIElement
{
	public static inline var DEFAULT_QUESTION_LAYOUT:String = "TextQuestion";
	public static inline var SOCIAL_STUDIES_QUESTION_LAYOUT:String = "SocialStudiesQuestion";
	
	private static inline var QUESTION_LABEL:String = "lbl_question";
	private static inline var QUESTION_VO_BUTTON:String = "btn_question_vo";
	
	public var text(get, set):String;
	
	private var m_questionLabel:TextField;
	
	private function new(layout:String)
	{
		super(layout);
		
		m_questionLabel = getChildAs(QUESTION_LABEL, TextField);
	}
	
	override public function showMenu():Void
	{
		var children:Array<String> = [QUESTION_VO_BUTTON, QUESTION_LABEL];
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
		var children:Array<String> = [QUESTION_VO_BUTTON, QUESTION_LABEL];
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
		var children:Array<String> = [QUESTION_VO_BUTTON, QUESTION_LABEL];
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			
			Actuate.tween(obj, UIElement.FADE_DURATION, {alpha: 0});
		}
	}
	
	public function showVOButton():Void
	{
		showObject(QUESTION_VO_BUTTON);
	}
	
	public function hideVOButton():Void
	{
		return hideObject(QUESTION_VO_BUTTON);
	}
	
	private function get_text():String
	{
		return m_questionLabel.text;
	}
	
	private function set_text(value:String):String
	{
		m_questionLabel.text = value;
		
		var result = TextParser.formattedText.apply(value);
		if (result.status)
		{
			m_questionLabel.htmlText = result.value;
		}
		
		return m_questionLabel.text;
	}
	
	public static function makeDefault():TextQuestion
	{
		return new TextQuestion(DEFAULT_QUESTION_LAYOUT);
	}
	
	public static function makeSocialStudies():TextQuestion
	{
		return new TextQuestion(SOCIAL_STUDIES_QUESTION_LAYOUT);
	}
}