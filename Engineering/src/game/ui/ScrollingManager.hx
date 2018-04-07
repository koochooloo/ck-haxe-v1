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

package game.ui;
import com.firstplayable.hxlib.display.GenericMenu;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import game.ui.ScrollingManager.PanDirection;
import game.ui.ScrollingManager.ScrollPoint;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

// Menus in the app scroll in one of two directions: 
enum ScrollingOrientation
{
	HORIZONTAL;
	VERTICAL;
}

enum PanDirection
{
	RIGHT;
	LEFT;
	UP;
	DOWN;
}

// For easy position ref
typedef ScrollPoint =
{
	x:Float,
	y:Float
}

// For easy sprite bounds ref (coordinate space is non-intuitive?)
typedef ScrollArea =
{
	x1:Float,
	x2:Float,
	y1:Float,
	y2:Float
}

 /*
  * SCROLLING ITEM: 
  *  	Small container class for DisplayObjectContainer items that are parented to a different menu. Items from other menus are represented as panels 
  * 		with children assets (images, buttons, etc.) by paist convention. This class stores those as well as some other relevant data for 
  * 		editing and referencing. For example, for ease of use, this class also explicitly stores the button child of these paist groups.
  * 	
  * 	NOTE: Position data is in reference to the original parent menu, not this child menu as a sub-coordinate-space within it. 
  * */
class ScrollingItem extends DisplayObjectContainer
{
	private static inline var DRAG:Float = 2;
	
	public var scrollWidth(default, null):Float; 
	public var scrollHeight(default, null):Float;
	public var scrollId(default, null):Int; 
	public var hidden:Bool;
	
	private var m_pos:ScrollPoint; // Position assigned by actions in this menu.
	private var m_container:DisplayObjectContainer;
	private var m_button:GraphicButton;
	private var m_parentMenu:DisplayObjectContainer;
	private var m_scrollMenu:ScrollingManager;
	private var m_tapThreshold:Float;
	private var m_button2:GraphicButton; // SECONDARY BUTTON - for favorites menu "remove" button, by definition placed on top of the regular button
	private var m_velocity:Float;
	private var m_dir:PanDirection;
	private var m_drag:Float;
	
	public function new( parent:DisplayObjectContainer, scrollMenu: ScrollingManager, container:DisplayObjectContainer, button:GraphicButton, id:Int, ?secondaryButton:GraphicButton )
	{
		super();
		m_parentMenu = parent;
		m_scrollMenu = scrollMenu;
		m_container = container;
		m_button = button;
		m_button2 = secondaryButton;
		m_pos =  { x: container.x, y: container.y };
		hidden = false;
		
		scrollId = id;
		
		scrollWidth = button.width;
		scrollHeight = button.height;
		name = button.name;
		
		m_container.addEventListener( Event.ENTER_FRAME, onFrame );
	}
	
	// ------------------------------
	// ---- Movement functions ------
	// ------------------------------
	
	public function reposition( distance:Float, bounds:ScrollArea, dir:PanDirection, ?velocity:Float = 0):Void
	{
		// Switchboard for the relative direction the sprite should move in
		m_dir = dir;
		
		if ( velocity != 0)
		{
			m_velocity = velocity;

			m_drag = switch( dir )
			{
				case PanDirection.RIGHT: DRAG * -1;
				case PanDirection.LEFT: m_drag = DRAG;
				case PanDirection.UP: m_drag = DRAG;
				case PanDirection.DOWN: m_drag = DRAG * -1;
			}
			
			// Instruction to move the sprite (if not currently moving) 
			if (! hasEventListener( Event.ENTER_FRAME ) ) addEventListener( Event.ENTER_FRAME, tween );
		}
		else
		{
			switch( m_scrollMenu.orientation )
			{
				case ScrollingOrientation.HORIZONTAL:
				{
					m_pos.x += distance;
					m_container.x = m_pos.x;
				}
				case ScrollingOrientation.VERTICAL:
				{
					m_pos.y += distance;
					m_container.y = m_pos.y;
				}
			}
		}
	}
	
