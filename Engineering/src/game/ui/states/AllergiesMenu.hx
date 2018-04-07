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
import com.firstplayable.hxlib.state.StateManager;
import game.Ingredient;
import game.def.GameState;
import game.ui.VirtualScrollingMenu;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

/*
 * ALLERGENS MENU - Allows user to mark off certain ingredients to filter recipes that contain them from the app. 
 * Button names are made to match ingredient names to prevent costly ingredient lookup onButtonHit. 
 * 
 * NOTE: Nomenclature - add/remove refers to an item being added or removed from the global allergens list (see: DataManager.hx)
 * NOTE: Nomenclature - a "toggled" button is one that has been pressed to the "down" state. 
 * 			When a button is toggled, it is marked "unsafe", and added to the allergens list.
 * */

class AllergiesMenu extends SpeckMenu
{	
	// ------ Member vars:	
	private var m_toggledState:Map< String, Bool >; // 	Maps an ingredient name to a "toggled" status - <up/false/safe> or <down/true/unsafe>
	private var m_scrollMenu:VirtualScrollingMenu;
	
	public function new() 
	{
		super( "AllergiesMenu" );
		
		// ---------------------------------------------------
		// Init button toggle tracker
		// ---------------------------------------------------
		m_toggledState = new Map();
		for ( ingredient in SpeckGlobals.dataManager.allIngredients )
		{
			m_toggledState.set( ingredient.name, false );
		}
		
		// ---------------------------------------------------
		// Set up scrolling
		// ---------------------------------------------------
		var refGroup1:DisplayObjectContainer = cast getChildByName( "ingredient1" );
		var refGroup2:DisplayObjectContainer = cast getChildByName( "ingredient2" );
		var scrollBounds:OPSprite = cast getChildByName( "spr_scrollBounds" );
		var scrollBar:OPSprite = cast getChildByName( "scrollHandle" );
		var scrollTrack:OPSprite = cast getChildByName( "spr_scrollBacking" );
		m_scrollMenu = new VirtualScrollingMenu( scrollBounds, Orientation.VERTICAL, refGroup1, refGroup2, scrollBar, scrollTrack );
		
		addScrollingData();
		this.addChild( m_scrollMenu );
		
		m_scrollMenu.init();
		
		reparentScrollMasks();
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		WebAudio.instance.play( "SFX/button_click" );	

		if ( caller.name == "btn_confirm" )
		{
			// Go to confirmation screen
			StateManager.setState( GameState.ALLERGIESCONFIRM );
		}
		else if ( caller.name == "btn_cancel" )
		{
			// Return to settings menu
			StateManager.setState( GameState.GLOBE );
		}
		else
		{
			trace( caller.name );
			
			SpeckGlobals.dataManager.allIngredients.get( caller.name );
			var toggled:Bool = m_toggledState.get( caller.name );
			var ingredient:Ingredient = SpeckGlobals.dataManager.allIngredients.get( caller.name );
			var unsafe:Bitmap = ResMan.instance.getImage( "2d/Buttons/btn_x_up" );
			var safe:Bitmap = ResMan.instance.getImage( "2d/Buttons/btn_checkSmall_up" );
			
			// Flip the button state
			m_toggledState.set( caller.name, !toggled );
			
			// Flip button image
			if ( toggled )
			{
				trace( caller.name + " marked safe" );
				SpeckGlobals.dataManager.removeAllergen( ingredient );
				caller.changeImage( safe );
			}
			else
			{
				trace( caller.name + " marked unsafe" );
				SpeckGlobals.dataManager.addAllergen( ingredient );
				caller.changeImage( unsafe );
			}
		}
	}
	
	private function addScrollingData():Void
	{
		var unsafe:Bitmap = ResMan.instance.getImage( "2d/Buttons/btn_x_up" );
		var safe:Bitmap = ResMan.instance.getImage( "2d/Buttons/btn_checkSmall_up" );
		
		for (ingredient in SpeckGlobals.dataManager.allIngredients)
		{
			var label:String = ingredient.name; 
			var buttonImg:Bitmap = null;
			
			if ( SpeckGlobals.dataManager.hasAllergen( ingredient ) )
			{
				m_toggledState.set( ingredient.name, true );
				buttonImg = unsafe;
			}
			else
			{
				m_toggledState.set( ingredient.name, false );
				buttonImg = safe;
			}
			
			m_scrollMenu.addData( null, buttonImg, null, label );
		}
	}
	
	/**
	 *  Reparents scroll masks that add an artificial "fade" effect
	 */
	private function reparentScrollMasks()
	{
		var top:OPSprite = cast getChildByName( "pnl_allergens_top" );
		top.mouseEnabled = false;
		top.mouseChildren = false;
		addChildAt( top, this.numChildren );
		
		var cancel:GraphicButton = cast getChildByName( "btn_cancel" );
		var confirm:GraphicButton = cast getChildByName( "btn_confirm" );
		addChildAt( cancel, this.numChildren );
		addChildAt( confirm, this.numChildren );
		
		var ribbon:OPSprite = cast getChildByName( "spr_header_ribbon" );
		var text:OPSprite = cast getChildByName( "spr_header" );
		
		addChildAt( ribbon, this.numChildren );
		addChildAt( text, this.numChildren );
		
	}
}