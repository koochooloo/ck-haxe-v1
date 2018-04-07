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
package com.firstplayable.hxlib.display;
import haxe.ds.StringMap;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Holds sprite parameters from Oriolo/.rpj files, including "center" aka refpt,
 * "bounds", "attackbox", "vulnerablebox", and "attackselectbox", among others.
 * 
 * Roughly the same API as ParamsResourceData in dslib.
 * 
 * @see https://wiki.1stplayable.com/index.php/Web/Haxe/Reference_Points_and_Boxes_RFC
 * @see https://wiki.1stplayable.com/index.php/Tools/RPJ2DS
 * @author Leander
 */
class Params
{
	//
	// Known / common parameter names and aliases.
	//
	
	public static inline var CENTER:String       = "center";
	public static inline var REFPT:String        = CENTER;
	public static inline var BOUNDS:String       = "bounds";
	public static inline var BOUNDING_BOX:String = BOUNDS;
	public static inline var LOOPING:String      = "looping";
	public static inline var ATTACK_BOX:String   = "attackbox";
	public static inline var VULNERABLE_BOX:String = "vulnerablebox";
	public static inline var ATTACK_SELECT_BOX:String = "attackselectbox";
	
	public static inline var OFFSET:String       = "offset";
	
	
	//
	// Other constants
	//
	
	/** Placeholder for any frame / all frames / no frame info. */
	public static inline var NO_FRAME:Int = -1;
	public static inline var NO_FRAME_STR:String = "-1";
	/** Placeholder for any ID / all IDs / no ID info. */
	public static inline var NO_ID:Int = -1;
	public static inline var NO_ID_STR:String = "-1";
	
	
	//
	// Behavior flags
	//
	
	/** Search at NO_FRAME after trying frame, if appropriate. */
	public static inline var FRAME_FALLBACK:Int = 1 << 1;

	/** When specifying a frame, find params that overlap that frame (frame <= x <= lastFrame).
	 * Currently only implemented for getAll.
	 */
	public static inline var FRAME_OVERLAP:Int = 1 << 2;
	
	//
	// Members and constructor.
	// 
	
	/**
	 * Two-level map: name -> frameStr -> [ param ]
	 */
	private var nameFrameMap:Dynamic;

	public function new( paramsData:Dynamic ) 
	{
		nameFrameMap = paramsData;
		if ( nameFrameMap == null )
		{
			nameFrameMap = {};
		}
	}
	
	
	//
	// Param accessors.
	//
	
	/**
	 * @return true if get( name, frame, id, behaviorFlags ) would return non-null.
	 */
	public function has( name:String, frame:Int = NO_FRAME, id:Int = NO_ID, behaviorFlags:Int = 0 ):Bool
	{
		return get( name, frame, id, behaviorFlags ) != null;
	}
	
	/**
	 * Find a parameter.  NO_ID = match any id; NO_FRAME = only match NO_FRAME or missing frame.
	 * @return null or a reference to the param at (name,frame,id);
	 *         take care not to modify!
	 */
	public function get( name:String, frame:Int = NO_FRAME, id:Int = NO_ID, behaviorFlags:Int = 0 ):Dynamic
	{
		var frameMap:Dynamic = Reflect.field( nameFrameMap, name );
		if ( frameMap != null )
		{
			var frameStr:String = Std.string( frame );
			var idStr:String = Std.string( id );
			
			var paramList:Dynamic = Reflect.field( frameMap, frameStr );
			if ( paramList != null )
			{
				for ( i in 0...paramList.length )
				{
					var param:Dynamic = paramList[i];
					if ( id == NO_ID || getParamIdOrDefault( param ) == id )
					{
						return param;
					}
				}
			}
			
			if ( ( frame != NO_FRAME ) && ( ( behaviorFlags & FRAME_FALLBACK ) != 0 ) )
			{
				paramList = Reflect.field( frameMap, NO_FRAME_STR );
				if ( paramList != null )
				{
					for ( i in 0...paramList.length )
					{
						var param:Dynamic = paramList[i];
						if ( id == NO_ID || getParamIdOrDefault( param ) == id )
						{
							return param;
						}
					}
				} // end if ( paramList != null )
			} // end FRAME_FALLBACK logic
		} // end if ( mapFrameId != null )

		return null;
	}
	
