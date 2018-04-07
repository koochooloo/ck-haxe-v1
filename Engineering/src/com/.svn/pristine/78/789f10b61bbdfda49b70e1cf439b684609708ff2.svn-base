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

package com.firstplayable.hxlib.events;

import openfl.events.Event;

class BadgeEvent extends Event
{
	/**
	 * Triggers when a badge is progressed
	 */
	public static inline var BADGE_PROGRESS:String = "badgeProgress";
	
	/**
	 * Triggers when a badge is earned
	 */
	public static inline var BADGE_COMPLETE:String = "badgeComplete";
	
	/**
	 * ID of the badge
	 */
	public var badgeId:EnumValue;
	
	/**
	 * Current progress of the badge
	 */
	public var progress:Int;
	
	public function new( badgeId:EnumValue, type:String, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.badgeId = badgeId;
	}
	
}