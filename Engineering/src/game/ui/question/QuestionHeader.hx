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

class QuestionHeader extends UIElement
{
	public static inline var LAYOUT:String = "QuestionHeader";
	
	private static inline var HEADER_LABEL:String = "headerText_country";
	
	public var header(get, set):String;
	
	private var m_headerLabel:TextField;
	
	public function new()
	{
		super(LAYOUT);
		
		m_headerLabel = getChildAs(HEADER_LABEL, TextField);
	}
	
	override public function showMenu():Void
	{
		var children:Array<String> = [HEADER_LABEL];
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
		var children:Array<String> = [HEADER_LABEL];
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
		var children:Array<String> = [HEADER_LABEL];
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			
			Actuate.tween(obj, UIElement.FADE_DURATION, {alpha: 0});
		}
	}
	
	private function get_header():String
	{
		return m_headerLabel.text;
	}
	
	private function set_header(value:String):String
	{
		m_headerLabel.text = value;
		
		return m_headerLabel.text;
	}
}