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
import com.firstplayable.hxlib.display.OPSprite.DivIterator;
import com.firstplayable.hxlib.display.ParamBoxData.ParamBoxType;
import com.firstplayable.hxlib.display.Params.ParamsIter;
import com.firstplayable.hxlib.utils.MathUtils;
import format.swf.Data.Rect;
import haxe.EnumFlags;
import haxe.EnumTools;
import lime.ui.MouseCursor;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.Shape;

enum DebugDrawingFlag
{
	DRAW_BOUNDS_BOX;
	DRAW_VULNERABLE_BOX;
	DRAW_ATTACK_BOX;
	DRAW_ATTACK_SELECT_BOX;
	INVALID_FLAG;
}

/**
 * DisplayObjectContainer that is meant to work with RPJ data from Oriolo.
 * Currently supports bounding boxes and reference points.
 */
@:access(openfl.geom.Rectangle) // see DisplayObject
class OPSprite extends DisplayObjectContainer
{
	private static var __tempBounds = new Rectangle ();
	
	/**
	 * Used to determine whether or not to run debug drawing logic.
	 * Will be set to true when any of the debug drawing flags are enabled,
	 * and is never unset. 
	 */
	private static var ms_debugDrawingEnabled:Bool = false;
	private static var ms_debugDrawingFlags:EnumFlags<DebugDrawingFlag> = new EnumFlags<DebugDrawingFlag>(0);
	
	//This forces bitmap smoothing on for all new OPSprites.
	public static var ms_forceSmoothingOn:Bool = true;
	//This turns bitmap smoothing on for an individual OPSprite
	public var smoothing( default, set ):Bool = false;
	
	private var m_boundsDataShape:Shape;
	private var m_paramBoxShapes:Array<Shape>;
	
	private var m_img( default, set ):Bitmap = null;
	private var m_userData:SpriteBoxData = null;
	private var m_paramsData:SpriteBoxData = null;
	private var m_scaledBoxData:SpriteBoxData = null;
		
	/** 
	 * Array of "9-slice" division points on x-axis.
	 * 
	 * Even index elements (including 0th aka first) are end of fixed, odd are end of stretchy sections.
	 * If the last element isn't >= width, it's as if there's an implicit width element tacked on.
	 * 
	 * If the given array is empty, the above implies that there's one fixed slice of width.
	 * 
	 * When set to `null`, fall back to what params specify; if params are empty or null,
	 * the above implies there's one fixed slice of width.
	 */
	public var xDivs( get, set ):Array<Int>;
	/**
	 *  Array of "9-slice" division points on y-axis, @see xDivs.
	 */
	public var yDivs( get, set ):Array<Int>;

	public var bitmapData(get, set):BitmapData;

	/** Mouse cursor to show when hovering over this object. */
	public var cursor:MouseCursor;
	

	private var m_originalBitmapData:BitmapData = null;
	private var m_userXDivs:Array<Int> = null;
	private var m_userYDivs:Array<Int> = null;
	private var m_paramsXDivs:Array<Int> = null;
	private var m_paramsYDivs:Array<Int> = null;
	
	private var m_advertisedScaleX:Float = 1.0;
	private var m_advertisedScaleY:Float = 1.0;

	private static var _staticDrawRect = new Rectangle();
	private static var _staticDrawMatrix = new Matrix();
	private static var _staticDrawPoint = new Point();
	private static var _staticDrawZeroPoint = new Point( 0, 0 );
	
	private inline static var _fillColor:UInt = 0x00000000;

	
	public static function create( imgData:BitmapData, ?boxData:SpriteBoxData )
	{
		return new OPSprite( new Bitmap( imgData ), boxData );
	}

	//-----------------------------------------------------------------------------------------------------------

	public function new( ?img:Bitmap, ?boxData:SpriteBoxData )
	{
		super();
		if (!ms_forceSmoothingOn)
		{
			smoothing = ( img != null ) ? img.smoothing : false;
		}
		else
		{
			smoothing = true;
		}
		
		m_img = img;
		if (m_img != null)
		{
			m_img.smoothing = smoothing;
		}
		updateBounds( boxData );
	}
	
	//-----------------------------------------------------------------------------------------------------------

	public function getBitmap():Bitmap
	{
		// This is a bit inconsistent with the bitmapData public accessor below,
		// but it makes sense to be explicit here, I think...
		return m_img;
	}
	
	//-----------------------------------------------------------------------------------------------------------

	public function getBitmapData():BitmapData
	{
		if ( m_originalBitmapData != null )
		{
			return m_originalBitmapData;
		}
		else if ( m_img != null )
		{
			return m_img.bitmapData;
		}
		else
		{
			return null;
		}
	}
	
	//-----------------------------------------------------------------------------------------------------------

	/**
	 * @return Direct reference (UNSCALED, UNTRANSLATED -- relative to refpt) to current SpriteBoxData (do not mutate);
	 *         user-specified data from updateBounds will be provided before data from params.
	 */
	private function getBoxData():SpriteBoxData
	{
		// User data overrides.
		if ( m_userData != null ) return m_userData;
		else return m_paramsData;
	}

	//-----------------------------------------------------------------------------------------------------------

