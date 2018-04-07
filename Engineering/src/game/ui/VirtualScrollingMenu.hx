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
import com.firstplayable.hxlib.display.OPSprite;
import game.ui.VirtualScrollingMenu.ScrollingData;
import haxe.ds.Option;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Sprite;

/**
 * Describes label text, image src, button src(s) to be populated onto an existing set of display objects. 
 * These are wrapped in Option<T> to allow variation in list items that are populated. 
 * @param imgSrc:String  - bitmap src URL
 * @param pBtnSrc:String - bitmap src URL
 * @param sBtnSrc:String - bitmap src URL for a second button (used in Favorites menu)
 * @param lbl:String 	 - text used to populate scrolling item label
 */
class ScrollingData
{
	public var imgSrc(default, null):Option< Bitmap >; // bitmap src URL
	public var primaryButtonSrc(default, null):Option< Bitmap >;
	public var secondaryButtonSrc(default, null):Option< Bitmap >;
	public var label(default, null):Option< String >;  // text used to populate scrolling item label
	
	public function new( ?img:Bitmap, ?pBtn:Bitmap,?sBtn:Bitmap, ?lbl:String )
	{
		imgSrc = (img != null) ? Some(img):None;
		primaryButtonSrc = (pBtn != null) ? Some(pBtn):None;
		secondaryButtonSrc = (sBtn != null) ? Some(sBtn):None;
		label = (lbl != null) ? Some(lbl):None;
	}
}

enum Orientation
{
	HORIZONTAL;
	VERTICAL;
}

/**
 * Defines directionality of scrolling items moving within a ScrollingOrientation
 * 		Horizonal forward = items move down
 * 		Horizontal backward = items move up
 * 		Vertical forward = items move right
 * 		Vertical backward = items mvoe left
 * */
enum Direction
{
	FORWARD;
	BACKWARD;
}

/**
 *  A menu that handles the movement and data population of single-row/column scrolling lists. 
 *  See MultidimensionalScrollingMenu for multi row/column support.
 * 
 * (Design TODO - make this a root class and split single and multidimensional logic both into extensions) 
 * 
 *  To be added as a child of an existing menu, and used to handle user input and the respositioning of items. 
 *  Items are still children of the parent menu.
 * 
 *  A small set of virtual scrolling items are displayed onscreen and looped into and out of view.
 *  These these items are populated with data (appropriate labels, images, etc.) as described by 
 * 	the user's current place in the dataset. This place is tracked by this class and moved forward/backwards as they scroll. 
 */
class VirtualScrollingMenu extends DisplayObjectContainer
{
	// ScrollArea - rectangular sprite drawn over the paist-defined scroll area. Used to detect mouse interaction over an area and to mask scrolling items 
	//		from view when scrolled out of bounds. The scroll area is a 1px sprite in paist scaled to fill the desired scroll bounds in the parent menu. 
	// 		It is passed to this menu via its constructor.
	private var m_scrollArea:Sprite; 
	
	private var m_dataset:Array< ScrollingData >; // An array of data used to edit VirtualScrollingItems, traversed during scrolling
	private var m_scrollingItems:Array< VirtualScrollingItem >; // An array of the scrolling display object groups
	private var m_visibleItems:Int; // Number of items visible at one time in the scrolling list
	private var m_userPos:Int; // Position of user in the scrolling list. Refers to the first visible item in the list
	private var m_startPos:Float; // Pixels - Where items looped to the upper scroll position will be placed (top/leftmost pos of the scrollbounds)
	private var m_endPos:Float;  // Pixels - Where items looped to the lower scroll position will be placed (bottom / rightmost pos of the scrollbonds)
	private var m_upperScrollLimit:Float; // Pixels - Top of the scroll bounds, used for max scroll testing
	private var m_lowerScrollLimit:Float; // Pixels - Bottom of the scroll bounds, used for min scroll testing
	private var m_orientation:Orientation; // Horizontal or vertical
	private var m_itemSpacing:Float; // Pixels - Vertical/horizontal space between item placement, depending on orientation. Includes item size + padding.
	private var m_itemSize:Float; // Pixels - Horizontal = width, vertical = height. List assumes uniform items.
	private var m_paistRef:DisplayObjectContainer; // Keep main ref for redrawing items
	
