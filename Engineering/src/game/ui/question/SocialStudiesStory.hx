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

import game.utils.TextFieldExtension;
import game.utils.TextParser;
import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.text.TextField;

class SocialStudiesStory extends UIElement
{
	public static inline var COMPACT_LAYOUT:String = "SocialStudiesStoryCompact";
	public static inline var EXPANDED_LAYOUT:String = "SocialStudiesStoryExpanded";
	
	private static inline var STORY_LABEL:String = "lbl_story";
	private static inline var STORY_VO_BUTTON:String = "btn_story_vo";
	private static inline var CLOSE_BUTTON:String = "btn_close";
	private static inline var EXPAND_BUTTON:String = "btn_expand";
	
	public var text(get, set):String;
	
	private var m_storyLabel:TextField;
	
	private function new(layout:String)
	{
		super(layout);
		
		m_storyLabel = getChildAs(STORY_LABEL, TextField);
	}
	
	override public function showMenu():Void
	{
		var children:Array<String> = [STORY_LABEL, STORY_VO_BUTTON];
		
		if (menuName == COMPACT_LAYOUT)
		{
			children.push(EXPAND_BUTTON);
		}
		else
		{
			children.push(CLOSE_BUTTON);
		}
		
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
		var children:Array<String> = [STORY_LABEL, STORY_VO_BUTTON];
		
		if (menuName == COMPACT_LAYOUT)
		{
			children.push(EXPAND_BUTTON);
		}
		else
		{
			children.push(CLOSE_BUTTON);
		}
		
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
		var children:Array<String> = [STORY_LABEL, STORY_VO_BUTTON];
		
		if (menuName == COMPACT_LAYOUT)
		{
			children.push(EXPAND_BUTTON);
		}
		else
		{
			children.push(CLOSE_BUTTON);
		}
		
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			
			Actuate.tween(obj, UIElement.FADE_DURATION, {alpha: 0});
		}
	}
	
	public function showVOButton():Void
	{
		showObject(STORY_VO_BUTTON);
	}
	
	public function hideVOButton():Void
	{
		hideObject(STORY_VO_BUTTON);
	}
	
	public function isTextClipped():Bool
	{
		return TextFieldExtension.willTextBeClipped(m_storyLabel);
	}
	
	public function shortenText():Void
	{
		TextFieldExtension.shortenTextToFit(m_storyLabel);
	}
	
	private function get_text():String
	{
		return m_storyLabel.text;
	}
	
	private function set_text(value:String):String
	{
		m_storyLabel.text = value;
		
		var result = TextParser.formattedText.apply(value);
		if (result.status)
		{
			m_storyLabel.htmlText = result.value;
		}
		
		return m_storyLabel.text;
	}
	
	public static function makeCompact():SocialStudiesStory
	{
		return new SocialStudiesStory(COMPACT_LAYOUT);
	}
	
	public static function makeExpanded():SocialStudiesStory
	{
		return new SocialStudiesStory(EXPANDED_LAYOUT);
	}
}