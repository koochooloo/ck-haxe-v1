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

package game.ui.states;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.Country;
import game.Recipe;
import game.controllers.FlowController;
import game.def.GameState;
import game.def.RecipeTypes;
import game.net.NetAssets;
import game.ui.ScrollingManager;
import game.ui.SpeckMenu;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.events.Event;
import openfl.events.FocusEvent;

using StringTools;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

// A parent group that contains button elements. 
typedef RecipeGroup =
{
	panel:DisplayObjectContainer,
	button:GraphicButton,
	label:TextField,
	image:OPSprite
}

class RecipesMenu extends SpeckMenu
{
	// ------ Static tunable vars:
	// TODO - callback to pull from paist bounding box
	private static inline var SCROLLWIDTH:Float = 900;
	private static inline var SCROLLHEIGHT:Float = 600;
	private static inline var DISPLAYNUM:Int = 6;
	private static inline var CATEGORYNUM:Int = 7;
	
	// ------ Member vars:
	private var m_scrollMenu:ScrollingManager;
	private var m_categories:Array< RecipeTypes >;
	private var m_paistGroups:Array< RecipeGroup >;
	private var m_categoryUp:Bitmap;
	private var m_categoryDown:Bitmap;
	private var m_searchTerms:TextField;
	
	//  Indices of left and rightmost rendered objects 
	private var m_renderRight:Int; 
	private var m_renderLeft:Int;
	
	//	Keeps track of persistent up/down toggle for category buttons.
	//		Down state = toggled = true. 
	//		Up state = untoggled = false. 
	private var m_toggledStates:Map< String, Bool >;
	
	private var DEMORECIPES:Array< String > = [ "Coconut Rice", "Filipino Noodles", "Green Garam Sprouts Salad", "Peachy Panzanella Salad", "Persian Meat Balls", "Potato Pancake", "Spring Rolls", "Tuna Sandwiches", "Tomato and Olive Penne", "Whole Wheat Crepes"];    
	private static var DEFAULT_SEARCH:String;
	
	public function new( ?p:GameStateParams) 
	{
		super( "RecipesMenu" );
		
		// Initialize members
		m_toggledStates = new Map();
		m_categories = new Array();
		m_paistGroups = getPaistReference();
		m_renderLeft = 0;
		m_renderRight = DISPLAYNUM;
		m_categoryUp = ResMan.instance.getImage( "2d/Buttons/btn_recipeCategory_up" );
		m_categoryDown = ResMan.instance.getImage( "2d/Buttons/btn_recipeCategory_down" );
		
		// If this menu has been given GameStateParams, we came here from a Country menu
		if ( FlowController.currentPath == FlowPath.CONSUMER_COUNTRY )
		{
			// Set menu title
			var title:TextField = cast getChildByName( "headerText_recipes" );
			title.text = capitalize( FlowController.data.selectedCountry.name );
		}
		
		// Initialize states for all category buttons.
		// 		There are seven categories, ID starting from 0. 
		//		All button start out untoggled (up, false)
		for (n in 0...CATEGORYNUM) 
		{
			var name:String = getButtonById( n ).name;
			m_toggledStates.set( name, false ); 
		}
		
		// Create Scroll menu
		var scrollBounds:DisplayObjectContainer = cast getChildByName( "scroll_border" );
		m_scrollMenu = new ScrollingManager( scrollBounds.x, scrollBounds.y, SCROLLWIDTH, SCROLLHEIGHT, this, "horizontal", DISPLAYNUM );
		
		// Initialize search bar 
		m_searchTerms = cast getChildByName( "lbl_rSearch" );
		if ( DEFAULT_SEARCH == null ) 		
			DEFAULT_SEARCH = m_searchTerms.text;
		m_searchTerms.selectable = true;
		m_searchTerms.type = TextFieldType.INPUT;
		m_searchTerms.addEventListener( Event.CHANGE, onTextUpdate );
		m_searchTerms.addEventListener( FocusEvent.FOCUS_IN, onFocusIn );
		m_searchTerms.addEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
		
		// Initialize recipe buttons & add them to the scroll menu.
		drawRecipes();
		
		// Initialize scroll menu
		m_scrollMenu.init();
		this.addChild( m_scrollMenu );
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		// Button naming convention: btn_(type)(number)
		var name:String = caller.name;
		var type:String = name.substring(4, name.length - 1);
		var number:String = name.charAt(name.length - 1);
		
		// Category buttons filter the recipes displayed.
		// When toggled, refresh the recipes that are being displayed. 
		if (type == "category")
		{
			var category:RecipeTypes = null;
			var isDown:Bool = m_toggledStates.get( name );
			
			// Pattern match vs cateogry enum
			switch( number )
			{
				case "0": 	category = RecipeTypes.VEGETARIAN;
				case "1": 	category = RecipeTypes.DAIRYFREE;
				case "2": 	category = RecipeTypes.GLUTENFREE;
				case "3": 	category = RecipeTypes.APPETIZERS;
				case "4": 	category = RecipeTypes.BREAKFAST;
				case "5": 	category = RecipeTypes.MAINCOURSE;
				case "6": 	category = RecipeTypes.DESSERT;
			}
			if ( isDown )
			{
				// Switch button to up (untoggled, false)
				m_toggledStates.set( name, false );
				caller.upState = m_categoryUp;
				caller.downState = m_categoryUp;
				caller.overState = m_categoryUp;
				
				// Remove filter & redraw recipes 
				m_categories.remove( category );
				drawRecipes();
			}
			else
			{
				// Switch button to down (toggled, true)
				m_toggledStates.set( name, true );
				caller.upState = m_categoryDown;
				caller.downState = m_categoryDown;
				caller.overState = m_categoryDown;
				
				// Add filter and redraw recipes
				m_categories.push( category );
				drawRecipes();
			}
		}
		else
		{
			WebAudio.instance.play( "SFX/recipe_click" );
			
			// On this menu, if it's not a category button, it's a recipe button. 
			// Set the selected recipe and go to the next state in the flow
			var recipe:Recipe = SpeckGlobals.dataManager.getRecipe( name.substring(4, name.length) );
			var country:Country = SpeckGlobals.dataManager.getCountry( recipe.country );
			
			FlowController.data.selectedRecipe = recipe;
			FlowController.data.selectedCountry = country;
			FlowController.goToNext();
			
			return;
		}
		
		WebAudio.instance.play( "SFX/button_click" );	

	}
	
