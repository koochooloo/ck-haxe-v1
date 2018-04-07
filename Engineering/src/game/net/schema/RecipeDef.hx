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

typedef RecipeDef =
{
	var id:Int;
	var country_id:Int;
	var name:String;
    var time:String;
    var thumbnail:String;
    var presentation:String;
    var updated_at:Int;
    var is_deleted:Bool;
    var dietary_preferences:Array<DietaryPreferenceDef>;
    var meal_types:Array<MealTypeDef>;
    var ingredients:Array<IngredientDef>;
    var images:Array<ImageDef>;
    var steps:Array<StepDef>;
    var tools:Array<ToolDef>;
}