	/**
	 * Find all params named name at frame frame.
	 *
	 * Usage example: for ( boxParam in myParams.getAll( "attackBox", curFrame ) )
	 *
	 * Takes the place of populateWith and populateWith2 in ParamsResourceData.
	 * 
	 * May take FRAME_OVERLAP or FRAME_FALLBACK.
	 * 
	 * NO_FRAME only matches other NO_FRAME/null-frame entries;
	 * it will not match all frames.
	 *
	 * @return an iterator over the references to all the params at (name,frame);
	 *         take care not to modify! Can't return null.
	 */
	public function getAll( name:String, frame:Int, behaviorFlags:Int = 0 ):ParamsIter
	{
		var frameMap:Dynamic = Reflect.field( nameFrameMap, name );
		return new ParamsIter( frameMap, frame, behaviorFlags );
	}

	/**
	 * Attempt to find and return a parameter's attribute's contents, falling back to
	 * fallbackValue (first arg) if anything goes wrong.
	 * 
	 * Effectively, this will return the fallbackValue unless (in order):
	 *    1.) obj implements HasParams (provides .getParams())
	 *    2.) params -- from obj.getParams() -- is not null
	 *    3.) param -- from params.get( name, frame, id ) -- is found and therefore not null
	 *    4.) applying func( param ) returns a non-null value
	 * 
	 * Example:
	 *   Params.getWithDefault( false, behavior, Params.getParamValueBool, Params.LOOPING );
	 * 
	 * @return parameter attribute value (type T) or fallbackValue.
	 */
	public static function getWithDefault<T>( fallbackValue:T, obj:Dynamic, func:Dynamic->T, name:String, frame:Int = NO_FRAME, id:Int = NO_ID, behaviorFlags:Int = 0 ):T
	{
		if ( ! Std.is( obj, HasParams ) )
		{
			// This is not an object type that carts around Params.
			return fallbackValue;
		}
		
		var objWithParams:HasParams = cast obj;
		var params:Params = objWithParams.getParams();
		if ( params == null )
		{
			// No Params.
			return fallbackValue;
		}
		
		var param:Dynamic = params.get( name, frame, id, behaviorFlags );
		if ( param == null )
		{
			// Param not found.
			
			// Technically not necessary since the func candidates
			// should all return null when given null, but
			// user may pass in another func or something...
			// Let's be paranoid!
			return fallbackValue;
		}
		
		var retVal:Null<T> = func( param );
		if ( retVal == null )
		{
			// No attribute on this param.
			
			return fallbackValue;
		}
		
		return retVal;
	}
	
	private static inline function getParamFieldAsInt( param:Dynamic, field:String ):Null<Int>
	{
		var v:Dynamic = Reflect.field( param, field );
		return Std.is (v, Int) ? cast v : null;
	}
	
	private static inline function getParamFieldAsBool( param:Dynamic, field:String ):Null<Bool>
	{
		var v:Dynamic = Reflect.field( param, field );
		if ( Std.is (v, Bool) )
		{
			return cast v;
		}
		else if ( Std.is (v, Int) )
		{
			var vAsInt:Int = cast v;
			return vAsInt != 0;
		}
		else // TODO other truthy things? https://developer.mozilla.org/en-US/docs/Glossary/Truthy
		{
			return null;
		}
	}
	
	private static inline function getParamFieldAsString( param:Dynamic, field:String ):String
	{
		var v:Dynamic = Reflect.field( param, field );
		return Std.is (v, String) ? cast v : null;
	}

	/**
	 * @return parameter name if present, otherwise throws.  Should be present for valid parameters.
	 */
	public static inline function getParamName( param:Dynamic ):String
	{
		return cast param.name;
	}
	
	/**
	 * @return parameter frame if present, otherwise null.
	 * @note NO_FRAME means "don't care" or "all frames".
	 */
	public static inline function getParamFrame( param:Dynamic ):Null<Int>
	{
		return getParamFieldAsInt( param, "frame" );
	}
	
