//
// Copyright (C) 2017, 1st Playable Productions, LLC. All rights reserved.
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

package game.utils;
import haxe.ds.Option;

using StringTools;

#if js
import js.Browser;
#end

class URLUtils
{
	public static function didProvideView(view:String):Bool
	{
		#if js
		if (Browser.window.location.search == null)
		{
			return false;
		}

		var queryStr:String = Browser.window.location.search.substr(1);
		
		var viewRegex:EReg = ~/view=(.+)/;
		
		for (pair in queryStr.split("&"))
		{
			if (viewRegex.match(pair))
			{
				var viewInUrl:String = viewRegex.matched(1);
				return (view == viewInUrl);
			}
		}
		
		return false;
		#else
		return false;
		#end
	}
	
	public static function didProvideURL(domain:String):Bool
	{
		#if js
		if (Browser.window.location.search == null)
		{
			return false;
		}

		if ( Browser.window.location.hostname == domain )
		{
			return true;
		}
		return false;
		#else
		return false;
		#end
	}
	
	public static function didProvideAssessment():Bool
	{
		return didProvideView("assess");
	}
	
	public static function didProvideAdmin():Bool
	{
		#if js
		if (Browser.window.location.hostname != "demos.1stplayable.com")
		{
			return false;
		}
		#end
		
		return didProvideView("admin");
	}
	
	public static function didProvideTeacherId():Bool
	{
		#if js
		if (Browser.window.location.search == null)
		{
			return false;
		}

		var queryStr:String = Browser.window.location.search.substr(1);
		
		var teacherIdRegex:EReg = ~/teacherid=.+/;
		
		for (pair in queryStr.split("&"))
		{
			if (teacherIdRegex.match(pair))
			{
				return true;
			}
		}
		#end
		
		return false;
	}
	
	public static function getTeacherId():Option<String>
	{
		#if js
		if (Browser.window.location.search == null)
		{
			return None;
		}

		var queryStr:String = Browser.window.location.search.substr(1);
		
		var teacherIdRegex:EReg = ~/teacherid=(.+)/;
		
		for (pair in queryStr.split("&"))
		{
			if (teacherIdRegex.match(pair))
			{
				var id:String = teacherIdRegex.matched(1);
				return Some(id);
			}
		}
		#end
		
		return None;
	}
}