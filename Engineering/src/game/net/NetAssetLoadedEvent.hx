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
import openfl.events.Event;

/**
 * Event sent out by a NetAssetLoader when it completes.
 */
class NetAssetLoadedEvent extends Event
{
	public static inline var ASSET_LOADED:String = "NET ASSET LOADED";
	
	public var loader(default, null):NetAssetLoader;
	public var success(default, null):Bool;

	public function new(loader:NetAssetLoader, success:Bool)
	{
		super(ASSET_LOADED);
		
		this.loader = loader;
		this.success = success;
	}
	
}