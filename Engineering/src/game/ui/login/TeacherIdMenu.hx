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

package game.ui.login;

import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import game.events.TextFieldEvents;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import lime.ui.KeyCode;

// TODO: Show error message
class TeacherIdMenu extends SpeckMenu
{
	public static inline var LAYOUT:String = "LoginMenu";
	
	private static inline var INPUT_TEXT:String = "lbl_input";
	private static inline var MESSAGE_TEXT:String = "lbl_message";
	private static inline var ERROR_MESSAGE_TEXT:String = "lbl_error_message";
	private static inline var LOGIN_BUTTON:String = "btn_login";
	
	public var message(get, set):String;
	public var inputText(get, set):String;
	
	private var m_inputLabel:TextField;
	private var m_messageLabel:TextField;
	private var m_errorMessageLabel:TextField;
	private var m_loginBtn:GraphicButton;
	
	public function new()
	{
		super(LAYOUT);
		
		m_inputLabel = getChildAs(INPUT_TEXT, TextField);
		m_messageLabel = getChildAs(MESSAGE_TEXT, TextField);
		m_errorMessageLabel = getChildAs(ERROR_MESSAGE_TEXT, TextField);
		m_loginBtn = getChildAs(LOGIN_BUTTON, GraphicButton);
		
		m_inputLabel.type = TextFieldType.INPUT;
	}
	
	public function start():Void
	{
		m_inputLabel.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
		m_inputLabel.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		m_inputLabel.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		Application.app.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	public function stop():Void
	{
		m_inputLabel.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
		m_inputLabel.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		m_inputLabel.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		Application.app.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	public function show():Void
	{
		GameDisplay.attach(LayerName.PRIMARY, this);
		
		var event = new GenericEvent(this, GenericMenuEvents.SHOWN);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	public function hide():Void
	{
		GameDisplay.remove(LayerName.PRIMARY, this);
		
		var event = new GenericEvent(this, GenericMenuEvents.HIDDEN);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	override public function onButtonHit(?caller:GraphicButton):Void
	{
		super.onButtonHit(caller);
		
		WebAudio.instance.play( "SFX/button_click" );
		
		var event = new GenericEvent(caller.id, GenericMenuEvents.BUTTON_CLICKED);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	public function enableLoginButton():Void
	{
		m_loginBtn.enabled = true;
	}
	
	public function disableLoginButton():Void
	{
		m_loginBtn.enabled = false;
	}
	
	public function showErrorMessage(message:String):Void
	{
		m_errorMessageLabel.text = message;
		m_errorMessageLabel.visible = true;
	}
	
	public function hideErrorMessage():Void
	{
		m_errorMessageLabel.visible = false;
	}
	
	private function onTextInput(event:TextEvent):Void
	{
		var event = new GenericEvent(this, TextFieldEvents.TEXT_CHANGED);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	private function onFocusIn(event:FocusEvent):Void
	{
		var event = new GenericEvent(this, TextFieldEvents.FOCUS_GAINED);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	private function onFocusOut(event:FocusEvent):Void
	{
		var event = new GenericEvent(this, TextFieldEvents.FOCUS_LOST);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	private function onKeyUp(event:KeyboardEvent):Void
	{
		switch (event.keyCode)
		{
			case KeyCode.BACKSPACE | KeyCode.DELETE:
				{
					var event = new GenericEvent(this, TextFieldEvents.TEXT_CHANGED);
					SpeckGlobals.event.dispatchEvent(event);
				}
			default:
				{
				}
		}
	}
	
	private function get_message():String
	{
		return m_messageLabel.text;
	}
	
	private function set_message(value:String):String
	{
		m_messageLabel.text = value;
		
		return m_messageLabel.text;
	}
	
	private function get_inputText():String
	{
		return m_inputLabel.text;
	}
	
	private function set_inputText(value:String):String
	{
		m_inputLabel.text = value;
		
		return m_inputLabel.text;
	}
}