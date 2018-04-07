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

package game.save;

@:enum
abstract SaveVersion(String) from String to String
{
	var FIRST 	= "1.0.0";
	var SECOND 	= "1.0.1";
	var THIRD 	= "1.0.2";
	var FOURTH 	= "1.0.3";
	var FIFTH 	= "1.0.4";
	var SIXTH 	= "1.0.5";
	var SEVENTH = "1.0.6";
	var EIGHTH  = "1.0.y";
	var CURRENT = "1.0.8";
	
}