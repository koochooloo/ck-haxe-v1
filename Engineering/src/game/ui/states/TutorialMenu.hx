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
import com.firstplayable.hxlib.display.GraphicButton;
import game.controllers.FlowController;
import game.def.GameState;
import game.ui.SpeckMenu;
import com.firstplayable.hxlib.state.StateManager;
import motion.Actuate;
import openfl.display.DisplayObjectContainer;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryDef;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryType;
import com.firstplayable.hxlib.loader.LibraryLoader;
import game.ui.load.SpeckLoader;

using StringTools;

class TutorialMenu extends SpeckMenu
{
	private var m_curStep:Int; 
	private var m_curContainer:DisplayObjectContainer;
	
	public function new() 
	{
		super( "TutorialMenu" );
		
		// Initialize members for first displayed step
		m_curStep = 1; 
		showNextStep();
		
		// Disable HUD during the tutorial
		SpeckGlobals.hud.disableButtons();
		
		// Disable globe during the tutorial
		SpeckGlobals.hud.mainMenuRef.toggleMouseEnabled( false );
	}
	
	override public function onButtonHit(?caller:GraphicButton):Void 
	{
		super.onButtonHit(caller);
		
		WebAudio.instance.play( "SFX/button_click" );	

		if ( caller.name.startsWith("btn_x") )
		{	
			exit();
		}
		else
		{
			m_curStep++;
			Actuate.tween( m_curContainer, SpeckGlobals.FADE_TIME, { alpha: 0 } );
			showNextStep();
		}
	}
	
	private function showNextStep():Void
	{
		if ( FlowController.currentMode == FlowMode.PILOT )
		{
			if ( m_curStep == 4 ) // Skip 4th and 5th step in pilot flow since those buttons don't exist
			{
				m_curStep = 6;
			}
		}
		
		if ( m_curStep <= 7 )
		{
			m_curContainer = cast getChildByName( "tut" + m_curStep );
			m_curContainer.alpha = 0;
			Actuate.tween( m_curContainer, SpeckGlobals.FADE_TIME, { alpha: 1 } );
		}
		else 
		{
			exit();
		}
	}
	
	private function exit()
	{
		// Hide menu
		m_curContainer.visible = false;
			
		// Unload tutorial assets
		LibraryLoader.unloadLibraries( SpeckLoader.tutorialBubbleAssets );
		
		// Reenable HUD & globe
		SpeckGlobals.hud.enableButtons();
		SpeckGlobals.hud.mainMenuRef.toggleMouseEnabled( true ); 
	}
}