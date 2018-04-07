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

package com.firstplayable.hxlib.utils.json;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.loader.IResourceMap;
import com.firstplayable.hxlib.utils.IGamestrings;


typedef The = GlobalTable;
class GlobalTable
{
	public static var resourceMap( get, null ):IResourceMap;
	private static function get_resourceMap():IResourceMap
	{
		if ( resourceMap == null )
		{
			Debug.warn( "Global Table has not been initialized; returning an empty map" );
			resourceMap = new EmptyResourceMap();
		}
		return resourceMap;
	}
	
	public static var gamestrings( get, null ):IGamestrings;
	private static function get_gamestrings():IGamestrings
	{
		if ( gamestrings == null )
		{
			Debug.warn( "Global Table has not been initialized; returning an empty map!" );
			gamestrings = new EmptyGamestrings();
		}
		return gamestrings;
	}
	
	
	public static function init( resMap:IResourceMap = null, strings:IGamestrings = null ):Void
	{
		resourceMap = ( resMap != null ) ? resMap : new EmptyResourceMap();
		
		gamestrings = ( strings != null ) ? strings : new EmptyGamestrings();
	}
}

class EmptyResourceMap implements IResourceMap
{
	public var INVALID:String = "invalid";
	
	public function new()
	{
	}
	
	public function getSheetPath( assetName:String ):String
	{
		return INVALID;
	}
}

class EmptyGamestrings implements IGamestrings
{
	public function new()
	{
	}
	
	public function has( id:String ):Bool
	{
		return false;
	}
	
	public function get( id:String ):String
	{
		return id;
	}
}