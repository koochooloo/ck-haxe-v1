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
package com.firstplayable.hxlib.net;
import com.firstplayable.hxlib.Debug;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

class SharedSave
{
    private static inline var dir:String = "/";
    
    /**
     * Writes a game save object to the system browser cache.
     * @param    save    Game save object to write.
     */
    public static function post( save:Dynamic, cacheFilename:String ):Void
    {
        var so:SharedObject = SharedObject.getLocal( cacheFilename, dir );
        //TODO: ByteArray support
        
        so.data.profile = save;
        
        if ( so.flush() != SharedObjectFlushStatus.FLUSHED )
        {
            //error occured
            Debug.warn( "Error writing to browser cache. Could not save " + cacheFilename );
        }
        
        #if !js
        {
            so.close();
        }
        #end
    }
    
    /**
     * Attempts to grab a GameSave object from the system browser cache. If it fails, returns null.
     * @param    cacheFilename     profileName property of the sought game save object.
     * @return        the game save, if found. Otherwise returns null.
     */
    public static function get( cacheFilename:String ):Dynamic
    {
        var so:SharedObject = SharedObject.getLocal( cacheFilename, dir );
        //TODO: ByteArray support
        
        #if !js
        {
            so.close();
        }
        #end
        
        //check if lookup was successful
        if ( !Reflect.hasField( so.data, "profile" ) )
        {
            return null;
        }
        
        return so.data.profile;
    }
}