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

package game.ui.load;

import assets.SoundLib;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryDef;
import com.firstplayable.hxlib.loader.LibraryLoader.LibraryType;
import game.def.GameState;
import openfl.events.EventDispatcher;

/**
 * Lists assets for each state to be used in batch loading/unloading.
 */
class SpeckLoader extends EventDispatcher
{
	// Initialized at game start and kept in memory for the duration
	public static var commonAssets(get, never):List<LibraryDef>;
	private static function get_commonAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();

		// Spritesheet JSON
		assets.add({name: "2d/allergen_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/login_MENU.json", type: LibraryType.SPRITESHEET_DATA } );		
		assets.add({name: "2d/splash_MENU.json", type: LibraryType.SPRITESHEET_DATA } );		
		assets.add({name: "2d/coreHud_MENU.json", type: LibraryType.SPRITESHEET_DATA } );	
		assets.add({name: "2d/fullHud_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/passport_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/globe_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/country_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/countryDisplay_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/about_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/didyouKnow_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/question_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/common_MENU.json", type: LibraryType.SPRITESHEET_DATA } );
		assets.add({name: "2d/loading_MENU.json", type: LibraryType.SPRITESHEET_DATA});

		// Individual sprites
		assets.add({name: "2d/common_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		assets.add({name: "2d/loading_MENU.png", type:LibraryType.SPRITESHEET_IMAGE});
		
		return assets;
	}
	
	// Usable for: splash, tutorial, support
	public static var splashAssets(get, never):List<LibraryDef>;
	private static function get_splashAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/splash_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		return assets;
	}
	
	public static var loginAssets(get, never):List<LibraryDef>;
	private static function get_loginAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/login_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		return assets;
	}
	
	
	public static var hudCoreAssets(get, never):List<LibraryDef>;
	private static function get_hudCoreAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/coreHud_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		return assets;
	}
	
	public static var hudFullAssets(get, never):List<LibraryDef>;
	private static function get_hudFullAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/fullHud_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		return assets;
	}
	
	public static var globeAssets(get, never):List<LibraryDef>;
	private static function get_globeAssets():List<LibraryDef> 
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/globe_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		//assets.add({name: "3d/globe.jpg", type: LibraryType.SPRITESHEET_IMAGE});
		
		return assets;
	}
	
	public static var countryMenuAssets(get, never):List<LibraryDef>;
	private static function get_countryMenuAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/country_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;
	}

	public static var allergenAssets(get, never):List<LibraryDef>;
	private static function get_allergenAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/allergen_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;
	}
	
	// Used for allergen confirmation screen, ingredient info screen
	public static var allergenConfirmAssets(get, never):List<LibraryDef>;
	private static function get_allergenConfirmAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/recipesFlowCommon_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;
	}
	
	public static var aboutAssets(get, never):List<LibraryDef>;
	private static function get_aboutAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/about_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;		
	}
	
	// Used for country intro and country story
	public static var countryDisplayAssets(get, never):List<LibraryDef>;
	private static function get_countryDisplayAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/countryDisplay_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );

		return assets;			
	}
	
	public static var recipeIngredientAssets(get, never):List<LibraryDef>;
	private static function get_recipeIngredientAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/recipesFlowCommon_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );

		return assets;			
	}
	
	public static var recipeServingAssets(get, never):List<LibraryDef>;
	private static function get_recipeServingAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/recipesFlowCommon_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );

		return assets;
	}
	
	public static var recipeStepsAssets(get, never):List<LibraryDef>;
	private static function get_recipeStepsAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/recipesFlowCommon_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );

		return assets;			
	}
	
	public static var didYouKnowAssets(get, never):List<LibraryDef>;
	private static function get_didYouKnowAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/didyouKnow_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;
	}
	
	public static var questionAssets(get, never):List<LibraryDef>;
	private static function get_questionAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/question_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;
	}
	
	public static var passportAssets(get, never):List<LibraryDef>;
	private static function get_passportAssets():List<LibraryDef> 
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/passport_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;
	}
	
	public static var flagGameAssets(get, never):List<LibraryDef>;
	private static function get_flagGameAssets():List<LibraryDef> 
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/recipesFlowCommon_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;
	}
	
	public static var tutorialBubbleAssets(get, never):List<LibraryDef>;
	private static function get_tutorialBubbleAssets():List<LibraryDef>
	{
		var assets:List<LibraryDef> = new List<LibraryDef>();
		
		// JSON & spritesheet
		assets.add({name: "2d/tutorialBubbles_MENU.png", type: LibraryType.SPRITESHEET_IMAGE } );
		
		return assets;		
	}
}