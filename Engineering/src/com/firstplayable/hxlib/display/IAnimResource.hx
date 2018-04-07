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
import openfl.display.BitmapData;

/**
 *   The AnimResource interface should be implemented by all classes that define resources to be used by an Anim.
 */
interface IAnimResource
{
    // The number of frames the animation has.
    public var numFrames(get, null): Int;
    
    public function getFrameImage( frameIndex: Int ): BitmapData;    

    private function get_numFrames(): Int;
	
	public function dispose():Void;
}