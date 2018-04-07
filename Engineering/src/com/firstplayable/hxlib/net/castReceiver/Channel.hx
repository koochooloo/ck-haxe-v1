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

//=========================================================================
@:fakeEnum( Int )
@:native("cast.receiver.CastChannel.EventType")
extern enum ChannelEventType
{
	CLOSE;
	MESSAGE;
}

//=========================================================================
@:native("cast.receiver.CastChannel.Event")
extern class ChannelEvent
{
	public var message: Dynamic;
	public function new( type: String, message: Dynamic );
}

//=========================================================================
@:native("cast.receiver.CastChannel")
extern class Channel
{
	// Channels cannot be created, only acquired from a castReceiver.MessageBus.
	
	public dynamic function onClose( event: ChannelEvent ): Void;
	public dynamic function onMessage( event: ChannelEvent ): Void;
	public function getNamespace(): String;
	public function getSenderId(): String;
	public function send( message: Dynamic ): Void;
}
