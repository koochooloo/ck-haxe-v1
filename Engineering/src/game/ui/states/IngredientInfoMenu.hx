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
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.Ingredient;
import game.def.GameState;
import game.ui.SpeckMenu;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

class IngredientInfoMenu extends SpeckMenu
{
	private static var SCROLLWIDTH:Int = 580;
	private static var SCROLLHEIGHT:Int = 370; 
	
	public function new(p:GameStateParams) 
	{
		super( "IngredientInfoMenu" );
		
		// Params from Recipe Ingredients Menu: 
		// { args: [ GameState.RECIPEINGREDIENTS, selectedIngredient] } 
		trace( p );
		var ingredient:Ingredient = p.args[1];
		
		// Populate the ingredient spotlight text.
		var spotlight:TextField = cast getChildByName( "lbl_about" );
		spotlight.text = ingredient.spotlight;
		spotlight.autoSize = TextFieldAutoSize.LEFT;
		
		// Change scene title to ingredient title, capitalized
		var title:TextField = cast getChildByName( "lbl_ingredient" );
		
		var titleWords:Array< String > = ingredient.name.split( " " );
		var titleString:String = "";
		for ( word in titleWords )
		{
			word.substring( 0, 1 );
			titleString += word.substring( 0, 1 ).toUpperCase() + word.substring( 1, word.length ) + " ";
		}
		
		title.text = titleString;
		title.autoSize = TextFieldAutoSize.LEFT;
		
		// Disable info button
		var button:GraphicButton = cast getChildByName( "btn_info" );
		button.enabled = false;
		
		// Add text scrolling
		var ingredientText:TextField = cast getChildByName("lbl_about");
		var scrollMgr:TextScrollingManager = new TextScrollingManager( this, ingredientText, ingredientText.x, ingredientText.y, SCROLLWIDTH, SCROLLHEIGHT );
		this.addChild( scrollMgr );
		
		showMenu();
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		WebAudio.instance.play( "SFX/button_click" );	
		
		// In the current implementation, both buttons do the same thing: return to the Recipe Ingredients state.
		StateManager.setState( GameState.RECIPEINGREDIENTS );
	}
	
	private function toggleButtonEnabled( btnID:Int, enabled:Bool ):Void
	{
		var btn:GraphicButton = getButtonById( btnID );
		if ( btn != null )
		{
			btn.enabled = enabled;
		}
	}
	
}