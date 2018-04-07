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
import com.firstplayable.hxlib.display.DisplayTools.Origin;
import openfl.display.DisplayObject;

enum OriginX
{
    Left;
    Center;
    Right;
}

enum OriginY
{
    Top;
    Middle;
    Bottom;
}

/**
 * Determines origin positioning. Use { x:Left, y:Top };
 */
typedef Origin = { x:OriginX, y:OriginY }
/**
 * Determines origin positioning. Use { x:15, y:20 };
 */
typedef OriginPos = { x:Float, y:Float }

class DisplayTools
{
	/**
     * Offset the container relative to its size.
     * @param	d	The display object to change.
     * @return
     */
    public static function setOrigin( d:DisplayObject, o:Origin ):Void
    {
		d.x =
			switch( o.x )
			{
				case Left:		0;
				case Center:	-d.width * 0.5;
				case Right:		-d.width;
			};
        
		d.y =
			switch( o.y )
			{
				case Top:		0;
				case Middle:	-d.height * 0.5;
				case Bottom:	-d.height;
			};
    }
	
	/**
     * Offset the container absolutely.
     * @param	d	The display object to change.
     * @return
     */
    public static function setOriginPos( d:DisplayObject, o:OriginPos ):Void
    {
		d.x = -o.x;
		d.y = -o.y;
	}
}