	// Movement helpers
	private var m_isMouseDown:Bool;
	private var m_downPos:Float; // Position of last "MOUSEDOWN" event 
	private var m_overPos:Float; // Position of last "MOUSEOVER" event
	private var m_swipeTime:Int; // Incremented every frame after mouseDown to help calc. swipe velocity (pixels/frame)
	private var m_velocity:Float; // Pixels/frame
	private var m_distance:Float; // Pixels
	private var m_drag:Float; // Pixels - incrementally subtracted from velocity as items tween
	private var m_isTweening:Bool;
	private var m_direction:Direction; // Movement Direction
	private static inline var DRAG:Float = 2;
	private static inline var TAP_THRESHOLD:Float = 5; // Number of pixels between mouse up/down events that articulates a pan/swipe vs tap action
	private static inline var SWIPE_THRESHOLD:Float = 10; // Number of pixels between mouse up/down events that articulates a swipe vs a pan/tap action
	private static inline var VELOCITY_DAMPING:Float = 2; // Scales down swipe velocity; aesthetic
	private var MAX_FRAME_DISTANCE:Float; // Max distance scrollable in one frame. Set to item size.
	
	// Scroll UI (scroll bar/scroll track)
	private var m_scrollBar:OPSprite;
	private var m_scrollTrack:OPSprite;
	
	/**
	 * Setup requires: 
	 * 		- two example groups of display objects for reference
	 * 		- a sprite that illustrates desired scrolling area
	 * 		- adding this menu as a child of a parent menu
	 * 		- parent menu to supply data (addData)
	 * @param scrollBounds - sprite used to define scroll area in paist
	 * @param orientation  - vertical or horizontal
	 */
	public function new( scrollBounds:OPSprite, orientation:Orientation, refGroup1:DisplayObjectContainer, refGroup2:DisplayObjectContainer, ?scrollBar:OPSprite, ?scrollTrack:OPSprite ) 
	{
		super();
		
		// ---------------------------------------------------
		// Init member vars
		// ---------------------------------------------------
		m_orientation = orientation; 
		m_dataset = new Array();
		m_scrollingItems = new Array();
		m_isMouseDown = false;
		m_swipeTime = 0;
		m_velocity = 0;
		m_distance = 0;
		m_isTweening = false;
		m_userPos = 0;
		
		// Use bounding sprite to determine scroll limits
		switch ( orientation )
		{
			case VERTICAL: 
			{
				m_upperScrollLimit = scrollBounds.y;
				m_lowerScrollLimit = scrollBounds.y + scrollBounds.scaleY;
			}
			case HORIZONTAL: 
			{
				m_upperScrollLimit = scrollBounds.x;
				m_lowerScrollLimit = scrollBounds.x + scrollBounds.scaleX;
			}
		}
	
		// ---------------------------------------------------
		// Create mouse detection sprite using paist reference
		// ---------------------------------------------------
		
		m_scrollArea = new Sprite();
		m_scrollArea.graphics.beginFill(0, 0);
		m_scrollArea.graphics.drawRect( scrollBounds.x, 
										scrollBounds.y, 
										scrollBounds.scaleX,
										scrollBounds.scaleY
									  ); // ScrollBounds is a scale-adjusted 1px sprite in paist, anchored at the top left corner
		m_scrollArea.graphics.endFill();
		
		// ---------------------------------------------------
		// Early return if invalid ref.
		// (Also a signal for multidimensional scroll override.)
		// ---------------------------------------------------
		if ( refGroup1 == null || refGroup2 == null )
		{
			Debug.log( "Null ref; ScrollingMenu returning early from constructor" );
			return;
		}
		
		// ---------------------------------------------------
		// Init other member vars using paist ref:
		// - Visisble items
		// - Item spacing
		// - Item size
		// - Start & End pos
		// - List of scrolling items
		// ---------------------------------------------------
		m_paistRef = refGroup1;
		addRef( refGroup1, refGroup2 );
		
		// ---------------------------------------------------
		// Add scroll bar/track, if applicable
		// ---------------------------------------------------
		addScrollUI( scrollBar, scrollTrack );
	}
	
