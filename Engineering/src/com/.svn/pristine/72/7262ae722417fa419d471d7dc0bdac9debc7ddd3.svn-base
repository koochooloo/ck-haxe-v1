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
package com.firstplayable.hxlib.net.castReceiver;

@:fakeEnum( Int )
@:native("cast.receiver.LoggerLevel")
extern enum LoggerLevel
{
	DEBUG;
	ERROR;
	INFO;
	NONE;
	VERBOSE;
}

@:native("cast.receiver")
extern class Receiver
{
	public static inline var VERSION: String;
	
	public static var logger:
	{
		function setLevelValue( cast.receiver.LoggerLevel ): Void;
	}
	
	public static inline var media:
	{
		inline var MEDIA_NAMESPACE: String;
	}
}