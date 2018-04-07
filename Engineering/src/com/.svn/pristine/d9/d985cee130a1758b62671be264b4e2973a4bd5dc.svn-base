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

package com.firstplayable.hxlib.testing;

import js.Browser;
import js.html.MetaElement;
import openfl.display.DisplayObject;
import openfl.geom.Point;

#if !js
#error "Autotest is only implemented for JavaScript targets!!!"
#end

class Autotest
{
	private static var m_meta:MetaElement = null;
	private static var m_counter:Int = 0;

	// Creates a meta tag on the page with the name & id of autotest,
	// to be read by the testing program.
	public static function init():Void
	{
        m_meta = Browser.window.document.createMetaElement();
        m_meta.name = "autotest";
        m_meta.id = "autotest";
        m_meta.content = "";

        Browser.window.document.head.appendChild(m_meta);
	}

	// Updates the content field of the autotest meta tag in order
	// to pass information to the testing program.
	public static function setMeta(msg:String):Void
	{
        if (m_meta == null)
		{
			init();
		}

        m_meta.content = msg;
	}

	// Puts a message in the meta tag to tell the autotest program to click on the given coordinates.
	public static function clickCoords(x:Float, y:Float)
	{
		var msg:String = 'CLICK $m_counter:$x,$y';
		setMeta(msg);
		m_counter++;
	}

	// Click on the given point
	public static function clickPoint(pt:Point)
	{
		clickCoords(pt.x, pt.y);
	}

	// Click on the given display object
	public static function clickDisplayObject(obj:DisplayObject)
	{
		clickCoords(obj.x, obj.y);
	}
}
