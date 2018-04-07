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

class VolumeChangedEvent extends Event
{
	//No use case for events other than VOLUME_CHANGED_MOVIE
	//don't worry about them until we need them.
	//public static inline var VOLUME_CHANGED:String = "VolumeChanged_GENERAL";
	//public static inline var VOLUME_CHANGED_SFX:String = "VolumeChanged_SFX";
	//public static inline var VOLUME_CHANGED_BGM:String = "VolumeChanged_BGM";
	public static inline var VOLUME_CHANGED_MOVIE:String = "VolumeChanged_MOVIE";
	
	public var volume:Float;
	
	public function new( type:String, vol:Float ) 
	{
		super( type );
		
		volume = vol;
	}
	
	override public function clone():Event
	{
		return new VolumeChangedEvent( type, volume );
	}
}