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

import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import openfl.text.TextField;

class TeacherIdConfirmation extends SpeckMenu
{
	public static inline var LAYOUT:String = "TeacherConfirmation";
	
	private static inline var MESSAGE_TEXT:String = "lbl_message";
	
	public var message(get, set):String;
	
	private var m_messageLabel:TextField;
	
	public function new()
	{
		super(LAYOUT);
		
		m_messageLabel = getChildAs(MESSAGE_TEXT, TextField);
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
	
	private function get_message():String
	{
		return m_messageLabel.text;
	}
	
	private function set_message(value:String):String
	{
		m_messageLabel.text = value;
		
		return m_messageLabel.text;
	}
}