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

import game.def.SocialInfo;
import js.Browser;

typedef GAPI = GoogleServicesApi;

typedef Scope = String;

typedef GAPIAuthConfig = {
	// The application's client ID. Visit the Google Developers Console to get an OAuth 2.0 client ID.
	var client_id:String;
	// The auth scope or scopes to authorize as a space-delimited string. Auth scopes for individual APIs can be found in their documentation.
	var scope:String;
	// If true, then login uses "immediate mode", which means that the token is refreshed behind the scenes, and no UI is shown to the user.
	var immediate:Bool;
	// The OAuth 2.0 response type property. Default: token
	@:optional var response_type:String;
};

/**
 * Google services API.
 * https://developers.google.com/api-client-library/javascript/reference/referencedocs
 */
class GoogleServicesApi
{
	// https://developers.google.com/+/domains/authentication/scopes
	// This list is incomplete, feel free to add others as needed.  See link above.
	public static inline var SCOPE_LOGIN:Scope = "https://www.googleapis.com/auth/plus.login";
	public static inline var SCOPE_PROFILE:Scope = "https://www.googleapis.com/auth/plus.me";
	public static inline var SCOPE_STREAM_WRITE:Scope = "https://www.googleapis.com/auth/plus.stream.write";
	public static inline var SCOPE_EMAILS_READ:Scope = "https://www.googleapis.com/auth/plus.profile.emails.read";

	private static var BUTTON_ID:String = "plus_btn";
	
	private static var m_win:Dynamic = Browser.window;
	private static var gapi(get,null):Dynamic;
	
	//always try to refresh the object in case it changes
	private static function get_gapi():Dynamic
	{
		if ( m_win.gapi == null )
			Browser.console.warn( "Google API could not be reached!" );
		return m_win.gapi;
	}

	public static function isAvailable():Bool
	{
		return gapi != null &&
			   gapi.client != null &&
			   gapi.auth != null;
	}
	
	/**
	 * Initializes Google API by settings api key.
	 * @param	apiKey
	 */
	public static function init( apiKey:String ):Void
	{
		if (gapi.client == null)
		{
			return;
		}

		gapi.client.setApiKey( apiKey );
		gapi.client.load( "plus", "v1" );
	}
	
	/**
	 * Opens a sign in dialog to log into Google.
	 * @param	cliendId	app's client id key.
	 * @param	scopes		array of Scopes (ie permissions). See above for available ones.
	 * @param	response	when login succeeds, triggers this callback.
	 */
	public static function login( cliendId:String, scopes:Array<Scope>, response:Dynamic->Void ):Void
	{
		var scopeStr = scopes.join(" ");
		var config:GAPIAuthConfig = { client_id:cliendId, scope:scopeStr, immediate:false };
		gapi.auth.authorize( config, response );
	}
	
	public static function logout():Void
	{
		gapi.auth.signOut();
	}
	
	/**
	 * Gets the user's token info.
	 * @return
	 */
	public static function getToken():Dynamic
	{
		return gapi.auth.getToken();
	}
	
	/**
	 * Returns true if user is signed in to google. This function must be called from inside a callback with response object.
	 * @param	response	The received response object from Google.
	 * @return
	 */
	public static function isLoggedIn( response:Dynamic ):Bool
	{
		// note: not sure if both or one should be returned
		return response.status.google_logged_in && response.status.signed_in;
	}
	
	/**
	 * Obtains lots of info about the user.
	 * @param	response	a complex object of information, like friends and locations lived.
	 */
	public static function getPeopleInfo( response:Dynamic->Void ):Void
	{
		if ( gapi.client.plus == null ) trace( "Error. Plus API not loaded." );
		
		var req:Dynamic = gapi.client.plus.people.get( { userId:"me", fields:"id,emails" } );
		req.execute( response );
	}

	/**
	 * Uses the Google+ share link interface to open a new window
	 * in which to share a link on G+.
	 *
	 * https://developers.google.com/+/web/share/#share-link
	 *
	 * The target page can be set up with various metadata to determine
	 * what the preview of the link looks like in the user's feed.
	 *
	 * https://developers.google.com/+/web/snippet/#documentation
	 *
	 * @param url - Address of the page to be shared
	 */
	public static function shareLink(url:String, ?surveyRedirect:Bool = false, ?saveID:String):Void
	{
		var encoded = StringTools.urlEncode(url);

		if ( surveyRedirect ) 
		{
			Browser.window.open('survey.php?s=$saveID&r=https://plus.google.com/share?url=$encoded');
		}
		else
		{
			Browser.window.open('https://plus.google.com/share?url=$encoded');
		}
	}

	/**
	 * Creates a share button via the Google+ javascript api.
	 * This is kinda hacky, we're creating a raw html element in front
	 * of our canvas (and everything else).
	 *
	 * This button lives entirely outside of haxe-land and can only be
	 * destroyed by removePlusBtn().
	 *
	 * https://developers.google.com/+/web/share/#javascript-api
	 *
	 * NOTE: This function is in a somewhat incomplete state and may
	 *		 need some effort to work correctly.
	 *
	 * @param x Percentage from the top pf the browser window.
	 * @param y Percentage from the left of the browser window.
	 * @param url Address of the page to be shared.
	 */
	public static function createPlusBtn(x:Int, y:Int, url:String)
	{
		var div = Browser.window.document.createDivElement();
		div.style.position = "absolute";
		div.style.left = '$x%';
		div.style.top = '$y%';
		div.style.zIndex = "1000";
		div.id = BUTTON_ID;
		// div.style.width = "100px";
		// div.style.height = "24px";
		// div.style.background = "#f00";

		Browser.window.document.body.appendChild(div);

		var params = {
			action:"share",
			annotation:"bubble",
			height:"24",
			href:url
		};

		gapi.plus.render(div, params);

		// var params = {
		// 	contenturl:"https://wilson.1stplayable.com",
		// 	clientid:SocialInfo.GO_CLIENT_ID,
		// 	// cookiepolicy:"http://1stplayable.com",
		// 	// cookiepolicy:"single_host_origin",
		// 	cookiepolicy:"none",
		// 	calltoactionlabel:"PLAY",
		// 	calltoactionurl:"https://wilson.1stplayable.com",
		// 	prefilltext:"Hello, world!",
		// 	approvalprompt:"force",
		// 	scope:'$SCOPE_LOGIN $SCOPE_STREAM_WRITE'
		// };

		// gapi.interactivepost.render(div, params);
	}

	/**
	 * Removes the button created by the dark wizardry in createPlusBtn().
	 */
	public static function removePlusBtn():Void
	{
		var div = Browser.window.document.getElementById(BUTTON_ID);

		if (div != null)
		{
			Browser.window.document.body.removeChild(div);
		}
	}
}
