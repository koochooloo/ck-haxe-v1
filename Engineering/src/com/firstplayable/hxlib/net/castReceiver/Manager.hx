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
@:fakeEnum( String )
@:native("cast.receiver.CastReceiverManager.EventType")
extern enum ManagerEventType
{
	READY;
	SHUTDOWN;
	SENDER_CONNECTED;
	SENDER_DISCONNECTED;
	ERROR;
	SYSTEM_VOLUME_CHANGED;
	VISIBILITY_CHANGED;
}

//=========================================================================
@:native("cast.receiver.CastReceiverManager.Event")
extern class ManagerEvent
{
	public var data: Dynamic;
	
	public function new( type: ManagerEventType, data: Dynamic );
}

//=========================================================================
@:native("cast.receiver.CastReceieverManager.Config")
extern class Config
{
	public var maxInactivity: Int;
	public var statusText: String;

	public function new();
}


//=========================================================================
@:native("cast.receiver.CastReceiverManager")
extern class Manager
{
	public function new();
	
	public dynamic function onReady( event: ManagerEvent ): Void;
	public dynamic function onSenderConnected( event: ManagerEvent ): Void;
	public dynamic function onSenderDisconnected( event: ManagerEvent ): Void;
	public dynamic function onShutdown( event: ManagerEvent ): Void;
	public dynamic function onSystemVolumeChanged( event: ManagerEvent ): Void;
	public dynamic function onVisibilityChanged( event: ManagerEvent ): Void;
	
	public function start( ?config: Config ): Void;
	public function stop(): Void;
	public function isSystemReady(): Bool;
	
	public function getSenders(): Array< String >;
	public function getSender( senderId: String ): Sender;
	public function getApplicationData(): ApplicationData;
	public function setApplicationState( statusText: String ): Void;
	public function getCastMessageBus( namespace: String, ?messageType: MessageBus.MessageType ): MessageBus;
	
	public static function getInstance(): Void;
}