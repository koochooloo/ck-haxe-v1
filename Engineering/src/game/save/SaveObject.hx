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

import game.def.PassportDefs;

typedef SaveObject = 
{
	var version:SaveVersion;
	var hasSeenTutorial:Bool;
	var savedAllergens:Array< String >;
	var savedFavorites:Array< String >;
	var passportStamps:Array< StampData >;
	var gradeLevel:String;
	var uuid:String;
	var userId:String;
};
