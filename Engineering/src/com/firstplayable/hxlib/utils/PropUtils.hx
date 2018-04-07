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
import com.firstplayable.hxlib.Debug;
import haxe.ds.StringMap;
using Reflect;

class PropUtils
{
    /**
     * Iterates all properties of a source object and copies them into a destination object.
     * @param    sourceObj    The object whose properties to copy.
     * @param    destObj      The object whose properties to set. Note the original object is modified.
     * @param    verify       Denotes whether to verify the property on the destination object exists before setting it.
     * @return                The modified destination object.
     */
    public static function copyProperties( sourceObj:Dynamic, destObj:Dynamic, verify:Bool = true ):Void
    {
        var typeStr:String = Type.typeof( destObj ).getName();
        
        if ( verify )
        {
            for ( prop in sourceObj.fields() )
            {
                if ( destObj.hasField( prop ) )
                {
                    destObj.setField( prop, sourceObj.field( prop ) );
                    Debug.log( typeStr + "." + prop + " = " + Reflect.field( sourceObj, prop ) );
                }
                else
                {
                    Debug.log( typeStr + " does not contain property \'" + prop + "\'");
                }
            }
        }
        else
        {
            for ( prop in sourceObj.fields() )
            {
                destObj.setField( prop, sourceObj.field( prop ) );
                Debug.log( typeStr + "." + prop + " = " + Reflect.field( sourceObj, prop ) );
            }
        }
    }
    
    /**
     * Gets a list of properties and their values of an object in the form of a StringMap.
     * @param    obj
     * @return
     */
    public static function getProperties( obj:Dynamic ):StringMap<Dynamic>
    {
        var map:StringMap<Dynamic> = new StringMap();
        
        for ( prop in obj.fields() )
        {
            map.set( prop, obj.field( prop ) );
        }
        
        return map;
    }
}