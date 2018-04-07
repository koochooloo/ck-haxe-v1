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
import lime.ui.Window;
import openfl.Lib;
import openfl.display.Application;
import openfl.geom.Point;
import openfl.system.Capabilities;

enum Platform
{
	Android;
	BlackBerry;
	iPhone;
	iPad;
	iPod;
	iOS;
	Opera_Mini;
	IEMobile;
	Windows;
}

@:enum
abstract Browser(String)
{
	var CHROME = "Chrome";
	var FIREFOX = "Firefox";
	var MSIE = "Internet Explorer";
	var OPERA = "Opera";
	var SAFARI = "Safari";
	var UNKNOWN = "Unknown";
}

class DeviceCapabilities
{
	/**
	 * Gets a capability report based on various functions in this class.
	 * @return
	 */
	public static function string():String
	{
		return "Device Capabilities:"
			+ "\n  platform: " + platform()
			+ "\n  isMobile?: " + isMobile()
			+ "\n  os: " + os()
			+ "\n  resolution: " + screenResolution();
	}

#if js
	//! Name of the browser.  Could be an Enum...
	public static var browser(get, null):Browser;
	//! Major version number
	public static var browserVersion(get, null):Int;

	private static function get_browser():Browser
	{
		if (browser == null)
		{
			getBrowserAndVersion();
		}

		return browser;
	}

	private static function get_browserVersion():Int
	{
		if (browser == null)
		{
			getBrowserAndVersion();
		}

		return browserVersion;
	}

	// Pieces borrowed from:
	// http://www.javascripter.net/faq/browsern.htm
	// http://www.javascriptkit.com/javatutors/navigator.shtml
	private static function getBrowserAndVersion():Void
	{
		var ua = js.Browser.navigator.userAgent;
		var i:Int;
		var version:String;

		if ((i = ua.indexOf("OPR/")) != -1)
		{
			// Opera checks have to come before MSIE
			// Newer versions of Opera (15+)
			browser = OPERA;
			version = ua.substr(i + 4);
		}
		else if ((i = ua.indexOf("Opera")) != -1)
		{
			// Older versions of Opera
			browser = OPERA;
			version = ua.substr(i + 8);
		}
		else if ((i = ua.indexOf("MSIE")) != -1)
		{
			browser = MSIE;
			version = ua.substr(i + 5);
		}
		else if ((i = ua.indexOf("Trident")) != -1)
		{
			// Trident checks have to come after MSIE
			// IE 11+ no longer has MSIE in the ua
			browser = MSIE;
			i = ua.indexOf("rv:");
			version = ua.substr(i + 3);
		}
		else if ((i = ua.indexOf("Chrome")) != -1)
		{
			// Chrome check has to come before Safari
			browser = CHROME;
			version = ua.substr(i + 7);
		}
		else if ((i = ua.indexOf("Safari")) != -1)
		{
			browser = SAFARI;
			version = ua.substr(i + 7);
			if ((i = ua.indexOf("Version")) != -1)
			{
				// Some versions of Safari have a Version tag
				version = ua.substr(i + 8);
			}
		}
		else if ((i = ua.indexOf("Firefox")) != -1)
		{
			browser = FIREFOX;
			version = ua.substr(i + 8);
		}
		else
		{
			browser = UNKNOWN;
			version = "0";
		}

		browserVersion = Std.parseInt(version);

	}
#end
	
    /**
     * Checks if the device is a mobile platform or not.
     * @return
     */
    public static inline function isMobile():Bool
    {
        #if flash
            return ~/AND|IOS/i.match( platform() );
        #elseif js
            return ~/Android|BlackBerry|iPhone|iPad|iPod|Opera Mini|IEMobile/i.match( platform() );
        #elseif android
            return true; //Android is always mobile
		#elseif iphoneos
			return true;
		#elseif ios
			return true;
		#elseif windows
			return true; // TOPORT
        #else
            #error "Not yet implemented on this platform in hxlib."
        #end
    }
	
