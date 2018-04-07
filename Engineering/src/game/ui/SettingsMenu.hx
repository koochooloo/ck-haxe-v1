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

package game.ui;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.app.MainLoop;
import com.firstplayable.hxlib.app.Time.Milliseconds;
import com.firstplayable.hxlib.app.Updateable.UpdateContext;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.StateManager;
import com.firstplayable.hxlib.utils.Delay;
import com.firstplayable.hxlib.utils.DeviceCapabilities;
import com.firstplayable.hxlib.utils.Utils;
import com.firstplayable.hxlib.utils.Version;
import game.def.GameState;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import game.events.HudEvent;
import lime.ui.MouseCursor;
import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end


enum SettingsButtonIDs
{
	ALLERGIES;
	TUTORIAL;
	SUPPORT;
	ABOUT;
	
	FACEBOOK;
	TWITTER;
	GPLUS;
		
	NUM_BUTTONS;
}
	
class SettingsMenu extends SpeckMenu
{
	public function new() 
	{
		super( "SettingsMenu" );
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		var buttonId = Type.createEnumIndex( SettingsButtonIDs, caller.id );
	
		switch( buttonId )
		{
			case ALLERGIES:		StateManager.setState( GameState.ALLERGIES );
			case TUTORIAL:		StateManager.setState( GameState.TUTORIAL );
			case SUPPORT:		StateManager.setState( GameState.SUPPORT ); 
			case ABOUT:			StateManager.setState( GameState.ABOUT ); 
			case FACEBOOK: 		socialMedia("facebook");
			case TWITTER: 		socialMedia("twitter");
			case GPLUS:			socialMedia("gplus");
			case NUM_BUTTONS:
				// Illegal value / TODOs
		}
	}
	
	public function enableButtons()
	{
		if (getButtonById(0) == null || getButtonById(0).enabled == true)
		{
			return;
		}
		
		for (i in 0...NUM_BUTTONS.getIndex())
		{
			toggleButtonEnabled( i, true );
		}
	}

	public function disableButtons()
	{
		for (i in 0...NUM_BUTTONS.getIndex())
		{
			toggleButtonEnabled( i, false );
		}
	}
	
	private function socialMedia(buttonType:String):Void
	{
		trace("TODO - open web browser with link to " + buttonType);
	}
	
	private function toggleButtonEnabled( btnID:Int, enabled:Bool ):Void
	{
		var btn:GraphicButton = getButtonById( btnID );
		if ( btn != null )
		{
			btn.enabled = enabled;
		}
	}
	
}