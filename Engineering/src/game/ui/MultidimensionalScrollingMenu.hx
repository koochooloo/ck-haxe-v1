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

import com.firstplayable.hxlib.display.OPSprite;
import game.Country;
import game.ui.VirtualScrollingMenu.ScrollingData;
import haxe.Constraints.FlatEnum;
import openfl.display.DisplayObjectContainer;
import game.ui.VirtualScrollingMenu.Orientation;
import game.ui.VirtualScrollingMenu.Direction;
import com.firstplayable.hxlib.display.OPSprite;
import openfl.display.Sprite;


enum Dimension
{
	ROW;
	COLUMN;
}

/**
 *  A virtual scrolling menu that handles lists of multiple rows/columns.
 *  Does its own setup, but adopts parent's movement/data functions
 */
class MultidimensionalScrollingMenu extends VirtualScrollingMenu
{

	private var m_visibleCols:Int;
	private var m_colSpacing:Float;
	private var m_visibleRows:Int;
	private var m_rowSpacing:Float;
	
	private var m_colPos:Null<Float>;
	private var m_rowPos:Null<Float>;
	
	
	/**
	 * @param	centerRef - top left object in a scrolling gred
	 * @param	bottomRef - object directly below center ref 
	 * @param	rightRef - object directly to the right of center ref 
	 */
	public function new( scrollBounds:OPSprite, orientation:Orientation, centerRef:DisplayObjectContainer, ?bottomRef:DisplayObjectContainer, ?rightRef:DisplayObjectContainer, ?scrollBar:OPSprite, ?scrollTrack:OPSprite )
	{
		super ( scrollBounds, orientation, null, null, scrollBar, scrollTrack );

		// ---------------------------------------------------
		// Init other member vars using paist ref:
		// - Visisble items
		// - Item spacing
		// - Item size
		// - Start & End pos
		// - List of scrolling items
		// ---------------------------------------------------
		addMultiRef( centerRef, bottomRef, rightRef );
		
		// ---------------------------------------------------
		// Add scroll bar/track, if applicable
		// ---------------------------------------------------
		addScrollUI( scrollBar, scrollTrack );
	}
	