	public static function isPlatform( pform:Platform ):Bool
	{
		#if js
			var reg:EReg =
				switch( pform )
				{
					case Android:		~/Android/i;
					case BlackBerry:	~/BlackBerry/i;
					case iPhone:		~/iPhone/i;
					case iPad:			~/iPad/i;
					case iPod:			~/iPod/i;
					case iOS:			~/iPad|iPod|iPhone/i;
					case Opera_Mini:	~/Opera Mini/i;
					case IEMobile:		~/IEMobile/i;
					case Windows:		~/Windows/i;
				};
			
			return reg.match( platform() );
		#elseif android
			return pform == Android;
		#else
			Debug.warn( "Not yet implemented on this platform in hxlib." );
			return false;
		#end
	}
	
    /**
     * The platform the application is running on.
     * flash: ie, "AND" for Android.
     * js:    ie, "Android" for Android.
     */
    public static inline function platform():String
    {
        #if flash
            return Capabilities.version.split(",")[ 0 ].split(" ")[ 0 ];
        #elseif js
            return js.Browser.navigator.userAgent;
        #elseif android
            return "android"; //The platform is always android
		#elseif ios
			return "ios";
		#elseif windows
			return "windows";
        #else
            #error "Not yet implemented on this platform in hxlib."
        #end
    }

    public static function aspectRatio():Float
	{
		var w:Int = 0;
		var h:Int = 0;
		
		#if js
			var app:Application = Lib.application;
			if ( app != null )
			{
				var win:Window = app.window;
				if ( win != null )
				{
					w = win.width;
					h = win.height;
				}
			}
			
			if ( w == 0 )
			{
				w = js.Browser.window.innerWidth;
			}
			if ( h == 0 )
			{
				h = js.Browser.window.innerHeight;
			}
		#elseif (android || ios)
			//TODO: get w/h of platform
			//w = Lib.current.stage.stageWidth;
			//h = Lib.current.stage.stageHeight;
			//trace( w, h );
			w = 1920; // 16:9 dimensions
			h = 1080;
		#elseif windows // TOPORT
			//TODO: get w/h of platform
			//w = Lib.current.stage.stageWidth;
			//h = Lib.current.stage.stageHeight;
			//trace( w, h );
			w = 1920; // 16:9 dimensions
			h = 1080;
		#else
			// TODO: test this; doesn't work on Android
			w = Std.int( Capabilities.screenResolutionX );
			h = Std.int( Capabilities.screenResolutionY );
			Debug.warn("Warning: Untested on non-js platforms!!!");
		#end
		
		var aspect:Float = Math.max(w, h) / Math.min(w, h);
		
		//Debug.warn('w: $w\nh: $h\naspect: $aspect');
		
		return aspect;
	}
	
	/**
	 * A helper function which indicates if the current platform is CocoonJS
	 * @return true if the platform is CocoonJS, false otherwise.
	 */
	public static function isCocoonJS():Bool
	{
		#if js
			return untyped __js__("Boolean(window.navigator.isCocoonJS)");
		#else
			return false;
		#end
	}

	// This 1.5 is a semi-magical number.
	// 4:3 = 1.33
	// 16:10 = 1.6
	// 16:9 = 1.78
	// PSoC 1024x704 = 1.45
	// PSoC 1366x704 = 1.94
	// Also, changes to this number *must* be reflected in assets/data/index.html in
	// html5 projects that support widescreen backgrounds.
	/**
	 * Semi-deprecated; different projects use different magic numbers; you should just compare 
	 * aspectRatio() against whatever is in your index.html file (or whatever best works with 
	 * your layouts)
	 */
	public static var isWidescreen:Bool = aspectRatio() > 1.5;
    
	/**
	 * The player version information; "WIN 11,1,0,0" for Windows, Flash Player 11.1. The String is
	 * in format "platform majorVersion, minorVersion, buildNumber, internalBuildNumber". These may be obtained
	 * individually from other functions in VersionCue.
	 */
	/*public static inline function versionInfo():String
	{
		return Capabilities.version;
	}*/
	
