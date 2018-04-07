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

import com.firstplayable.hxlib.Debug.*;
import haxe.macro.Compiler;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

/**
	A singleton class for tracking build version info, based 
	on dslib/core/util/Version. Reads info from assets/Version.txt 
	which is created by the autobuild script.
	
	In order to work, this class requires an assets/version.txt file
	in the project that contains the following lines:
		Revision: x
		Build: y
		Machine: z
	
	See the leroy projects autobuild.bat for an example of how to create this.
	
	That file is imported by putting the following line in the project.xml:
	<haxeflag name="-resource" value="assets/version.txt@version" />
	
	The buildVersion and buildName fields are set directly in 
	the project.xml file with lines like:
	<haxedef name="buildVersion" value="1.2.6" />
	<haxedef name="buildName" value=" " />
 */
class Version extends TextField
{
	public static var versionInfo( get, null ):String = "";
	public static function get_versionInfo():String
	{
		if ( versionInfo == "" )
		{
			new Version();
		}
		return versionInfo;
	}
	
	//TODO: convert properties to proper types? ie, Int
	// Returns the svn version of the build (ie 845:896M)
	public var svnRev(default, null):String = "0";

	// For autobuilds, returns the Jenkins build number (ie 127). For local builds, it's 0.
	public var buildNum(default, null):String = "0";

	// Returns the timestamp of when the build was created.
	public var buildTime(default, null):String = "0";

	// Returns the name of the build machine
	public var machine(default, null):String = "?";

	// Returns the build type (ie Debug, Release, etc)
	public var buildType(default,null):String = "release";

	// Returns the buildVersion set in the project.xml (ie 1.2.1)
	public var buildVersion(default, null):String = "";

	// Returns the buildName set in the project.xml
	public var buildName(default,null):String = "";

	// denotes if a local build (true) or a jenkins build (false)
	public var isLocal(default,null):Bool;
	
	/**
	 * Constructs a new Version object, which is a text field to be added to the stage.
	 * @param	x		pos
	 * @param	y		pos
	 * @param	color	text color
	 */
	public function new( x:Float = 10, y:Float = 10, color:Int = 0x000000 ) 
	{
		super();
		
		this.x = x;
		this.y = y;
		textColor = color;
		autoSize = TextFieldAutoSize.LEFT;
		selectable = false;
		
		var raw:String = haxe.Resource.getString("version");
		
		if (raw == null)
		{
			raw = "";
		}
		
		//parse build info
		var lines:Array<String> = raw.split("\n");
		
		for (a in raw.split("\n") )
		{
			a = StringTools.trim( a );
			var i:Int = a.indexOf(":");
			var name:String = a.substring(0, i);
			var value:String = a.substring(i + 1);
			value = StringTools.trim( value );
			
			switch (name)
			{
				case "Revision":
					svnRev = value;
				case "Build":
					buildNum = value;
				case "Machine":
					machine = value;
			}
		}
		
		buildTime = MacroUtils.getBuildDate();
		
		buildVersion = Compiler.getDefine( "buildVersion" );
		if ( buildVersion == null )
		{
			buildVersion = "";
		}
		
		buildName = Compiler.getDefine( "buildName" );
		if ( buildName == null )
		{
			buildName = "";
		}
		
		#if debug
		buildType = "debug";
		#end
		
		#if build_cheats
		buildType += " -cheats";
		#end
		
		isLocal = Std.parseInt(buildNum) == 0;
		
		//local: svn rev, buildType, machine, timestamp - "623M debug on COMPNAME 2015-10-31 23:59:59"
		if ( isLocal )
		{
			text = svnRev + " " + buildType + " on " + machine + " " + buildTime;
		}
		//server: build version, build number, buildType, buildTime - "v1.0.0.264-debug	2015-10-31 23:59:59"
		else
		{
			text = "v" + buildVersion + "." + buildNum + "-" + buildType + "	" + buildTime;
		}
		
		versionInfo = text;
	}
	
	/**
	 * Logs properties of this class to console output.
	 */
	public function test():Void
	{
		log(buildVersion);
		log(buildName);
		log(svnRev);
		log(buildNum);
		log(machine);
		log(buildType);
		log(buildTime);
	}
}
