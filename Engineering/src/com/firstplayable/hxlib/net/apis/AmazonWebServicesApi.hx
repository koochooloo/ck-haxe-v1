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
import js.Error;

/**** 

  Wrapper class for interacting with thw Amazon Web Services API.

  In order to use this class, load the library in the project's
  index.html <head> block, with the following:
	<script src="https://sdk.amazonaws.com/js/aws-sdk-2.2.33.min.js"></script>

	TODOs:
	  - Need to make sure window.AWS is loaded.

***/

typedef AWS = AmazonWebServicesApi;

class AmazonWebServicesApi
{
	private static var m_win:Dynamic = Browser.window;

	public static function connect(region:String, identityPoolId:String):Void
	{
		m_win.AWS.config.region = region;
		m_win.AWS.config.credentials = new CognitoIdentityCredentials({ IdentityPoolId:identityPoolId });
		m_win.AWS.apiVersions = {
			dynamodb: '2012-08-10',
			s3: '2006-03-01'
		}

	}
}

//////////////////////
//  Wrappers
//////////////////////

// http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/CognitoIdentityCredentials.html
@:native("AWS.CognitoIdentityCredentials")
extern class CognitoIdentityCredentials
{
	function new(params:Dynamic);
}

// http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Request.html
@:native("AWS.Request")
extern class Request
{
}

// http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/DynamoDB.html
@:native("AWS.DynamoDB")
extern class DynamoDB
{
	function new(params:Dynamic = {});

	function batchGetItem(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function batchWriteItem(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function createTable(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function deleteItem(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function deleteTable(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function describeTable(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function getItem(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function listTables(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function putItem(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function query(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function scan(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function updateItem(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function updateTable(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
	function waitFor(state:String, params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
}

// http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html
@:native("AWS.S3")
extern class S3
{
	function new(options:Dynamic = {});

	// Not adding all the functions as there are a ton.
	// See above link for more and feel free to add as needed.
	function putObject(params:Dynamic = {}, callback:Error->Dynamic->Void):Request;
}
