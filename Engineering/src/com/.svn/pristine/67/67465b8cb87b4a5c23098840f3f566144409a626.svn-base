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
package com.firstplayable.hxlib.app;

import com.firstplayable.hxlib.Debug.*;

typedef Milliseconds = Float;

abstract Seconds( Milliseconds ) from Milliseconds to Milliseconds
{ 
    public function new( seconds: Float ) { this = seconds * 1000; }
}

abstract Minutes( Milliseconds ) from Milliseconds to Milliseconds
{ 
    public function new( minutes: Float ) { this = minutes * 60000; }
}

class MonotonicTime
{
    public static function get(): Milliseconds
    {
        // Gets the best approximation to a monononic timestamp that we can manage.
        // The absolute value of this time value is not necessarily meaningful, but
        // it should (hopefully!) be an accurate relative value of time since the last call to this
        // function, in Milliseconds.
        
        // TODO: Unfortunately, this is hard to do on a completely cross-platform basis;
        // results may vary, and this needs significant work.
        // See haxe.Timer.stamp() for haxe's best attempt to deal with this.
        
        // This may be better than haxe.Timer.stamp() for JavaScript targets:
        #if js
            // Browser.window.performance.timing can return null if disabled by the browser itself;
            //   see http://www.w3.org/TR/navigation-timing/#sec-window.performance-attribute
            if ( js.Browser.window.performance != null )
            {
                // This time must be monotonic, in conformant implementations.
                return js.Browser.window.performance.now();
            }
            else
            {
                return Date.now().getTime();
            }

        #else
			return Date.now().getTime();
        #end
    }
}
