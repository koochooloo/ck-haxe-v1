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
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;

class ImageAnswer extends Answer
{
	public static inline var LAYOUT:String = "ImageAnswer";
	
	private static inline var ANSWER_IMAGE:String = "spr_answer";
	private static inline var CORRECT_IMAGE:String = "spr_correct_answer";
	private static inline var WRONG_IMAGE:String = "spr_wrong_answer";
	
	public var image(never, set):Bitmap;
	
	private var m_answerImage:OPSprite;
	
	public function new()
	{
		super(LAYOUT);
		
		m_answerImage = getChildAs(ANSWER_IMAGE, OPSprite);
		m_answerImage.mouseEnabled = false;
		m_answerImage.mouseChildren = false;
	}
	
	override public function markCorrect():Void
	{
		showObject(CORRECT_IMAGE);
	}
	
	override public function markWrong():Void
	{
		showObject(WRONG_IMAGE);
	}
	
	override public function showMenu():Void
	{
		var children:Array<String> = [ANSWER_IMAGE, CORRECT_IMAGE, WRONG_IMAGE];
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
		var children:Array<String> = [ANSWER_IMAGE, CORRECT_IMAGE, WRONG_IMAGE];
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
		var children:Array<String> = [ANSWER_IMAGE, CORRECT_IMAGE, WRONG_IMAGE];
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			
			Actuate.tween(obj, UIElement.FADE_DURATION, {alpha: 0});
		}
	}
	
	private function set_image(value:Bitmap):Bitmap
	{
		m_answerImage.changeImage(value);
		
		return value;
	}
}