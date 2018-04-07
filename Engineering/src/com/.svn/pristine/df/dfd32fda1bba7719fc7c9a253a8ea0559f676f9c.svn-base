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
package com.firstplayable.hxlib.utils;
import openfl.geom.Point;

import com.firstplayable.hxlib.Debug;

class MathUtils
{
    /**
     * A multiplier used to convert degrees to radians. Equal to Math.PI / 180
     */
    public static inline var RADIANS_MULTIPLIER:Float = 0.0174532925;
    
    /**
     * A multiplier used to convert radians to degrees. Equal to 180 / Math.PI
     */
    public static inline var DEGREES_MULTIPLIER:Float = 57.2957795;
    
	/**
	 * Generates a random integer within range (min,max].
	 * @param	min
	 * @param	max
	 * @return
	 */
	public static inline function randomRange( min:Int, max:Int ):Int
	{
		return Std.random( max - min ) + min;
	}
	
    /**
     * Calculates the dot product of two vectors.
     * @param    vectorOne    The first vector.
     * @param    vectorTwo    The second vector.
     * @return    The dot product.
     */
    public static function dotProduct( vectorOne:Point, vectorTwo:Point ):Float
    {
        return ( vectorOne.x * vectorTwo.x ) + ( vectorOne.y * vectorTwo.y );
    }

    /**
     * equalFloat - tests equality of floating point values using a given epsilon.
     * @param    a First float.
     * @param    b Second float.
     * @param    fEpsilon (optional)
     * @return  returns whether the two values are within the specified epsilon of each other
     */
    public static inline function equalFloat( a:Float, b:Float, fEpsilon:Float = 0.0001 ):Bool
    {
        var d:Float = a - b;
        return ( d < fEpsilon ) && ( d > -fEpsilon );
    }
    
    /**
     * DEPRECATED
     *
     * This is a wrapper around equalFloat.
     * The convention should be to name functions with a descriptive name
     * followed by a type, so please use equalFloat in the future.
     */
    public static inline function floatEqual(a:Float, b:Float, ?fEpsilon:Float = 0.0001):Bool
    {
        return equalFloat( a, b, fEpsilon );
    }
    
    /**
     * Implements the sign (aka signum) function for float values.
     * @param  value input float
     * @return  returns -1.0 for negatives, -0.0 for negative zero, 0.0 for positive zero, 1.0 for positives, and NaN for NaNs.
     */
    public static inline function signFloat( value:Float ):Float
    {
        if ( value > 0.0 )
        {
            // This case also catches positive infinity.
            return 1.0;
        }
        else if ( value < 0.0 )
        {
            // This case also catches negative infinity.
            return -1.0;
        }
        else
        {
            // Passes through all remaining values: positive zero, negative zero, and NaNs.
            //assert( value == 0.0 || Math.isNaN( value ) );
            return value;
        }
    }

    /**
    * Lerp(Linear Interpolation) gets the position based on a scalar of a S curve based on 2 vectors
    * @param    u First vector.
    * @param    v Second vector.
    * @param    t Scalar used determine what point in the S curve is returned.
    * @return  returns the position on the S curve based on the scalar.
    */
    public static function lerp( p1:Point, p2:Point, t:Float ):Point
    {
        return Point.interpolate(p2,p1,t);
    }
    
    /**
     * Projects a vector onto a vector
     * @param    u Vector to project.
     * @param    v Vector to project on to.
     * @return  Projected vector.
     */
    public static function project( u:Point, v:Point ):Point
    {
        var vLen:Float = Math.sqrt( v.x * v.x + v.y * v.y );
        if (equalFloat(vLen, 0.0))
        {
            return new Point(0,0);
        }
        var vn_x:Float = v.x /= vLen;
        var vn_y:Float = v.y /= vLen;
        var vn:Point = new Point(vn_x, vn_y);

        var dotProd:Float = dotProduct( u, vn );
        vn.x *= dotProd;
        vn.y *= dotProd;
        return vn;
    }
    