	private function inBounds():Bool
	{
		// Detect whether or not the item is being moved out of the scroll bounds
		// 		NOTE: Item pos based on the container pos, which is anchored at the top left corner.
		var inBounds:Bool = switch ( m_scrollMenu.orientation )
		{
			case VERTICAL: 	(m_pos.y + scrollHeight) > m_scrollMenu.mousefieldBounds.y1 && (m_pos.y) < m_scrollMenu.mousefieldBounds.y2;
			case HORIZONTAL: (m_pos.x + scrollWidth) > m_scrollMenu.mousefieldBounds.x1 && (m_pos.x) < m_scrollMenu.mousefieldBounds.x2;
		}
		
		return true ;// inBounds;
	}
	
	private function tween( e:Event ):Void
	{
		if ( (m_drag < 0 && m_velocity <= 0) || (m_drag > 0 && m_velocity >= 0) )
		{
			stopTween();
		}
		else 
		{
			switch( m_scrollMenu.orientation )
			{
				case ScrollingOrientation.HORIZONTAL:
				{
					m_pos.x += m_velocity;
					m_container.x = m_pos.x;
				}
				case ScrollingOrientation.VERTICAL:	
				{
					m_pos.y += m_velocity;
					m_container.y = m_pos.y;
				}
			}
			
			m_velocity += m_drag;
		}
	}
	
	public function stopTween():Void
	{
		if ( hasEventListener( Event.ENTER_FRAME ) ) removeEventListener( Event.ENTER_FRAME, tween );
	}
	
	private function onFrame( e:Event ):Void
	{
		if ( inBounds() && !hidden )
		{
			show();
		}
		else
		{
			hide();
		}
	}
	
	// ------------------------------
	// --- Interaction functions ----
	// ------------------------------
	
	public function tap( tapPos:ScrollPoint ):Void
	{
		// Check secondary button first, as it is overlayed on top of the primary button
		if ( m_button2 != null && isButtonLocatedAt( tapPos/*, "secondary"*/ ) && m_button2.enabled )
		{
			m_button2.onHit( m_button2 );
		}
		else if ( m_button.enabled ) 
		{
			m_button.onHit( m_button );
		}
	}
	
	// For testing primary vs secondary button tap
	//		Similar to isLocatedAt but tests button location instead of testing the whole ScrollingItem
	public function isButtonLocatedAt( pos:ScrollPoint /*, num:String */)
	{
		var b:GraphicButton = ( m_button2 != null )? m_button2:m_button; 

		var bGlobalPosX = (m_pos.x + scrollWidth - b.width);
		var bGlobalPosY = (m_pos.y + scrollHeight - b.height);

		var upperBoundPos:ScrollPoint = { x: bGlobalPosX + b.width, y: bGlobalPosY + b.height };
		var lowerBoundPos:ScrollPoint = { x: bGlobalPosX, y: bGlobalPosY } ;
		
		var xbound:Bool = pos.x >= lowerBoundPos.x &&  pos.x <= upperBoundPos.x;
		var ybound:Bool = pos.y >= lowerBoundPos.y &&  pos.y <= upperBoundPos.y;
		
		return (xbound && ybound); 
	}
	
	public function switchState( mouseOver:Bool ):Void
	{
		var b:GraphicButton = ( m_button2 != null ) ? m_button2 : m_button; 

		// Disabled state currently unused & mirrors upState
		b.upState = ( mouseOver ) ? b.overState : b.disabledState;
	}
	
	// --------------------------------------
	// --- Position & Visibility Helpers ----
	// --------------------------------------
	
	public function isLocatedAt( pos:ScrollPoint ):Bool
	{
		var upperBoundPos:ScrollPoint = { x: m_pos.x + scrollWidth, y: m_pos.y + scrollHeight };
		var lowerBoundPos:ScrollPoint = { x: m_pos.x, y: m_pos.y } ;
		
		var xbound:Bool = pos.x >= lowerBoundPos.x &&  pos.x <= upperBoundPos.x;
		var ybound:Bool = pos.y >= lowerBoundPos.y &&  pos.y <= upperBoundPos.y;
		
		return (xbound && ybound); 
	}
	
	public function isAbove( pos:ScrollPoint ):Bool
	{
		return m_pos.y + ( scrollHeight * 1.25 ) < pos.y; // Want bottom item to be a little above the lower limit
	}
	
	public function isBelow( pos:ScrollPoint ):Bool
	{
		return m_pos.y > pos.y;
	}
	
	public function isLeftOf( pos:ScrollPoint ):Bool
	{
		return m_pos.x + ( scrollWidth * 1.25 ) < pos.x; // Want leftmost item to be a little left of the lower limit
	}
	
