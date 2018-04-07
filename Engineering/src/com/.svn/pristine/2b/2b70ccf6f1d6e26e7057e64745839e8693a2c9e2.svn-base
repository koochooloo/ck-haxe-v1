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
@:native("cast.receiver.CastMessageBus.MessageType")
extern enum MessageType
{
	STRING;
	JSON;
	CUSTOM;
}

//=========================================================================
@:fakeEnum( Int )
@:native("cast.receiver.CastMessageBus.EventType")
extern enum MessageBusEventType
{
	MESSAGE;
}

//=========================================================================
@:native("cast.receiver.CastMessageBus.Event")
extern class MessageBusEvent
{
	public var data: Dynamic;
	public var senderId: String;
	public function new( type: MessageBusEventType, senderId: String, data: Dynamic );
}

//=========================================================================
@:native("cast.receiver.CastMessageBus")
extern class MessageBus
{
	public dynamic function deserializeMessage( message: String ): Dynamic;
	public dynamic function seializeMessage( message: Dynamic ): String;
	
	public dynamic function onMessage( event: MessageBusEvent ): Void;
	
	public function getNamespace(): String;
	public function getMessageType(): MessageType;
	
	public function send( senderId: String, message: Dynamic ): Void;
	
	public function broadcast( message: Dynamic ): Void;
	
	public function getCastChannel( senderId: String ): Channel;
}



