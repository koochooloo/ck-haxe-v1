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

package game.events;
import openfl.events.Event;

/**
 * Event passed to inform about a modified zoom level
 */
class ZoomEvent extends Event
{
	public static inline var ZOOM_EVENT:String = "ZOOM CHANGED";

	/**
	 * 1 = 100%
	 */
	public var zoomPercent:Float;
	
	public function new(zoom:Float = 0) 
	{
		super(ZOOM_EVENT);
		
		zoomPercent = zoom;
	}
	
}