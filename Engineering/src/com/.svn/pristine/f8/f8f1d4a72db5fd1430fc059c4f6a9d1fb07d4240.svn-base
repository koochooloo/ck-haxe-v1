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

package com.firstplayable.hxlib.utils.json;

using Reflect;

/**
 * Helper function(s) for working with JSON files (specifically those created in Paist that are used to create eg GenericMenus) 
 */
class JsonUtils
{
    /**
     * Given an object representing some JSON data and a key, attempts to find a value for a field whose name is given by key. 
     * @param    key    -    name of the field you're looking for
     * @param    d    -    the json object containing that data
     * @return    the first value found with key matching argument key
     * 
     * @example if key = font and d represents the following JSON data:
         * { 
            "name" : "left",
            "text" : "LEFT",
            "inheritable" : { 
                "position" : [ 104, 16 ],
                "loadParams" : false,
                "font" : "/fonts/LiberationSans-Regular_16.fnt",
                "autoSize" : true
            }
            
        then "/fonts/LiberationSans-Regular_16.fnt" will be returned
     * 
     */
	// TODO: I don't think we need this function in JsonMenuPlugin or any other Json classes because
	//       we can just get the variable we need from the Dynamic (d). d.inheritable.position or d.name. -jm
    public static function getValueRecursively( key:String, d:Dynamic ):Dynamic
    {
        // d MUST be an annonymous object ( will break when targeting html5 if it's e.g. an Array )
        if ( !( d.isObject() && Type.getClass( d ) == null ) )
        {
            // EARLY RETURN
            return null;
        }
        
        var val:Dynamic = null;
        
        for ( n in d.fields() )
        {
            if ( n == key )
            {
                return d.field( n );
            }
            
            // Check child objects
            val = getValueRecursively( key, d.field( n ) );
            if ( val != null )
            {
                return val;
            }
        }
        
        return val;
    }
    
    
}