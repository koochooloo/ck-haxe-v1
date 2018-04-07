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

import lime.graphics.Image;
import openfl.display.BitmapData;

/**
 * A BitmapData that also carries around Params.
 * @author Leander
 */
class BitmapDataWithParams extends BitmapData implements HasParams
{
	private var params:Params;
	
	/** Index into originating animation.
	 * NO_FRAME (-1) if not set or not available.
	 */
	public var animFrameIndex(default,null):Int;

	public function new( params:Params, width:Int, height:Int, transparent:Bool=true, fillColor:UInt=0xFFFFFFFF ) 
	{
		super(width, height, transparent, fillColor);
		this.params = params;
		this.animFrameIndex = Params.NO_FRAME;
	}
	
	/**
	 *  @return current Params; may return null which implies "has no params".
	 * @note The opposite does not hold; "has no params" may not imply null.
	 *       This may return a valid but empty Params.
	 */
	public function getParams():Null<Params>
	{
		return params;
	}
	
	public static function fromImageWithParams( params:Params, image:Image, transparent:Bool = true ):BitmapDataWithParams {
		
		if (image == null || image.buffer == null) return null;
		
		var bitmapData = new BitmapDataWithParams (params, 0, 0, transparent);
		bitmapData.__fromImage (image);
		bitmapData.image.transparent = transparent;
		return bitmapData;
		
	}
	
	/**
	 * Allows downcast-style promotion from BitmapData to a new BitmapDataWithParams.
	 * Best done before any action that causes expensive conversion (e.g. to HTML5 canvas).
	 */
	public static function fromAnimParamsAndBitmapData( animFrameIndex:Int, params:Params, bitmapData:BitmapData ):BitmapDataWithParams
	{
		var bdwp:BitmapDataWithParams;
		
		// Like clone(), but static, and takes image by reference.
		if (!bitmapData.__isValid) {
			
			bdwp = new BitmapDataWithParams( params, bitmapData.width, bitmapData.height, bitmapData.transparent );
			
		} else {
			
			bdwp = BitmapDataWithParams.fromImageWithParams( params, bitmapData.image, bitmapData.transparent );
			
		}
		
		bdwp.animFrameIndex = animFrameIndex;
		return bdwp;
	}
	
	// TODO other from* methods?
	
	public override function clone ():BitmapDataWithParams {
		
		var bdwp:BitmapDataWithParams;

		// Like clone(), but by reference.
		if (!__isValid) {
			
			bdwp = new BitmapDataWithParams( params, width, height, transparent );
			
		} else {
			
			bdwp = BitmapDataWithParams.fromImageWithParams( params, image.clone(), transparent );
			
		}
		
		bdwp.animFrameIndex = animFrameIndex;
		return bdwp;
		
	}

	
}