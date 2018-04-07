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
package com.firstplayable.hxlib.debug;
import com.firstplayable.hxlib.utils.MacroUtils;
import com.firstplayable.hxlib.utils.Version;
import haxe.macro.Compiler;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

class BuildInfo extends Sprite
{
	public function new() 
	{
		super();
		
		var buildStamp:TextField = new TextField();
		buildStamp.autoSize = TextFieldAutoSize.LEFT;
		
		var buildTime:String = MacroUtils.getBuildDate();
		var buildVersion:String = "v" + Compiler.getDefine( "buildVersion" );
		var buildNum:String = "build " + Version.getBuildNumber();
		var buildRev:String = "rev " + Version.getSVNRevision();

		var buildName:String = Compiler.getDefine( "buildName" );
		var buildState:String = Version.getBuildType();		

		if ( buildVersion == null )
			buildVersion = "";
		if ( buildName == null )
			buildName = "";
		
		buildStamp.text = buildVersion + " " + buildName + "\n" + buildTime + "\n" + buildNum + "\n" + buildRev + "\n" + buildState;
		addChild( buildStamp );
		
		mouseChildren = true;
		mouseEnabled = false;
	}
}