    /**
     * Reflects a vector across another vector.
     * @param    u Vector to reflect.
     * @param    v Vector to reflect across.
     * @return  Reflected vector.
     */
    public static function reflect( toReflect:Point, toReflectAcross:Point ):Point
    {
        var projectedVector:Point = project( toReflect, toReflectAcross );
        
        var dp:Point = projectedVector.subtract(toReflect);
        projectedVector.offset(dp.x,dp.y);
        return projectedVector;
    }
    
    /**
     * Converts truncates decimal places after specified digits.
     * @param    f
     * @return
     */
    public static function truncateTo( f:Float, dig:Int ):Float
    {
        var power:Float = Math.pow( 10, dig );
        return Std.int( f * power ) / power;
    }
    
    /**
     * Checks if a number is even.
     * @param    i    The number to check.
     * @return    true if value is even.
     */
    public static inline function isEven( i:Int ):Bool
    {
        return ( i & 1 ) == 0;
    }
    
    /**
     * Checks if a number is odd.
     * @param    i    The number to check.
     * @return    true if value is odd.
     */
    public static inline function isOdd( i:Int ):Bool
    {
        return !isEven( i );
    }
    
    /**
     * Checks if number is a power of two.
     * @param    i    The number to check.
     * @return    true if value greater than zero and a power of 2 (only one bit set).
     */
    public static inline function isPow2( i:Int ):Bool
    {
        return ( i > 0 ) && ( ( i & ( i - 1 ) ) == 0 );
    }
    
    /**
     * Gets the absolute value of a number using bitwise operation. About 40x faster than openfl.Math.abs().
     * @param    i    The number to absolute.
     * @return    The absolute value.
     */
    public static inline function absInt( i:Int ):Int
    {
        return (i > 0) ? i : -i;
    }
    
    /**
     * Gets the absolute value of a number using bitwise operation. About 40x faster than openfl.Math.abs().
     * @param    num    The number to absolute.
     * @return    The absolute value.
     */
    public static function absNum( num:Float ):Float
    {
        return ( num < 0 ? -num : num );
    }

    public static function max( a:Int, b:Int ):Int
	{
		return (a < b) ? b : a;
	}

    public static function min( a:Int, b:Int ):Int
	{
		return (b < a) ? b : a;
	}
    
    /**
     * Finds the result of using modulus on a number; only works if "mod" parameter is a power of 2.
     * @param    i    The number.
     * @param    mod    The modulus (must be a positive power of 2).
     * @return    The remainder.
     */
    public static function modPow2( i:Int, mod:Int ):Int
    {
        return i & ( mod - 1 );
    }
        
    /**
     * Calculates the squared distance of two points.
     * @param    p1x    The first point-x.
     * @param    p1y    The first point-y;
     * @param    p2x    The second point-x;
     * @param    p2y    The second point-y;
     * @return    The distance squared.
     */
    public static function distanceSqInt( p1x:Int, p1y:Int, p2x:Int, p2y:Int ):Int
    {
        var a:Int = p2x - p1x;
        var b:Int = p2y - p1y;
        return ( a * a + b * b );
    }
	
	/**
     * Calculates the squared distance of two points.
     * @param    p1x    The first point-x.
     * @param    p1y    The first point-y;
     * @param    p2x    The second point-x;
     * @param    p2y    The second point-y;
     * @return    The distance squared.
     */
    public static function distanceSq( p1x:Float, p1y:Float, p2x:Float, p2y:Float ):Float
    {
        var a:Float = p2x - p1x;
        var b:Float = p2y - p1y;
        return ( a * a + b * b );
    }
    
    /**
     * Converts an angle from degrees to radians.
     * @param    angle    The angle to convert.
     * @return    The angle in radians.
     */
    public static function degreesToRadians( angle:Float ):Float
    {
        return angle * RADIANS_MULTIPLIER;
    }
    
    /**
     * Converts an angle from radians to degrees.
     * @param    angle    The angle to convert.
     * @return    The angle in degrees.
     */
    public static function radiansToDegrees( angle:Float ):Float
    {
        return angle * DEGREES_MULTIPLIER;
    }
    
