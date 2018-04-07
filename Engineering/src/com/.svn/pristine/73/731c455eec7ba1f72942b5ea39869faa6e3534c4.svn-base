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

#if (debug || build_cheats)
package com.firstplayable.hxlib.debug.tunables.eventHandlers;
import com.firstplayable.hxlib.audio.WebAudio;
import openfl.display.DisplayObjectContainer;
import openfl.display.DisplayObject;
import openfl.Lib;
import openfl.display.Stage;
import com.firstplayable.hxlib.display.OPSprite;
import haxe.EnumTools;
import com.firstplayable.hxlib.display.OPSprite.DebugDrawingFlag;
import com.firstplayable.hxlib.debug.events.TunableUpdatedEvent;

/**
 * Class that handles updating WebAudio settings when appropriate Tunables change.
 */
class WebAudioUpdateHandler extends PropertyUpdateHandler
{	
	/**
	 * Constructor
	 */
	public function new() 
	{
		var tunableToFieldMap:Map<String, String> = [
			"WEBAUDIO_BGM_VOLUME" => "bgmVolume"
		];
		
		super(WebAudio, tunableToFieldMap);
	}
	
}
#end
