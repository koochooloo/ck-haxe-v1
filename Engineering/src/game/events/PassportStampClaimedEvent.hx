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
 * Event passed to inform about a stamp for a given country being claimed
 */
class PassportStampClaimedEvent extends Event
{
	public static inline var STAMP_CLAIMED_EVENT:String = "STAMP CLAIMED";

	public var country:String;
	
	public function new(country:String) 
	{
		super(STAMP_CLAIMED_EVENT);
		
		this.country = country;
	}
	
}