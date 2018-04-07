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
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.loader.ResMan;
import motion.Actuate;
import openfl.display.DisplayObject;

class AnswerPanel extends UIElement
{
	public static inline var DEFAULT_ANSWER_PANEL_LAYOUT:String = "AnswerPanel";
	public static inline var LARGE_TEXT_ANSWER_PANEL_LAYOUT:String = "AnswerPanelTextLarge";
	public static inline var SMALL_TEXT_ANSWER_PANEL_LAYOUT:String = "AnswerPanelTextSmall";
	public static inline var SOCIAL_STUDIES_ANSWER_PANEL_LAYOUT:String = "SocialStudiesAnswerPanel";
	
	private static inline var ANSWER_VO_BUTTON:String = "btn_answer_vo";
	private static inline var ANSWER_ONE:String = "ref_answer_one";
	private static inline var ANSWER_TWO:String = "ref_answer_two";
	private static inline var ANSWER_THREE:String = "ref_answer_three";
	
	public var answers(get, set):Array<Answer>;
	
	private var m_answers:Array<Answer>;
	
	private function new(layout:String)
	{
		super(layout);
		
		m_answers = [];
	}
	
	override public function showMenu():Void
	{
		var children:Array<String> = [ANSWER_VO_BUTTON, ANSWER_ONE, ANSWER_TWO, ANSWER_THREE];
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
		var children:Array<String> = [ANSWER_VO_BUTTON, ANSWER_ONE, ANSWER_TWO, ANSWER_THREE];
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
		var children:Array<String> = [ANSWER_VO_BUTTON, ANSWER_ONE, ANSWER_TWO, ANSWER_THREE];
		for (child in children)
		{
			var obj:DisplayObject = getChildByName(child);
			
			Actuate.tween(obj, UIElement.FADE_DURATION, {alpha: 0});
		}
		
		for (answer in answers)
		{
			answer.fadeOut();
		}
	}
	
	public function showVOButton():Void
	{
		showObject(ANSWER_VO_BUTTON);
	}
	
	public function hideVOButton():Void
	{
		hideObject(ANSWER_VO_BUTTON);
	}
	
	public function disableButtonsForCA(id:QuestionButtonIds):Void
	{
		for (i in 0...answers.length)
		{
			var btn:GraphicButton = getButtonById(i);
			btn.mouseEnabled = false;
			btn.mouseChildren = false;
		}
	}
	
	public function markAnswerCorrect(id:QuestionButtonIds):Void
	{
		var answer:Answer = m_answers[id];
		answer.markCorrect();
	}
	
	public function markAnswerWrong(id:QuestionButtonIds):Void
	{
		var answer:Answer = m_answers[id];
		answer.markWrong();
	}
	
	private function get_answers():Array<Answer>
	{
		return m_answers.copy();
	}
	
	private function set_answers(value:Array<Answer>):Array<Answer>
	{
		for (answer in m_answers)
		{
			removeChild(answer);
		}
		
		m_answers = value.copy();
		
		var children:Array<String> = [ANSWER_ONE, ANSWER_TWO, ANSWER_THREE];
		for (answer in m_answers)
		{
			if (children.length <= 0)
			{
				break;
			}
			
			var child:String = children.shift();
			
			var ref:DisplayObject = getChildByName(child);
			
			answer.x = ref.x;
			answer.y = ref.y;
			
			ref.parent.addChild(answer);
		}
		
		for (child in children)
		{
			hideObject(child);
		}
		
		return m_answers.copy();
	}
	
	public static function makeDefault():AnswerPanel
	{
		return new AnswerPanel(DEFAULT_ANSWER_PANEL_LAYOUT);
	}
	
	public static function makeSocialStudes():AnswerPanel
	{
		return new AnswerPanel(SOCIAL_STUDIES_ANSWER_PANEL_LAYOUT);
	}
	
	public static function makeLargeText():AnswerPanel
	{
		return new AnswerPanel(LARGE_TEXT_ANSWER_PANEL_LAYOUT);
	}
	
	public static function makeSmallText():AnswerPanel
	{
		return new AnswerPanel(SMALL_TEXT_ANSWER_PANEL_LAYOUT);
	}
}