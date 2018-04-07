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

package com.firstplayable.hxlib.loader;
import com.firstplayable.hxlib.display.SpriteBoxData;


class SpriteDataManager
{
	public static var instance( get, null ):SpriteDataManager;
	
	private var m_map:Map<String, SpriteBoxData>;

	private function new() 
	{
		m_map = new Map();
	}
	
	private static function get_instance():SpriteDataManager
	{
		//If we need an instance, create one!
		if ( instance == null )
		{
			instance = new SpriteDataManager();
		}
		
		return instance;
	}
	
	/**
	 * Gets a SpriteBoxData that defines ref point and boxes for asset with specified url
	 * @param	resSrc - url of the asset, eg "drone/avatar/avatar.png"
	 * @return  the SpriteBoxData, or null if the resSrc is not found
	 */
	public function get( resSrc:String ):SpriteBoxData
	{
		return m_map.get( resSrc );
	}
	
	public function add( resSrc:String, boxData:SpriteBoxData ):Void
	{
		m_map.set( resSrc, boxData );
	}
}