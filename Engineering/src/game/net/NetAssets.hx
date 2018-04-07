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
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.EventDispatcher;

using StringTools;

/**
 * Class that handles loading and caching image resources requested from the internet
 */
class NetAssets extends EventDispatcher
{
	//=============================================
	// Singleton
	//=============================================
	public static var ms_instance:NetAssets;
	public static var instance(get, never):NetAssets;
	
	public static function get_instance():NetAssets
	{
		if (ms_instance == null)
		{
			ms_instance = new NetAssets();
		}
		
		return ms_instance;
	}
	
	//=============================================
	// Loader
	//=============================================
	
	public var timeout:Int;
	
	/**
	 * Map of URLs to the image assets loaded from that URL.
	 * If accessed, and doesn't yet axist, an asset download is triggered.
	 */
	private var m_assets:Map<String, Bitmap>;
	
	/**
	 * Map of URLs to active loaders.
	 * Used to check if we are already in the process of loading an asset
	 * for the requested URL
	 */
	private var m_loaders:Map<String, NetAssetLoader>;
	
	/**
	 * Map of callbacks to call when images are loaded.
	 */
	private var m_callbacks:Map<String, Array<Bitmap -> Void>>;
	
	public function new() 
	{
		super();
		
		//Defaults to never timeout
		timeout = -1;
		
		//============================================
		// Setup the maps
		//============================================
		m_assets = new Map<String, Bitmap>();
		m_loaders = new Map<String, NetAssetLoader>();
		m_callbacks = new Map<String, Array<Bitmap -> Void>>();
		
		//============================================
		// Setup the listeners
		//============================================
		addEventListener(NetAssetLoadedEvent.ASSET_LOADED, onAssetLoaded);
	}
	
	/**
	 * Handles the completion of an asset load
	 * @param	e
	 */
	private function onAssetLoaded(e:NetAssetLoadedEvent):Void
	{
		//=======================================
		// Ensure the loader is what we expect
		//=======================================
		if (!m_loaders.exists(e.loader.m_url))
		{
			Debug.warn("got a load completion from a loader we don't know about: " + e.loader.m_url);
			e.loader.release();
			
			return;
		}
		
		if (m_loaders[e.loader.m_url] != e.loader)
		{
			Debug.warn("loader mismatch for: " + e.loader.m_url);
			
			e.loader.release();
			m_loaders[e.loader.m_url].release();
			m_callbacks.remove(e.loader.m_url);
			
			return;
		}

		if (!e.success)
		{
			var url = e.loader.m_url;
			if (url.endsWith(".png"))
			{
				// If we fail to load a .png, try again with a .jpg
				//TODO: Would be nice to generalize this, set up
				//		primary/alternate extensions or something.
				var newUrl = url.replace(".png", ".jpg");
				getImage(newUrl);
				m_callbacks[newUrl] = m_callbacks[url];

				m_callbacks.remove(url);
				m_loaders.remove(url);
				e.loader.release();

				return;
			}
		}
		
		//=======================================
		// Handle callbacks if any
		//=======================================
		if (m_callbacks.exists(e.loader.m_url))
		{
			var cbData:Dynamic;
			if (e.success)
			{
				cbData = e.loader.m_data;
			}
			else
			{
				cbData = null;
			}
			
			for (cb in m_callbacks[e.loader.m_url])
			{
				cb(cbData);
			}
			
			m_callbacks.remove(e.loader.m_url);
		}
		
		//=======================================
		// Store the data
		//=======================================
		
		//We only want to store the data on success.
		//This allows us to potentially try again later.
		if (e.success)
		{
			m_assets[e.loader.m_url] = e.loader.m_data;
		}
		
		//=======================================
		// Cleanup the loader
		//=======================================
		
		m_loaders.remove(e.loader.m_url);
		e.loader.release();
	}
	
	//==========================================================
	// Public Interface
	//==========================================================
	
	/**
	 * Returns whether the provided asset is already in our cache
	 * @param	url
	 * @return
	 */
	public function isAssetLoaded(url:String):Bool
	{
		return m_assets.exists(url);
	}
	
	/**
	 * Attemps to get the BitmapData at the provided URL, and will call the provided callback with the data retrieved
	 * If the asset has not yet been loaded, the load will be triggered, otherwise the asset will be returned
	 * immediately.
	 * @param	url
	 * @param	callback
	 */
	public function getImage(url:String, ?callback:Bitmap -> Void):Void
	{
		if ((url == null) || (url == ""))
		{
			Debug.log("URL was null, or empty, calling callback with null");
			if (callback != null)
			{
				callback(null);
			}
			return;
		}
		
		//================================
		// Check if we already have the asset
		//================================
		if (m_assets.exists(url))
		{
			if (callback != null)
			{
				var image:Bitmap = cast m_assets.get(url);
				callback(image);
			}
			return;
		}
		
		//================================
		// Check if we're in the middle of loading the asset
		//================================
		if (m_loaders.exists(url))
		{
			if (callback != null)
			{
				if (!m_callbacks.exists(url))
				{
					m_callbacks[url] = [];
				}
				if (m_callbacks[url].indexOf(callback) == -1)
				{
					m_callbacks[url].push(callback);
				}
			}
			else
			{
				Debug.log("Load already in progress for (" + url + ") and no callback provided");
			}
			
			return;
		}
		
		//================================
		// We don't have, and are not loading, the asset yet.
		// Begin the load
		//================================
		
		if (callback != null)
		{
			if (!m_callbacks.exists(url))
			{
				m_callbacks[url] = [];
			}
			
			m_callbacks[url].push(callback);
		}
		
		var newLoader:NetAssetLoader = new NetAssetLoader(url, timeout);
		m_loaders[url] = newLoader;
		
		if (Tunables.DEBUG_DATABASE_RESOURCES)
		{
			Debug.log("trigger load of " + url );
		}
		newLoader.load();
	}
	
	/**
	 * Cancel all active callbacks (but not in progress asset loading.
	 */
	public function cancelCallbacks():Void
	{
		m_callbacks = new Map<String, Array<Bitmap -> Void>>();
	}
	
}