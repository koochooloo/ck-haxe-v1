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
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.Country;
import game.Ingredient;
import game.Recipe;
import game.Tool;
import game.controllers.FlowController;
import game.def.GameState;
import game.net.NetAssets;
import game.ui.VirtualScrollingMenu;
import game.ui.MultidimensionalScrollingMenu;
import game.ui.SpeckMenu;
import game.ui.states.RecipeIngredientsMenu.IngredientGroup;
import game.ui.states.RecipeIngredientsMenu.ToolGroup;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.display.DisplayObjectContainer;



#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

using StringTools;

typedef IngredientGroup =
{
	panel:DisplayObjectContainer,
	label:TextField,
	button:GraphicButton,
	ingredient:Ingredient
}

typedef ToolGroup = 
{
	panel:DisplayObjectContainer,
	label:TextField,
	button:GraphicButton,
	tool:Tool
}


/*
 * Class for the Recipe Tools & Ingredients menu. Manages two separate scrolling lists of items.
 * */
class RecipeIngredientsMenu extends SpeckMenu
{
	// ------ Member vars:
	private var m_ingredientsMenu:VirtualScrollingMenu; 
	private var m_toolsMenu:MultidimensionalScrollingMenu;
	private var m_imageIdx:Int; // Position in recipe image array
	private var m_recipeImage:OPSprite;

	public function new( p:GameStateParams ) 
	{
		super( "RecipeIngredientsMenu" );
		
		// Grab highlighted recipe for setting up img/favorites
		var recipe:Recipe = FlowController.data.selectedRecipe;

		// ---------------------------------------------------
		// Set menu title
		// ---------------------------------------------------
		var title:TextField = cast getChildByName( "headerText" );
		title.text = capitalize( recipe.name ); 
	
		// ---------------------------------------------------
		// Set up the scrolling ingredients menu
		// ---------------------------------------------------
		var ingredientBounds:OPSprite = cast getChildByName( "spr_scrollBounds_ingredients" );
		var ingredientScrollBar:OPSprite = cast getChildByName( "handleIngredients" );
		var ingredientScrollTrack:OPSprite = cast getChildByName( "spr_scrollBacking_ingredients" );
		var ingredientRef1:DisplayObjectContainer = cast getChildByName( "group_ingredient1" );
		var ingredientRef2:DisplayObjectContainer = cast getChildByName( "group_ingredient2" );
		
		// Set menu-specific button onHit
		var ingredientRefButton:GraphicButton = cast ingredientRef1.getChildByName( "btn_ingredient1" );
		ingredientRefButton.onHit = onIngredientHit;
		
		m_ingredientsMenu = new VirtualScrollingMenu( ingredientBounds, Orientation.VERTICAL, ingredientRef1, ingredientRef2, ingredientScrollBar, ingredientScrollTrack );
		
		addIngredientData();
		this.addChild( m_ingredientsMenu );
		m_ingredientsMenu.init();
		
		// ---------------------------------------------------
		// Set up the scrolling tools menu
		// ---------------------------------------------------
		var toolBounds:OPSprite = cast getChildByName( "spr_scrollBounds_tools" );
		var toolScrollBar:OPSprite = cast getChildByName( "handleTools" );
		var toolScrollTrack:OPSprite = cast getChildByName( "spr_scrollBacking_tools" );
		var toolRef1:DisplayObjectContainer = cast getChildByName( "group_tool1" );
		var toolRef2:DisplayObjectContainer = cast getChildByName( "group_tool2" );
		var toolRef3:DisplayObjectContainer = cast getChildByName( "group_tool3" );
		
		
		
		// Set menu-specific button onHit
		var toolRefButton:GraphicButton = cast toolRef1.getChildByName( "btn_tool1" );
		toolRefButton.onHit = onToolHit;
		
		var toolRef1:DisplayObjectContainer = cast getChildByName( "group_tool1" );
		var refLabel:TextField = cast toolRef1.getChildByName( "lbl_tool1" );			
		
		m_toolsMenu = new MultidimensionalScrollingMenu( toolBounds, Orientation.VERTICAL, toolRef1, toolRef3, toolRef2, toolScrollBar, toolScrollTrack );
		
		addToolData();
		this.addChild( m_toolsMenu );
		m_toolsMenu.init();

		// ---------------------------------------------------
		// Set up the favorites button
		// ---------------------------------------------------
		// Favoriting button is only visible in the consumer flow
		if ( FlowController.currentMode == FlowMode.CONSUMER )
		{
			// Show favorites button
			var fav:GraphicButton = cast getChildByName( "btn_favorite" );
			fav.visible = true;
			fav.alpha = 1;
			
			// Set up favorites button ( toggled/not )
			if ( SpeckGlobals.dataManager.hasFavorite( recipe ) )
			{
				fav.upState   = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
			}
			else
			{
				fav.upState   = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
			}
		}

		// ---------------------------------------------------
		// Set up the first recipe image
		// ---------------------------------------------------
		var paistImg:OPSprite = cast getChildByName( "recipeImage" );
		m_imageIdx = 0;
		
		if (Tunables.USE_DATABASE_RESOURCES)
		{
			displayDatabaseImage( recipe, m_imageIdx );
		}
		else
		{
			var fileName:String = StringTools.replace( recipe.name, " ", "_" );
			var recipeImg:Bitmap = ResMan.instance.getImageUnsafe( "2d/UI/recipesLarge/recipe_" + fileName + "_01" );
			if ( recipeImg == null ) // Use placeholder image if no recipe image exists
			{
				recipeImg = ResMan.instance.getImage( "2d/UI/recipesLarge/placeholder" );
			}
			updateRecipeImage(recipeImg);
		}
		
		
		//-----------------------------------------------
		// Set up recipe image paging UI
		//-----------------------------------------------
		var pageRight:GraphicButton = cast getChildByName( "btn_pageRight" );
		var pageLeft:GraphicButton = cast getChildByName( "btn_pageLeft" );
		if (!Tunables.USE_DATABASE_RESOURCES || recipe.images.length <= 1 )
		{
			// Disable paging arrows if only one image or not using db assets
			pageRight.enabled = false;
			pageLeft.enabled = false;
		}
		else
		{
			// Since we are at the first in the set, disable the left paging button
			pageLeft.enabled = false;
		}
		
		//-----------------------------------------------
		// Reparent tools header
		//-----------------------------------------------
		var headerRibbon:OPSprite = cast getChildByName( "spr_header_ribbon" );
		var headerLabel:OPSprite = cast getChildByName( "spr_header_tools" );
		this.addChildAt( headerRibbon, this.numChildren );
		this.addChildAt( headerLabel, this.numChildren );
		
		reparentScrollMasks();
	}
	
