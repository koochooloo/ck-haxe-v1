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

class DataLoadedEvent extends Event
{
	public static inline var DATA_LOADED:String = "ALL DATA LOADED";
	public static inline var DATABASE_DATA_PROGRESS:String = "DATABASE DATA PROGRESS";
	public static inline var DATABASE_DATA_LOADED:String = "DATABASE DATA LOADED";
	public static inline var DATABASE_DATA_ERROR:String = "DATABASE DATA ERROR";
	
	public function new(type = DATA_LOADED) 
	{
		super(type);
	}
}