    /**
     * Converts frames-per-second to milliseconds-per-frame.
     * @param    fps
     * @return
     */
    public static function fpsToMs( fps:Float ):Float
    {
        return ( 1000 / fps );
    }
    
    /**
     * Finds a point along a line based from its distance.
     * @param p1    start point for the line.
     * @param p2    end point for the line.
     * @param dist  distance along the line.
     * @param ?mod  a point to modify (for efficiency). If null, this function will make a new Point to return.
     * @return  the coordinates of the sought point along the line.
     */
    public static function getLinearPoint( p1:Point, p2:Point, dist:Float, ?mod:Point ):Point
    {
        var x3:Float = p2.x - p1.x;
        var y3:Float = p2.y - p1.y;
        
        //normalize and scale
        var len:Float = Math.sqrt( x3 * x3 + y3 * y3 );
        x3 /= len;
        y3 /= len;
        x3 *= dist;
        y3 *= dist;
        
        var result:Point = ( mod == null ) ? new Point() : mod;
        result.x = p1.x + x3;
        result.y = p1.y + y3;
        
        return result;
    }
    
    /**
     * Calculates an angle for source point that is needed to orient it towards dest point.
     * @param source    the point to find the angle of to orient toward dest.
     * @param dest      the point that source needs to orient itself toward.
     * @return  the angle, in degrees, to make point source orient towards point dest.
     */
    public static function pointAt( source:Point, dest:Point ):Float
    {
        var dX:Float = dest.x - source.x;
        var dY:Float = dest.y - source.y;
        return Math.atan2( dY, dX ) * DEGREES_MULTIPLIER;
    }
    
    
    /**
     * Check if a number is in the provided range.
     * @param	val	the value to check.
     * @param	min	(inclusive) the low value of the range.
     * @param	max	(inclusive) the high value of the range.
     */
    public static function inRange( val:Float, min:Float, max:Float )
    {
        return ( val >= min && val <= max );
    }
    
    /**
     * Restric numerical value to be within a certain range.
     * @param	val	the value to be clamped.
     * @param	min	(inclusive) the minimum output value.
     * @param	max	(inclusive) the maximum output value.
     */
    public static function clamp( val:Float, min:Float, max:Float )
    {
		// Warn if val is non-numerical (most likely null or NaN).
		// Note: null case will only apply on dynamic targets.
        Debug.warn_if( !Std.is( val, Float ) || Math.isNaN( val ), 'Attempting to clamp a non-numerical value $val. Will result in non-numerical output.' );
		
		// Warn if the provided range is invalid.
        Debug.warn_if( max < min, 'Attempting to clamp to range [$min, $max] with high value less than low value.' );
        
		// Separation and order of if statements is intentional.
		// They allow us to reclamp to min if range is invalid s.t. max < min.
		// This assumes min is the value more likely to be valid.
		
		// Handles val > max
        if ( val > max )
        {
            val = max;
        }
        
		// Handles val < min and max < min
        if ( val < min )
        {
            val = min;
        }
        
		// Will return NaN if original value is NaN
		// because these comparisions with NaN are always false.
		// The same behaviour applies to null.
        return val;
    }
    
    /**
     * Restrict Integral value to be within a certain inclusive range.
     * @param	val	the value to be clamped.
     * @param	min	(inclusive) the minimum output value.
     * @param	max	(inclusive) the maximum output value.
     */
    public static function clampInt( val:Int, min:Int, max:Int )
    {
		// Warn if val is non-integral (most likely null or a float).
		// Note: This should only apply on dynamic targets.
		Debug.warn_if( !Std.is( val, Int ), 'Attempting to clamp non-integral value $val to integer range.' );
		
		// Warn if the provided range is invalid.
        Debug.warn_if( max < min, 'Attempting to clamp to range [$min, $max] with high value less than low value.' );
        
		// See MathUtils.clamp for documentation on this logic.
        if ( val > max )
        {
            val = max;
        }
        
        if ( val < min )
        {
            val = min;
        }
        
        return val;
    }
}