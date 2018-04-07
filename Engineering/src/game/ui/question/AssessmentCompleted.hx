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
import com.firstplayable.hxlib.state.StateManager;
import game.controllers.FlowController;
import game.def.GameState;
import com.firstplayable.hxlib.display.GraphicButton;
import game.net.DatabaseInterface;

class AssessmentCompleted extends UIElement
{
	public static inline var LAYOUT:String = "AssessmentCompleted";
	
	public function new()
	{
		super(LAYOUT);
	}
	
	override public function onButtonHit(?caller:GraphicButton):Void
	{
		super.onButtonHit( caller );
		
		if ( caller.name == "btn_next" )
		{
			DatabaseInterface.initFromBackend();
			FlowController.initPilot();
			SpeckGlobals.hud.hideConsumerButtons();
			StateManager.setState( GameState.GLOBE );	
		}
	}
}