	public function isRightOf( pos:ScrollPoint ):Bool
	{
		return m_pos.x > pos.x;
	}
	
	public function show():Void
	{
		m_container.visible = true;
		
		for ( child in m_container.__children ) 
		{
			child.visible = true;
		}
	}
	
	public function hide():Void
	{
		m_container.visible = false;
		for ( child in m_container.__children ) 
		{
			child.visible = false;
		}
	}
	
	public function isVisible():Bool
	{
		return m_container.visible;
	}
	
	public function clear():Void
	{
		// Remove event listeners
		stopTween();
		if ( m_container.hasEventListener( Event.ENTER_FRAME ) ) m_container.removeEventListener( Event.ENTER_FRAME, onFrame );
		
		// Remove from display tree
		for ( child in m_container.__children )
		{
			m_container.removeChild( child );
		}
		
		m_parentMenu.removeChild( m_container );
	}
}

/*
 * SCROLLING MANAGER: 
 * 		A management class for scrolling functionality. To be used as a child of another menu, and given DisplayObjectContainers from that menu.
 * 			Class handles object positioning, then defers to the parent menu for appropriate event handling for those objects. 
 * 
 * 		Uses a transparent overlay sprite to detect mouse input, and redirects to appropriate "on button hit" functionality for the given 
 * 			child in the parent class. This overlay is defined in parent coordinate space & given by the parent. 
 * */
class ScrollingManager extends DisplayObjectContainer
{
	// ------ Static tunable vars:
	private static inline var SWIPE_THRESHOLD:Float = 20; // Number of pixels between mouse up/down events that articulates a swipe vs tap action
	private static inline var VELOCITY_DAMPING:Float = 1.25; // Denominator scaling to reduce swipe velocity for aesthetic/usability
	
	// ------ Public vars:
	public var orientation(default, null):ScrollingOrientation;
	public var mousefieldBounds(default, null):ScrollArea;
	public var topMaskEnd(default, null):Float;
	public var bottomMaskStart(default, null):Float;
	
	// ------ Member vars:	
	private var m_mouseField:Sprite; // A rectangle placed as a detection area over the menu space
	private var m_downPos:ScrollPoint;
	private var m_globalId:Int; // Id tally for items. Unique to this menu instance. (Unsafe re:overflow? Though in practice is not likely to occur.) 
	private var m_parentMenu:DisplayObjectContainer;
	private var m_items:Array< ScrollingItem >; // List of all items in the menu.
	private var m_displayNum:Int; // Number of items visible in the menu at once; used for scroll val tuning. 
	private var m_mouseDown:Bool;
	private var m_bar:OPSprite; // Scroll bar
	private var m_barTrack:OPSprite; // Tracker for scroll bar
	private var m_itemHeight:Float = 0;
	private var m_itemWidth:Float = 0;
	private var m_cols:Int;

	private var m_swipeTime:Float;
	private var m_prevPos:ScrollPoint;
	
	public function new( xPos:Float, yPos:Float, width:Float, height:Float, parent:DisplayObjectContainer, p_orientation:String, displayNum:Int, ?cols:Int = 1 ) 
	{
		super();
		
		// Init members
		m_globalId = 0;
		m_parentMenu = parent;
		m_displayNum = displayNum;
		m_items = new Array();
		m_mouseDown = false;
		m_cols = cols;
		
		m_swipeTime = 0;
		
		// Create bounding sprite to detect mouse movement
		mousefieldBounds = { x1: xPos, x2: xPos + width, y1: yPos, y2: yPos + height };
		m_mouseField = new Sprite();
		m_mouseField.graphics.beginFill(0, 0);
		m_mouseField.graphics.drawRect( xPos, yPos, width, height );
		m_mouseField.graphics.endFill();
		this.addChild( m_mouseField );
		
		//==============================
		// Use the mouse field to determine scroll limits
		//==============================
		topMaskEnd = mousefieldBounds.y1;
		bottomMaskStart = mousefieldBounds.y2;
		
		// Add event listeners to the bounding sprite
		m_mouseField.addEventListener( MouseEvent.MOUSE_UP, onMouseUp ); 
		m_mouseField.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown ); 
		m_mouseField.addEventListener( MouseEvent.MOUSE_MOVE, onMouseOver );
		m_mouseField.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
		m_mouseField.addEventListener( Event.ENTER_FRAME, onFrame );

