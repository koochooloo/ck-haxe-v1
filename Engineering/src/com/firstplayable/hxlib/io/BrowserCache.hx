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
package com.firstplayable.hxlib.io;
import openfl.net.SharedObject;

class BrowserCache
{
	/**
	 * Saves/overwrites a file to the browser cache, or deletes a cache.
	 * @param	id		The name of the file to get.
	 * @param	o		The object to save to the cache. If null is used, deletes the cache id instead.
	 */
	public static function post( id:String = "1p-cache", o:Dynamic = null ):Void
	{
		#if (js || flash)
		if ( id == null )
		{
			Debug.log( "id is required" );
			return;
		}
		
		var save:SharedObject = SharedObject.getLocal( id );
		
		if ( o == null )
		{
			save.clear();
		}
		else
		{
			//trace( "saving " + o );
			save.data.info = o;
			save.flush();
		}
		#else
			#error "Not supported on your platform."
			return;
		#end
		
		
	}
	
	/**
	 * Retrieves browser cached file.
	 * @param	id		The name of the file to get.
	 * @return	saved object.
	 */
	public static function get( id:String = "1p-cache" ):Dynamic
	{
		#if !js && !flash
			#error "Not supported on your platform."
			return null;
		#end
		
		var save:SharedObject = SharedObject.getLocal( id );
		
		if ( save != null )
			return save.data.info;
		
		return null;
	}
}