	/**
	 * The operation system that the player is running from; "Windows XP" for Windows XP. Note: It is possible that
	 * not all OSs are considered - use with caution.
	 */
	public static inline function os():String
	{
		return Capabilities.os;
	}
	
	/**
	 * The language code of the operating system that the player is running from; "en" for English.
	 */
	/*public static inline function get language():String
	{
		return Capabilities.language;
	}*/
	
	/**
	 * Determines if the platform is mobile. True if IOS or ANDROID
	 * @return true if running on a mobile platform (IOS or ANDROID)
	 * TODO: merge with above isMobile()
	 */
	/*public static inline function isMobilePlatform():Boolean
	{
		var testPlatform:String = platform();
		return ( testPlatform == PLATFORM_AND || testPlatform == PLATFORM_IOS );
	}*/
	
	/**
	 * The player's type.
	 * @return	type string
	 */
	/*public static inline function playerType():String
	{
		return Capabilities.playerType;
	}*/
	
	/**
	 * Checks if the app is playing from a browser.
	 * @return	true if playing from browser.
	 */
	/*public static inline function isPlayerTypeBrowser():Boolean
	{
		#if flash
			var playerType:String = Capabilities.playerType;
			return ( playerType == PLAYER_PLUGIN || playerType == PLAYER_ACTIVEX );
		#end
	}*/
	
	/**
	 * Checks if the app is playing in stand alone flash player.
	 * @return	true if playing in stand alone flash player.
	 */
	/*public static inline function isPlayerTypeStandAlone():Boolean
	{
		return Capabilities.playerType == PLAYER_STANDALONE;
	}*/
	
	/**
	 * The major version number of the player; "11" for Flash Player 11.
	 */
	/*public static inline function get versionMajor():int
	{
		return int( Capabilities.version.split(",")[ 0 ].split(" ")[ 1 ] );
	}*/
	
	/**
	 * The minor version number of the player; "1" for Flash Player x.1.
	 */
	/*public static inline function get versionMinor():int
	{
		return int( Capabilities.version.split(",")[ 1 ] );
	}*/
	
	/**
	 * The complete version number of the player; "11.1" for Flash Player 11.1.
	 */
	/*public static inline function get version():Number
	{
		return Number( versionMajor + "." + versionMinor );
	}*/
	
	/**
	 * The build number of the player; "103" for Flash Player build 103.
	 */
	/*public static inline function get buildNumber():int
	{
		return int( Capabilities.version.split(",")[ 2 ] );
	}*/
	
	/**
	 * The internal build number of the player; "54" for Flash Player internal build 54.
	 */
	/*public static inline function get buidNumberInternal():int
	{
		return int( Capabilities.version.split(",")[ 3 ] );
	}*/
	
	/**
	 * The browser, if any, that the app is being run on
	 */
	/*public static inline function browserInfo():String
	{
		//We need to makesure that the Flash Player is being run as a plugin or this line of code will break in a normal dev enviroment. 
		if ( Capabilities.playerType == "PlugIn" )
		{
			var userBrowser:String = ExternalInterface.call("function(){return navigator.appCodeName+'-'+navigator.appName+'-'+navigator.appVersion;}");
			return userBrowser;
		}
		return "";
	}*/
	
	/**
	 * The runtime environment / player type. Possible values include 'Desktop', 'PlugIn', or 'ActiveX'.
	 */
	/*public static inline function get runtimeEnvironment():String
	{
		return Capabilities.playerType;
	}*/
	
	/**
	 * Specifies if AIR runtime; true for AIR, false for FLASH.
	 */
	/*public static inline function rteAIR():Boolean
	{
		if ( runtimeEnvironment == "Desktop" )
		{
			return true;
		}
		
		return false;
	}*/
	
	/**
	 * The browser name, if any, that the app is being run on.
	 */
	/*public static inline function browserType():String
	{
		//We need to makesure that the Flash Player is being run as a plugin or this line of code will break in a normal dev enviroment. 
		if ( Capabilities.playerType == "PlugIn" )
		{
			var userBrowser:String = ExternalInterface.call("function(){return navigator.appCodeName;}");
			return userBrowser;
		}
		
		return "";
	}*/
	
