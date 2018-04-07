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

package game.ui.states;
import com.firstplayable.hxlib.audio.WebAudio;
import game.MultipleChoiceQuestion;
import openfl.text.TextField;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.loader.ResMan;
import game.Country;
import game.Recipe;
import game.def.GameState;
import game.ui.SpeckMenu;
import openfl.display.DisplayObjectContainer;
import Random;

using StringTools;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

// TODO - integrate with database/some CMS?
class MathGameMenu extends SpeckMenu
{
	// ------ Static tunable vars:
	private static var FADE_ALPHA:Float = 0.25; 
	private static var CORRECT:String = "That is correct!";
	private static var INCORRECT:String = "Try again!";
	
	// ------ Member vars:
	private var m_correctId:Int;
	
	public function new( p:GameStateParams ) 
	{
		super( "MathGameMenu" );
		
		// Set up/display a random math question.
		setUpQuestion();
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		if ( caller.id == m_correctId )
		{
			// Correct answer behavior - Fade other buttons
			WebAudio.instance.play( "SFX/quiz_true_click" );
			
			for ( i in 1...5 )
			{
				var button:GraphicButton = getButtonById( i );
				if ( button != caller )
				{
					var panel:DisplayObjectContainer = cast getChildByName( "option" + i );
					var label:TextField = cast panel.getChildByName( "lbl_option" + i );
					button.alpha = FADE_ALPHA;
					label.alpha = FADE_ALPHA;
				}
			}
			
			// Display correct answer text
			var wordLabel:TextField = cast getChildByName( "lbl_wordProblem" );
			wordLabel.text = CORRECT;
			
			// Disable all buttons
			toggleButtonsEnabled( false );
			
			// Display refresh button
			var refresh:GraphicButton = cast getChildByName( "btn_refresh" );
			refresh.visible = true;
			refresh.alpha = 1;
			refresh.enabled = true;
			
			return;
		}
		else if ( caller.name == "btn_refresh" )
		{
			// Set up a new question
			setUpQuestion();
		}
		else
		{
			// Incorrect answer behavior - Fade button
			WebAudio.instance.play( "SFX/quiz_false_click" );
			
			var panel:DisplayObjectContainer = cast getChildByName( "option" + caller.id );
			var label:TextField = cast panel.getChildByName( "lbl_option" + caller.id );
			caller.alpha = FADE_ALPHA;
			label.alpha = FADE_ALPHA;
			
			// Display incorrect answer text
			var wordLabel:TextField = cast getChildByName( "lbl_wordProblem" );
			wordLabel.text = INCORRECT;
			
			return;
		}
		
		WebAudio.instance.play( "SFX/button_click" );	

	}
	
	private function setUpQuestion():Void
	{
		// Enable buttons
		toggleButtonsEnabled( true );
		
		// Hide refresh button
		var refresh:GraphicButton = cast getChildByName( "btn_refresh" );
		refresh.visible = false;
		refresh.enabled = false;
			
		// Get a random question
		var r:Int = Random.int( 0, SpeckGlobals.dataManager.mathQuestions.length - 1);
		var question:MultipleChoiceQuestion = SpeckGlobals.dataManager.mathQuestions[ r ];
		
		// Display question
		var wordLabel:TextField = cast getChildByName( "lbl_wordProblem" );
		var eqLabel:TextField = cast getChildByName( "lbl_numberProblem" );
		wordLabel.text = question.problem;
		eqLabel.text = question.secondaryProblem; 
		
		// Set up/display answers
		for ( i in 1...5 )
		{
			var option:DisplayObjectContainer = cast getChildByName( "option" + i );
			var button:GraphicButton = cast option.getChildByName( "btn_option" + i );
			var label:TextField = cast option.getChildByName( "lbl_option" + i );
			
			if ( question.answers[ (i - 1) ] == question.correctAnswer ) 
			{
				m_correctId = i;
			}
			label.text = question.answers[ (i - 1) ];
			
			// Verify answers are un-faded
			button.alpha = 1;
			label.alpha = 1;
			button.visible = true;
			label.visible = true;
		}
		
		showMenu();
	}
	
	private function toggleButtonsEnabled( enabled:Bool ):Void
	{
		for ( i in 1...5 )
		{
			var btn:GraphicButton = getButtonById( i );
			if ( btn != null )
			{
				btn.enabled = enabled;
			}
		}
	}
}