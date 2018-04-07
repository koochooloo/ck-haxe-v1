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

package game.def;

enum StampStatus 
{
	UNEARNED;
	EARNED;
	CLAIMED;
}

typedef StampData = {
	var country:String;
	var status:Int;
};

class PassportDefs
{
	public static inline var STAMPS_PER_GRADE:Int = 10;
	
	public static inline var STAMP_ASSET_PATH:String = "2d/UI/passport/";
	
	public static var COUNTRY_STAMP_MAP:Map<String, String> = [
		"france" 		=>	"Stamp-France",
		"india"			=>	"Stamp-India",
		"iran"			=>	"Stamp-Iran",
		"israel"		=>	"Stamp-Israel",
		"italy"			=>	"Stamp-Italy",
		"mexico"		=>	"Stamp-Mexico",
		"nigeria"		=>	"Stamp-Nigeria",
		"philippines"	=>	"Stamp-Philippines",
		"united states"	=>	"Stamp-USA",
		"vietnam"		=>	"Stamp-Vietnam",
		
		"angola"		=>	"Stamp-Angola",
		"china"			=>	"Stamp-China",
		"costa rica"	=>	"Stamp-CostaRica",
		"egypt"			=>	"Stamp-Egypt",
		"japan"			=>	"Stamp-Japan",
		"south korea"	=>	"Stamp-Korea",
		"peru"			=>	"Stamp-Peru",
		"spain"			=>	"Stamp-Spain",
		"thailand"		=>	"Stamp-Thailand",
		"united kingdom"=>	"Stamp-UnitedKingdom",
		
		"cambodia" 		=> "Stamp-Cambodia",
		"el salvador"	=> "Stamp-ElSalvador",
		"ethiopia"		=> "Stamp-Ethiopia",
		"germany" 	    => "Stamp-Germany",
		"greece"		=> "Stamp-Greece",
		"ireland"	    => "Stamp-Ireland",
		"kenya"		    => "Stamp-Kenya",
		"russia"	    => "Stamp-Russia",
		"turkey"		=> "Stamp-Turkey",
		"sri lanka" 	=> "Stamp-SriLanka",
	];
}