	/**
	 * @return parameter frame if present, otherwise NO_FRAME.
	 * @note NO_FRAME means "don't care" or "all frames".
	 */
	public static inline function getParamFrameOrDefault( param:Dynamic ):Int
	{
		var frameOrNull:Null<Int> = getParamFrame( param );
		if ( frameOrNull != null )
		{
			var frame:Int = frameOrNull;
			return frame;
		}
		else
		{
			return NO_FRAME;
		}
	}

	/**
	 * @return parameter lastFrame if present, otherwise null.
	 * @note NO_FRAME (-1) means single-frame-only (unless getParamFrame == NO_FRAME)
	 */
	public static inline function getParamLastFrame( param:Dynamic ):Null<Int>
	{
		return getParamFieldAsInt( param, "lastFrame" );
	}

	/**
	 * @return parameter lastFrame if present, otherwise NO_FRAME.
	 * @note NO_FRAME (-1) means "don't care" or "all frames".
	 */
	public static inline function getParamLastFrameOrDefault( param:Dynamic ):Int
	{
		var lastFrameOrNull:Null<Int> = getParamLastFrame( param );
		if ( lastFrameOrNull != null )
		{
			var lastFrame:Int = lastFrameOrNull;
			return lastFrame;
		}
		else
		{
			return NO_FRAME;
		}
	}

	/**
	 * @return parameter id if present, otherwise null.
	 * @note NO_ID (-1) means "don't care" or "all IDs".
	 */
	public static inline function getParamId( param:Dynamic ):Null<Int>
	{
		return getParamFieldAsInt( param, "id" );
	}

	/**
	 * @return parameter id if present, otherwise NO_ID.
	 * @note NO_ID (-1) means "don't care" or "all IDs".
	 */
	public static inline function getParamIdOrDefault( param:Dynamic ):Int
	{
		var idOrNull:Null<Int> = getParamId( param );
		if ( idOrNull != null )
		{
			var id:Int = idOrNull;
			return id;
		}
		else
		{
			return NO_ID;
		}
	}

	/**
	 * @return box (aka Rectangle) for box type params, otherwise null.
	 */
	public static function getParamBox( param:Dynamic ):Rectangle
	{
		var w:Null<Int> = getParamFieldAsInt( param, "width" );
		if ( w == null ) return null;
		var h:Null<Int> = getParamFieldAsInt( param, "height" );
		if ( h == null ) return null;
		var x:Null<Int> = getParamFieldAsInt( param, "x" );
		if ( x == null ) return null;
		var y:Null<Int> = getParamFieldAsInt( param, "y" );
		if ( y == null ) return null;
		return new Rectangle( x, y, w, h );
	}
	
	/**
	 * @return vector (aka Point) for vector and box type params, otherwise null.
	 * @note this works for boxes too; we could check "type" to avoid this.
	 */
	public static function getParamVector( param:Dynamic ):Point
	{
		var x:Null<Int> = getParamFieldAsInt( param, "x" );
		if ( x == null ) return null;
		var y:Null<Int> = getParamFieldAsInt( param, "y" );
		if ( y == null ) return null;
		return new Point( x, y );
	}
	
	/**
	 * @return parameter value for bool type params, otherwise null.
	 */
	public static function getParamValueBool( param:Dynamic ):Null<Bool>
	{
		return getParamFieldAsBool( param, "value" );
	}

	/**
	 * @return parameter value for int type params, otherwise null.
	 */
	public static function getParamValueInt( param:Dynamic ):Null<Int>
	{
		return getParamFieldAsInt( param, "value" );
	}

	/**
	 * @return parameter value for string type and event type params, otherwise null.
	 */
	public static function getParamValueString( param:Dynamic ):String
	{
		return getParamFieldAsString( param, "value" );
	}

	/**
	 * Add a subtree of params under "name", replacing any existing.
	 * For use only by BehaviorDataWithParams for now.
	 */
	public function replaceSubtree( name:String, subtree:Dynamic ):Void
	{
		Reflect.setField( nameFrameMap, name, subtree );
	}
}

