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

package game.net.schema;

typedef CountryDef =
{
	var id:Int;
	var code:String;
	var name:String;
	var capital:String;
	var population:Int;
	var national_dish:String;
	var country_image:String;
	var country_flag:String;
	var salutation:String;
	var updated_at:Int;
	var is_deleted:Bool;
	var available:Bool;
	var languages:Array<LanguageDef>;
	var greeting_audio:Array<AudioDef>;
	var bonappetit_audio:Array<AudioDef>;
	var audios:Array<AudioDef>;
	var social_issues:Array<SocialIssueDef>;
	var fact:Array<FactDef>;
}
