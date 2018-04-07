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
package com.firstplayable.hxlib;
import com.firstplayable.hxlib.Debug.warn;
using Std;

/**
 * Really basic level standard functions. This is an extension of haxe Std.hx.
 */
class StdX extends Std
{
    /**
     * Max integer value.
     */
    public static inline var INT_MAX: Int = 0x7FFFFFFF;
    
    /**
     * If cast successful, returns type. Else, returns null. Similar to AS3 as keyword.
     * @param    obj     The object to be casted (may be null, in which case this will return null).
     * @param    type    The desired type of obj.
     * @return        If obj is type, returns obj as type; else returns null.
     */
    public static inline function as<T>( obj:Dynamic, type:Class<T> ):T
    {
        return Std.is( obj, type ) ? cast obj : null;
    }
    
    /**
     * Hard casts an object to a type. If it fails, the application will crash.
     * @param    obj     The object to be casted.
     * @param    type    The desired type of obj.
     * @return        Casted object.
     */
    public static inline function to<T>( obj:Dynamic, type:Class<T> ):T
    {
        return cast obj;
    }
    
    /**
     * True if the object is null.
     * @param    obj
     * @return
     */
    public static inline function isNull( obj:Dynamic ):Bool
    {
        return obj == null;
    }
    
    /**
     * True if the object is NOT null.
     * @param    obj
     * @return
     */
    public static inline function isValid( obj:Dynamic ):Bool
    {
        return obj != null;
    }
    
    /**
     * Converts a String into a Boolean
     * @param    value    The String to convert
     * @param    ?trueSet:Array<String>    (optional) array of string values which validly map to boolean true
     *                                     If null the trueSet is [ "true", "yes" ]
     * @param    ?falseSet:Array<String>   (optional) array of string values which validly map to boolean false
     *                                     If null the trueSet is [ "false", "no" ]
     * @param    errorReturn:Bool          (default: false) The default value to return in the event of an error
     * @return   true if specified value maps to true set, false if the value maps to the false set, otherwise errorReturn
     */
    public static function parseBool( value:String, ?trueSet:Array<String>, ?falseSet:Array<String>, errorReturn:Bool=false ):Bool
    {
        if ( value.length <= 0 )
        {
            //--The string was empty so no need to go further
            warn( "Parsed bool( \"\" ) is an unexpected/invalid value. Returning " + errorReturn.string() + "." );
            return errorReturn;
        }
        
        //    TODO:  Look at using lambda clause for array searches (ex lambda.exists)
        if ( isValid( trueSet ) )
        {
            for ( knownTrue in trueSet )
            {
                if ( knownTrue != value )
                {
                    //  Skip this iteration if there's
                    //    no match
                    continue;
                }
                
                return true;
            }
        }
        
        if ( isValid( falseSet ) )
        {
            for ( knownFalse in falseSet )
            {
                if ( knownFalse != value )
                {
                    //  Skip this iteration if there's
                    //    no match
                    continue;
                }
                
                return false;
            }
        }
        
        var normalizedString = value.toLowerCase();
        if ( !isValid( trueSet ) && normalizedString == "true" || normalizedString == "yes" )
        {
            return true;
        }
        else if ( !isValid( falseSet ) && normalizedString == "false" || normalizedString == "no" )
        {
            return false;
        }
        
        warn( "Parsed bool( '" + value + "' ) is an unexpected/invalid value. Returning " + errorReturn.string() + "." );
        return errorReturn;
    }
    
    /**
     * Converts a bool value to int.
     * @param    bool
     * @return
     */
    public static function int( bool:Bool ):Int
    {
        return ( bool ) ? 1 : 0;
    }
    
    /**
     * Converts a bool value to int.
     * @param    bool
     * @return
     */
    public static function bool( int:Int ):Bool
    {
        return ( int > 0 ) ? true : false;
    }
	
	/**
	 * Wrapper for Std.parseFloat that ensures non-NaN return value.
	 * This allows you to safely use the return value in-line. 
	 * @return the casted float, or 0.0 if the value cannot be casted
	 */
	public static function parseFloat( input:String, ?warnOnNaN:Bool = true ):Float
	{
		var fl:Float = Std.parseFloat( input );
		var isValid:Bool = !Math.isNaN( fl );
		if ( !isValid && warnOnNaN )
		{
			warn( "Value could not be casted to float: '" + input + "'." );
		}
		
		return isValid ? fl : 0.0;
	}
}