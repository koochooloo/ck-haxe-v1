//
// Copyright (C) 2006-2016, 1st Playable Productions, LLC. All rights reserved.
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

package com.firstplayable.hxlib.display;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.loader.SpriteDataManager;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import spritesheet.data.BehaviorData;


class SpriteBoxData
{
	public var refPoint( default, null ):Point;
	/**
	 * Raw bounds data, expressed in terms of location relative to top-left
	 */
	public var bounds( default, null ):Rectangle;
	/**
	 * Bounds data expressed in terms of location relative to ref point.
	 */
	public var offsetBounds( get, null ):Rectangle;

	public function new( ref:Point, bnds:Rectangle ) 
	{
		refPoint = ( ref != null ) ? ref : new Point();
		bounds = ( bnds != null ) ? bnds : new Rectangle();
	}
	
	/**
	 * Gets Bounds data expressed in terms of location relative to ref point.
	 * Note: Potentially expensive due to the call to Rectangle.clone.
	 * TODO: Handle negative scale correctly!
	 * @return Bounds expresssed relative to the reference point.
	 */
	public function get_offsetBounds():Rectangle
	{
		var offset:Point = new Point();
		if (refPoint != null)
		{
			offset = refPoint;
		}
		var bnds:Rectangle = bounds.clone();
		bnds.x -= offset.x;
		bnds.y -= offset.y;
		return bnds;
	}
	
	public function copy():SpriteBoxData
	{
		return new SpriteBoxData( refPoint.clone(), bounds.clone() );
	}
	
	public function toString():String
	{
		return '[SpriteBoxData refPoint=$refPoint bounds=$bounds]';
	}
	
	public function print():Void
	{
		Debug.log( toString() );
	}
}