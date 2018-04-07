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

import com.firstplayable.hxlib.display.OPSprite;
import game.utils.TextParser;
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.text.TextField;

class ImageQuestion extends UIElement
{
	public static inline var LAYOUT:String = "ImageQuestion";
	
	private static inline var QUESTION_LABEL:String = "lbl_question";
	private static inline var QUESTION_IMAGE:String = "ref_image";
	private static inline var QUESTION_VO_BUTTON:String = "btn_question_vo";
	
	public var text(get, set):String;
	public var image(never, set):Bitmap;
	
	private var m_questionLabel:TextField;
	private var m_questionImage:OPSprite;
	
	public function new()
	{
		super(LAYOUT);
		
		m_questionLabel = getChildAs(QUESTION_LABEL, TextField);
		m_questionImage = getChildAs(QUESTION_IMAGE, OPSprite);
	}
	
	override public function showMenu():Void
	{
		var children:Array<String> = [QUESTION_IMAGE, QUESTION_LABEL, QUESTION_VO_BUTTON];
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
		var children:Array<String> = [QUESTION_IMAGE, QUESTION_LABEL, QUESTION_VO_BUTTON];
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
		var children:Array<String> = [QUESTION_IMAGE, QUESTION_LABEL, QUESTION_VO_BUTTON];
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
	
	private function set_image(value:Bitmap):Bitmap
	{
		m_questionImage.changeImage(value);
		
		return value;
	}
}