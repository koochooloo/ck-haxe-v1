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
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

/**
 * Tests whether the application has network access.
 */
class ConnectionTest extends URLLoader
{
    /**
     * Creates a new ConnectionTest object.
     */
    public function new() 
    {
        super( null );
    }
    
    //variables for pass and fail functions received by test()
    private dynamic function passed():Void {}
    private dynamic function failed():Void {}
    
    /**
     * Checks during runtime if the device is connected to the internet.
     * @return    True if device is connected to the internet, false if it is not.
     */
    public static inline function checkConnection():Bool
    {
        #if js
        {
            return js.Browser.navigator.onLine;
        }
        #else
        {
            Debug.warn( "Static checkConnection() is only supported in javascript. Please use non-static testConnection() instead." );
            return false;
        }
        #end
    }
    
    #if flash
    /**
     * Tests whether this application has network access.
     * @param    onPass        Called if connection is successful.
     * @param    onFail        Called if connection is unsuccessful.
     */
    public function testConnection( onPass:Void->Void, onFail:Void->Void ):Void
    {
        var r:URLRequest = new URLRequest( "https://www.google.com/images/srpr/logo11w.png" ); //Google's banner
        Debug.log( "Testing connection to \'" + r.url + "\'..." );
        
        passed = onPass;
        failed = onFail;
        
        addEventListener( Event.COMPLETE, passedConnection );
        addEventListener( IOErrorEvent.IO_ERROR, failedConnection );
        
        load( r );
    }
    #end
    
    /**
     * Triggers when the connection test was unsuccessful.
     * @param    e
     */
    private function failedConnection( e:IOErrorEvent ):Void
    {
        Debug.warn( e.type + ": Failed to connect to host! Please check your connection and try again. " + e.text );
        
        close();
        failed();
    }
    
    /**
     * Triggers when the connection test was successful.
     * @param    e
     */
    private function passedConnection( e:Event ):Void
    {
        Debug.log( "Connection to host successful!" );
        
        close();
        passed();
    }
    
    /**
     * Closes network connection and removes active listeners.
     */
    override public function close():Void
    {
        removeEventListener( Event.COMPLETE, passedConnection );
        removeEventListener( IOErrorEvent.IO_ERROR, failedConnection );
        
        super.close();
    }
}