	// Flips the boolean for a given category button
	private function toggleCategory( buttonName ):Bool
	{
		var b:Bool = !m_toggledStates.get( buttonName );
		m_toggledStates.set( buttonName, b );
		return m_toggledStates.get( buttonName );
	}
	
	private function getPaistReference():Array< RecipeGroup >
	{
		// Get paist reference
		var paistGroups:Array< RecipeGroup > = new Array();
		
		for ( n in 0...DISPLAYNUM )
		{
			var panel:DisplayObjectContainer = cast getChildByName( "group_recipe" + n );
			var button:GraphicButton = cast panel.getChildByName( "btn_recipe" + n );
			var label:TextField = cast panel.getChildByName( "lbl_Name" + n);
			var image:OPSprite = cast panel.getChildByName( "image" + n);
			paistGroups.push( { panel: panel, button: button, label: label, image: image } );
			
			panel.visible = false; // Hide layout items
		}
		
		return paistGroups;
	}
	
	// Creates a masterlist of recipe buttons and adds them to the scroll menu
	private function drawRecipes():Void
	{
		// Get search filter
		var filter:String = m_searchTerms.text;
		
		// Clear scroll list
		m_scrollMenu.clear();
		
		// Get button column spacing for offset placement
		var colSpacing:Float = m_paistGroups[ 1 ].panel.x - m_paistGroups[ 0 ].panel.x; // X difference between two adj items
		
		// Loop through recipes and add them to the scroll manager 
		var pos:Int = 0; // Loop through positions in the array of paist references
		var offset:Float = 0; // Increment every time we've looped through the whole pos list.
		
		for ( recipe in SpeckGlobals.dataManager.allRecipes )
		{
			// If we have a selected country, only show recipes from that country
			var isCountryRecipe:Bool = true;
			if ( FlowController.currentPath == FlowPath.CONSUMER_COUNTRY )
			{
				if ( FlowController.data.selectedCountry.name != recipe.country )
				{
					isCountryRecipe = false;
				}
			}

			// Verify that the recipe being displayed has the given search filter
			var hasFilter:Bool = ( filter == DEFAULT_SEARCH ) || ( recipe.name.toLowerCase().indexOf( filter.toLowerCase() ) >= 0 ); 
			
			// Viable tests if it is in the selected categories and is not a marked allergen
			if ( isCountryRecipe && hasFilter && recipe.isViable( m_categories ) ) 
			{
				var DEMONAME:String = StringTools.replace( recipe.name, " ", "_" );
				
				var ref:RecipeGroup = m_paistGroups[ pos ];

				var panel:DisplayObjectContainer = new DisplayObjectContainer();
				panel.x = ref.panel.x + offset;
				panel.y = ref.panel.y;
				
				var img:Bitmap = ResMan.instance.getImage( "2d/UI/recipeSelect" );
				var button:GraphicButton = new GraphicButton( img, img, img, img, null, onButtonHit );
				button.x = ref.button.x;
				button.y = ref.button.y;
				button.name = "btn_" + recipe.name;
				panel.addChild( button );
				
				var label:TextField = new TextField();
				label.text = recipe.name;
				label.x = ref.label.x;
				label.y = ref.label.y;
				label.width = 200;
				label.height = 40;
				label.setTextFormat( ref.label.getTextFormat() );
				label.multiline = true;
				label.wordWrap = true;
				panel.addChild( label );
				
				//======================================================
				// Setup initial recipe image
				//======================================================
				var img2:Bitmap;
				if (Tunables.USE_DATABASE_RESOURCES)
				{
					img2 = ResMan.instance.getImageUnsafe( "2d/UI/recipesLarge/loading" );
					//trigger load later.
				}
				else
				{
					img2 = ResMan.instance.getImageUnsafe( "2d/UI/recipesLarge/recipe_" + DEMONAME + "_01" );
					if ( img2 == null ) // TEMP WHILE LACKING DATABASE HOOKUP - use placeholder if no recipe image
					{
						img2 = ResMan.instance.getImage( "2d/UI/recipesLarge/placeholder" );
					}
				}
				
				var recipeImageBtn:GraphicButton = new GraphicButton( img2, img2, img2, img2, null, onButtonHit ); 
				
				// Image is sized to keep the same dimensions, but scale up until it hits the dimensions.
				var imageScaleW:Float = ref.image.width / recipeImageBtn.width;
				var imageScaleH:Float = ref.image.height / recipeImageBtn.height;
				
				if ( recipeImageBtn.width >= recipeImageBtn.height )
				{
					recipeImageBtn.scaleX = imageScaleW;
					recipeImageBtn.scaleY = imageScaleW;
				}
				else if ( recipeImageBtn.height > recipeImageBtn.width )
				{
					recipeImageBtn.scaleX = imageScaleH;
					recipeImageBtn.scaleY = imageScaleH;
				}
				
				var xOffsetRecipe:Float = ref.image.x - ref.button.x;
				var yOffsetRecipe:Float = ref.image.y - ref.button.y;
				recipeImageBtn.x = xOffsetRecipe;
				recipeImageBtn.y = yOffsetRecipe;
				button.addChild( recipeImageBtn );
				
				var recipeImageButtonName:String = "img_" + recipe.name;
				recipeImageBtn.name = recipeImageButtonName;
				
				//======================================
				// Trigger loading of actual recipe image
				// TODO: consider doing this only when the recipe becomes visible?
				//======================================
				if (Tunables.USE_DATABASE_RESOURCES)
				{
					if (recipe.images[0] != null)
					{
						NetAssets.instance.getImage(recipe.images[0], function(downloadedImg:Bitmap){
							if (downloadedImg != null)
							{
								button.removeChild(recipeImageBtn);
								
								var newRecipeImageBtn:GraphicButton = new GraphicButton( downloadedImg, downloadedImg, downloadedImg, downloadedImg, null, onButtonHit ); 
								// Image is sized to keep the same dimension ratios, but scale up until it hits the dimensions of the container
								var imageScaleW:Float = ref.image.width / newRecipeImageBtn.width;
								var imageScaleH:Float = ref.image.height / newRecipeImageBtn.height;
								
								if ( newRecipeImageBtn.width >= newRecipeImageBtn.height )
								{
									newRecipeImageBtn.scaleX = imageScaleW;
									newRecipeImageBtn.scaleY = imageScaleW;
									
									yOffsetRecipe += (newRecipeImageBtn.width - newRecipeImageBtn.height) / 2;
								}
								else if ( newRecipeImageBtn.height > newRecipeImageBtn.width )
								{
									newRecipeImageBtn.scaleX = imageScaleH;
									newRecipeImageBtn.scaleY = imageScaleH;
									
									xOffsetRecipe += (newRecipeImageBtn.height - newRecipeImageBtn.width) / 2;
								}
								
								newRecipeImageBtn.x = xOffsetRecipe;
								newRecipeImageBtn.y = yOffsetRecipe;
								
								button.addChild( newRecipeImageBtn );
								newRecipeImageBtn.name = recipeImageButtonName;
							}
						});
					}
				}
				
				this.addChild( panel );

				// Add to scroll menu
				m_scrollMenu.addItem( panel, button );
				
				// Increment/loop position
				if ( pos == 5)
				{
					pos = 0;
					offset += colSpacing * 3 ; // New set of buttons uses the same ref but is built (offset) pixels to the right
											   // 	TODO - replace this with virtual lists
				}
				else
				{
					pos++;
				}
			}
		}
		
		showMask();
	}
	
	private function showMask():Void
	{
		m_scrollMenu.reparent();
	}
	
	private function onTextUpdate( e:Event ):Void 
	{
		drawRecipes();
	}
	
	private function onFocusIn( e:FocusEvent ):Void
	{
		if ( m_searchTerms.text == DEFAULT_SEARCH )
		{
			m_searchTerms.text = "";
		}
	}
	
	private function onFocusOut( e:FocusEvent ):Void
	{
		// If there is no search content, restore default text
		if ( m_searchTerms.text == "" )
		{
			m_searchTerms.text = DEFAULT_SEARCH;
		}
	}
}