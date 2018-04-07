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
import openfl.errors.Error;
/**
 * ...
 * @author ...
 */
class AssertUtil
{
    public static function Assert(expression:Bool, ?text:String): Void
	{
    #if debug
    {
        if ( !expression )
        {
            if ( text == null || text == "")
            {
                Debug.log ( "assertion failed " );
                throw new Error("Assertion failed!");
            }
            else
            {
                Debug.log ( text );
                throw new Error(text);
            }
        }
    }
    #end
	}
	
}