	/**
	 * @return Reference (partially SCALED but UNTRANSLATED -- relative to refpt) to current or cached SpriteBoxData (do not mutate);
	 *         user-specified data from updateBounds will be provided before data from params.
	 *         This version only accounts for scale *differences* between m_advertisedScaleX and the scale encoded in DisplayObject's transform:
	 *         DisplayObject.get_scaleX.  See TODO SCALE commentary on OPSprite.get_scaleX.
	 */
	private function getMungedBoxData():SpriteBoxData
	{
		var unscaledBoxData:SpriteBoxData = getBoxData();
		// We need to account for any scale that *isn't* accounted for in transform.
		var scaleDiffX:Float = m_advertisedScaleX / super.get_scaleX();
		var scaleDiffY:Float = m_advertisedScaleY / super.get_scaleY();
		var scaleIsAccountedFor:Bool = ( scaleDiffX == 1.0 ) && ( scaleDiffY == 1.0 );
		if ( unscaledBoxData == null || scaleIsAccountedFor )
		{
			return unscaledBoxData;
		}
		else
		{
			var scaledRefX = unscaledBoxData.refPoint.x    * scaleDiffX;
			var scaledRefY = unscaledBoxData.refPoint.y    * scaleDiffY;
			var scaledBoxX = unscaledBoxData.bounds.x      * scaleDiffX;
			var scaledBoxY = unscaledBoxData.bounds.y      * scaleDiffY;
			var scaledBoxW = unscaledBoxData.bounds.width  * scaleDiffX;
			var scaledBoxH = unscaledBoxData.bounds.height * scaleDiffY;
			
			if ( m_scaledBoxData != null )
			{
				m_scaledBoxData.refPoint.x    = scaledRefX;
				m_scaledBoxData.refPoint.y    = scaledRefY;
				m_scaledBoxData.bounds.x      = scaledBoxX;
				m_scaledBoxData.bounds.y      = scaledBoxY;
				m_scaledBoxData.bounds.width  = scaledBoxW;
				m_scaledBoxData.bounds.height = scaledBoxH;
			}
			else
			{
				var scaledRef:Point = new Point( scaledRefX, scaledRefY );
				var scaledBox:Rectangle = new Rectangle( scaledBoxX, scaledBoxY, scaledBoxW, scaledBoxH );
				m_scaledBoxData = new SpriteBoxData( scaledRef, scaledBox );
			}
		}
		
		return m_scaledBoxData;
	}

	//-----------------------------------------------------------------------------------------------------------
	
	public function updateBounds( boxData:SpriteBoxData, ?force:Bool = false ):Void
	{
		if ( m_userData != boxData )
		{
			m_userData = boxData;
			force = true;
		}
		
		if ( force == true )
		{
			updateBoxDataAndDivs();
			updateRenderOffset();
			updateDebugDrawing();
		}
	}
	
