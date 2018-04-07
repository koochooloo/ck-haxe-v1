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
package com.firstplayable.hxlib.display.anim.importers;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.StdX;
import com.firstplayable.hxlib.display.BitmapDataWithParams;
import com.firstplayable.hxlib.display.HasParams;
import com.firstplayable.hxlib.display.Params;
import openfl.display.BitmapData;
import openfl.geom.Point;
import lime.graphics.utils.ImageCanvasUtil;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.data.SpritesheetFrame;


/**
 * Subclass of BehaviorData that totes around an additional Params.
 *
 * @see https://wiki.1stplayable.com/index.php/Web/Haxe/Reference_Points_and_Boxes_RFC
 * @author Leander
 */
class BehaviorDataWithParams extends BehaviorData implements HasParams
{
	public var params:Params = null;
	public var bitmapData:Array<BitmapData>;


	public function new( paramsData:Dynamic, ssFrames:Array<SpritesheetFrame>, name:String="", frames:Array<Int>=null, loop:Bool=false, frameRate:Int=30, originX:Float=0, originY:Float=0 ) 
	{
		super(name, frames, loop, frameRate, originX, originY);
		
		if ( paramsData != null )
		{
			params = new Params( paramsData );
			// TODO override origin?
			//var centerParam:Dynamic = params.get( Params.CENTER );
			//var center:Point = ( centerParam != null ) ? centerParam.getParamVector() : null;
			//if ( center != null )
			//{
				//Debug.log( "Overriding origin for behavior $name : $center" );
				//this.originX = center.x; // TODO negative?
				//this.originY = center.y; // TODO negative?
			//}
		}
		
		// Check for offsets.
		if ( ssFrames != null )
		{
			if ( params == null )
			{
				// No params yet = no place to put offsets.  Manifest an empty Params.
				// TODO: lazily do this, so we don't end up with empty params later?
				// (No existing cases would do this, but future might.)
				params = new Params( null );
			}
			
			// TODO: bake this in tools/common/SpritesheetModifier.py, rather than adding here
			var paramSubtree:Dynamic = {};
			var paramsCount:Int = 0;
			var animFrameIdx:Int = 0;
			for ( ssFrameIdxIter in frames )
			{
				var ssFrameIdx:Int = cast ssFrameIdxIter;
				var ssFrame:SpritesheetFrame = ssFrames[ ssFrameIdx ];
				if ( ssFrame != null )
				{
					if ( ssFrame.offsetX != 0 || ssFrame.offsetY != 0 )
					{
						var animFrameStr:String = Std.string( animFrameIdx );
						Reflect.setField( paramSubtree, animFrameStr, [ {"name":Params.OFFSET, "type":"vector", "frame":animFrameIdx, "x":ssFrame.offsetX, "y":ssFrame.offsetY} ] );
						++paramsCount;
					}
				}
				++animFrameIdx;
			}
			if ( paramsCount > 0 )
			{
				params.replaceSubtree( Params.OFFSET, paramSubtree );
			}
		}
		
		resetCache();
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

	
	public function resetCache()
	{
		this.bitmapData = new Array<BitmapData>();
		if ( frames.length > 0 )
		{
			// Extend and fill with null.
			bitmapData[frames.length - 1] = null;
		}
	}

	/**
	 * Get BitmapData associated with this frame.
	 * If it has Params, attach them (return BitmapDataWithParams) and cache as needed.
	 * @return null, or BitmapData, or BitmapDataWithParams.
	 */
	@:access( spritesheet.Spritesheet.sourceImage ) // see notes below
	public static function getCacheData( data:BehaviorData, sheet:Spritesheet, animFrameIndex:Int ):BitmapData
	{
		if ( ( data == null ) || ( sheet == null ) || ( animFrameIndex >= data.frames.length ) )
		{
			return null;
		}

		var frameData:BitmapData = null;


		var dataWithParams:BehaviorDataWithParams = StdX.as( data, BehaviorDataWithParams );
		if ( ( dataWithParams != null ) && ( dataWithParams.params != null ) )
		{
			// Has params.  Check cache.
			var cachedBitmapData:BitmapData = dataWithParams.bitmapData[ animFrameIndex ];
			if ( cachedBitmapData != null )
			{
				// Cache hit.
				frameData = cachedBitmapData;
			}
			else
			{
				// Cache miss.  Get source image -- may trigger copy.
				var sheetFrameIndex:Int = data.frames[ animFrameIndex ];
				
				// Don't explicitly copy pixels (yet).
				var frame:SpritesheetFrame = sheet.getFrame( sheetFrameIndex, false );
				if ( frame != null )
				{
					var bmd:BitmapData = frame.bitmapData;
					
					if ( bmd == null )
					{
						// Not yet loaded.
						// Search through all other animation frames in this animation...
						for ( otherAnimFrameIndex in 0 ... data.frames.length )
						{
							// ...for something using the same portion of the sheet...
							var otherSheetFrameIndex:Int = data.frames[ otherAnimFrameIndex ];
							if ( sheetFrameIndex == otherSheetFrameIndex )
							{
								// ...and use that, if it exists.
								// TODO: reuse the full BDWP if params (and animFrameIndex) are same.
								bmd = dataWithParams.bitmapData[ otherAnimFrameIndex ];
								if ( bmd != null )
								{
									// Partial cache hit.  Reuse the BitmapData part.
									break;
								}
							}
						}
					}
					
					if ( bmd == null )
					{
						// Still null?  Copy from source sheet.
						frame = sheet.getFrame( sheetFrameIndex, true ); // "true" now, may copy pixels
						bmd = frame.bitmapData;
					}
					
					// Add params and cache.
					frameData = BitmapDataWithParams.fromAnimParamsAndBitmapData( animFrameIndex, dataWithParams.params, bmd );
					dataWithParams.bitmapData[ animFrameIndex ] = frameData;
					
					#if (js && html5)
					// Assume we'll render soon, and we're not going to 
					// tint or otherwise manipulate pixels first.
					// If that assumption fails, we'll take a bit of 
					// overhead copying back to uint8 data.
					// But if we *never* render, this prevents us from 
					// keeping both uint8 data *and* a canvas around.
					//
					// See 
					ImageCanvasUtil.convertToCanvas (frameData.image); // clears __srcImage if present
					ImageCanvasUtil.sync (frameData.image, true); // true = clear uint8 data if present
					#end // #if (js && html5)

				}
			}
		}
		else
		{
			// No params.  Get source frame image -- may trigger copy.
			// Won't have animFrameIndex, but presumably we don't need it since we don't have params.
			var sheetFrameIndex:Int = data.frames[ animFrameIndex ];
			var frame:SpritesheetFrame = sheet.getFrame( sheetFrameIndex );
			if ( frame != null )
			{
				frameData = frame.bitmapData;
			}
		}
		
		return frameData;
	}
	
	public override function clone ():BehaviorDataWithParams
	{
		// Empty name triggers new unique id, like BehaviorData.clone()
		var cloned:BehaviorDataWithParams = new BehaviorDataWithParams( null, null, "", frames.copy (), loop, frameRate, originX, originY );
		cloned.params = params; // by ref for now
		return cloned;
	}

}