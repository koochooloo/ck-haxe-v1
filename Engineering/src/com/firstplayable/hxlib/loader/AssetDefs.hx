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

package com.firstplayable.hxlib.loader;

/**
 * Collection of definitions useful for asset macros and managements
 */
class AssetDefs
{
	/**
	 * This is explicitly separated because the current working directory is different on iOS
	 */
	#if ios
	public static inline var ASSETS_2D_DIRECTORY:String = "../../../../assets/2d/";
	public static inline var ASSETS_LAYOUTS_DIRECTORY:String = "../../../../assets/layouts/";
	#else
	public static inline var ASSETS_2D_DIRECTORY:String = "assets/2d/";
	public static inline var ASSETS_LAYOUTS_DIRECTORY:String = "assets/layouts/";
	#end
	
	public static inline var BIN_2D_DIRECTORY:String = "2d/";
	public static inline var BIN_LAYOUTS_DIRECTORY:String = "layouts/";
	
}