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
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import game.ui.SpeckMenu;
import openfl.display.DisplayObjectContainer;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

// Uses tweening and dragging logic from ScrollingManager.hx
// 		TODO - build & incorporate more robust scrolling class 
class TextScrollingManager extends DisplayObjectContainer
{
	private var m_mouseDown:Bool;
	private var m_downPosY:Float;
	private var m_prevPosY:Float;
	private var m_label:TextField;
	private var m_swipeTime:Float;
	private var m_velocityY:Float;
	private var m_mouseField:Sprite;
	private var m_upperBound:Float;
	private var m_lowerBound:Float;

	private var tweening:Bool = false;
	private var m_drag:Float; // flipped +/- depending on direction
	private static inline var VELOCITY_DAMPING:Float = 1.25;
	private static inline var DRAG:Float = 1;
	
	public function new( parent:SpeckMenu, label:TextField, xPos:Float, yPos:Float, scrollWidth:Float, scrollHeight:Float ) 
	{
		super();
		
		// Init swipe time
		m_swipeTime = 0;
		
		// Get text
		m_label = label;
		
		// Determine upper/lower scroll bounds
		m_upperBound = yPos;
		m_lowerBound = yPos + scrollHeight;
		
		// Add bounding (mouse detection) sprite
		m_mouseField = new Sprite();
		m_mouseField.graphics.beginFill(0, 0);
		m_mouseField.graphics.drawRect( xPos, yPos, scrollWidth, scrollHeight );
		m_mouseField.graphics.endFill();
		this.addChild( m_mouseField );
		
		// Create mask based on bounding sprite
		var fieldBounds:Rectangle = m_mouseField.getBounds(m_mouseField.parent);
		var scrollMask:Shape = new Shape();
		parent.addChild(scrollMask);
		scrollMask.graphics.beginFill(0xFF00FF, 1);
		scrollMask.graphics.drawRect( fieldBounds.x, fieldBounds.y, fieldBounds.width, fieldBounds.height);
		scrollMask.graphics.endFill();
		label.mask = scrollMask;
		
		m_mouseField.addEventListener( Event.ADDED_TO_STAGE, onAdded );
	}
	
	private function onMouseDown( e:MouseEvent ):Void
	{
		if ( m_mouseField.hasEventListener( Event.ENTER_FRAME ) )		removeEventListener( Event.ENTER_FRAME, tween );
		tweening = false;
		m_swipeTime = 0;
		m_mouseDown = true;
		m_downPosY = e.localY;
		m_prevPosY = m_downPosY;
	}
	
	private function onMouseMove( e:MouseEvent ):Void
	{		
		// If we're holding down and dragging
		if ( m_mouseDown ) 
		{
			var curPosY:Float = e.localY;
			var distanceY:Float = curPosY - m_prevPosY;
						
			if ( (distanceY < 0 ) && !atUpperLimit() )
			{
				m_label.y += distanceY;
			}
			else if ( (distanceY > 0) && !atLowerLimit() )
			{
				m_label.y += distanceY;
			}

			m_prevPosY = curPosY;
		}
	}
	
	private function onMouseUp( e:MouseEvent ):Void
	{
		var distanceY:Float = e.localY - m_downPosY; // Distance from start of swipe
		m_velocityY = (distanceY / m_swipeTime) / VELOCITY_DAMPING; // Pixels/frame
		
		// Set drag coefficient and start tweening based on direction:
		if ( m_velocityY > 0 && !atLowerLimit() )
		{	
			m_drag = DRAG * -1; 
			
			if ( !tweening && !hasEventListener( Event.ENTER_FRAME ) ) 
			{
				addEventListener( Event.ENTER_FRAME, tween );
				tweening = true;
			}
		}
		else if ( m_velocityY < 0 && !atUpperLimit() )
		{
			m_drag = DRAG;
			
			if ( !tweening && !hasEventListener( Event.ENTER_FRAME ) ) 
			{
				addEventListener( Event.ENTER_FRAME, tween );
				tweening = true;
			}
		}

		// Reset values
		m_mouseDown = false;
	}
	
	// Measure the number of frames spent swiping
	private function onFrame( e:Event ):Void
	{
		if ( m_mouseDown && !tweening )	m_swipeTime++;
	}
	
	// Move text each frame
	private function tween( e:Event ):Void
	{	
		if ( ( atUpperLimit() || (m_drag < 0 && ( m_velocityY <= 0 ) ) ) || 
			 ( atLowerLimit() || (m_drag > 0 && ( m_velocityY >= 0 ) ) )  )
		{
			m_mouseField.removeEventListener( Event.ENTER_FRAME, tween );
			tweening = false;
		}
		else 
		{
			m_label.y += m_velocityY; 
			m_velocityY += m_drag;
		}
	}
	
	private function atUpperLimit():Bool
	{		
		return m_label.y + m_label.height <= m_lowerBound;
	}
	
	private function atLowerLimit():Bool
	{		
		return (m_label.y) >= m_upperBound;
	}
	
	private function onMouseOut( e:Event ):Void
	{
		m_mouseDown = false;
	}
	
	private function onAdded( e:Event ):Void
	{
		m_mouseField.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		m_mouseField.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		m_mouseField.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		m_mouseField.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
		m_mouseField.addEventListener( Event.ENTER_FRAME, onFrame );
		m_mouseField.addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
	}
	
	private function onRemoved( e:Event ):Void
	{
		// Clean up event listeners
		if ( m_mouseField.hasEventListener( MouseEvent.MOUSE_UP ) ) 	m_mouseField.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		if ( m_mouseField.hasEventListener( MouseEvent.MOUSE_DOWN ) ) 	m_mouseField.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		if ( m_mouseField.hasEventListener( MouseEvent.MOUSE_MOVE ) ) 	m_mouseField.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		if ( m_mouseField.hasEventListener( MouseEvent.MOUSE_OUT ) ) 	m_mouseField.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
		if ( m_mouseField.hasEventListener( Event.ENTER_FRAME ) ) 		m_mouseField.removeEventListener( Event.ENTER_FRAME, onFrame );
		if ( m_mouseField.hasEventListener( Event.REMOVED_FROM_STAGE) ) m_mouseField.addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
	}
}