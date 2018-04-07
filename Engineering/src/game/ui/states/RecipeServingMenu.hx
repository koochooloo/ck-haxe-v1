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
import assets.Gamestrings;
import assets.SoundLib;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.controllers.FlowController;
import game.def.GameState;
import game.Country;
import game.Recipe;
import game.net.NetAssets;
import game.ui.SpeckMenu;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.display.Bitmap;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.state.StateManager;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

class RecipeServingMenu extends SpeckMenu
{
	private var m_recipeImage:OPSprite;
	private var m_imageIdx:Int; // Position in recipe image array
	
	public function new( p:GameStateParams ) 
	{
		super( "RecipeServingMenu" );
		
		m_recipeImage = null;
		
		var recipe:Recipe = FlowController.data.selectedRecipe;
		
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
		
		// ---------------------------------------------------
		// Rotate speech bubble
		// ---------------------------------------------------
		var bubble:OPSprite = cast getChildByName( "bubble" );
		bubble.scaleX *= -1;
		bubble.x += bubble.width;
		
		
		//-----------------------------------------------
		// Hide favorites button if not in consumer flow
		//-----------------------------------------------
		var fav:GraphicButton = cast getChildByName( "btn_favorite" );
		if ( FlowController.currentMode == FlowMode.CONSUMER )
		{	
			fav.visible = true;
			fav.alpha = 1;
			
			// Set up favorites button ( toggled/not )
			if ( SpeckGlobals.dataManager.hasFavorite( recipe ) )
			{
				fav.upState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
			}
			else
			{
				fav.upState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				fav.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
			}
		}
 
		//-----------------------------------------------
		// Edit menu text fields 
		//-----------------------------------------------
		var enjoy:TextField = cast getChildByName("lbl_enjoy");
		enjoy.text = FlowController.data.selectedCountry.wish;
		
		var instructions:TextField = cast getChildByName("lbl_instructions");
		instructions.text = recipe.presentation;
		instructions.autoSize = TextFieldAutoSize.LEFT;
		instructions.wordWrap = true;
		
		showMenu();
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
	
	public function release():Void
	{
		if (m_recipeImage != null)
		{
			removeChild(m_recipeImage);
			m_recipeImage = null;
		}
	}
	
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
		
		var xOffset:Float = paistWidth - paistImg.width;
		var yOffset:Float = paistHeight - paistImg.height;
		
		m_recipeImage = new OPSprite(newRecipeImg);
		addChild(m_recipeImage);
		
		var imageScaleW:Float = paistWidth / newRecipeImg.width;
		var imageScaleH:Float = paistHeight / newRecipeImg.height;
		
		if ( m_recipeImage.width >= m_recipeImage.height )
		{
			m_recipeImage.scaleX = imageScaleW;
			m_recipeImage.scaleY = imageScaleW;
			
			yOffset -= (m_recipeImage.width - m_recipeImage.height) / 2;
		}
		else if ( m_recipeImage.height > newRecipeImg.width )
		{
			m_recipeImage.scaleX = imageScaleH;
			m_recipeImage.scaleY = imageScaleH;
			
			xOffset -= (m_recipeImage.height - m_recipeImage.width) / 2;
		}
		
		m_recipeImage.x = paistImg.x - xOffset;
		m_recipeImage.y = paistImg.y - yOffset;
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		var recipe:Recipe = FlowController.data.selectedRecipe;
		var country:Country = FlowController.data.selectedCountry;
		
		if (caller.name == "btn_favorite" )
		{			
			if ( SpeckGlobals.dataManager.hasFavorite( recipe ) )
			{				
				// If already favorited, toggle to up state
				caller.upState 	 = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_up" );
				
				// Remove from favorites list
				SpeckGlobals.dataManager.removeFavorite( recipe );
			}
			else
			{
				// If not already favorited, toggle to down state
				caller.upState 	 = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				caller.downState = ResMan.instance.getImage( "2d/Buttons/btn_favorites_down" );
				
				// Add to favorites list
				SpeckGlobals.dataManager.addFavorite( recipe );
			}
		}
		else if (caller.name == "btn_twitter" || caller.name == "btn_fb" || caller.name == "btn_gplus")
		{
			var type = caller.name.substring( 4, caller.name.length );
			
			if ( type == "fb" ) 		socialMedia( SpeckGlobals.gameStrings.get( "SOCIALMEDIA_FACEBOOK" ));
			if ( type == "twitter" )	socialMedia( SpeckGlobals.gameStrings.get( "SOCIALMEDIA_TWITTER" ));
			if ( type == "gplus" ) 		socialMedia( SpeckGlobals.gameStrings.get( "SOCIALMEDIA_GOOGLEPLUS" ));
		}
		else if ( caller.name == "vo_enjoy" )
		{
			var soundURL:String = "SFX/Enjoy/" + country.code + "_EnjoyMeal";
			
			if ( SoundLib.SOUNDS.indexOf( soundURL ) >= 0 )
			{			
				WebAudio.instance.playVO( soundURL );
			}
			else
			{
				Debug.log( "No VO for " + country.name + " at " + soundURL );
			}
			
			return;
		}
		else if ( caller.name == "btn_pageLeft" )
		{
			pageLeft();
		}
		else if ( caller.name == "btn_pageRight" )
		{
			pageRight();
		}
		
		WebAudio.instance.play( "SFX/button_click" );	

	}
	private function socialMedia(URL:String):Void
	{
		StateManager.setState( GameState.PARENTAL, { args: [ GameState.RECIPESERVING, URL] } );
	}
}