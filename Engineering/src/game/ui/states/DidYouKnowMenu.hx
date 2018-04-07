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
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.Country;
import game.SocialIssue;
import game.controllers.FlowController;
import game.def.GameState;
import game.ui.SpeckMenu;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

class DidYouKnowMenu extends SpeckMenu
{
	private static var SCROLLWIDTH:Int = 560;
	private static var SCROLLHEIGHT:Int = 330;
	
	private var m_selectedIssue:SocialIssue;
	
	public function new( p:GameStateParams ) 
	{
		super( "DidYouKnowMenu" );

		var country:Country = FlowController.data.selectedCountry;
		
		// Replace text
		var socialText:TextField = cast getChildByName( "lbl_info" );
		
		// Add text scrolling - use pre-autoSize text box size for bounds
		var scrollMgr:TextScrollingManager = new TextScrollingManager( this, socialText, socialText.x, socialText.y, SCROLLWIDTH, SCROLLHEIGHT );
		this.addChild( scrollMgr );
		
		if ( country.socialIssues.length > 0 ) // TEMP - arbitrarily select first issue; not sure how multiple would be used
		{
			m_selectedIssue = country.socialIssues[0];
			socialText.text = m_selectedIssue.description;
			socialText.autoSize = TextFieldAutoSize.CENTER;
			socialText.wordWrap = true;
		}
		else
		{
			socialText.text = "No action info available for this country." ;
		}
		
		// Reparent button above scrolling text
		var actionButton:GraphicButton = cast getChildByName( "btn_takeAction" );
		addChildAt( actionButton, this.numChildren );
		
		showMenu();
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );

		WebAudio.instance.play( "SFX/button_click" );	

		if ( m_selectedIssue != null )
		{
			goToURL( m_selectedIssue.charityLink );
		}
	}
	
	private function goToURL( URL:String ):Void
	{
		StateManager.setState( GameState.PARENTAL, { args: [ GameState.DIDYOUKNOW, URL] } );
	}
}