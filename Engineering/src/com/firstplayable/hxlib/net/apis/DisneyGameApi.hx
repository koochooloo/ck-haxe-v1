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

typedef ABCDM = DisneyGameApi

@:native( "abcdm.abc.com.GameApis" )
extern class DisneyGameApi
{
	/**
	 * Api has been initialized.
	 */
	public static var apiLoadComplete:Void->Void;
	
	/**
	 * Api has failed to initialize.
	 */
	public static var apiLoadFailed:Void->Void;
	
	/**
	 * The game is being closed by the App. Save any required state data now.
	 */
	public static var onClose:Void->Void;
	
	/**
	 * The application has be come active. Override to handle on resume events.
	 */
	public static var onActivated:Void->Void;
	
	/**
	 * The application has resigned active. Override to handle on pause type events.
	 */
	public static var onSuspended:Void->Void;
	
	/**
	 * Notify the application that state has been saved and it is safe to close the game.
	 */
	public static function gameCloseComplete():Void;
	
	/**
	 * Send Disney notifications.
	 * @param	notification	the message (json object) to send.
	 * Must be in this format:
	 * 
	 * 		"notification": {
	 *			"type": "error",
	 *			"payload":  {
	 *				"message": "ErrorXYZhadoccurred"
	 *			}
	 *		}
	 */
	public static function sendNotification( notification:Dynamic ):Void;
}