	private function addMultiRef( centerRef:DisplayObjectContainer, ?bottomRef:DisplayObjectContainer, ?rightRef:DisplayObjectContainer )
	{
		m_visibleCols = 1;
		m_visibleRows = 1;
		
		// ---------------------------------------------------------
		// Get relevant item dimension, based on scroll orientation
		// 		This is used for bounds detection.
		// ---------------------------------------------------------
		switch ( m_orientation )
		{
			case Orientation.HORIZONTAL:
			{
				m_itemSize = centerRef.width;
			}
			
			case Orientation.VERTICAL:
			{
				m_itemSize = centerRef.height;
			}
		}
		
		MAX_FRAME_DISTANCE = m_itemSize;
		
		// -------------------------------------------------------
		// Get column spacing data, if applicable
		// 		This is used when adding new columns in scrolling.
		// -------------------------------------------------------
		if ( rightRef != null )
		{
			m_colSpacing = rightRef.x - centerRef.x; // Includes item size + padding
			m_visibleCols = Math.floor( m_scrollArea.width / m_colSpacing );
		}
		
		// ----------------------------------------------------
		// Get row spacing data, if applicable
		//		This is used when adding new rows in scrolling.
		// ----------------------------------------------------
		if ( bottomRef != null )
		{
			m_rowSpacing = bottomRef.y - centerRef.y;
			m_visibleRows = Math.floor( m_scrollArea.height / m_rowSpacing );
		}
		
		// ----------------------------------------------------
		// Populate a set of items based on above dimensions.
		// Items are filled taking the scroll orientation into account, 
		// 		such that the last row/col of items in the list are at the scroll end.
		// ----------------------------------------------------
		
		m_visibleItems = m_visibleRows * m_visibleCols; // used for bounds checking
		
		var numRows:Int = m_visibleRows;
		var numCols:Int = m_visibleCols;
		var rowOffset:Float = m_rowSpacing;
		var colOffset:Float = m_colSpacing;
		var count:Int = 0;
		
		switch( m_orientation )
		{	
			case Orientation.HORIZONTAL:
			{
				numCols+= 1; // Since we are adding new columns when scrolling, place an extra set out of view
				var initXPos:Float = centerRef.x;
				var initYPos:Float = centerRef.y;
				rowOffset = initYPos;
				colOffset = initXPos;
				for ( col in 0...numCols )
				{
					rowOffset = initYPos;
					
					for ( row in 0...numRows)
					{
						var item:VirtualScrollingItem = new VirtualScrollingItem( centerRef, count );
						item.addMask( m_scrollArea );
						item.setCoordinates( colOffset, rowOffset );
						m_scrollingItems.push( item );
						
						rowOffset += m_rowSpacing;
						count++; // Temp - debugging
					}

					colOffset += m_colSpacing;
				}
			}
			case Orientation.VERTICAL:
			{
				numRows += 1; // Since we are adding new rows when scrolling, place an extra set out of view
				var initXPos:Float = centerRef.x;
				var initYPos:Float = centerRef.y;
				rowOffset = initYPos;
				colOffset = initXPos;
				for ( row in 0...numRows)
				{	
					colOffset = initXPos;
					
					for ( col in 0...numCols )
					{
						var item:VirtualScrollingItem = new VirtualScrollingItem( centerRef, count );
						item.addMask( m_scrollArea );
						item.setCoordinates( colOffset, rowOffset );
						m_scrollingItems.push( item );

						colOffset += m_colSpacing;
						count++; // Temp - debugging
					}
					
					rowOffset += m_rowSpacing;
				}
			}
		}
		
		centerRef.visible = false;
		bottomRef.visible = false;
		rightRef.visible = false;
	}
	
	// ===================================
	// Object positioning helper functions
	// ===================================
	
	/**
	 * Checks if list & repopulates a scrolling item at the top or bottom as needed
	 */
	private override function handleVirtualReposition( dir:Direction ):Void 
	{
		// Early return if user is scrolling towards the end of the list
		if ( scrollingAtLimit( m_direction ) )
		{
			return;
		}
		
		switch( m_orientation )
		{
			case HORIZONTAL: // todo
			case VERTICAL:
			{
				switch( dir )
				{
					case FORWARD:	
					{
						if ( scrolledOneItemForward() )
						{
							repositionSetAtStart();
						}
					}
					case BACKWARD:  
					{
						if ( scrolledOneItemBackward() )
						{
							repositionSetAtEnd();
						}

					}
				}
			}
		}
	}
	
