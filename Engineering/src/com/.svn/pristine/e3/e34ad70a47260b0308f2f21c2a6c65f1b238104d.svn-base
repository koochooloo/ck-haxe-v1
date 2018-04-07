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
import js.Browser;
import openfl.Lib;
import openfl.net.URLRequest;

class DebugUtils
{
#if js
	public static function mailto( to:String, subject:String, ?contents:String = null ):Void
	{
		if ( contents == null )
		{
			contents = Debug.stream();
			
			// Strip some unnecessary package info
			var regex = ~/->game[.][a-z]+[.][a-z]+[.]/ig;
			contents = regex.replace( contents, "");
		}

		// Browsers typically have a character limit; only include the most recent parts of the log
		contents = contents.substr( -1500 );

		// Add the version info
		contents = Version.versionInfo + "\n\n" + contents;

		
		var body:String = StringTools.urlEncode( contents );
		var href:String = "mailto:" + to + "?subject=" + subject + "&body=" + body;
		Lib.getURL( new URLRequest( href ) );
	}
#end
}
