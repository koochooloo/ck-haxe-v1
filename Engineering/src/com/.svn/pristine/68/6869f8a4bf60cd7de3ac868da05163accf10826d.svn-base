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

import com.firstplayable.hxlib.audio.AudioObject;
import openfl.events.Event;

class AudioEvent extends Event
{
	public static inline var STARTED:String = "AudioEvent_STARTED";
	public static inline var COMPLETE:String = "AudioEvent_COMPLETE";
	
	public var audioObject( default, null ):AudioObject;
	
	public function new( type:String, obj:AudioObject ) 
	{
		super( type );
		
		audioObject = obj;
	}
	
	override public function clone():Event
	{
		return new AudioEvent( type, audioObject );
	}
}