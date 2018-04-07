//
// Copyright (C) 2016, 1st Playable Productions, LLC. All rights reserved.
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
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import flash.Lib;
import flash.net.URLRequest;
import game.def.GameState;
import game.ui.SpeckMenu;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;

using StringTools;

class ParentalMenu extends SpeckMenu
{
	private static inline var CORRECT:String = "14";
	private var DEFAULT:String; 
	private var m_answered:Bool = false;
	private var m_prevMenu:GameState; 
	private var m_URL:String;
	
	public function new( p:GameStateParams ) 
	{
		super( "ParentalMenu" );
		
		// Set up textfield for input
		var field:TextField = cast getChildByName( "lbl_text" );
		field.selectable = true;
		field.type = TextFieldType.INPUT;
		field.maxChars = 2; // user can only enter up to 2 characters
		field.restrict = "0-9"; // user can only enter numbers 
		DEFAULT = field.text; 
		
		field.addEventListener( Event.CHANGE, onInput );
		field.addEventListener( FocusEvent.FOCUS_IN, onFocusIn );

		
		//	GameStateParams args: 	[ GameState enum, String URL ]
		m_prevMenu = p.args[0];
		m_URL = p.args[1]; 
		
		//showMenu();
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		WebAudio.instance.play( "SFX/button_click" );	

		if ( caller.name == "btn_confirm" )
		{
			if ( m_answered )
			{
				StateManager.setState( m_prevMenu );
				Lib.getURL( new URLRequest( m_URL ) );
			}
		}
		else if ( caller.name == "btn_cancel" )
		{
			StateManager.setState( m_prevMenu );
		}
	}
	
	public function onInput( e:Event ):Void
	{
		var input:TextField = e.target;
		var displayed:String = input.text.substring( 0, input.maxChars ); // Max input shown on screen
		
		// If we're at max length, replace text with the first two characters so internal text val reflects what is displayed
		if ( input.text.length >= input.maxChars )
		{
			input.text = displayed;
		}
		
		// Prune internal text val of non-digit characters as they are entered
		//		ParseInt will interpret values starting with "0x" as hex
		if ( StringTools.ltrim( displayed.toLowerCase() ) == "0x" || Std.parseInt( input.text ) == null )
		{
			input.text = input.text.substring( 0, input.text.length - 1 );
		}
		
		trace ( input.text );
		
		// Allow user to proceed if they've entered the right answer
		if ( input.text == CORRECT )
		{
			m_answered = true;
		}
		else
		{
			m_answered = false;
		}
	}
	
	private function onFocusIn( e:FocusEvent ):Void
	{
		// Clear default text
		var input:TextField = e.target;
		if ( input.text == DEFAULT )
		{
			input.text = "";
		}
	}
}