	// ===================================
	// Image paging 
	// ===================================
	private function displayDatabaseImage( recipe:Recipe, index:Int ):Void
	{
		//Put placeholder
		var recipeImg:Bitmap = ResMan.instance.getImageUnsafe( "2d/UI/recipesLarge/loading" );
		updateRecipeImage(recipeImg);
		
		//Load asset
		NetAssets.instance.getImage(recipe.images[index], function(newImage:Bitmap):Void{
			if (newImage != null)
			{
				updateRecipeImage(newImage);			
				
				// Show & reparent favorites button
				if ( FlowController.currentMode == FlowMode.CONSUMER )
				{
					var fav:GraphicButton = cast getChildByName( "btn_favorite" );
					fav.visible = true;
					fav.alpha = 1;
					this.addChildAt( fav, this.numChildren );
				}
			}
		});
	}
	
	private function pageLeft():Void
	{
		var recipe:Recipe = FlowController.data.selectedRecipe;
		var pageRight:GraphicButton = cast getChildByName( "btn_pageRight" );
		var pageLeft:GraphicButton = cast getChildByName( "btn_pageLeft" );
		
		// Early return if only one recipe image
		if ( recipe.images.length <= 1 )
		{
			return;
		}
		
		// Make sure previous arrow is enabled
		pageRight.enabled = true;
		
		// Decrement position
		m_imageIdx--;
		
		// If we're at the first image, disable the left arrow
		if ( m_imageIdx == 0 )
		{
			pageLeft.enabled = false;
		}
		
		// Display new image
		displayDatabaseImage( recipe, m_imageIdx );
	}
	
	private function pageRight():Void
	{
		var recipe:Recipe = FlowController.data.selectedRecipe;
		var pageRight:GraphicButton = cast getChildByName( "btn_pageRight" );
		var pageLeft:GraphicButton = cast getChildByName( "btn_pageLeft" );
		
		// Early return if only one recipe image
		if ( recipe.images.length <= 1 )
		{
			return;
		}
		
		// Make sure previous arrow is enabled
		pageLeft.enabled = true;
		
		// Increment position
		m_imageIdx++;
		
		// If we're at the first image, disable the left arrow
		if ( m_imageIdx >= recipe.images.length - 1 )
		{
			pageRight.enabled = false;
		}
		
		// Display new image
		displayDatabaseImage( recipe, m_imageIdx );
	}
	
	// ===================================
	// Scroll setup 
	// ===================================
	
	private function addIngredientData()
	{
		var recipe:Recipe = FlowController.data.selectedRecipe;
		
		for ( ingredient in recipe.ingredients )
		{
			var label:String; 
			var buttonImg:Bitmap;
			
			if (Tunables.USE_DATABASE_RESOURCES)
			{
				label = ingredient.name;
			}
			else
			{
				label = ingredient.amount + "- " + ingredient.unit + " " + ingredient.name; 
			}
			
			if ( ingredient.spotlight != "" )
			{
				buttonImg = ResMan.instance.getImage( "2d/Buttons/btn_info_up" );
			}
			else
			{
				buttonImg = ResMan.instance.getImage( "2d/Buttons/btn_checkSmall_up" );
				// TODO button.enabled = false; // Check "buttons" are not interactable.
			}
			
			m_ingredientsMenu.addData( null, buttonImg, null, label );
		}
	}
	
