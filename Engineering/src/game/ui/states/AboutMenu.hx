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
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import game.ui.SpeckMenu;
import game.ui.TextScrollingManager;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

// Uses tweening and dragging logic from ScrollingManager.hx
// 		TODO - build & incorporate more robust scrolling class 
class AboutMenu extends SpeckMenu
{
	private static var SCROLLWIDTH:Int = 580;
	private static var SCROLLHEIGHT:Int = 480; 
	
	private var m_mouseDown:Bool;
	private var m_downPosY:Float;
	private var m_prevPosY:Float;
	private var m_label:TextField;
	private var m_swipeTime:Float;
	private var m_velocityY:Float;
	private var m_mouseField:Sprite;

	private var tweening:Bool = false;
	private var m_drag:Float; // flipped +/- depending on direction
	private static inline var VELOCITY_DAMPING:Float = 2;
	private static inline var DRAG:Float = 1;
	
	public function new() 
	{
		super( "AboutMenu" );
		
		// Init swipe time
		m_swipeTime = 0;
		
		// Replace about text
		m_label = cast getChildByName( "lbl_about" );
		m_label.wordWrap = true;
		m_label.autoSize = TextFieldAutoSize.CENTER;
		
		// Add scrolling text menu
		var scrollMgr:TextScrollingManager = new TextScrollingManager( this, m_label, m_label.x, m_label.y, SCROLLWIDTH, SCROLLHEIGHT);
		this.addChild( scrollMgr );
		
		// Re-add check button so it sits above text.
		this.addChildAt( getButtonById( 0 ), this.numChildren );
		
		showMenu();
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void
	{
		super.onButtonHit( caller );
		
		WebAudio.instance.play( "SFX/button_click" );
		
		StateManager.setState( GameState.GLOBE );
	}
}