	/**
	 *  Get paist ref and calculate visible items, object spacing, scrollingitem layout
	 *  @param refGroup1 - first display object container in the list
	 *  @param refGroup2 - second display object container in the list
	 */
	private function addRef( refGroup1:DisplayObjectContainer, refGroup2:DisplayObjectContainer ):Void
	{
		// Get ref item spacing & size
		// Use ref size and spacing + scrolling area size to det. visible items
		switch ( m_orientation )
		{
			case HORIZONTAL:	
			{
				m_itemSpacing = refGroup2.x - refGroup1.x; // Includes item size + padding
				m_itemSize = refGroup1.width;
				m_visibleItems = Math.ceil( m_scrollArea.width / m_itemSpacing );
				m_startPos = refGroup1.x;

			}
			case VERTICAL: 		
			{
				m_itemSpacing = refGroup2.y - refGroup1.y; // Includes item size + padding
				m_itemSize = refGroup1.height;
				m_visibleItems = Math.ceil( m_scrollArea.height / m_itemSpacing );
				m_startPos = refGroup1.y;
			}
		}
		
		// Set start/end position of the out of bounds items using scroll limits and item size
		m_endPos   = m_lowerScrollLimit + m_itemSpacing;
		
		// Set max frame distance to respective item width or height
		MAX_FRAME_DISTANCE = m_itemSize;
		
		// Adjust ref group to sit at the startpos
		switch( m_orientation )
		{
			case HORIZONTAL: refGroup1.x = m_startPos;
			case VERTICAL:   refGroup1.y = m_startPos;
		}
		
		populateScrollingItems();
		
		// Hide ref when we're done using it
		refGroup1.visible = false; 
		refGroup2.visible = false;
	}
	
	private function populateScrollingItems()
	{
		// Populate scrollingItems using the visible item number. 
		// Number of virtually scrolling display objects should be 1 + visibleItems 
		//		( All that are visible and one just below view; list display starts off at the top)
		var startX:Float = m_paistRef.x;
		var startY:Float = m_paistRef.y;
		
		var numItems:Int = m_visibleItems + 1;
		var count:Int = 0;
		
		for ( i in 0...numItems)
		{
			// Increment position
			if ( i > 0 )
			{
				switch( m_orientation )
				{
					case HORIZONTAL: m_paistRef.x += m_itemSpacing;
					case VERTICAL:   m_paistRef.y += m_itemSpacing;
				}
			}

			// Create & add scrolling item
			var item = new VirtualScrollingItem( m_paistRef, count );
			m_scrollingItems.push( item );
			
			// Add mask to scrolling item
			// NOTE: mask is currently added to all items for simplicity, but technically only needs to be added to the top/bottommost items.
			//		 If there is a space/memory need to reduce masking in the future, this is an option.
			item.addMask( m_scrollArea ); 
						
			// TEMP 
			count++;
		}
		
		m_paistRef.x = startX;
		m_paistRef.y = startY;
	}
	
