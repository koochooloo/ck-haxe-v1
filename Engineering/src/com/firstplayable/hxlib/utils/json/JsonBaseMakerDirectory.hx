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

import com.firstplayable.hxlib.Debug.*;
import openfl.display.DisplayObject;
import haxe.ds.StringMap.StringMap;

/**
 * A directory of functions used to construct objects from JSON data. 
 * Extend this class; do not use directly. 
 */
class JsonBaseMakerDirectory
{
    private var m_makerDirectory:StringMap<Dynamic -> DisplayObject>;

    public function new() 
    {
        m_makerDirectory = new StringMap<Dynamic -> DisplayObject>();
    }
    
    /**
     * Registers a function (typically one in a class that extends this) that is used to make a specific type of object
     * @param    makerName    - The name of the object type to create with this function
     * @param    makerFunc    - The function that will construct display objects
     * @return    true, if the function was successfully registered; false otherwise
     * 
     * @example JsonMenuMakerDirectory, which extends this, uses the makeSprite function to make 
     *             objects that are called "spriteObject" in the JSON data. It registers this function
     *             using registerMakerFunc( "spriteObject", makeSprite );
     */
    public function registerMakerFunc( makerName:String, makerFunc:Dynamic -> DisplayObject ):Bool
    {
        if ( makerFunc == null )
        {
            warn( "Trying to register a NULL makerFunc!!" );
            return false;
        }

        if ( makerName == null || makerName == "" )
        {
            warn( "Trying to register a makerFunc to an Empty Name" );
            return false;
        }

        if ( m_makerDirectory.get( makerName ) == null )
        {
            m_makerDirectory.set( makerName, makerFunc );
            return true;
        }

        warn( makerName + " already has a function registered!!" );

        return false;
    }

    /**
     * Gets a function used to make objects
     * @param    makerName    - the type of object to make (whatever was used for makerName when registering the maker function)
     * @return    a function that takes a Dynamic and returns a DisplayObject, that will be used for creating the object
     */
    public function getMakerFunc( makerName:String ):Dynamic
    {
        return m_makerDirectory.get( makerName );
    }
}