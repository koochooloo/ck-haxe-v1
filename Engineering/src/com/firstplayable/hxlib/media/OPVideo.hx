//
// Copyright (C) 2006-2017, 1st Playable Productions, LLC. All rights reserved.
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

package com.firstplayable.hxlib.media;

import openfl.media.Video;
import openfl.net.NetStream;

//Needed in the original Video class to access members of __stream.
//We need it too.
@:access(openfl.net.NetStream)

/**
 * Video class with custom functionality
 * such as sizing the streaming video to match
 * the dimmensions of this display object,
 * which does not work properly for HTML5 in the
 * base class.
 */
class OPVideo extends Video 
{	
	#if (js && html5)
	
	// HTML5 size set fix
	public var videoWidth(get, null):Float;
    public var videoHeight(get, null):Float;
	
    public function get_videoWidth():Float
	{
        if (__stream != null)
		{
            return (__stream.__video.videoWidth);
        } 
		else
		{
            return (0);
        }
    }    
    public function get_videoHeight():Float
	{		
        if (__stream != null)
		{
            return (__stream.__video.videoHeight);
        }
		else
		{
            return (0);
        }
    }
	
	override public function set_width(value:Float):Float
	{		
		if(videoWidth != 0)
		{
			//Setting dimmension resets the scale to 1.
			//Since we're updating the scale here, we want
			//the base dimmension to be that of the video.			
			super.set_width(videoWidth);
			scaleX = value / videoWidth;
		}
		else
		{
			super.set_width(value);
		}
		
		return value;
	}
	
	override public function set_height(value:Float):Float
	{
		if (videoHeight != 0)
		{
			//Setting dimmension resets the scale to 1.
			//Since we're updating the scale here, we want
			//the base dimmension to be that of the video.
			super.set_height(videoHeight);			
			scaleY = value / videoHeight;
		}
		else 
		{
			super.set_height(value);
		}
		return value;
	}
	
	public function clearVideo():Void
	{
		if (__stream != null)
		{
			__stream.__video = null;
		}
	}
	
    #end
	
	public function new(width:Int=320, height:Int=240) 
	{
		super(width, height);
	}	
}