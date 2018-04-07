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
import com.firstplayable.hxlib.utils.DeviceCapabilities;
import haxe.ds.EnumValueMap;
import openfl.geom.Point;

enum SupportedPlatform 
{
	Custom1;
	Custom2;
}

class LayoutMap
{
	public static var widescreenThreshold:Float = 1.5;
	
	/**
	 * The game's current layout.
	 */
	public static var curLayout( get, null ):SupportedPlatform;
	
	private static function get_curLayout():SupportedPlatform
	{
		if ( curLayout == null )
		{
			//TODO: convert rez to closest matching SupportedPlatform
			//var rez:Point = DeviceCapabilities.screenResolution();
			
			//temp to swap between Custom1 (widescreen) and Custom2 (standard) resolutions based on device size
			curLayout = ( DeviceCapabilities.aspectRatio() > widescreenThreshold ) ? Custom1 : Custom2;
		}
		return curLayout;
	}
	
	public static function getLayoutSize():Point
	{
		return m_map.get( curLayout );
	}
	
	private static var m_map:EnumValueMap<SupportedPlatform,Point> = 
	{
		m_map = new EnumValueMap();
		//TODO: read in proper menu dimensions from json data for each size?
		m_map.set( Custom1, new Point( 576, 1024 ) );
		m_map.set( Custom2, new Point( 768, 1024 ) );
		m_map;
	};
}