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
package com.firstplayable.hxlib.net.apis;
#if js // TOPORT
import js.Browser;
#end

/**

  Wrapper class for interacting with the Google Analytics 
  javascript API (analytics.js).

  Internally, all commands go through the ga() command queue with
  no validation of required parameters, etc.  This class tries to
  mitigate that as much as possible with helper functions for the
  most common actions.

  Google Analytics Documentation: 
  https://developers.google.com/analytics/devguides/collection/analyticsjs/

  In order to use this class, the following script block must be included in the 
  project's index.html *before* the block that includes the lime.embed() call:
	<script>
		(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
		(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
		m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
		})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	</script>
  There also needs to be a call to GA.create() as early as possible, probably in
  the project's Main.hx class.

  TODOs:
    - All send commands should support an arbitrary list of name:value
      parameters, currently none of the helper functions do.
	- Support for named trackers, if needed.  Currently everything
	  goes through the default tracker.
	- Plugin functionality.  May be as simple as adding helpers for 
	  'require' and provide' commands.
	- It may prove useful to make the ga() getter function public so that
	  more advanced interactions are possible without requiring helper
	  functions to be written for everything.

**/

typedef GA = GoogleAnalyticsApi;

class GoogleAnalyticsApi
{
	/**
	 * Google API object
	 */
	// private static var ga( get, null ):Dynamic;
	
	// init
	// private static function get_ga():Dynamic
	// {
	// 	if ( ga == null )
	// 	{
	// 		var win:Dynamic = cast Browser.window;
	// 		// win.ga_debug = {trace: true};
	// 		ga = win.ga;
	// 	}
		
	// 	return ga;
	// }

	#if js // TOPORT
	private static var win:Dynamic = cast Browser.window;
	#end
	
	/**
	 * Creates and initializes the default tracker that all subsequent commands
	 * will be sent to.
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/creating-trackers
	 *
	 * @param	trackingID
	 * @param	cookieDomain
	 */
	public static function create( trackingID:String, cookieDomain:String = "auto" ):Void
	{
	#if js // TOPORT
		win.ga( "create", trackingID, cookieDomain );
	#end
	}
	
	/**
	 * Sets a key-value pair of data on the tracker that will be sent along with all items.
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/command-queue-reference#set
	 *
	 * List of available fields:
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/field-reference
	 * 
	 * @param	name
	 * @param	value
	 */
	public static function setField( name:String, value:String ):Void
	{
	#if js // TOPORT
		win.ga( "set", name, value );
	#end
	}

	/**
	 * Requires a plugin to be loaded into the command queue.
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/command-queue-reference#require
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/using-plugins
	 *
	 * @param pluginName
	 * @param pluginOptions
	 */
	public static function require( pluginName:String, ?pluginOptions:Dynamic ):Void
	{
	#if js // TOPORT
		win.ga("require", pluginName, pluginOptions);
	#end
	}
	
	/**
	 *
	 * Track an Event
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/events
	 * 
	 * @param	eventCategory
	 * @param	eventAction
	 * @param	eventLabel
	 * @param	eventValue
	 */
	public static function sendEvent( eventCategory:String, eventAction:String, ?eventLabel:String, ?eventValue:Float ):Void
	{
		send( [ "event", eventCategory, eventAction, eventLabel, eventValue ] );
	}
	
	/**
	 *
	 * Track a Social Interaction
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/social-interactions
	 * 
	 * @param	socialNetwork
	 * @param	socialAction
	 * @param	socialTarget
	 */
	public static function sendSocial( socialNetwork:String, socialAction:String, socialTarget:String ):Void
	{
		send( [ "social", socialNetwork, socialAction, socialTarget ] );
	}
	
	/**
	 * 
	 * Track a Pageview
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/pages
	 *
	 * @param	page
	 */
	public static function sendPageview( ?page:String ):Void
	{
		send( [ "pageview", page ] );
	}

	/**
	 * 
	 * Track a Screenview
	 *
	 * NOTE:  Before sending screenviews, you MUST set the appName 
	 *		  field (GA.setField("appName", "Something")) or your 
	 *		  screenview calls will fail silently.
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/screens
	 *
	 * @param	screen
	 */
	public static function sendScreenview( screen:String ):Void
	{
		send( [ "screenview", {'screenName': screen} ] );
	}
	
	/**
	 * 
	 * Track a User Timing
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/user-timings
	 *
	 * @param	timingCategory
	 * @param	timingVar
	 * @param	timingValue
	 * @param	timingLabel
	 */
	public static function sendTiming( timingCategory:String, timingVar:String, timingValue:Float, ?timingLabel:String ):Void
	{
		send( [ "timing", timingCategory, timingVar, timingValue, timingLabel ] );
	}
	
	/**
	 * 
	 * A generic send command in case someone needs to do fancy things that aren't
	 * covered by the above helper functions.  Pass in all the fields as a set of
	 * key:value pairs, i.e.:
	 *		var fieldsObject = 
	 *		{
	 *			hitType : pageview
	 *			page : "/start"
	 *			title : "Hello, world!"
	 *		}
	 *
	 * https://developers.google.com/analytics/devguides/collection/analyticsjs/command-queue-reference#send
	 *
	 * @param	fieldsObject
	 */
	public static function sendObject( fieldsObject:Dynamic ):Void
	{
		send( [ fieldsObject ] );
	}
	
	// helper to call send func
	private static inline function send( args:Array<Dynamic> ):Void
	{
#if js // TOPORT
		
#if !skip_uploads
		// trace("Send..." + args);
		//add send arg
		args.unshift( "send" );
		Reflect.callMethod( null, win.ga, args );
#else
		//trace("Skipping send because of 'skip_uploads' flag is enabled");
#end

#end
		
	}
}
