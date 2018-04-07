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

package com.firstplayable.hxlib.net;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.Socket;

/**
 * Boiler plate base class for standard socket server in OpenFL.
 */
class BaseClient extends EventDispatcher
{
	private static inline var DEFAULT_HOST:String = "127.0.0.1";
	private static inline var DEFAULT_PORT:Int = 9001;
	
	private var m_host:String;
	private var m_port:Int;
	
	private var m_socket:Socket;
	
	public var isConnected:Bool;

	/**
	 * Constructs a Client that tries to connect on the provided Host and Port.
	 * @param	host
	 * @param	port
	 */
	public function new(host:String = DEFAULT_HOST, port:Int = DEFAULT_PORT)
	{
		super();
		
		m_host = host;
		m_port = port;
		
		isConnected = false;
		
		m_socket = new Socket();
	}
	
	/**
	 * Begin attempt to connect to server
	 */
	public function start():Void
	{
		Debug.log("attempting to connect to " + m_host + " on port: " + m_port);
		
		m_socket.addEventListener(Event.CONNECT, onConnect);
		m_socket.addEventListener(Event.CLOSE, onClose);
		m_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		m_socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
		
		m_socket.connect(m_host, m_port);
	}
	
	/**
	 * Close the socket.
	 */
	public function stop():Void
	{
		m_socket.close();
		
		onStop();
	}
	
	/**
	 * Clean up when closing the client, or the connection is force closed.
	 * Override for additional cleanup
	 */
	private function onStop():Void
	{	
		isConnected = false;
		
		m_socket.removeEventListener(Event.CONNECT, onConnect);
		m_socket.removeEventListener(Event.CLOSE, onClose);
		m_socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		m_socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
	}
	
	//==================================================================
	// Callbacks
	//==================================================================
	
	/**
	 * Event sent when the connection starts
	 * Override for specific handling.
	 * @param	e
	 */
	private function onConnect(e:Event):Void
	{
		Debug.log("Connected to " + m_host + " on port: " + m_port);
		isConnected = true;
	}
	
	/**
	 * Event sent when the connection closes
	 * Override for specific handling.
	 * @param	e
	 */
	private function onClose(e:Event):Void
	{
		Debug.log("Closed connection to " + m_host + " on port: " + m_port);
		onStop();
	}
	
	/**
	 * Event sent when an error occurs with the connection.
	 * Override for specific handling.
	 * @param	e
	 */
	private function onError(e:IOErrorEvent):Void
	{
		if (isConnected)
		{
			Debug.warn("Failed to connect to server.");
		}
		else
		{
			Debug.warn("Error on server! " + e);
		}
		onStop();
	}
	
	/**
	 * Event sent whenever data is received on the socket.
	 * Does not contain the data itself, you need to pull it
	 * from the socket.
	 * @param	e
	 */
	private function onSocketData(e:ProgressEvent):Void
	{
		Debug.log("Data received: (" + e.bytesLoaded + "/" + e.bytesTotal + ")");
	}
	
}

/**
 * Boiler plate code to copy to make your own client
 */
#if false
class TemplateClient extends BaseClient
{
	public function new()
	{
		super();
	}
	
	override private function onStop():Void
	{
		super.onStop();
	}
	
	//==================================================================
	// Callbacks
	//==================================================================
	
	override private function onConnect(e:Event):Void
	{
		super.onConnect(e);
	}
	
	override private function onClose(e:Event):Void
	{
		super.onClose(e);
	}
	
	override private function onError(e:IOErrorEvent):Void
	{
		super.onError(e);
	}
	
	override private function onSocketData(e:ProgressEvent):Void
	{
		super.onSocketData(e);
	}
	
}
#end
