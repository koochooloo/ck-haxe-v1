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
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.state.StateManager;
import game.controllers.FlowController;
import game.def.GameState;
import openfl.text.TextField;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

enum SupportButtonIDs
{
	EXIT;
	CHECK;
	ASSESS;
		
	NUM_BUTTONS;
}

class SupportMenu extends SpeckMenu
{

	public function new() 
	{
		super( "SupportMenu" );
		showMenu();
		
		if ( FlowController.currentMode == FlowMode.PILOT )
		{
			displayAssessment();
		}
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		WebAudio.instance.play( "SFX/button_click" );	

		var buttonId = Type.createEnumIndex( SupportButtonIDs, caller.id );
		switch( buttonId )
		{
			case EXIT:		StateManager.setState( GameState.GLOBE );
			case CHECK:		StateManager.setState( GameState.GLOBE );
			case ASSESS: 	StateManager.setState( GameState.ASSESSMENT );
			case NUM_BUTTONS:
				// Illegal value / TODOs
		}
	}
	
	private function displayAssessment()
	{
		var assessButton:GraphicButton = getButtonById( SupportButtonIDs.ASSESS.getIndex() );
		var assessText:TextField = cast getChildByName( "lbl_assess_dialogue" );
		
		assessButton.visible = true;
		assessText.visible = true;
		
		var supportDialogue:TextField = cast getChildByName( "lbl_tut4" );
		supportDialogue.visible = false;
	}
	
}