	/**
	 * The CPU architecture of the player; "ARM" for an ARM processor.
	 */
	/*public static inline function get architecture():String {
		return Capabilities.cpuArchitecture;
	}*/
	
	/**
	 * Verify that the user's player is at a required target or target range.
	 * @param	requiredVersion	Specifies a required version of the player. If the player version is less than this number, then the callback function will be called.
	 * @param	requiredCallback	The callback function for the required player version.
	 * @param	suggestedVersion	Specifies a suggested version of the player. If the player version is less than this number, than the callback function will be called.
	 * @param	suggestedCallback	The callback function for the suggested player version.
	 * @return	true if the player's version exceeds the suggested version.
	 */
	/*public static inline function verifyTarget( requiredVersion:Number, requiredCallback:Function, suggestedVersion:Number = 0.0, suggestedCallback:Function = null ):Boolean
	{
		//TODO: change params to ..rest, so we can use an undisclosed number of targets and callbacks
		//TODO: change suggestedVersion param to the flash player target compiler version
		
		//make sure player is at least required version
		if ( version < requiredVersion )
		{
			if ( requiredCallback != null )
			{
				requiredCallback();
				return false;
			}
			else
			{
				Tracer.traceLog( "Required version callback function is null!", "[VersionCue]" );
				return false;
			}
		}
		
		//make sure player is at least suggested version
		if ( version < suggestedVersion )
		{
			if ( suggestedCallback != null )
			{
				suggestedCallback();
				return false;
			}
			else
			{
				Tracer.traceLog( "Suggested version callback function is null!", "[VersionCue]" );
			}
		}
		
		//player version checked out okay
		return true;
	}*/
	
	/**
	 * True if the camera and microphone are enabled.
	 */
	/*public static inline function get hasAvHardware():Boolean {
		return Capabilities.avHardwareDisable;
	}*/
	
	/**
	 * True if the system has audio.
	 */
	/*public static inline function get hasAudio():Boolean {
		return Capabilities.hasAudio;
	}*/
	
	/**
	 * True if the system has an audio encoder, allowing streaming.
	 */
	/*public static inline function get hasAudioEncoder():Boolean {
		return Capabilities.hasAudioEncoder;
	}*/
	
	/**
	 * True if the system has an video encoder, allowing streaming.
	 */
	/*public static inline function get hasVideoEncoder():Boolean {
		return Capabilities.hasVideoEncoder;
	}*/
	
	/**
	 * True if your system allows embedded videos.
	 */
	/*public static inline function get hasEmbeddedVideo():Boolean {
		return Capabilities.hasEmbeddedVideo;
	}*/
	
	/**
	 * True if system allows streaming of audio.
	 */
	/*public static inline function get hasAudioStreaming():Boolean {
		return Capabilities.hasStreamingAudio;
	}*/
	
	/**
	 * True if system allows streaming of video.
	 */
	/*public static inline function get hasVideoStreaming():Boolean {
		return Capabilities.hasStreamingVideo;
	}*/
	
	/**
	 * True if running debugger swf.
	 */
	/*public static inline function get isDebug():Boolean {
		return Capabilities.isDebugger;
	}*/
	
	/**
	 * The pixel aspect ratio of the system's monitor.
	 */
	/*public static inline function pixelAspectRatio():Float
	{
		return Capabilities.pixelAspectRatio;
	}*/
	
	/**
	 * The DPI of the system's monitor.
	 */
	/*public static inline function screenDPI():Float
	{
		return Capabilities.screenDPI;
	}*/
	
	/**
	 * Gets the screen resolution of the system's monitor.
	 * @return	The x- and y-resolution in the form of a point.
	 */
	public static inline function screenResolution():Point
	{
		return new Point( Capabilities.screenResolutionX, Capabilities.screenResolutionY );
	}
}
