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

package game.events;
import openfl.events.Event;

/**
 * Adopted from Sheba revision 597.
 */
enum LoggingEventType
{
	TODO;
}

class LoggingEvent extends Event
{
	public static inline var LOGGING_EVENT:String = "LOGGING EVENT";
	
	public var loggingType:LoggingEventType;
	public var details:String;
	
	public function new(loggingType:LoggingEventType, details:String) 
	{
		this.loggingType = loggingType;
		this.details = details;
		super(LOGGING_EVENT);
	}
	
}