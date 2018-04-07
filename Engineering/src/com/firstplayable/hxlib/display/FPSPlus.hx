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

import flash.display.BitmapData;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * Display FPS and other frame statistics.
 * Originally from C:\HaxeToolkit\haxe\lib\openfl\3,6,0\openfl\display\FPS.hx
 * Modifications from http://haxecoder.com/post.php?id=24 (MEM)
 * Additional modifications from 1P (PixelCount)
 * 
 * Please note, this is mostly broken:
 * * System.totalMemory is JS memory only, not bitmaps
 * * System.totalMemory may only be available on Chrome
 * * System.totalMemory is quantized to avoid info leaks unless you pass a developer flag to Chrome
 * * BitmapData.pixelCount doesn't work properly unless you're on a platform that reliably calls dispose()
 */
class FPSPlus extends TextField {
	
	
	public var currentFPS (default, null):Int;
	
	private var cacheCount:Int;
	private var times:Array <Float>;
	private var cacheMem:Float = 0;
	private var memPeak:Float = 0;
	private var bitmapDataClass:Class<Dynamic> = null;
	private var hasPixelCount:Bool = false;
	private var cachePix:Int = 0;
	
	
	public function new (x:Float = 10, y:Float = 10, color:Int = 0x000000) {
		
		super ();
		
		this.x = x;
		this.y = y;
		
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat ("_sans", 12, color);
		text = "FPS: ";
		
		cacheCount = 0;
		times = [];
		
		addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
		
		bitmapDataClass = Type.getClass( new BitmapData( 1, 1 ) );
		hasPixelCount = Std.is( Reflect.field( bitmapDataClass, "pixelCount" ), Int );
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	@:noCompletion private function this_onEnterFrame (event:Event):Void {
		
		var currentTime = Timer.stamp ();
		times.push (currentTime);
		
		while (times[0] < currentTime - 1) {
			
			times.shift ();
			
		}
		
		var totalMem:Int = System.totalMemory;
		var mem:Float = ( ( totalMem * 100 ) >> 20 ) / 100;
		if (mem > memPeak) memPeak = mem;
		
		var currentCount = times.length;
		currentFPS = Math.round ((currentCount + cacheCount) / 2);
		
		var pix:Int = 0;
		if ( hasPixelCount )
		{
			pix = cast Reflect.field( bitmapDataClass, "pixelCount" );
		}
		
		if ( currentCount != cacheCount || mem != cacheMem || pix != cachePix )
		{
			text = 'FPS: ${currentFPS}\nMEM: ${mem} MiB\n(peak: ${memPeak} MiB)';
			if ( hasPixelCount )
			{
				text += '\nPix: ${pix}';
			}
		}
		
		
		cacheCount = currentCount;
		cacheMem = mem;
		cachePix = pix;
		
	}
	
	
}
