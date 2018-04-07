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

package com.firstplayable.hxlib.debug.menuEdit;
import com.firstplayable.hxlib.debug.events.MenuUpdatedEvent;
import com.firstplayable.hxlib.net.BaseClient;
import com.firstplayable.hxlib.utils.json.JsonMenuPlugIn;
import com.firstplayable.hxlib.utils.json.JsonUtils;
import haxe.Json;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.Socket;

/**
 * Class that listens for updates to JSON menus, and informs the rest of the
 * Menu Edit system.
 */
class MenuUpdateClient extends BaseClient
{	
	private static var ms_client:MenuUpdateClient = null;
	
	public static function connect():Void
	{
		if (ms_client == null)
		{
			ms_client = new MenuUpdateClient();
		}
		
		ms_client.start();
	}
	
	public static function close():Void
	{
		if (ms_client != null)
		{
			ms_client.stop();
		}
	}
	
	public static function release():Void
	{
		if (ms_client != null)
		{
			ms_client.stop();
			ms_client = null;
		}
	}
	
	public static function reset():Void
	{
		release();
		connect();
	}
	
	public static function getIsConnected():Bool
	{
		if (ms_client == null)
		{
			return false;
		}
		
		return ms_client.isConnected;
	}
	
	/**
	 * Adds an event listener to the active client
	 * @param	type
	 * @param	listener
	 */
	public static function addEventListenerToActiveClient(type:String, listener:Dynamic->Void):Void
	{
		if (ms_client == null)
		{
			Debug.warn("No client exists! Please start the client first.");
			return;
		}
		
		ms_client.addEventListener(type, listener);
	}
	
	/**
	 * Remove an event listener from the active client
	 * @param	type
	 * @param	listener
	 */
	public static function removeEventListenerFromActiveClient(type:String, listener:Dynamic->Void):Void
	{
		if (ms_client == null)
		{
			Debug.warn("No client exists! Please start the client first.");
			return;
		}
		
		ms_client.removeEventListener(type, listener);
	}
	
	//==================================================================
	// Instance code
	//==================================================================
	
	public function new()
	{
		super();
	}
	
	//==================================================================
	// Callbacks
	//==================================================================
	
	override private function onSocketData(e:ProgressEvent):Void
	{
		super.onSocketData(e);
		
		var socketMessageString:String = m_socket.readUTFBytes(cast(e.bytesLoaded, Int));
		
		try
		{
			var socketMessage:Dynamic = Json.parse(socketMessageString);
			if (socketMessage.messageType != "PAIST_FILE_UPDATED")
			{
				Debug.log("unhandled message type: " + socketMessage.messageType);
				return;
			}
			
			var messageData:Dynamic = socketMessage.messageData;
			
			var updatedLayout:String = socketMessage.messageData.layoutName;
			var paistData:Dynamic = socketMessage.messageData.layoutData;
			cleanPaistData(paistData);
			
			Debug.log("Layout Updated: (" + updatedLayout + ")");
			dispatchEvent(new MenuUpdatedEvent(updatedLayout, paistData));
		}
		catch (e:Dynamic)
		{
			Debug.warn("Error with socket message: " + Std.string(e) + "\n" + socketMessageString);
		}
	}
	
	/**
	 * Fixes paist data so it's in the format we expect.
	 * @param	rawData
	 * @return
	 */
	private static function cleanPaistData(rawData:Dynamic):Dynamic
	{	
		var topMenuVal:Dynamic = Reflect.getProperty( rawData, "topMenu" );
		return cleanPaistDataHelper(topMenuVal);
	}
	
	private static function cleanPaistDataHelper(rawData:Dynamic):Dynamic
	{
		for (objectType in JsonMenuPlugIn.OBJECT_TYPES)
		{
			var items:Array<Dynamic> = Reflect.getProperty( rawData, objectType );      
			if ( items == null )
			{
				// EARLY RETUN--no items to clean of this type
				continue;
			}
			
			// Loop through all the items of this type
			for ( nextItem in items )
			{	
				//Recurse into the object looking for any potential children,
				//cleaning them as well.
				cleanPaistDataHelper(nextItem);
				
				//All children have been explored, clean this resource
				if (!Reflect.hasField(nextItem, "inheritable"))
				{
					continue;
				}
				
				var inheritable:Dynamic = Reflect.field(nextItem, "inheritable");
				if (!Reflect.hasField(inheritable, "resource"))
				{
					continue;
				}
				
				var oldRes:String = nextItem.inheritable.resource;
				var newRes:String = "2d/" + oldRes;
				
				nextItem.inheritable.resource = newRes;
			}
		}
		
		return rawData;
	}
	
}