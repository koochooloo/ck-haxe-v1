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
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.Recipe;
import game.controllers.FlowController;
import game.def.GameState;
import game.ui.ScrollingManager;
import game.ui.SpeckMenu;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;

using StringTools;

// A parent group that contains button elements. 
typedef FavoriteGroup =
{
	panel:DisplayObjectContainer,
	button:GraphicButton,
	remove:GraphicButton,
	label:TextField,
	image:OPSprite
}

class FavoritesMenu extends SpeckMenu
{
	// ------ Static tunable vars:
	// TODO - callback to pull from paist bounding box
	private static inline var SCROLLWIDTH:Float = 1100;
	private static inline var SCROLLHEIGHT:Float = 600;
	private static inline var DISPLAYNUM:Int = 6;
	
	// ------ Member vars:
	private var m_scrollMenu:ScrollingManager;
	private var m_paistGroups:Array< FavoriteGroup >;
	private static var DEFAULT_SEARCH:String;
	private var m_searchTerms:TextField;
	
	public function new() 
	{
		super( "FavoritesMenu" );
		
		// Get preset paist items for reference, and hide them
		m_paistGroups = getPaistReference();
		
		if ( SpeckGlobals.dataManager.favorites.length < 1 )
		{
			// Display default text if there are no favorites
			var noFav:TextField = cast getChildByName( "noFavoritesText" );
			noFav.text = "All your favourited recipes will be shown here as soon as you add them. :)";
			noFav.width = SCROLLWIDTH/2;
			noFav.height = SCROLLHEIGHT;
			noFav.wordWrap = true;
			noFav.visible = true;
		}
		else
		{
			// Set up scroll menu
			var bounds:DisplayObjectContainer = cast getChildByName( "scroll_bounds" );
			m_scrollMenu = new ScrollingManager( bounds.x, bounds.y, SCROLLWIDTH, SCROLLHEIGHT, this, "horizontal", DISPLAYNUM );
			
			// Initialize search bar 
			m_searchTerms = cast getChildByName( "lbl_rSearch" );
			trace( m_searchTerms.text );
			if ( DEFAULT_SEARCH == null ) 		
				DEFAULT_SEARCH = m_searchTerms.text;
			m_searchTerms.selectable = true;
			m_searchTerms.type = TextFieldType.INPUT;
			m_searchTerms.addEventListener( Event.CHANGE, onTextUpdate );
			m_searchTerms.addEventListener( FocusEvent.FOCUS_IN, onFocusIn );
			m_searchTerms.addEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
		
			// Display favorite recipes
			drawFavorites();
			
			// Initialize scroll menu
			m_scrollMenu.init();
			this.addChild( m_scrollMenu );
		}
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void
	{
		super.onButtonHit( caller );
				
		if ( caller.name == "btn_globe" )
		{
			// Return to the splash menu.
			StateManager.setState( GameState.GLOBE );
		}
		else if ( caller.name == "btn_x" )
		{					
			// Remove recipe from the favorites screen.
			// Get recipe from the parent panel name
			var r:Recipe = SpeckGlobals.dataManager.getRecipe( caller.parent.name );
			
			// Remove recipe from favorites
			SpeckGlobals.dataManager.removeFavorite( r );
			
			if ( SpeckGlobals.dataManager.favorites.length == 0 )
			{
				// Disable search menu
				m_searchTerms.type = TextFieldType.DYNAMIC;
				if ( m_searchTerms.hasEventListener( Event.CHANGE ) )			m_searchTerms.removeEventListener( Event.CHANGE, onTextUpdate );
				if ( m_searchTerms.hasEventListener( FocusEvent.FOCUS_IN ) )	m_searchTerms.removeEventListener( FocusEvent.FOCUS_IN, onFocusIn );
				if ( m_searchTerms.hasEventListener( FocusEvent.FOCUS_OUT )	)	m_searchTerms.removeEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
			}
			
			// Refresh recipes being displayed
			drawFavorites();
		}
		else
		{
			WebAudio.instance.play( "SFX/recipe_click" );
			
			// Get recipe from parent panel name
			var recipe:Recipe = SpeckGlobals.dataManager.getRecipe( caller.parent.name );
			
			// Go to recipe ingredients/tools page with appropriate data
			FlowController.data.selectedRecipe = recipe;
			FlowController.goToNext();
			
			return;
		}
		
		WebAudio.instance.play( "SFX/button_click" );	

	}
	
	// Adds favorited recipes to the scroll menu. 
	//		Refer to RecipesMenu for similar functionality/reference.
	private function drawFavorites():Void
	{
		// Clear scroll menu items list
		m_scrollMenu.clear();
		
		// Loop through favorites and place, using paist ref 
		var pos:Int = 0; // Loop through positions in the array of paist references
		var offset:Float = 0; // Increment every time we've looped through the whole pos list.
		
		for ( recipe in SpeckGlobals.dataManager.favorites )
		{
			var DEMONAME:String = StringTools.replace( recipe.name, " ", "_" );

			var filter = m_searchTerms.text;
			var hasFilter:Bool = ( filter == DEFAULT_SEARCH ) || ( recipe.name.toLowerCase().indexOf( filter.toLowerCase() ) >= 0 );
			
			if ( hasFilter )
			{
				var ref:FavoriteGroup = m_paistGroups[ pos ];
				
				var panel:DisplayObjectContainer = new DisplayObjectContainer();
				panel.x = ref.panel.x + offset;
				panel.y = ref.panel.y;
				panel.name = recipe.name;
				
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
				
				var img2:Bitmap = ResMan.instance.getImageUnsafe( "2d/UI/recipesLarge/recipe_" + DEMONAME + "_01" );
				if ( img2 == null ) // TEMP WHILE LACKING DATABASE HOOKUP - use placeholder if no recipe image
				{
					img2 = ResMan.instance.getImage( "2d/UI/recipesLarge/placeholder" );
				}
				var image:GraphicButton = new GraphicButton( img2, img2, img2, img2, null, onButtonHit ); 

				// Image is sized to keep the same dimensions, but scale up until it hits the dimensions.
				var imageScaleW:Float = ref.image.width / image.width;
				var imageScaleH:Float = ref.image.height / image.height;
				
				if ( image.width >= image.height )
				{
					image.scaleX = imageScaleW;
					image.scaleY = imageScaleW;
				
				}
				else if ( image.height > image.width )
				{
					image.scaleX = imageScaleH;
					image.scaleY = imageScaleH;
				}
				
				image.x = ref.image.getBounds( ref.panel ).x + image.width/2;
				image.y = ref.image.getBounds( ref.panel ).y + image.height/2;
				panel.addChild( image );
				image.name = "img_" + recipe.name;
				
				var img3:Bitmap = ResMan.instance.getImage( "2d/Buttons/btn_x_up" );
				var img3Over:Bitmap = ResMan.instance.getImage( "2d/Buttons/btn_x_over" );
				var remove:GraphicButton = new GraphicButton( img3, img3, img3Over, img3, null, onButtonHit ); 
				remove.x = ref.remove.x;
				remove.y = ref.remove.y;
				panel.addChild( remove );
				remove.name = "btn_x";
				
				this.addChild( panel );

				// Add to scroll menu
				m_scrollMenu.addItem( panel, button, remove);
				
				// Increment/loop position
				if ( pos == 5)
				{
					pos = 0;
					offset += SCROLLWIDTH - SCROLLWIDTH/4 ;
				}
				else
				{
					pos++;
				}
			}
		}
		
		showMask();
	}
	
	private function getPaistReference():Array< FavoriteGroup >
	{
		// Get paist reference
		var paistGroups:Array< FavoriteGroup > = new Array();
		
		for ( n in 1...DISPLAYNUM + 1)
		{
			var panel:DisplayObjectContainer = cast getChildByName( "group_favorite" + n );
			var remove:GraphicButton = cast panel.getChildByName( "btn_x" + n);
			var button:GraphicButton = cast panel.getChildByName( "btn_recipe" + n );
			var label:TextField = cast panel.getChildByName( "lbl_Name" + n);
			var image:OPSprite = cast panel.getChildByName( "image" + n);
			paistGroups.push( { panel: panel, button: button, remove: remove, label: label, image: image } );
			
			panel.visible = false; // Hide layout items
		}
		
		return paistGroups;
	}
	
	private function showMask():Void
	{
		m_scrollMenu.reparent();
	}
	
	private function onTextUpdate( e:Event ):Void 
	{
		drawFavorites();
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