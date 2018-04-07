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

package game.ui.login;
import com.firstplayable.hxlib.display.GraphicButton;
import game.controllers.FlowController;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import haxe.ds.Option;
import game.utils.URLUtils;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;

class ModeSelectMenu extends SpeckMenu
{
	private var id:Option<String>;
	
	public function new( p:GameStateParams ) 
	{
		super( "ModeSelectMenu" );
		
		id = p.args[0];
	}

	public override function onButtonHit( ?caller:GraphicButton )
	{
		super.onButtonHit( caller );
		
		if ( caller.name == "btn_school_version" )
		{
			FlowController.initPilot();
			StateManager.setState( GameState.TEACHER_ID_LOGIN, {args:[id]});
		}
		else
		{
			FlowController.initConsumer();
			StateManager.setState( GameState.GLOBE );
		}
		
	}
}