	/**
	 * Take the last items of the list and place it at the top
	 * Returns reference to them for data updates.
	 * */
	private function repositionSetAtStart():Void
	{
		var firstRow:Array< VirtualScrollingItem > = new Array();
		var lastRow:Array< VirtualScrollingItem > = new Array();
		switch ( m_orientation )
		{
			case Orientation.VERTICAL:
			{	
				// Get the first row of the list 
				for ( item in m_scrollingItems )
				{
					firstRow.push( item );
				}
				
				// Get the the items in the last row
				var idx:Int = m_scrollingItems.length - 1;
				var count:Int = 0;
				while ( count < m_visibleCols )
				{
					var lastItem:VirtualScrollingItem = m_scrollingItems[ m_scrollingItems.length - 1 ];
					var lastRowPos:Float = lastItem.posY();
					var item:VirtualScrollingItem = m_scrollingItems[ idx ];
					if ( item.posY() == lastRowPos )
					{
						lastRow.push( m_scrollingItems[ idx ] );
					}
					
					idx--;
					count++;
				}
				
				// Fill in items from right -> left (opposite RepositionAtEnd) 
				// First row items will be rightmost
				var rowPos:Float = 0;
				var colPos:Float = 0;
				var firstRowItem:VirtualScrollingItem = firstRow[ 0 ];
				var firstRowColPos:Float = firstRowItem.posX();
				
				// Figure out repositioning start point based on the item placement in the top row
				var topRowFull:Bool = (firstRowColPos - m_colSpacing) < m_scrollArea.x;
				if ( topRowFull )
				{
					// If the top row is full, place at far right one row up
					rowPos = firstRowItem.posY() - m_rowSpacing;
					colPos = firstRowItem.posX() + ( m_colSpacing * (m_visibleCols - 1) );
				}
				else
				{
					// Otherwise, we fill in one from the right side
					colPos = firstRowItem.posX() - m_colSpacing;
					rowPos = firstRowItem.posY();
				}

				for ( i in 0...lastRow.length )
				{
					// Do not complete the row if we are at the end of the dataset
					var dataIdx:Int = m_userPos - m_visibleCols;
					if ( (dataIdx) < 0 )
					{
						m_userPos--; // Decrease user pos to hit end of bounds
						break;
					}
					
					// Get item we are repositioning + item whose position we are referencing
					var firstRowItem:VirtualScrollingItem = firstRow[ i ];
					var lastRowItem:VirtualScrollingItem = lastRow[ i ];

					// Change item screen position
					lastRowItem.setCoordinates( colPos, rowPos);
					colPos -= m_colSpacing;
					
					// Update item's position in the array
					m_scrollingItems.remove( lastRowItem ); // Remove from end (first instance of item)
					m_scrollingItems.insert( 0, lastRowItem ); // Add to beginning
					
					// Update item data
					m_userPos--;
					lastRowItem.updateData( m_dataset[dataIdx] );
				}
			}
			case HORIZONTAL:
			{
				// todo
			}
		}
	}
	
	/**
	 * Take the first row  of the list and place it at the bottom
	 * Returns reference to them for data updates.
	 * */
	private function repositionSetAtEnd():Void
	{
		var firstRow:Array< VirtualScrollingItem > = new Array();
		var lastRow:Array< VirtualScrollingItem > = new Array();
		switch ( m_orientation )
		{
			case VERTICAL:
			{	
				// Get the first row of the list 
				for ( item in m_scrollingItems )
				{
					firstRow.push( item );
				}
				
				// Get the the items in the last row
				var idx:Int = m_scrollingItems.length - 1;
				var count:Int = 0;
				while ( count < m_visibleCols )
				{
					lastRow.push( m_scrollingItems[ idx ] );
					idx--;
					count++;
				}
				
				// Pull items from left -> right (opposite RepositionAtStart)
				for ( i in 0...m_visibleCols )
				{
					// Get item data index 
					var dataIdx:Int = m_userPos + (m_visibleCols * 2);
					
					// Do not complete the row if we are at the end of the dataset
					if ( (dataIdx) >= m_dataset.length )
					{
						m_userPos++; // Increase user pos to hit end of bounds
						break;
					}
					
					// Change item screen position
					var firstRowItem:VirtualScrollingItem = firstRow[ i ];
					var lastRowItem:VirtualScrollingItem = lastRow[ lastRow.length - 1 - i ];
					firstRowItem.setCoordinates( lastRowItem.posX(), lastRowItem.posY() + m_rowSpacing );
					
					// Update item's position in the array
					m_scrollingItems.remove( firstRowItem ); // Remove from beginning (first instance of item)
					m_scrollingItems.push( firstRowItem ); // Add to end
					
					// Update item data
					m_userPos++;
					firstRowItem.updateData( m_dataset[dataIdx] );
				}
			}
			case HORIZONTAL:
			{
				// todo
			}
		}
	}
	
	/**
	 * Returns true if the bottom left corner of the first item in the list is below (left of) the start pos.
	 * Assumes top-left corner object anchoring.
	 */
	private override function scrolledOneItemForward():Bool
	{
		var lastItem:VirtualScrollingItem = m_scrollingItems[ m_scrollingItems.length - 1 ];
		return ( lastItem.pos(m_orientation) >= m_lowerScrollLimit);
	}
}