	/**
	 *  To be called after adding data to scrolling menu, and after scrolling menu
	 * 	is added to parent.
	 * 
	 *  Adds event listeners and populates data onto first batch of objects.
	 */
	public function init()
	{
		initData();
		start();
		
		// Hide scroll bar if it is not needed
		var haveScrollUI:Bool = m_scrollBar != null && m_scrollTrack != null;
		if ( haveScrollUI && (m_visibleItems >= m_dataset.length) )
		{
			m_scrollBar.visible = false;
			m_scrollTrack.visible = false;
		}
		
		this.parent.addChild( m_scrollArea );
		
		cleanUpItems();

	}
	/**
	 *  Add event listeners
	 */
	private  function start()
	{
		// Add listeners to menu
		this.addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		
		// Add listeners to the scroll interaction sprite
		m_scrollArea.addEventListener( MouseEvent.MOUSE_UP, onMouseUp ); 
		m_scrollArea.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown ); 
		m_scrollArea.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		m_scrollArea.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
		m_scrollArea.addEventListener( Event.ENTER_FRAME, onFrame );
	}
	
	/**
	 *  Set up data for first batch of visible items
	 */
	private function initData()
	{
		if ( m_dataset.length == 0 )
		{
			Debug.log( "No data provided for scrolling items.");
			return;
		}
		
		var numItems:Int = Math.floor( Math.min(m_scrollingItems.length, m_dataset.length) );
		for ( i in 0...numItems ) // Populate items idx 1->length with data starting at idx 0. Item 0 is above field of view.
		{
			m_scrollingItems[i].updateData( m_dataset[i] );
		}
	}
	
	// ===================================
	// Data management functions
	// ===================================
	
	/**
	 * Helper function removes display object groups that have not been populated with data.
	 */
	private function cleanUpItems()
	{
		for ( item in m_scrollingItems )
		{
			if ( !item.isUpdated )
			{
				item.clear();
			}
		}
	}
	
	/**
	 * Adds data to virtual scrolling menu, to be populated onto objects
	 */
	public function addData( ?imgSrc:Bitmap, ?pBtnSrc:Bitmap, ?sBtnSrc:Bitmap, ?lbl:String )
	{
		var data:ScrollingData = new ScrollingData( imgSrc, pBtnSrc, sBtnSrc, lbl );
		m_dataset.push( data );
	}

	/**
	 * Returns true if user is at the start of the data list 
	 */
	private function atUpperScrollLimit():Bool
	{
		// Early return for empty items 
		if ( m_scrollingItems.length < 1 )
		{
			Debug.log( "Cannot detect upper scroll limits; no data available." );
			return true;
		}
		
		return ( scrolledOneItemForward() && m_userPos <= 0);
	}
	
	/**
	 *  Returns true if user is ( m_visibleItems ) away from the end of the data list.
	 */
	private function atLowerScrollLimit():Bool
	{
		// Early return for empty items 
		if ( m_scrollingItems.length < 1 )
		{
			Debug.log( "Cannot detect lower scroll limits; no data available." );
			return true;
		}
		
		var lastDataPos:Int = m_dataset.length - 1;
		return  scrolledOneItemBackward() && ( m_userPos >= (lastDataPos - m_visibleItems ) );
	}
	
	private function scrollingAtLimit( dir:Direction ):Bool
	{
		return ( dir == BACKWARD && atLowerScrollLimit() || dir == FORWARD && atUpperScrollLimit() );
	}
	
	// ===================================
	// Object positioning helper functions
	// ===================================
	
	/**
	 * Checks if list & repopulates a scrolling item at the top or bottom as needed
	 */
	private function handleVirtualReposition( dir:Direction ):Void 
	{
		var newItem:VirtualScrollingItem = null;
		var dataIdx:Int = 0;
		
		// Early return if user is scrolling towards the end of the list
		if ( scrollingAtLimit( m_direction ) )
		{
			return;
		}
		
		switch( dir )
		{
			case BACKWARD:
			{
				if ( scrolledOneItemBackward()) // only reposition items when a new one has come into view
				{
					dataIdx = m_userPos + m_visibleItems + 1;
					
					if (( dataIdx < m_dataset.length ))
					{
						newItem = repositionAtEnd();
						newItem.updateData( m_dataset[dataIdx] );
						m_userPos++;
					}
				}
			}
			case FORWARD:
			{
				if ( scrolledOneItemForward() ) // only reposition items when a new one has come into view
				{
					dataIdx = m_userPos - 1;
					
					if ( ( dataIdx >= 0 ) )
					{
						newItem = repositionAtStart();
						newItem.updateData( m_dataset[dataIdx] );
						m_userPos--;
					}
				}
			}
		}
	}
	
	/**
	 * Returns true if the bottom left corner of the first item in the list is below (left of) the start pos.
	 * Assumes top-left corner object anchoring.
	 */
	private function scrolledOneItemForward():Bool
	{
		// Early return for empty items 
		if ( m_scrollingItems.length < 1 )
		{
			Debug.log( "Cannot scroll forward. No items in scrolling list." );
			return false;
		}
		
		var firstItem:VirtualScrollingItem = m_scrollingItems[ 0 ];
		return ( firstItem.pos(m_orientation) >= m_upperScrollLimit);
	}
	
	/**
	 * Returns true if the top left corner of the last item in the list is above (right of) the end pos.
	 * Assumes top-left corner object anchoring.
	 */
	private function scrolledOneItemBackward():Bool
	{
		// Early return for empty items 
		if ( m_scrollingItems.length < 1 )
		{
			Debug.log( "Cannot scroll backward. No items in scrolling list." );
			return false;
		}
		
		var lastItem:VirtualScrollingItem = m_scrollingItems[ m_scrollingItems.length - 1 ];
		return ( lastItem.pos( m_orientation ) + m_itemSize <= m_lowerScrollLimit );
	}
	
	/**
	 * Take the last item of the list and place it at the top
	 * Returns reference to this item for data updates.
	 * */
	private function repositionAtStart():VirtualScrollingItem
	{
		// Early return for empty items 
		if ( m_scrollingItems.length < 1 )
		{
			Debug.log( "Cannot reposition items at start of list. No items in scrolling list." );
			return null;
		}
		
		var lastItem:VirtualScrollingItem = m_scrollingItems.pop();
		var firstItem:VirtualScrollingItem = m_scrollingItems[ 0 ];
		
		var firstItemPos:Float = firstItem.pos( m_orientation ) - m_itemSpacing;
		lastItem.setPosition( firstItemPos, m_orientation );
		m_scrollingItems.insert( 0, lastItem );
		
		return lastItem;
	}
	
	/**
	 * Take the first item of the list and place it at the bottom
	 * Returns reference to this item for data updates.
	 * */
	private function repositionAtEnd():VirtualScrollingItem
	{
		// Early return for empty items 
		if ( m_scrollingItems.length < 1 )
		{
			Debug.log( "Cannot reposition items at end of list. No items in scrolling list." );
			return null;
		}
		
		var firstItem:VirtualScrollingItem = m_scrollingItems.shift();
		var lastItem:VirtualScrollingItem = m_scrollingItems[ m_scrollingItems.length - 1 ];
		
		var lastItemPos:Float = lastItem.pos( m_orientation ) + m_itemSpacing;
		firstItem.setPosition( lastItemPos, m_orientation );
		m_scrollingItems.insert( m_scrollingItems.length, firstItem );
		
		return firstItem; 
	}
	
	/**
	 * Derive movement direction based on the sign of the distance float 
	 */
	private function getDirection( distance:Float ):Direction
	{
		var dir:Direction;
		if ( distance > 0 )
		{
			dir = FORWARD;
		}
		else
		{
			dir = BACKWARD;
		}
		return dir;
	}
	
	// ========================================
	// Object positioning/interaction callbacks
	// ========================================
	
	private function onMouseUp( e:MouseEvent ):Void
	{
		// Early return; mouseUp actions are dependent on mouseDown actions
		if ( !m_isMouseDown )
		{
			return;
		}
		
		m_isMouseDown = false;

		var pos:Float = switch ( m_orientation )
		{
			case HORIZONTAL: e.localX;
			case VERTICAL: 	 e.localY;
		}
		
		var distance:Float = pos - m_downPos;
		
		if ( distance > MAX_FRAME_DISTANCE )
		{
			distance = MAX_FRAME_DISTANCE;
		}
		
		// ---------------------------------------------------
		// Test for tap action - attempt to tap item button
		// ---------------------------------------------------
		var isTapAction:Bool = ( Math.abs( distance ) <= TAP_THRESHOLD);
		if ( isTapAction )
		{
			tap( e.localX, e.localY );
			return;
		}
		
		// ---------------------------------------------------
		// Test for swipe action - init tweens
		// ---------------------------------------------------
		var isSwipeAction:Bool = Math.abs( distance ) > SWIPE_THRESHOLD;
		if ( isSwipeAction && !m_isTweening )
		{
			m_direction = getDirection( distance );
			initTween( distance );
		}
	}
	
	private function onMouseDown( e:MouseEvent ):Void
	{
		m_isMouseDown = true;
		m_isTweening = false;
		m_swipeTime = 0;
		
		m_downPos = switch ( m_orientation )
		{
			case HORIZONTAL: e.localX;
			case VERTICAL: 	 e.localY;
		}
		
		m_overPos = m_downPos;
	}
	
	private function onMouseMove( e:MouseEvent ):Void
	{
		handleButtonOverState( e.localX, e.localY );
		
		// Only relevant if dragging; return if mouse is not down
		if ( !m_isMouseDown )
		{
			return;
		}
		
		// ---------------------------------------------------
		// Set up data for panning
		// ---------------------------------------------------
		var pos:Float = switch ( m_orientation )
		{
			case HORIZONTAL: e.localX;
			case VERTICAL: 	 e.localY;
		}
		
		var distance:Float = pos - m_overPos;
		if ( Math.abs( distance ) > MAX_FRAME_DISTANCE )
		{
			if ( distance > 0 ) distance = MAX_FRAME_DISTANCE;
			else if ( distance < 0 ) distance = MAX_FRAME_DISTANCE * -1;
		}
		
		m_overPos = pos;
		
		m_direction = getDirection( distance );
		// ----------------------------------------------------------
		// Early return if we are scrolling towards respective limits
		// ----------------------------------------------------------
		if ( scrollingAtLimit( m_direction ) )
		{
			return;
		}
		
		// ---------------------------------------------------
		// Pan items with the mouse drag
		// ---------------------------------------------------
		for ( item in m_scrollingItems )
		{
			item.incrementPosition( distance, m_orientation );
		}
		
		// ---------------------------------------------------
		// Update scroll bar pos. with panning items
		// ---------------------------------------------------
		repositionScrollBar( distance );
	}
	
	private function onMouseOut( e:MouseEvent ):Void
	{
		onMouseUp( e );
	}
	
	private function onFrame( e:Event ):Void
	{		
		// ---------------------------------------------------
		// Increment swipe time
		// ---------------------------------------------------
		if ( m_isMouseDown )
		{
			m_swipeTime++; // Increment swipe time per frame spent potentially swiping
		}
		
		// ---------------------------------------------------
		// Tween items (if applicable)
		// ---------------------------------------------------
		if ( scrollingAtLimit( m_direction ) )
		{
			m_isTweening = false; // Halt tweening if at respective limits
			return; // Do not attempt to add new items if at limits (skips handleVirtualReposition)
		}
		
		if ( m_isTweening )
		{	
			if ( (m_drag < 0 && m_velocity <= 0) || (m_drag > 0 && m_velocity >= 0) )
			{
				m_isTweening = false;
			}
			else 
			{
				// Update item pos
				for ( item in m_scrollingItems )
				{
					tweenItem( item, m_velocity );
				}
				
				// Update scroll bar pos
				repositionScrollBar( m_velocity );
				
				m_velocity += m_drag;
			}
		}
		
		// ---------------------------------------------------
		// Update new sprites above/below as the list moves,
		//		as determined by sprite position
		// ---------------------------------------------------
		if ( m_direction != null )
		{
			handleVirtualReposition( m_direction );
		}
	}

	/**
	 * Tween moves objects with momentum. Tweening occurs in onFrame, and this function
	 * sets the environment up for tweening. 
	 */
	private function initTween( distance:Float ):Void
	{
		if ( m_swipeTime == 0 )
		{
			return;
		}
		
		// Get velocity
		m_velocity = distance / m_swipeTime / VELOCITY_DAMPING ;
		
		// Set drag opposite velocity
		if ( m_velocity > 0 )
		{
			m_drag = DRAG * (-1);
		}
		else
		{
			m_drag = DRAG;
		}
		
		// Set isTweening to true so onFrame can start moving objects
		m_isTweening = true;
	}
	
	/**
	 * Used in onFrame callback to move items wiht momentum
	 */ 
	private function tweenItem( item:VirtualScrollingItem, velocity:Float ):Void
	{
		item.incrementPosition( velocity, m_orientation );
	}
	
	// ===================================
	// Object interaction helpers
	// ===================================
	
	private function tap( posY:Float, posX:Float ):Void
	{
		for ( item in m_scrollingItems )
		{
			item.tap( posY, posX );
		}
	}
	
	private function handleButtonOverState( posY:Float, posX:Float ):Void
	{
		for ( item in m_scrollingItems )
		{
			item.handleButtonOverState( posY, posX );
		}
	}
	
	// ===================================
	// Scroll bar handling
	// ===================================
	
	private function addScrollUI( scrollBar:OPSprite, scrollTrack:OPSprite ):Void
	{
		if ( scrollBar == null || scrollTrack == null )
		{
			return;
		}
		
		m_scrollTrack = scrollTrack;
		m_scrollBar = scrollBar;
	}
	
	/**
	 * 	NOTE: only works for vertical scrolling lists. 
	 *	TODO - Functionality for horizontal menu scrollbars
	 */
	private function repositionScrollBar( listScrollDistance:Float )
	{
		// Early return if no scrollbar 
		if ( m_scrollBar == null || m_scrollBar.visible == false )
		{
			return;
		}
		
		// ---------------------------------------------------
		// Calculate scroll bar movement 
		// ---------------------------------------------------
		
		// Calculate top and bottom for scroll bar and scroll track sprites
		// 		Scroll track top/bottom calc'd here are the effective top/bottom for the scroll bar. 
		// 		That is, they take the bar sprite size/anchoring into account.
		// NOTE: Scroll bar is anchored at the center
		var anchorOffset:Float = m_scrollBar.height / 2;
		var trackTop:Float = Math.floor( m_scrollTrack.y);
		var trackBottom:Float = Math.floor( m_scrollTrack.y + m_scrollTrack.height); 
		var barTop:Float = Math.floor( m_scrollBar.y - anchorOffset) ;
		var barBottom:Float = Math.floor( m_scrollBar.y + anchorOffset);
		
		// Amount of space the scrollbar has to move
		var scrollBarSpace:Float = trackBottom - trackTop;
		
		// Amount of space the whole list of items has outside of the visible field
		
		var listSpace:Float = m_dataset.length * m_itemSize; // px
		
		// Ratio between scrollbar movement space and total movement space
		var movementRatio:Float = scrollBarSpace / listSpace; // px
		
		// Amount the scrollbar moves is the amount scroll (dist) multiplied by the ratio between spaces.
		// 		Sign is flipped so the scrollbar moves with the items (opposite dir) 
		var scrollBarDistance:Float = listScrollDistance * movementRatio * -1 / VELOCITY_DAMPING;
		
		// ---------------------------------------------------
		// Update scroll bar position
		// ---------------------------------------------------
		m_scrollBar.y += scrollBarDistance;
	}
	
	// ===================================
	// Cleanup/Exit handling
	// ===================================
	
	private function onRemoved( e:Event ):Void
	{
		dispose();
	}
	
	private function dispose():Void
	{
		removeScrollListeners();
		
		// Clear menu
		clearData();
		
		// Remove event listeners from menu
		this.removeEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
	}
	
	private function removeScrollListeners():Void
	{
		// Remove listeners from the scroll interaction sprite
		m_scrollArea.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp ); 
		m_scrollArea.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown ); 
		m_scrollArea.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		m_scrollArea.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut);
		m_scrollArea.removeEventListener( Event.ENTER_FRAME, onFrame );
	}
	
	/**
	 * Clears scroll data for reinitialization. 
	 */
	public function reset():Void
	{
		m_paistRef.visible = true;
		
		clearData();
	}
	
	/**
	 * To be called after clearing data; at the moment used for search functionality
	 */
	public function reInit()
	{
		populateScrollingItems();
		init();
		
		// Clear list if there is no data
		if ( m_dataset.length < 1 )
		{
			clearData();
			Debug.log( "No data availabile on reinitialization." );
		}
		
		m_paistRef.visible = false;
	}
	
	/**
	 * Clears scroll data and display objects from the menu. Also removes event listeners.
	 */
	private function clearData():Void
	{
		m_isTweening = false;
		removeScrollListeners();
		
		m_userPos = 0;
		m_dataset = [];
		
		for ( item in m_scrollingItems )
		{
			item.clear();
		}
		
		m_scrollingItems = [];
	}
}