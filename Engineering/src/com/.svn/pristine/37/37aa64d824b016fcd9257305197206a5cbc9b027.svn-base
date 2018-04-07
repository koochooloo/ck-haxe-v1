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
package com.firstplayable.hxlib.display;

import com.firstplayable.hxlib.display.anim.importers.BehaviorDataWithParams;
import flash.display.BitmapData;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.data.SpritesheetFrame;

class SpritesheetWithParams extends Spritesheet
{
	public function new(image:BitmapData=null, frames:Array<SpritesheetFrame>=null, behaviors:Map<String, BehaviorData>=null, imageAlpha:BitmapData=null) 
	{
		super(image, frames, behaviors, imageAlpha);
	}
	
	public override function updateImage( image:BitmapData, imageAlpha:BitmapData = null ):Void
	{
		super.updateImage( image, imageAlpha );
		
		for ( bd/*:BehaviorData*/ in behaviors )
		{
			var bdwp:BehaviorDataWithParams = StdX.as( bd, BehaviorDataWithParams );
			if ( bdwp != null )
			{
				bdwp.resetCache();
			}
		}
	}

}