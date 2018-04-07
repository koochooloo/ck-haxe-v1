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
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Manages a bar that fills with code, instead of via animation.
 */
class FillBar extends DisplayObject
{	
	private var m_barFill:OPSprite;
	private var m_fillRect:Rectangle;
	private var m_barBacking:OPSprite;
	private var m_fillRatio:Float;

	/**
	 * Construct the fill meter
	 * @param	backing
	 * @param	fill
	 */
	public function new(backing:OPSprite, fill:OPSprite) 
	{
		super();
		m_fillRatio = 0.0;
		
		m_barFill = fill;
		
		m_fillRect = m_barFill.getBoundsData().offsetBounds;
		m_fillRect.x = 0;
		m_fillRect.y = 0;
		m_fillRect.width += 1;
		m_fillRect.height += 1;
		
		m_barBacking = backing;
		
		m_barFill.getBitmap().scrollRect = m_fillRect;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		
		updateMeter(m_fillRatio);
	}
	
	private function onRemovedFromStage(e:Event)
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		
		m_barFill = null;
		m_barBacking = null;
		m_fillRect = null;
	}
	
	/**
	 * Updates the meter to the specified ratio of full.
	 * provided the fill ratio [0,1.0].
	 * @param	fill
	 */
	public function updateMeter(fill:Float)
	{
		if (m_barFill == null)
		{
			return;
		}
		
		//Keep fill in a valid range
		if (fill > 1.0)
		{
			fill = 1.0;
		}
		m_fillRatio = Math.min(1.0, fill);
		
		//scroll rect the fill meter to show the proper progress amount
		m_barFill.getBitmap().scrollRect = null;
		var newScrollX:Float = -(m_fillRect.width * (1 - m_fillRatio));
		var newScrollRect:Rectangle = m_fillRect.clone();
		newScrollRect.x = newScrollX;
		m_barFill.getBitmap().scrollRect = newScrollRect;
		
		//From https://trello.com/c/8c7cpCwy/2-scrollrect-workaround
		#if html5
		m_barFill.getBitmap().x = newScrollRect.left -1;
		m_barFill.getBitmap().y = newScrollRect.top - 1;
		#end
		
	}
	
	public function getFillPosition():Point
	{
		var fillBounds:Rectangle = m_barFill.getBitmap().getBounds(stage);
		
		var fillPosX:Float = fillBounds.right;
		var fillPosY:Float = fillBounds.y;
		return new Point(fillPosX, fillPosY);
	}
	
}