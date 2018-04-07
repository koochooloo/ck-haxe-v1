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

import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GenericMenu;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;

class UIElement extends SpeckMenu
{
	public static inline var FADE_DURATION:Float = 0.2;
	
	public function new(layout:String)
	{
		super(layout);
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
		
		var event = new GenericEvent(caller.id, GenericMenuEvents.BUTTON_CLICKED);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	public function fadeOut():Void
	{
	}
	
	public function showButtonWithId(id:Int):Void
	{
		var btn:GraphicButton = getButtonById(id);
		btn.visible = true;
	}
	
	public function hideButtonWithId(id:Int):Void
	{
		var btn:GraphicButton = getButtonById(id);
		btn.visible = false;
	}
	
	public function enableButtonById(id:Int):Void
	{
		var btn:GraphicButton = getButtonById(id);
		btn.enabled = true;
	}
	
	public function disableButtonById(id:Int):Void
	{
		var btn:GraphicButton = getButtonById(id);
		btn.enabled = false;
	}
}