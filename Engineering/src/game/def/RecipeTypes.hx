//
// Copyright (C) 2016, 1st Playable Productions, LLC. All rights reserved.
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

/*
 * Types of recipes presented in the game; referred to as "flags" in the database. 
 * Used to filter recipes in the All Recipes and Country Recipes menus. 
 * */

enum RecipeTypes 
{
	VEGETARIAN;
	DAIRYFREE;
	GLUTENFREE;
	APPETIZERS;
	BREAKFAST;
	MAINCOURSE;
	DESSERT;
}