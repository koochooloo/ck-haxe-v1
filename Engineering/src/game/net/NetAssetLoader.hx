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

package game.net;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import haxe.Timer;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

/**
 * Class used for accessing image asset types from over the internet
 * as opposed to those hosted locally.
 * Sends a NetAssetLoaded event
 */
class NetAssetLoader extends DisplayObject
{
	public static inline var HTTP_SUCCESS:Int = 200;
	
	//========================================
	// Parameters provided by constructor
	//========================================
	public var m_url(default, null):String;
	
	private var m_timeout(default, null):Float;
	
	//========================================
	// Data populated by the URL request
	//========================================
	public var m_data(default, null):Bitmap;
	
	//========================================
	// Internal variables used for handling the URI request
	//========================================
	private var m_request:URLRequest;
    private var m_loader:Loader;
    private var m_httpStatus:Int;
    
    private var m_lastTime:Float;
    private var m_loading:Bool;
	
	/**
	 * 
	 * @param	url			URL of the asset you wish to retrieve
	 * @param 	timeout		If > 0, will send a failed event if the time is exceeded
	 */
	public function new(url:String, timeout = -1)
	{
		super();
		
		m_url = url;
		m_timeout = timeout;
		
		m_data = null;
	}
	
	/**
	 * Starts the load
	 */
	public function load():Void
	{
		//=============================================
		// Setup the request
		//=============================================
		m_request = new URLRequest(m_url);
		m_loader = new Loader();
		
		//=============================================
		//Handle the events from loader
		//=============================================
		m_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
		m_loader.contentLoaderInfo.addEventListener( Event.OPEN, onOpen );
		m_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgress );
		m_loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
		m_loader.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus );
		m_loader.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS, onHTTPStatus );
		m_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
		
		//=============================================
		// Update timer to watch for timeouts
		//=============================================
		m_lastTime = Timer.stamp();
		if (m_timeout > 0)
		{
			addEventListener( Event.ENTER_FRAME, onFrame );
		}
		
		//=============================================
		// Begin the Request
		//=============================================
		//Default the status to success.
		m_httpStatus = HTTP_SUCCESS;
		
		m_loader.load(m_request);
	}

	/**
	 * Cleanup the NetAssetLoader
	 */
	public function release():Void
	{
		if (Tunables.DEBUG_DATABASE_RESOURCES)
		{
			Debug.log("release loader for: " + m_url);
		}
		
		removeEventListener( Event.ENTER_FRAME, onFrame );
		
		m_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
		m_loader.contentLoaderInfo.removeEventListener( HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus );
		m_loader.contentLoaderInfo.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onHTTPStatus );
		m_loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
		m_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onProgress );
		m_loader.contentLoaderInfo.removeEventListener( Event.OPEN, onOpen );
		m_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onComplete );
		
		m_loader = null;
		m_request = null;
		m_data = null;
	}
	
	//========================================================
	// Event Callbacks
	//========================================================
	
	/**
	 * Sent when the asset is retrieved.
	 * @param	e
	 */
	private function onComplete(e:Event):Void
	{
		removeEventListener( Event.ENTER_FRAME, onFrame );
		
		if (m_httpStatus == HTTP_SUCCESS)
		{			
			if (Tunables.DEBUG_DATABASE_RESOURCES)
			{
				Debug.log(m_url + " : SUCCESS");
			}
			
			m_data = cast m_loader.content;
			
			NetAssets.instance.dispatchEvent(new NetAssetLoadedEvent(this, true));
		}
		else
		{
			Debug.warn("failed with http status: " + m_httpStatus);
			handleFailure();
		}
	}
	
	/**
	 * When the download of the asset has started.
	 * @param	e
	 */
	private function onOpen(e:Event):Void
	{
		if (Tunables.DEBUG_DATABASE_RESOURCES)
		{
			Debug.log(m_url + " : OPEN");
		}
		
		m_loading = true;
	}
	
	/**
	 * When progress on downloading the asset has been made
	 * @param	e
	 */
	private function onProgress(e:ProgressEvent):Void
	{
		if (Tunables.DEBUG_DATABASE_RESOURCES)
		{
			var progress:Float = e.bytesLoaded / e.bytesTotal * 100;
			Debug.log(m_url + " : PROGRESS(" + progress + "%)");
		}
	}
	
	/**
	 * When a security error is encountered while downloading
	 * @param	e
	 */
	private function onSecurityError(e:SecurityErrorEvent):Void
	{
		Debug.warn("Security Error: " + e);
        handleFailure();
	}
	
	/**
	 * When an HTTP status event is sent by the loader
	 * @param	e
	 */
	private function onHTTPStatus(e:HTTPStatusEvent):Void
	{
		if (Tunables.DEBUG_DATABASE_RESOURCES)
		{
			Debug.log(m_url + " : HTTP STATUS(" + e.status + ")");
		}
        m_httpStatus = e.status;
	}
	
	/**
	 * When an HTTP status event is sent by the loader
	 * @param	e
	 */
	private function onResponseStatus(e:HTTPStatusEvent):Void
	{
		if (Tunables.DEBUG_DATABASE_RESOURCES)
		{
			Debug.log(m_url + " : HTTP RESPONSE STATUS(" + e + ")");
		}
		
		m_httpStatus = e.status;
	}
	
	/**
	 * When an IO error is encountered accessing the file
	 * @param	e
	 */
	private function onIOError(e:IOErrorEvent):Void
	{
		Debug.warn("IO Error: " + e);
        handleFailure();
	}
	
	/**
	 * Watch for timeout
	 * @param	e
	 */
	private function onFrame( e:Event ) 
	{
        var time = Timer.stamp();
        var delta = time - m_lastTime;
        if ( delta > m_timeout ) 
		{
			if (Tunables.DEBUG_DATABASE_RESOURCES)
			{
				Debug.log(m_url + " : TIMEOUT");
			}
			
			handleFailure();
		}
		
		m_lastTime = time;
	}
	
	/**
	 * Function call for if something goes wrong during asset retrieval
	 */
	private function handleFailure():Void
	{
		removeEventListener( Event.ENTER_FRAME, onFrame );
		
		if (Tunables.DEBUG_DATABASE_RESOURCES)
		{
			Debug.log(m_url + " : FAILED");
		}
		
		m_loading = false;
		
		NetAssets.instance.dispatchEvent(new NetAssetLoadedEvent(this, false));
	}
    
}