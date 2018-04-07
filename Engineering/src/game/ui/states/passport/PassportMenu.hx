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

package game.ui.states.passport;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.state.StateManager;
import game.controllers.FlowController;
import game.events.PassportStampClaimedEvent;
import game.ui.SpeckMenu;
import game.def.GameState;
import game.ui.states.passport.PassportBook;
import motion.Actuate;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;

/**
 * Shows passport progress of player.
 */
class PassportMenu extends SpeckMenu
{
	public static inline var MENU_NAME:String = "PassportMenu";
	
	private var m_book:PassportBook;
	
	//==============================================
	// Paist object references
	//==============================================
	
	private var m_leaveButton:GraphicButton;
	
	private var m_speechBubble:DisplayObjectContainer;
	private var m_speechText:TextField;
	
	public function new() 
	{
		super(MENU_NAME);
		
		m_book = new PassportBook();
		
		var refBook:OPSprite = getChildAs("ref_passport", OPSprite);
		m_book.x = refBook.x;
		m_book.y = refBook.y;
		
		refBook.visible = false;
		addChild(m_book);
		
		m_leaveButton = getChildAs("btn_leave", GraphicButton);
		m_speechBubble = getChildAs("spr_dialogBubble", DisplayObjectContainer);
		m_speechText = getChildAs("lbl_passport", TextField);
		
		if (SpeckGlobals.saveProfile.haveStampsToClaim())
		{
			//m_leaveButton.visible = false;
			
			SpeckGlobals.event.addEventListener(PassportStampClaimedEvent.STAMP_CLAIMED_EVENT, onStampClaimed);
		}
		
		if ( FlowController.flowPos > 0 ) // If we access this menu from the game flow, rather than the hub
		{
			m_leaveButton.visible = false; // Hide leave button; use HUD
		}
	}
	
	public function release():Void
	{
		SpeckGlobals.event.removeEventListener(PassportStampClaimedEvent.STAMP_CLAIMED_EVENT, onStampClaimed);
		
		m_book.release();
		removeChild(m_book);
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		if (caller.name == "btn_leave")
		{
			WebAudio.instance.play( "SFX/button_click" );
			
			StateManager.setState(GLOBE);
		}
	}
	
	private function onStampClaimed(e:PassportStampClaimedEvent):Void
	{
		if (!SpeckGlobals.saveProfile.haveStampsToClaim())
		{
			m_leaveButton.visible = true;
			Actuate.tween(m_leaveButton, Tunables.STAMP_FADE_TIME, {alpha: 1.0});
	
			m_speechBubble.visible = true;
			Actuate.tween(m_speechBubble, Tunables.STAMP_FADE_TIME, {alpha: 1.0});
			
			m_speechText.visible = true;
			Actuate.tween(m_speechText, Tunables.STAMP_FADE_TIME, {alpha: 1.0});
		}
	}
}