class ParamsIter // implements Iterator
{
	private var behaviorFlags:Int; // TODO: remove if not used after "new"
	private var frameMap:Dynamic;

	private var frameInt:Int;
	private var nextFrameToCheck:Int;
	
	private var paramList:Dynamic;
	private var paramIdx:Int;
	
	private var curr:Dynamic;
	
	public function new( frameMap:Dynamic, frame:Int, behaviorFlags:Int = 0 )
	{
		this.behaviorFlags = behaviorFlags;
		this.frameMap = frameMap;

		this.frameInt = frame;
		this.nextFrameToCheck = shouldLookForOverlap() ? 0 : frame; // will start at NO_FRAME for NO_FRAME
		this.paramList = null;
		this.paramIdx = 0;
		
		this.curr = null;
		findNext();
		
		var useFrameFallback:Bool = ( behaviorFlags & Params.FRAME_FALLBACK ) != 0;
		if ( ( curr == null ) && ( frame != Params.NO_FRAME ) && useFrameFallback )
		{
			// No values found for exact frame.
			// Start over, searching for NO_FRAME only.
			this.frameInt = Params.NO_FRAME;
			this.nextFrameToCheck = Params.NO_FRAME;
			this.paramList = null;
			this.paramIdx = 0;
			
			//this.curr = null;
			findNext();
		}
	}
	
	private inline function shouldLookForOverlap():Bool
	{
		return ( frameInt != Params.NO_FRAME ) && ( ( behaviorFlags & Params.FRAME_OVERLAP ) != 0 );
	}

	private inline function hasNextInThisFrame():Bool
	{
		return paramList != null && paramIdx < paramList.length;
	}
	
	private function findNext():Void
	{
		var lookForOverlap:Bool = shouldLookForOverlap();
		
		while ( hasNextInThisFrame() || ( nextFrameToCheck <= frameInt ) ) // params remaining?
		{
			// Not set up yet, or ran out of id entries for this frame?
			// Set up params to search for this frame.
			if ( ! hasNextInThisFrame() )
			{
				// Set up to iterate over next frame.
				paramIdx = 0;
				paramList = null;
				if ( frameMap != null )
				{
					paramList = Reflect.field( frameMap, Std.string( nextFrameToCheck ) );
				}
				++nextFrameToCheck;
			}

			// Okay, check all params for this frame, if we found any.
			var currentFrameInt:Int = nextFrameToCheck - 1;
				
			if ( ! lookForOverlap )
			{
				// Can ignore lastFrame entirely and just emit any found.
				if ( hasNextInThisFrame() )
				{
					curr = paramList[paramIdx++];
					return; // <--- EARLY EXIT --------------------------
				}
			}
			else
			{
				// Should never enter this block looking for NO_FRAME;
				// "overlapping" only makes sense if we have a specific target frame.
				//assert( frameInt != NO_FRAME );
				
				// Looking for overlap, must check lastFrame.
				while ( hasNextInThisFrame() )
				{
					var param:Dynamic = paramList[paramIdx++];
					//assert( param != null );
					
					// This should pass whether or not we're looking for overlap,
					// as long as lastFrame == NO_FRAME or lastFrame >= frame for all registered params.
					var lastFrameInt:Int = Params.getParamLastFrameOrDefault( param );
					if ( frameInt <= lastFrameInt )
					{
						// Match (within range [currentFrameInt,lastFrameInt] inclusive).
						curr = param;
						return; // <--- EARLY EXIT --------------------------
					}
					else if ( lastFrameInt == Params.NO_FRAME )
					{
						// This param doesn't have a range; it covers only one frame.
						// Is it for the target frame?
						if ( frameInt == currentFrameInt )
						{
							curr = param;
							return; // <--- EARLY EXIT --------------------------
						}
					}
					
				} // end while ( hasNextInThisFrame() )
				
			} // end lookForOverlap blocks
			
		} // end while "params remaining?"
		
		// No more nexts in current frame, no more next frame.
		curr = null;
	}

	public function hasNext():Bool
	{
		return curr != null;
	}
	
	public function next():Dynamic
	{
		var toReturn = curr;
		findNext();
		return toReturn;
	}
	
}