	private function addToolData()
	{
		var recipe:Recipe = FlowController.data.selectedRecipe;
		for ( tool in recipe.tools )
		{
			// Button
			var buttonImg:Bitmap;
			if ((tool.URL == null) || (tool.URL == ""))
			{
				buttonImg = ResMan.instance.getImage( "2d/Buttons/btn_store_disabled", false );
			}
			else
			{
				buttonImg = ResMan.instance.getImage( "2d/Buttons/btn_store_up", false );
			}
			
			// Label to display the tool name 
			var label:String;
			label = tool.name;
			var toolRef1:DisplayObjectContainer = cast getChildByName( "group_tool1" );
			var refLabel:TextField = cast toolRef1.getChildByName( "lbl_tool1" );
			m_toolsMenu.addData( null, buttonImg, null, label );
		}
	}
	
	// ===================================
	// Menu setup
	// ===================================
	
	/**
	 * Updates the image 
	 * @param	image
	 */
	private function updateRecipeImage(newRecipeImg:Bitmap):Void
	{
		if (m_recipeImage != null)
		{
			removeChild(m_recipeImage);
			m_recipeImage = null;
		}
		
		var paistImg:OPSprite = cast getChildByName( "recipeImage" );
		paistImg.visible = false;
		var paistWidth:Float = paistImg.width;
		var paistHeight:Float = paistImg.height;
		
		m_recipeImage = new OPSprite(newRecipeImg);
		addChild(m_recipeImage);
		
		var imageScaleW:Float = paistWidth / newRecipeImg.width;
		var imageScaleH:Float = paistHeight / newRecipeImg.height;
		
		if ( m_recipeImage.width >= m_recipeImage.height )
		{
			m_recipeImage.scaleX = imageScaleW;
			m_recipeImage.scaleY = imageScaleW;
		}
		else if ( m_recipeImage.height > newRecipeImg.width )
		{
			m_recipeImage.scaleX = imageScaleH;
			m_recipeImage.scaleY = imageScaleH;
		}
		
		m_recipeImage.x = paistImg.x;
		m_recipeImage.y = paistImg.y;
	}
	
	// ===================================
	// Button interaction 
	// ===================================
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		var recipe:Recipe = FlowController.data.selectedRecipe;
		
		WebAudio.instance.play( "SFX/button_click" );	

		if ( caller.name == "btn_favorite" )
		{			
			if ( SpeckGlobals.dataManager.hasFavorite( recipe ) )
			{				
				// If already favorited, toggle to up state
				caller.upState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				
				// Remove from favorites list
				SpeckGlobals.dataManager.removeFavorite( recipe );
			}
			else
			{				
				// If not already favorited, toggle to down state
				caller.upState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				
				// Add to favorites list
				SpeckGlobals.dataManager.addFavorite( recipe );
			}
			
		}
		else if ( caller.name == "btn_pageLeft" )
		{
			pageLeft();
		}
		else if ( caller.name == "btn_pageRight" )
		{
			pageRight();
		}
	}
	
	private function onIngredientHit( ?caller:GraphicButton ):Void
	{
		WebAudio.instance.play( "SFX/button_click" );	
		
		// Go to the ingredient info state
		var selectedIngredient:Ingredient = SpeckGlobals.dataManager.allIngredients.get( caller.name );
		if ( selectedIngredient.spotlight != "" )
		{
			StateManager.setState( GameState.INGREDIENTINFO,  { args: [ GameState.RECIPEINGREDIENTS, selectedIngredient] } );
		}
	}
	
	private function onToolHit( ?caller:GraphicButton ):Void
	{
		WebAudio.instance.play( "SFX/button_click" );	
		
		for ( tool in FlowController.data.selectedRecipe.tools)
		{
			if ( tool.name == caller.name )
			{
				goToUrl( tool.URL );
				return;
			}
		}
	}
	
	private function goToUrl( URL:String ):Void
	{
		StateManager.setState( GameState.PARENTAL, { args: [ GameState.RECIPEINGREDIENTS, URL] } );
	}
	
	/**
	 *  Reparents scroll masks that add an artificial "fade" effect
	 */
	private function reparentScrollMasks()
	{
		var ingredTop:OPSprite = cast getChildByName( "pnl_ingredient_top" );
		ingredTop.mouseEnabled = false;
		ingredTop.mouseChildren = false;
		addChildAt( ingredTop, this.numChildren );
		
		var toolTop:OPSprite = cast getChildByName( "pnl_tools_top" );
		toolTop.mouseEnabled = false;
		toolTop.mouseChildren = false;
		addChildAt( toolTop, this.numChildren );
		
		var toolRibbon:OPSprite = cast getChildByName( "spr_header_ribbon" );
		var toolText:OPSprite = cast getChildByName( "spr_header_tools" );
		var ingredRibbon:OPSprite = cast getChildByName( "spr_header_ribbon_ingredients" );
		var ingredText:OPSprite = cast getChildByName( "spr_header_ingredients" );
		
		addChildAt( toolRibbon, this.numChildren );
		addChildAt( toolText, this.numChildren );
		addChildAt( ingredRibbon, this.numChildren );
		addChildAt( ingredText, this.numChildren );
		
	}
	
	// ===================================
	// Exit handling
	// ===================================
	override public function dispose() 
	{
		 // todo
	}
}
