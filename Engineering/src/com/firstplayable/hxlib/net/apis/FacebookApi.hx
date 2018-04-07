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
import js.Browser;

typedef Fb = FacebookApi;

typedef FbInitSettings = {
	// your app id
	var appId:String;
	// enable cookies to allow the server to access the session
	@:optional var cookie:Bool;
	// parse social plugins on this page
	@:optional var xfbml:Bool;
	// api version; ie "v2.5"
	var version:String;
};

typedef FbAuthResponse = {
	// Contains an access token for the person using the app.
	var accessToken:String;
	// Indicates the UNIX time when the token expires and needs to be renewed.
	var expiresIn:String;
	// A signed parameter that contains information about the person using the app.
	var signedRequest:String;
	// The ID of the person using the app.
	var userID:String;
	// If requested by login(), will be a list of user-granted scopes.
	@:optional var grantedScopes:String;
};

typedef FbLoginStatus = {
	/* specifies the login status of the person using the app. The status can be one of the following:
	 *	"connected"		The person is logged into Facebook, and has logged into your app.
	 *	"not_authorized"	The person is logged into Facebook, but has not logged into your app.
	 *	"unknown"		The person is not logged into Facebook, so you don't know if they've logged into your app.
	 * 					Or FB.logout() was called before and therefore, it cannot connect to Facebook.
	 */
	var status:String;
	// authResponse is included only if the status is connected.
	@:optional var authResponse:FbAuthResponse;
};

/**
 * Facebook API mappings.
 * https://developers.facebook.com/docs/facebook-login/web
 * https://developers.facebook.com/docs/reference/javascript/FB.login/v2.5
 */
@:native( "FB" )
extern class FacebookApi
{
	// see FbLoginStatus above
	public static inline var STATUS_CONNECTED:String = "connected";
	public static inline var STATUS_NO_AUTH:String = "not_authorized";
	public static inline var STATUS_UNKNOWN:String = "unknown";
	
	/**
	 * Initializes Facebook API. Must be called before anything else.
	 * @param	settings
	 * @usage	instead of calling here, copy this to index.html inside <body> javascript
	 * 
	 *		window.fbAsyncInit = function() {
	 *			FB.init({
	 *				appId      : 'your app id here',
	 *				xfbml      : true,
	 *				version    : 'v2.5'
	 *			});
	 *		};
	 */
	public static function init( settings:FbInitSettings ):Void;
	
	/**
	 * Gets the log in status of a user.
	 * @param	response
	 */
	public static function getLoginStatus( response:FbLoginStatus->Void ):Void;
	
	/**
	 * Summons FB log in dialog.
	 * @param	response
	 * @param	?scope		Object with comma separated permission requests; ie { scope:'public_profile,email,user_friends', return_scopes:false }
	 * 						All other request types must be approved by Facebook. If return_scopes is true, authResponse will also gain a 'grantedScopes' property.
	 * 						Complete scopes list here: https://developers.facebook.com/docs/facebook-login/permissions
	 */
	public static function login( response:FbLoginStatus->Void, ?scope:Dynamic ):Void;
	
	/**
	 * Logs a person out of FB.
	 * @param	response
	 */
	public static function logout( response:FbLoginStatus->Void ):Void;
	
	/**
	 * Talks with the FB Graph API.
	 * @param	collection	Facebook data structure to get/modify; ie "/me" to get a user's info or /me/feed to post to their wall.
	 * @param	?method		The method within the collection to use; ie 'post' to post to a user's wall.
	 * @param	?params		Parameter object to use for the post; ie { message: 'my post message' }
	 * @param	?response	Callback receiving anonymous object that contains various info on the request.
	 */
	public static function api( collection:String, ?method:String, ?params:Dynamic, ?response:Dynamic->Void ):Void;
}

class FbPost
{
	private static var reply:Dynamic->Void;

	/**
	 * Uses the Facebook web API for simple URL sharing.
	 *
	 * https://developers.facebook.com/docs/sharing/reference/share-dialog
	 *
	 * The target page can be marked up with metadata to help format the
	 * preview of this link.
	 *
	 * https://developers.facebook.com/docs/sharing/webmasters#markup
	 *
	 * @param url - Address of the page to be shared
	 * @param appId - Facebook app id
	 */
	public static function shareLink(url:String, ?appId:String, ?surveyRedirect:Bool = false, ?saveID:String):Void
	{
		var encodedUrl = StringTools.urlEncode(url);
		var intent:String;

		if (appId != null)
		{
			var encodedId = StringTools.urlEncode(appId);
			intent = 'https://www.facebook.com/dialog/share?href=$encodedUrl&app_id=$encodedId';
		}
		else
		{
			intent = 'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl';
		}
		
		if ( surveyRedirect )
		{
			intent = "survey.php?s=" + saveID + "&r=" + intent;
		}
		Browser.window.open(intent);
	}
	
	/**
	 * helper func to set your facebook status
	 * @param	msg			the message to send.
	 * @param	?imgSrc		(optional) if provided, additionally posts an image.
	 * 						NOTE: make sure URL is not protected or it will fail!
	 * @param	response	(optional) callback for success or error.
	 * @usage	statusUpdate( "this is an interesting photo", "https://dl.dropboxusercontent.com/u/someuser/fb.png", doSomething );
	 */
	public static function statusUpdate( msg:String, ?imgSrc:String, ?response:Dynamic->Void ):Void
	{
		reply = response;
		
		// image post won't work if localhost or protected
		if ( Browser.location.href.indexOf( "http://localhost" ) > -1 || Browser.location.href.indexOf( "https://" ) > -1 )
			imgSrc = null;
		
		if( imgSrc == null )
			Fb.api( '/me/feed', 'post', { message: msg }, onFbSetStatus );
		else
			Fb.api( '/me/photos', 'post', { caption: msg, url: imgSrc }, onFbSetStatus );
	}
	
	// callback for setting fb status
	private static function onFbSetStatus( response:Dynamic ):Void
	{
		if ( response == null || response.error != null )
			Debug.log( "Facebook error has occurred." );
		else
			Debug.log( "Facebook status has been updated!" );
		
		#if debug
			trace( response );
		#end
		
		if ( reply != null )
		{
			reply( response );
		}
	}
}
