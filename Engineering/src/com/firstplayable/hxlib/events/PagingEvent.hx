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

package com.firstplayable.hxlib.events;
import openfl.events.Event;

/**
 * Event sent to inform a menu/model that new page has been requested.
 */
class PagingEvent extends Event
{
	public static inline var PAGING_EVENT:String = "PAGING_EVENT";
	public var page:Int;
	
	public function new( newPage:Int)
	{
		super( PAGING_EVENT );
		page = newPage;
	}	
}