		//Determine orientation
		switch (p_orientation) 
		{
			case "horizontal": 		
			{
				orientation = ScrollingOrientation.HORIZONTAL;
			}
			case "vertical": 
			{
				orientation = ScrollingOrientation.VERTICAL;
			}
		}
		
		// Add event listener for stage cleanup
		this.addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
	}
	
	public function reparent()
	{
		m_parentMenu.addChildAt( m_mouseField, m_parentMenu.numChildren );
	}
	
	// --------------------------------------
	// 	FRONT-FACING FUNCTIONS
	//  Add/remove objects from scroll
	// ---------------------------------------
	
	// Adds ScrollingMenuItem to the Scrolling Menu. Called externally by parent menu (ex - on new() populate with menu items)
	// As per project paist convention, items being passed should be grouping panel DisplayObjectContainerContainers that parent the buttons, labels, etc.
	// 
	// ***Returns item so the parent can track it for removal (TODO - unsafe? Unnecessary?) 
	public function addItem( groupPanel:DisplayObjectContainer, button:GraphicButton, ?secondaryButton:GraphicButton ):Int
	{
		//Create a clone of the mouse field.
		var fieldBounds:Rectangle = m_mouseField.getBounds(m_mouseField.parent);
		
		for (i in 0...groupPanel.numChildren)
		{
			var nextChild:DisplayObject = groupPanel.getChildAt(i);
			var scrollMask:Shape = new Shape();
			groupPanel.parent.addChild(scrollMask);
			scrollMask.graphics.beginFill(0xFF00FF, 1);
			scrollMask.graphics.drawRect( fieldBounds.x, fieldBounds.y, fieldBounds.width, fieldBounds.height);
			scrollMask.graphics.endFill();
			nextChild.mask = scrollMask;
		}
		
		var item:ScrollingItem = new ScrollingItem( m_parentMenu, this, groupPanel, button, m_globalId, secondaryButton);

		// Add item to scroll list.
		m_items.push( item );
		m_globalId++;
		
		// Make sure item is visible
		item.show();
		
		// Assumes uniform scrolling items
		m_itemHeight = button.height;
		m_itemWidth = button.width;
		
		// Return id for parent's tracking
		return item.scrollId;
	}
	
	public function clear():Void
	{
		for ( item in m_items )
		{
			//item.hide();
			item.clear();
		}
		
		m_items = new Array();
	}
	
	// Displays m_displayNum items. Hide the rest.
	// ***To be called after the parent menu adds all of its desired items.
	public function init():Void
	{
		if ( m_items.length == 0 )
		{
			return; 
		}
		
		showAll();
		
		if ( (m_bar != null && atLowerScrollLimit() && atUpperScrollLimit() ) )
		{
			m_bar.visible = false;
			m_barTrack.visible = false;
		}
	}
	
	// Hide mousefield & all items in the menu, without removing them from the list.
	public function hideAll():Void
	{
		for ( item in m_items )
		{
			item.hide();
			item.hidden = true;
		}
		
		m_mouseField.visible = false;
	}
	
	// Show mousefield & all items in menu
	public function showAll():Void
	{
		for ( item in m_items )
		{
			item.show();
			item.hidden = false; 
		}
		
		m_mouseField.visible = true;
	}
	
	// --------------------------------------
	// 	HELPER FUNCTIONS
	//  For pan/scroll, used by events (below)
	// ---------------------------------------
	
	// We don't want users to be able to infinitely scroll things offscreen & then have to get them back...
	//		So use this to impose a limit on how far down/up they can scroll.
	// Returns true if the last item is above or right of the top/leftmost bounds. 
	private function atUpperScrollLimit():Bool
	{
		var item:ScrollingItem;

		item = m_items[ m_items.length - 1 ];
		
		var lowerLimit:ScrollPoint = { x: mousefieldBounds.x2, y: mousefieldBounds.y2};	

		switch( orientation ) 
		{
			case ScrollingOrientation.HORIZONTAL: 	return item.isLeftOf( lowerLimit );
			case ScrollingOrientation.VERTICAL: 	return item.isAbove( lowerLimit );
		}
	}
	
	//	Returns true if the first item is just below the upper (or just left of the leftmost) bounds. 
	// 	Bounds are dimensions * 2 because it's testing againt the upper left hand corner of the sprite.
	private function atLowerScrollLimit():Bool
	{	
		var item:ScrollingItem;

		item = m_items[ 0 ];
		
		var upperLimit:ScrollPoint = { x: mousefieldBounds.x1, y: mousefieldBounds.y1}; 
		
		switch( orientation ) 
		{
			case ScrollingOrientation.HORIZONTAL: 	return item.isRightOf( upperLimit );
			case ScrollingOrientation.VERTICAL: 	return item.isBelow( upperLimit );
		}
	}
	
	// ----------------------
	// 	MOUSE EVENTS
	//  Use screen pos x/y
	// ----------------------
	
	private function onMouseOver( e:MouseEvent ):Void
	{	
		// Trigger button overstates where applicable
		for ( item in m_items )
		{
			var isOver:Bool = item.isButtonLocatedAt( { x: e.localX, y: e.localY } ); 
			item.switchState( isOver );
		}
		
		// If the mouse is down & moving over the scroll area, enact a "drag" action
		if ( m_mouseDown ) 
		{
			var curPos:ScrollPoint = { x: e.localX, y: e.localY };
			var distanceX:Float = curPos.x - m_prevPos.x;
			var distanceY:Float = curPos.y - m_prevPos.y;
			var direction:PanDirection = null;
			var atLimit:Bool = false;
								
			switch( orientation ) 
			{
				case ScrollingOrientation.HORIZONTAL:
				{
					if ( distanceX > 0 )	
					{
						atLimit = atLowerScrollLimit();
						direction = PanDirection.RIGHT;
					}
					else
					{
						atLimit = atUpperScrollLimit();
						direction = PanDirection.LEFT;
					}
					
					if ( !atLimit )
					{
						for ( item in m_items )
						{
							item.reposition( distanceX, mousefieldBounds, direction );
						}	
					}
				}
				case ScrollingOrientation.VERTICAL:
				{
					if ( distanceY < 0 )	
					{
						atLimit = atUpperScrollLimit();
						direction = PanDirection.UP;
						repositionScrollBar( distanceY, direction );
					}
					else 
					{
						atLimit = atLowerScrollLimit();
						direction = PanDirection.DOWN;
						repositionScrollBar( distanceY, direction );
						
					}
					
					if ( !atLimit )
					{
						for ( item in m_items )
						{
							item.reposition( distanceY, mousefieldBounds, direction );
						}
					}
				}
			}
			
			m_prevPos = curPos;
		}
	}
	
	// Track the position, to be combined with data from onMouseUp to determine tap vs drag
	private function onMouseDown( e:MouseEvent ):Void
	{
		if ( m_items.length > 0 )
		{
			// Only trigger if the mousefield is visible
			if ( !m_mouseField.visible )
			{
				m_downPos = null;
				return; 
			}

			// Restart swipe timer
			m_swipeTime = 0;
			
			// Set global mouseDown and save position
			m_mouseDown = true;
			m_downPos = { x: e.localX, y: e.localY };
			m_prevPos = m_downPos;
		}
	}

	// Combines with data from onMouseUp to determine tap vs drag
	private function onMouseUp( e:MouseEvent ):Void
	{
		if ( m_items.length > 0 )
		{

			var upPos:ScrollPoint = { x: e.localX, y: e.localY };
			m_mouseDown = false;
			
			// Early return if there has been no recorded MOUSE_DOWN
			if ( m_downPos == null || !m_mouseField.visible )
			{
				return;
			}
			
			// If we released at the same point as we pressed, it's a tap action
			if ( upPos.x == m_downPos.x && upPos.y == m_downPos.y)
			{
				tap( upPos );
				return; 
			}

			// Otherwise, we're swiping. Get direction info:
			var distance:Float = 0;
			var direction:PanDirection = null;
			var atLimit:Bool = false;
			
			switch( orientation )
			{
				case ScrollingOrientation.HORIZONTAL:
				{
					distance = upPos.x - m_downPos.x;
					
					if ( distance > 0 )
					{
						atLimit = atLowerScrollLimit();
						direction = PanDirection.RIGHT;
					}
					else
					{
						atLimit = atUpperScrollLimit();
						direction = PanDirection.LEFT;
					}
				}
				case ScrollingOrientation.VERTICAL:
				{
					distance = upPos.y - m_downPos.y; 
					if ( distance > 0 )
					{
						atLimit = atLowerScrollLimit();
						direction = PanDirection.DOWN;
					}
					else
					{
						atLimit = atUpperScrollLimit();
						direction = PanDirection.UP;
					}
				}
			}
			
			//Get swipe data:
			var velocity = (distance / m_swipeTime) / VELOCITY_DAMPING; // Pixels/frame
			
			// And pass it to each item for repositioning
			if ( !atLimit )
			{
				for ( item in m_items )
				{
					item.reposition( distance, mousefieldBounds, direction, velocity );
				}
			}
		}
	}
	
	// If we exit, stop movement.
	private function onMouseOut( e:MouseEvent ):Void
	{
		if ( m_items.length > 0 )
		{
			m_mouseDown = false; 
		}
	}

	// Triggered when a tap is detected. Checks for a button & defers to parent menu's onButtonHit.
	private function tap( tapPos:ScrollPoint ):Void
	{
		for ( item in m_items ) 
		{
			if ( item.isLocatedAt( tapPos ) )
			{
				item.tap( tapPos );
			}
		}
	}
	
	private function onFrame( e:Event ):Void
	{	
		// Callback for each time the frame refreshes - used to det. swipe velocity
		if ( m_mouseDown )
		{
			m_swipeTime++;
		}
		
		// Make sure item list stops tweening when they hit respective limits
		if ( (m_items.length > 0) && (atLowerScrollLimit() || atUpperScrollLimit()) )
		{
			for ( item in m_items )
			{
				item.stopTween();
			}
		}
	}
	
	// Callback for when the Scrolling Manager is removed from the stage
	private function onRemoved( e:Event ):Void 
	{
		dispose();
	}
	
	public function dispose():Void
	{
		removeEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		
		// remove event listeners from items
		for ( item in m_items )
		{
			item.clear();
		}
		
		// remove event listeners from the mousefield
		m_mouseField.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		m_mouseField.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		m_mouseField.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseOver );
		m_mouseField.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
		m_mouseField.removeEventListener( Event.ENTER_FRAME, onFrame );
	}
	
	public function addScrollBar( scrollBar:OPSprite, scrollTrack:OPSprite ):Void
	{
		m_barTrack = scrollTrack;
		m_bar = scrollBar;
	}
	
	private function repositionScrollBar( dist:Float, dir:PanDirection ):Void
	{
		
		// NOTE: only works for vertical scrolling lists. 
		//		TODO - Functionality for horizontal menu scrollbars
		
		if ( m_bar == null || m_bar.visible == false )
		{
			return;
		}
		
		// Calculate top and bottom for scroll bar and scroll bar track sprites
		// Scroll track top/bottom are the effective top/bottom for the scroll bar. That is, they take the bar sprite size/anchoring into account.
		// NOTE: Scroll bar is anchored at the center
		var trackTop:Float = Math.ceil( m_barTrack.y + m_bar.height / 2 );
		var trackBottom:Float = Math.floor( m_barTrack.y + m_barTrack.height - m_bar.height / 2 ); 
		var barTop:Float = Math.ceil( m_bar.y ) ;
		var barBottom:Float = Math.floor( m_bar.y );
		
		// Amount of space the scrollbar has to move
		var scrollBarSpace:Float = trackBottom - trackTop;
		
		// Amount of space the whole list of items has outside of the visible field
		var listSpace:Float = Math.ceil( (m_items.length * m_itemHeight / m_cols ) ) - m_mouseField.height ;
		
		// Ratio between scrollbar movement space and total movement space
		var movementRatio:Float = scrollBarSpace / listSpace;
		
		// Amount the scrollbar moves is the amount scroll (dist) multiplied by the ratio between spaces.
		// 		Sign is flipped so the scrollbar moves with the items (opposite dir) 
		var distance:Float = dist * movementRatio * -1 / VELOCITY_DAMPING;
		
		switch ( dir )
		{
			case PanDirection.LEFT:
			{
				// todo
			}
			case PanDirection.RIGHT:
			{
				// todo
			}
			case PanDirection.UP:
			{
				// Cap scrollbarm movement if the list is at an extreme or the motion would move it off the track
				if ( atUpperScrollLimit() || (barBottom + distance) >= trackBottom )
				{
					m_bar.y = trackBottom;
				}
				else
				{
					m_bar.y += distance;
				}
			}
			case PanDirection.DOWN:
			{
				// Cap scrollbarm movement if the list is at an extreme or the motion would move it off the track
				if ( atLowerScrollLimit() || (barTop + distance) <= trackTop )
				{
					m_bar.y = trackTop;
				}
				else
				{
					m_bar.y += distance;
				}
			}
		}
	}
}