	//-----------------------------------------------------------------------------------------------------------
	/**
	 * Returns an UNSCALED, UNTRANSLATED array of ParamBoxData representing the requested param box type for the current frame.
	 * @return Empty or Populated array of ParamBoxData
	 */
	public function getParamBoxes(boxType:ParamBoxType):Array<ParamBoxData>
	{
		var vulnBoxes:Array<ParamBoxData> = [];
		
		var animFrameIdx:Int = Params.NO_FRAME;
		if ( Std.is( bitmapData, BitmapDataWithParams ) )
		{
			var bdwp:BitmapDataWithParams = cast bitmapData;
			animFrameIdx = bdwp.animFrameIndex;
		}
	
		var offset:Point = _staticDrawZeroPoint;
		var boxData:SpriteBoxData = getBoxData();
		if (boxData != null)
		{
			offset = boxData.refPoint;
		}
		
		if ( Std.is( bitmapData, HasParams ) )
		{
			var objWithParams:HasParams = cast bitmapData;
			var params:Params = objWithParams.getParams();
			if ( params != null )
			{
				var paramName:String = ParamBoxData.getParamBoxNameFromType(boxType);
				var vulnParamIter:ParamsIter = params.getAll(paramName, animFrameIdx, Params.FRAME_OVERLAP);
				while (vulnParamIter.hasNext())
				{
					var param:Dynamic = vulnParamIter.next();
					var rect:Rectangle = Params.getParamBox(param);
					if ( rect == null )
					{
						Debug.warn( 'Non-box found while searching for $paramName for anim frame idx $animFrameIdx' );
						continue;
					}
					// Box parameters are expressed in a coordinate system relative to the original image top left.
					// We'd rather deal with refpt=origin, though.
					// TODO SCALE: Handle negative scale correctly!
					rect.x -= offset.x;
					rect.y -= offset.y;
					var id:Null<Int> = Params.getParamId(param);
					var frame:Null<Int> = Params.getParamFrame(param);
					var lastFrame:Null<Int> = Params.getParamLastFrame(param);
					var nextVulnBox:ParamBoxData = new ParamBoxData(boxType, rect, id, frame, lastFrame);
					vulnBoxes.push(nextVulnBox);
				}
			}
		}
		
		return vulnBoxes;
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	private function loadDivs( divParamIter:ParamsIter, array:Array<Int> ):Array<Int>
	{
		if ( ( divParamIter == null ) || ! divParamIter.hasNext() )
		{
			return null;
		}
		
		// TODO: re-use existing array?
		array = new Array<Int>();
		while ( divParamIter.hasNext() )
		{
			var param:Dynamic = divParamIter.next();
			var div:Null<Int> = Params.getParamValueInt( param );
			if ( div != null )
			{
				array.push( div );
			}
		}
		
		// Should we move this sort to someplace common, and use it
		// to sanitize userdata as well?
		// Should we assume params data is sorted and not do this?
		array.sort( function(a:Int, b:Int) {
			if ( a < b ) return -1;
			else if ( a > b ) return 1;
			else return 0;
		});
		
		return array;
	}

	//-----------------------------------------------------------------------------------------------------------

	/**
	 * Extract any new box and div param data for this frame.
	 */
	private function updateBoxDataAndDivs():Void
	{
		var animFrameIdx:Int = Params.NO_FRAME;
		if ( Std.is( bitmapData, BitmapDataWithParams ) )
		{
			var bdwp:BitmapDataWithParams = cast bitmapData;
			animFrameIdx = bdwp.animFrameIndex;
		}
		
		// First, load current params data, if present.
		{
			// Test for exact frame match, then NO_FRAME.
			var center:Point     = Params.getWithDefault( null, bitmapData, Params.getParamVector, Params.REFPT,        animFrameIdx, Params.NO_ID, Params.FRAME_FALLBACK );
			var bounds:Rectangle = Params.getWithDefault( null, bitmapData, Params.getParamBox,    Params.BOUNDING_BOX, animFrameIdx, Params.NO_ID, Params.FRAME_FALLBACK );
			if ( ( center != null ) || ( bounds != null ) )
			{
				m_paramsData = new SpriteBoxData( center, bounds );
				//trace( 'New paramsData for $name: $m_paramsData' );
			}
			else
			{
				m_paramsData = null;
			}
		}

		// Load slice data for grid.
		{
			if ( Std.is( bitmapData, HasParams ) )
			{
				var objWithParams:HasParams = cast bitmapData;
				var params:Params = objWithParams.getParams();
				if ( params != null )
				{
					m_paramsXDivs = loadDivs( params.getAll( "xDivs", animFrameIdx, Params.FRAME_FALLBACK ), m_paramsXDivs );
					m_paramsYDivs = loadDivs( params.getAll( "yDivs", animFrameIdx, Params.FRAME_FALLBACK ), m_paramsYDivs );
				}
			}
		}
	}

	/**
	 * Update render offset for refpt and trim offset; call after any updateBoxDataAndDivs.
	 * Accounts for scale; also call after any scaleGridInvalidate.
	 */
	private function updateRenderOffset( inAnimFrameIdx:Null<Int> = null ):Void
	{
		var animFrameIdx:Int = Params.NO_FRAME;
		if ( Std.is( bitmapData, BitmapDataWithParams ) )
		{
			var bdwp:BitmapDataWithParams = cast bitmapData;
			animFrameIdx = bdwp.animFrameIndex;
		}
		
		// Determine which box data is active, accounting for any new scale.
		var boxData:SpriteBoxData = getMungedBoxData();

		// Move everything so that ref point (or lack thereof) is accurate
		if ( m_img != null )
		{
			var renderX:Float = 0;
			var renderY:Float = 0;

			// Reference point, aka "center": offset from original image (with padding) top left corner.
			if ( boxData != null )
			{
				var refPt:Point = boxData.refPoint;
				if ( refPt != null )
				{
					//trace( 'refpt for $name: $refPt' );
					renderX = -refPt.x;
					renderY = -refPt.y;
				}
			}
			
			// Sprite trim offset (ala dataOffset in dslib):
			// vector from the original image (with padding) top left corner
			// to the top left corner of the minimum visible axis aligned box.
			var offset:Point = Params.getWithDefault( null, bitmapData, Params.getParamVector, Params.OFFSET, animFrameIdx, Params.NO_ID, Params.FRAME_FALLBACK );
			if ( offset != null )
			{
				//trace( 'offset for $name: $offset' );
				// TODO SCALE: scale by difference between m_advertisedScale and super.get_scale
				renderX += offset.x;
				renderY += offset.y;
			}
			
			m_img.x = renderX;
			m_img.y = renderY;
		}

	}

	/**
	 * Update debug drawing.  Call after any needed updateBoxDataAndDivs and after updateRenderOffset.
	 */
	private function updateDebugDrawing():Void
	{	
		if (ms_debugDrawingEnabled)
		{
			//Remove the previous bounds shape
			if (m_boundsDataShape != null)
			{
				removeChild(m_boundsDataShape);
				m_boundsDataShape = null;
			}
			
			if (ms_debugDrawingFlags.has(DRAW_BOUNDS_BOX))
			{
				var boxData:SpriteBoxData = getMungedBoxData();
				if( boxData != null )
				{
					m_boundsDataShape = new Shape();
					addChild(m_boundsDataShape);
				
				
					var boundsAlpha:Float = 0.3;
					var refPtAlpha:Float = 0.5;
					var refPtSize:Float = 8.0;
					
					//don't want negative scales to make ref point not draw!
					var absScaleX = Math.abs(scaleX);
					var absScaleY = Math.abs(scaleY);

					m_boundsDataShape.graphics.clear();
					
					var bounds:Rectangle = boxData.offsetBounds;
					if ( bounds != null )
					{
						m_boundsDataShape.blendMode = BlendMode.ADD;
						m_boundsDataShape.graphics.beginFill( 0x00FF00, boundsAlpha );
						m_boundsDataShape.graphics.drawRect( bounds.left, bounds.top, bounds.width, bounds.height );
						m_boundsDataShape.graphics.endFill();
					}
					
					// Reference point is exactly the same location as self; center around 0.
					// Only the child image (aka render position) moves with the reference point.
					//we dont want the ref pt marker to scale with the object
					m_boundsDataShape.graphics.beginFill( 0xFF0000, refPtAlpha );
					m_boundsDataShape.graphics.drawRect( -(refPtSize*0.5) / absScaleX, -(refPtSize*0.5) / absScaleY, refPtSize / absScaleX, refPtSize / absScaleY );
					m_boundsDataShape.graphics.endFill();
				}
			}
			
			//Remove any previous params shapes
			if (m_paramBoxShapes != null)
			{
				for (shape in m_paramBoxShapes)
				{
					removeChild(shape);
				}
			}		
			m_paramBoxShapes = [];
			
			if (shouldShowAnyParamBoxType())
			{
				var boxTypes:Array<ParamBoxType> = EnumTools.createAll(ParamBoxType);
				for (boxType in boxTypes)
				{
					if (shouldDrawParamBoxType(boxType))
					{
						var boxColor:Int = ParamBoxData.getDebugColorForBoxType(boxType);
						
						var paramBoxes:Array<ParamBoxData> = getParamBoxes(boxType);
						if ( paramBoxes.length > 0 )
						{	
							for (paramBox in paramBoxes)
							{
								var box:Rectangle = paramBox.box;
								var boxTopLeftX:Float = box.x;
								var boxTopLeftY:Float = box.y;
								
								var nextBox:Shape = new Shape();
								addChild(nextBox);
								
								nextBox.graphics.clear();
								nextBox.blendMode = BlendMode.ADD;
								nextBox.graphics.beginFill( boxColor, ParamBoxData.DEBUG_BOX_ALPHA );
								nextBox.graphics.drawRect( boxTopLeftX, boxTopLeftY, box.width, box.height );
								nextBox.graphics.endFill();
								
								m_paramBoxShapes.push(nextBox);
							}
						}
					}
				}
			}
		}
	}
	
	//-----------------------------------------------------------------------------------------------------------

	override private function __getBounds (rect:Rectangle, matrix:Matrix):Void {

		var boxData:SpriteBoxData = getMungedBoxData();
		if ( ( boxData != null ) && ( boxData.bounds != null ) )
		{
			// Override the DOC __getBounds; don't check children.
			var boundsToUse:Rectangle = boxData.bounds;
			if ( boxData.refPoint != null )
			{
				// Offset for refpt.
				__tempBounds.copyFrom( boundsToUse );
				__tempBounds.offset( -boxData.refPoint.x, -boxData.refPoint.y );
				boundsToUse = __tempBounds;
			}
			
			var transformedBounds:Rectangle = new Rectangle();
			boundsToUse.__transform( transformedBounds, matrix );
			rect.__expand( transformedBounds.x, transformedBounds.y, transformedBounds.width, transformedBounds.height );
		}
		else
		{
			// Fall back.
			// If we have a refPoint but no bounds, this should still work
			// due to offset child position.
			super.__getBounds( rect, matrix );
		}
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	/**
	  * Overrides DisplayObjectContainer __hitTest; @see Bitmap.hx for where this comes from.
	  */
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool {
		
		var boxData:SpriteBoxData = getMungedBoxData();
		if ( ( boxData != null ) && ( boxData.bounds != null ) )
		{
			if (!hitObject.visible || __isMask || bitmapData == null || (interactiveOnly && !mouseEnabled && !mouseChildren)) return false;
			if (mask != null && !mask.__hitTestMask (x, y)) return false;
			
			__getWorldTransform ();
			
			
			//trace( 'hittest $name x,y: $x, $y' );
			
			var px = __worldTransform.__transformInverseX (x, y);
			var py = __worldTransform.__transformInverseY (x, y);
			
			//trace( 'hittest px,py: $px, $py' );
			
			if ( boxData.refPoint != null )
			{
				px += boxData.refPoint.x;
				py += boxData.refPoint.y;
			}
			
			//trace( 'hittest px,py after refpt: $px, $py' );
			
			//trace( 'bounds: ${boxData.bounds}' );
			
			if ( boxData.bounds.contains( px, py ) ) {
				
				if (stack != null /* && !interactiveOnly */ ) { // TODO: don't assume we're interactive?
					
					//trace ( 'hit: push $hitObject' );
					
					stack.push (hitObject);
					
				}
				
				//trace( 'hit' );
				return true;
				
			}
			
			return false;
		}
		else
		{
			// Fall back.
			// Once again ok with refpt because child will be offset, and this is a DOC.
			return super.__hitTest( x, y, shapeFlag, stack, interactiveOnly, hitObject );
		}
		
	}

	//-----------------------------------------------------------------------------------------------------------
	
	/**
	 * @return Clone (UNSCALED, UNTRANSLATED -- relative to refpt) of current SpriteBoxData (safe to mutate);
	 *         user-specified data from updateBounds will be provided before data from params.
	 */
	public function getBoundsData():SpriteBoxData
	{
		var boxData:SpriteBoxData = getBoxData();
		return ( boxData != null ) ? boxData.copy() : null;
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	/**
	 * Just changes BitmapData, does not take/share ownership of the img Bitmap param.
	 */
	public function changeImage( img:Bitmap ):Void
	{
		changeImageData( img != null ? img.bitmapData : null );
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	private function isBitmapDataChanged( newBitmapData:BitmapData ):Bool
	{
		var oldBitmapData:BitmapData = ( m_img != null ) ? m_img.bitmapData : null;
		
		if ( newBitmapData == null )
		{
			// Changing to empty?
			return oldBitmapData != null;
		}
		
		if ( m_originalBitmapData != null )
		{
			// If original bitmap data exists, compare against that.
			return m_originalBitmapData != newBitmapData;
		}

		return oldBitmapData != newBitmapData;
	}
	
	
	//-----------------------------------------------------------------------------------------------------------

	public function changeImageData( imgData:BitmapData ):Void
	{
		if ( m_img != null )
		{
			if ( isBitmapDataChanged( imgData ) )
			{
				m_img.bitmapData = imgData;
				m_img.smoothing = smoothing;
				updateBoxDataAndDivs();
				scaleGridInvalidate();
				updateRenderOffset();
				updateDebugDrawing();
			}
		}
		else
		{
			m_img = new Bitmap( imgData ); // including null imgData
			// set_m_img will trigger updateBoxDataFromParams.
			m_img.smoothing = smoothing;
		}
		
	}

	//-----------------------------------------------------------------------------------------------------------

	// Convenience wrappers for BitmapData.
	// See http://community.openfl.org/t/local-transform-pivot-point-for-art/7437/2 .
	private inline function get_bitmapData():BitmapData {
		return ( m_img != null ) ? m_img.bitmapData : null;
	}
	private inline function set_bitmapData(value:BitmapData):BitmapData {
		changeImageData( value );
		return value;
	}
		
	private inline function set_smoothing(value:Bool):Bool {
		
		if (ms_forceSmoothingOn)
		{
			value = true;
		}
		
		if ( m_img != null )
		{
			m_img.smoothing = value;
		}
		return smoothing = value;
	}

	
	//-----------------------------------------------------------------------------------------------------------
	
	private function set_m_img( img:Bitmap ):Bitmap
	{
		if ( m_img != null )
		{
			if ( m_img.parent != null )
			{
				m_img.parent.removeChild( m_img );
			}
			m_img = null;
		}

		// Set m_img before calling updateBoxDataFromParams -- it needs m_img.
		// Also wise to set it before calling addChild, which can trigger arbitrary
		// code via Event dispatch.
		m_img = img;

		updateBoxDataAndDivs();
		scaleGridInvalidate();
		updateRenderOffset();

		if ( m_img != null )
		{
			addChild( m_img );
		}
		// Must be after addChild to ensure debug shapes are on top and in order.
		updateDebugDrawing();

		return m_img;
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	/**
	 * Turn on drawing debug shapes for bounding boxes.
	 * @deprecated Use enableDebugDrawFlag(DRAW_BOUNDS_BOX) instead.
	 */
	public static function showSpriteBoundingBoxes():Void
	{
		enableDebugDrawFlag(DRAW_BOUNDS_BOX);
	}
	
	//-----------------------------------------------------------------------------------------------------------
	/**
	 * Turn off drawing debug shapes for bounding boxes.
	 * @deprecated Use disableDebugDrawFlag(DRAW_BOUNDS_BOX) instead.
	 */
	public static function hideSpriteBoundingBoxes():Void
	{
		disableDebugDrawFlag(DRAW_BOUNDS_BOX);
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	public static function enableDebugDrawFlag(flag:DebugDrawingFlag):Void
	{
		ms_debugDrawingFlags.set(flag);
		ms_debugDrawingEnabled = true;
	}
	
	//-----------------------------------------------------------------------------------------------------------

	public static function disableDebugDrawFlag(flag:DebugDrawingFlag):Void
	{
		ms_debugDrawingFlags.unset(flag);
	}
	
	//-----------------------------------------------------------------------------------------------------------

	private static function shouldShowAnyParamBoxType():Bool
	{
		var shouldShow:Bool = false;
		var boxTypes:Array<ParamBoxType> = EnumTools.createAll(ParamBoxType);
		for (boxType in boxTypes)
		{
			if (shouldDrawParamBoxType(boxType))
			{
				shouldShow = true;
				break;
			}
		}
		
		return shouldShow;
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	private static function shouldDrawParamBoxType(boxType:ParamBoxType):Bool
	{
		var flagType:DebugDrawingFlag = INVALID_FLAG;
		switch(boxType)
		{
			case VULNERABLE: flagType = DRAW_VULNERABLE_BOX;
			case ATTACK: flagType = DRAW_ATTACK_BOX;
			case ATTACK_SELECT: flagType = DRAW_ATTACK_SELECT_BOX;
		}
		
		return ms_debugDrawingFlags.has(flagType);
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	public function setScale( size:Float ):Void
	{
		scaleGridUpdate( size, size );
		updateRenderOffset();
		updateDebugDrawing();
	}

	//-------------------------------------------
	private override function set_scaleY(value:Float):Float {
		scaleGridUpdate( m_advertisedScaleX, value );
		updateRenderOffset();
		updateDebugDrawing();
		return m_advertisedScaleY;
	}
	
	//-------------------------------------------
	private override function set_scaleX(value:Float):Float {
		scaleGridUpdate( value, m_advertisedScaleY );
		updateRenderOffset();
		updateDebugDrawing();
		return m_advertisedScaleX;
	}
	
	//-------------------------------------------
	private override function get_scaleX():Float
	{
		// TODO: this is bad, if you set_rotation or anything that updates transform matrix after this, this new scale may be rolled in, which we may not want.
		return m_advertisedScaleX;
	}

	//-------------------------------------------
	private override function get_scaleY():Float
	{
		// TODO: see comments on get_scaleX.
		return m_advertisedScaleY;
	}

	//-----------------------------------------------------------------------------------------------------------
	// Overriding __getCursor from DisplayObject, which always returns null.
	// Stage.__onMouse calls this on each DisplayObject under the cursor
	// to see if it should override the default (arrow) cursor.
	private override function __getCursor():MouseCursor
	{
		return cursor;
	}
	
	//-----------------------------------------------------------------------------------------------------------
	
	public function set_divs( newXDivs:Array<Int>, newYDivs:Array<Int> ):Void
	{
		m_userXDivs = newXDivs;
		m_userYDivs = newYDivs;
		scaleGridUpdate( m_advertisedScaleX, m_advertisedScaleY );
	}

	//-------------------------------------------
	public function get_xDivs():Array<Int>
	{
		if ( m_userXDivs != null ) return m_userXDivs;
		else return m_paramsXDivs;
	}

	//-------------------------------------------
	public function get_yDivs():Array<Int>
	{
		if ( m_userYDivs != null ) return m_userYDivs;
		else return m_paramsYDivs;
	}

	//-------------------------------------------
	public function set_xDivs(value:Array<Int>):Array<Int>
	{
		var ret:Array<Int> = ( m_userXDivs = value );
		scaleGridUpdate( m_advertisedScaleX, m_advertisedScaleY );
		return ret;
	}

	//-------------------------------------------
	public function set_yDivs(value:Array<Int>):Array<Int>
	{
		var ret:Array<Int> = ( m_userYDivs = value );
		scaleGridUpdate( m_advertisedScaleX, m_advertisedScaleY );
		return ret;
	}

	//-----------------------------------------------------------------------------------------------------------
	/**
	 * The "original" image has changed; make a note for the scale grid,
	 * and either lazily or immediately update the grid as needed (may change).
	 */
	private function scaleGridInvalidate():Void
	{
		m_originalBitmapData = null;
		scaleGridUpdate( m_advertisedScaleX, m_advertisedScaleY );
	}
	
	//-------------------------------------------
	private static function calcStretchySrcPixels( divIter:DivIterator, dim:Int ):Int
	{
		var numStretchyPixels = 0;
		divIter.reset();
		while ( divIter.hasNext() )
		{
			var divStart:Int = divIter.cursor;
			var divEnd:Int = divIter.next();
			
			if ( ! divIter.isFixed )
			{
				// Stretchy section! (Odd slice, starting at 0.)
				var sectionPx:Int = divEnd - divStart;
				numStretchyPixels += sectionPx;
			}
		}
		
		return numStretchyPixels;
	}
	
	//-------------------------------------------
	private static function calcStretchyDim( srcSectionDim:Int, dstSectionBgn:Int, dstDim:Int, numFixedSrcRemaining:Int, numStretchySrcRemaining:Int )
	{
		// Figure out how much space we have remaining.
		var dstTotalSpaceRemaining:Int = dstDim - dstSectionBgn;
		
		// Of that, how much should be stretchy?
		// One fixed source pixel = one fixed dest pixel, so subtract those out.
		var dstStretchySpaceRemaining:Int = dstTotalSpaceRemaining - numFixedSrcRemaining;

		var dstStrechySectionDim:Int = 0;
		if ( numStretchySrcRemaining > 0 )
		{
			// Now we want a fraction of that remaining dst space: srcSectionDim/numStretchySrcRemaining of the total.
			// Units are dst * (src/src) = dst, or equivalently ( ( dst * src ) / src ) = dst.
			// Round to nearest; clamped to stay in range later.
			dstStrechySectionDim = Math.round( ( dstStretchySpaceRemaining * srcSectionDim ) / numStretchySrcRemaining );
		}
		else
		{
			// No stretchy source pixels remaining, or some kind of error.
			// Return all the remaining stretchy space (likely zero).
			Debug.warn_if( dstStretchySpaceRemaining != 0, '9-slice: dst had $dstStretchySpaceRemaining stretchy px remaining, but src had $numStretchySrcRemaining' );
			dstStrechySectionDim = dstStretchySpaceRemaining;
		}
		
		// Clamp: within dstStretchySpaceRemaining if possible, and always positive or zero.
		if ( dstStrechySectionDim > dstStretchySpaceRemaining )
		{
			dstStrechySectionDim = dstStretchySpaceRemaining;
		}
		if ( dstStrechySectionDim < 0 )
		{
			dstStrechySectionDim = 0;
		}
		
		return dstStrechySectionDim;
	}


	//-------------------------------------------
	private function scaleGridUpdate( desiredScaleX:Float, desiredScaleY:Float ):Void
	{
		if ( ( m_originalBitmapData != null ) &&
			 ( desiredScaleX == m_advertisedScaleX ) &&
			 ( desiredScaleY == m_advertisedScaleY ) )
		{
			// No change.
			return;
		}
		
		m_advertisedScaleX = desiredScaleX;
		m_advertisedScaleY = desiredScaleY;
		
		// Make sure we're dealing with the original unscaled BitmapData.
		var srcBitmapData:BitmapData = m_originalBitmapData;
		if ( ( srcBitmapData == null ) && ( m_img != null ) )
		{
			// We don't have an "original"; the image must have been
			// recently updated.  Use it as original from here out.
			srcBitmapData = m_img.bitmapData;
			// We'll update m_originalBitmapData at the end, if we reach there.
		}
		
		if ( srcBitmapData == null )
		{
			// No image.  Need to wait for one.
			// Quiet return.
			// Let super.scale handle this.
			super.set_scaleX( desiredScaleX );
			super.set_scaleY( desiredScaleY );
			return;
		}
		
		var srcWidth:Int  = srcBitmapData.width;
		var srcHeight:Int = srcBitmapData.height;
		
		// Early exit if we don't have a grid.
		var myXDivs:Array<Int> = xDivs;
		var myYDivs:Array<Int> = yDivs;
		
		var noXDivs:Bool = ( myXDivs == null ) || ( myXDivs.length < 1 ) || ( myXDivs[0] >= srcWidth );
		var noYDivs:Bool = ( myYDivs == null ) || ( myYDivs.length < 1 ) || ( myYDivs[0] >= srcHeight );
		if ( noXDivs && noYDivs )
		{
			// No segments (or only one full-sized segment).
			// Quiet return.
			// Let super.scale handle this.
			super.set_scaleX( desiredScaleX );
			super.set_scaleY( desiredScaleY );
			return;
		}

		// Compute dstWidth and dstHeight.
		var effectiveScaleX:Float = Math.max( Math.abs( desiredScaleX ), 1.0 );
		var effectiveScaleY:Float = Math.max( Math.abs( desiredScaleY ), 1.0 );
		if ( ( effectiveScaleX == 1.0 ) && ( effectiveScaleY == 1.0 ) ) // TODO NaN early exit?
		{
			// No scale or less than one, no room to stretch.
			// Quiet return.
			// Let super.scale handle this.
			super.set_scaleX( desiredScaleX );
			super.set_scaleY( desiredScaleY );
			return;
		}
		
		var dstWidth:Int  = Math.ceil( srcBitmapData.width  * effectiveScaleX );
		var dstHeight:Int = Math.ceil( srcBitmapData.height * effectiveScaleY );
		
		// Create new target area.
		var dstBitmapData:BitmapData = null;
		if ( Std.is( srcBitmapData, HasParams ) )
		{
			var srcWithParams:HasParams = cast srcBitmapData;
			var params:Params = srcWithParams.getParams();
			if ( params != null )
			{
				// Create with params.  Flat black, possibly transparent.
				dstBitmapData = new BitmapDataWithParams( params, dstWidth, dstHeight, srcBitmapData.transparent, _fillColor );
			}
		}
		
		if ( dstBitmapData == null )
		{
			// Create without params.  Flat black, possibly transparent.
			dstBitmapData = new BitmapData( dstWidth, dstHeight, srcBitmapData.transparent, _fillColor );
		}
		
		// PERF: avoid iterator dynalloc?
		var iterX = new DivIterator( myXDivs, srcWidth );
		var iterY = new DivIterator( myYDivs, srcHeight );

		var numStretchyXSrcPixels:Int = calcStretchySrcPixels( iterX, srcWidth );
		var numStretchyYSrcPixels:Int = calcStretchySrcPixels( iterY, srcHeight );
		var numFixedXSrcPixels:Int = srcWidth  - numStretchyXSrcPixels;
		var numFixedYSrcPixels:Int = srcHeight - numStretchyYSrcPixels;
		
		// Loop over rows.
		{
			var numStretchyYSrcPixelsRemaining:Int = numStretchyYSrcPixels;
			var numFixedYSrcPixelsRemaining:Int = numFixedYSrcPixels;

			var dstSectionBgnY:Int = 0;
			iterY.reset();
			while ( iterY.hasNext() )
			{
				var srcSectionBgnY:Int = iterY.cursor;
				var srcSectionEndY:Int = iterY.next();
				var srcSectionDimY:Int = srcSectionEndY - srcSectionBgnY;
				var isFixedY:Bool = iterY.isFixed; // only after next()
				
				var dstSectionDimY:Int = isFixedY ? srcSectionDimY : calcStretchyDim( srcSectionDimY, dstSectionBgnY, dstHeight, numFixedYSrcPixelsRemaining, numStretchyYSrcPixelsRemaining );
				var dstSectionEndY:Int = dstSectionBgnY + dstSectionDimY;
				
				// Loop over columns.
				{
					// Reset stretchy and fixed counters for this new row.
					var numStretchyXSrcPixelsRemaining:Int = numStretchyXSrcPixels;
					var numFixedXSrcPixelsRemaining:Int = numFixedXSrcPixels;
					
					var dstSectionBgnX:Int = 0;
					iterX.reset();
					while ( iterX.hasNext() )
					{
						var srcSectionBgnX:Int = iterX.cursor;
						var srcSectionEndX:Int = iterX.next();
						var srcSectionDimX:Int = srcSectionEndX - srcSectionBgnX;
						var isFixedX:Bool = iterX.isFixed; // only after next()
						
						var dstSectionDimX:Int = isFixedX ? srcSectionDimX : calcStretchyDim( srcSectionDimX, dstSectionBgnX, dstWidth, numFixedXSrcPixelsRemaining, numStretchyXSrcPixelsRemaining );
						var dstSectionEndX:Int = dstSectionBgnX + dstSectionDimX;
						
						// TODO tile support?  Currently only stretch.
						drawSubrect( dstBitmapData, srcBitmapData,
							dstSectionBgnX, dstSectionBgnY,
							dstSectionDimX, dstSectionDimY,
							srcSectionBgnX, srcSectionBgnY,
							srcSectionDimX, srcSectionDimY );
						
						numStretchyXSrcPixelsRemaining -= isFixedX ? 0 : srcSectionDimX;
						numFixedXSrcPixelsRemaining -= isFixedX ? srcSectionDimX : 0;
						dstSectionBgnX = dstSectionEndX;
						//break; // DO NOT CHECK IN, for testing
					}
				}
				// end "Loop over columns."
				
				numStretchyYSrcPixelsRemaining -= isFixedY ? 0 : srcSectionDimY;
				numFixedYSrcPixelsRemaining -= isFixedY ? srcSectionDimY : 0;
				dstSectionBgnY = dstSectionEndY;
				//break; // DO NOT CHECK IN, for testing
			}
			
		}
		// End "Loop over rows."
		
		// Use new bitmap data (commit results).
		m_originalBitmapData = srcBitmapData;
		m_img.bitmapData = dstBitmapData;
		m_img.smoothing = smoothing;
		// Update super.scale: if we stretched this dimension here, 1.0 (or -1.0 if flippped), otherwise what was said.
		super.set_scaleX( ( effectiveScaleX > 1.0 ) ? MathUtils.signFloat(desiredScaleX) : desiredScaleX );
		super.set_scaleY( ( effectiveScaleY > 1.0 ) ? MathUtils.signFloat(desiredScaleY) : desiredScaleY );
		
		// TODO: vet for "no stretchy sections"
		// TODO: report if there are remaining stretchy or fixed pixels? (also in row loop)
	}

	private function drawSubrect( dstBitmapData:BitmapData, srcBitmapData:BitmapData,
								  dstSectionBgnX:Int, dstSectionBgnY:Int,
								  dstSectionDimX:Int, dstSectionDimY:Int,
								  srcSectionBgnX:Int, srcSectionBgnY:Int,
								  srcSectionDimX:Int, srcSectionDimY:Int )
	{
		// TODO: replace all of this with a polygrid draw where we can; no new BitmapData.
		
		if ( srcBitmapData == null || dstBitmapData == null )
		{
			// Should never reach here due to checks in caller.
			Debug.warn( "9-slice: missing src or dst BitmapData" );
			return;
		}
		if ( dstSectionDimX == 0 || dstSectionDimY == 0 )
		{
			// Nowhere to blit to.  Normal 0-sized section, ignore.
			// Quiet return.
			return;
		}
		if ( srcSectionDimX == 0 || srcSectionDimY == 0 )
		{
			// No source.  Leave as initialized (flat black, possibly transparent).
			// Also protects us from divide by zero below.
			// Quiet return.
			return;
		}
		
		// Smoothing may need to be off for some or all of our current renderers
		// to avoid pulling in out-of-region pixels.
		// However, smoothing off results in some very jagged edges with the current version of openfl (6.0.1)
		// TODO: re-test smoothing, and perhaps expose it to API clients
		//var smooth:Bool = false;

		var fixed:Bool = ( srcSectionDimX == dstSectionDimX ) && ( srcSectionDimY == dstSectionDimY );
		if ( fixed )
		{
			var srcRect:Rectangle = _staticDrawRect;
			srcRect.x = srcSectionBgnX;
			srcRect.y = srcSectionBgnY;
			srcRect.width  = srcSectionDimX;
			srcRect.height = srcSectionDimY;
			
			var dstPoint:Point = _staticDrawPoint;
			dstPoint.x = dstSectionBgnX;
			dstPoint.y = dstSectionBgnY;
			
			// copyPixels (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point,
			//     alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Bool = false):Void
			dstBitmapData.copyPixels( srcBitmapData, srcRect, dstPoint );
		}
		else
		{
			// Needs stretch.
			var mtx:Matrix = _staticDrawMatrix;
			mtx.identity();
			// TODO: blendmode equivalent to "replace"?
			// TODO: clip perf sucks?

			// We need to scale "around" the source section.  Translate it back to 0,0 and scale.
			mtx.translate( -srcSectionBgnX, -srcSectionBgnY);
			mtx.scale( dstSectionDimX / srcSectionDimX, dstSectionDimY / srcSectionDimY );
			
			// Finally, translate to the destination.
			mtx.translate( dstSectionBgnX, dstSectionBgnY );

			// Despite the AS3/OpenFL docs, the clipRect is in *destination* space; the
			// Cairo and HTML5 mask managers all clip the destination buffer.
			// TODO: verify under GL.
			var clipRect:Rectangle = _staticDrawRect;
			clipRect.x = dstSectionBgnX;
			clipRect.y = dstSectionBgnY;
			clipRect.width  = dstSectionDimX;
			clipRect.height = dstSectionDimY;

			// draw (source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null,
			//     blendMode:BlendMode = null, clipRect:Rectangle = null, smoothing:Bool = false):Void
			dstBitmapData.draw( srcBitmapData, mtx, null, null, clipRect, smoothing );
		}
	}
}

//-------------------------------------------
class DivIterator
{
	// Configuration (dimension) values.
	var divs:Array<Int> = null;
	var dim:Int = 0;
	
	// Iteration state.
	var idx:Int = 0;
	public var cursor(default,null):Int = 0;
	public var isFixed(default,null):Bool = false; //!< after first next(), will be true
	
	@:allow(com.firstplayable.hxlib.display.OPSprite)
	private function new( aDivs:Array<Int>, aDim:Int )
	{
		this.divs = aDivs;
		this.dim = ( ( aDim >= 0 ) ? aDim : 0 );
	}
	
	/** Re-start iterator. */
	public function reset():Void
	{
		idx = 0;
		cursor = 0;
		isFixed = false;
	}
	
	/** Are there div markers (or end div) remaining? */
	public function hasNext():Bool
	{
		return ( divs != null && idx < divs.length ) || ( cursor < dim );
	}

	/**
	 *  Advance to next div and return cursor (clamped and forced monotonic for safety).
	 * Will return dim once at end, if we haven't already met/exceeded it.
	 */
	public function next():Int
	{
		var val:Int;
		
		isFixed = ( ( idx & 1 ) == 0 ); // even indices are fixed
		if ( divs != null && idx < divs.length )
		{
			// Still reading the array.
			val = divs[idx++];
			if ( val < cursor )
			{
				Debug.warn( '9-slice: bad div array (non-monontonic increasing): $val < $cursor' );
				// Force monontonic: never return less than prior cursor.
				val = cursor;
			}
		}
		else
		{
			// Final entry, dim, in case the array didn't meet this.
			val = dim;
		}
		
		// Clamp for sanity.
		if ( val > dim )
		{
			Debug.warn( '9-slice: bad div array (out-of-bounds high): $val > $dim' );
			val = dim;
		}
		if ( val < 0 )
		{
			Debug.warn( '9-slice: bad div array (out-of-bounds low): $val < 0' );
			val = 0;
		}
		
		cursor = val;
		return val;
	}
}