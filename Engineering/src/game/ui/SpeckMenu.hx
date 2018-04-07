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

package game.ui;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GenericMenu;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.def.GameState;
import game.ui.login.StudentIdConfirmation;
import game.ui.login.TeacherIdConfirmation;
import game.ui.states.passport.PassportBook;
import game.ui.states.passport.PassportStamp;
import lime.ui.MouseCursor;
import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.text.TextField;

using StringTools;
/*
 * Base menu class for pumbaa
 */
class SpeckMenu extends GenericMenu 
{
	public function new(menuName:String) 
	{
		super(menuName);
		
		addEventListener( Event.ADDED_TO_STAGE, init );
		
	}
	
	/**
	 * Handles when a menu is first added to screen
	 * Do not override
	 */
	private function init( e:Event ):Void
	{
		removeEventListener( Event.ADDED_TO_STAGE, init );
		
		onInit(e);
		
		onAddedToStage(e);
	}
	
	/**
	 * Functionality for when a menu is first added to the stage
	 * @param e Event
	 */
	private function onInit( e:Event )
	{
		//Override to add custom functionality
	}
	
	/**
	 * Functionality for whenever a menu is added to the stage
	 * @param e Event
	 */
	private function onAddedToStage( e:Event ):Void
	{
		hideMenu();
		showMenu();
		
		// Button cursor is a pointing hand. 
		// Checks two levels of nested kids. TODO recursion?
		updateButtonPointer( this );
		for ( child in this.__children ) updateButtonPointer( child );
		
		removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
		//Override to add custom functionality
	}
	
	/**
	 * Functionality for whenever a menu is removed from the stage
	 * @param e Event
	 */
	private function onRemovedFromStage( e:Event ):Void
	{
		removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		
		dispose();
		//Override to add custom functionality
	}
	
	// -------------------------------
	// Fade transition  functionality 
	// -------------------------------
	
	public function showMenu():Void
	{
		if ( !tweenable() ) 
		{
			return;
		}

		for ( child in this.__children )
		{
			if ( child.visible ) // Don't show items hidden in the paist menu
			{
				Actuate.tween(child, SpeckGlobals.FADE_TIME, { alpha: 1 } ).onComplete( Actuate.stop, [ child ] );
			}

		}
	}
	
	public function hideMenu():Void
	{
		if ( !tweenable() ) 
		{
			return;
		}

		for ( child in this.__children )
		{
			if (child.visible)
			{
				child.alpha = 0;
			}
		}
	}
	
	private function tweenable():Bool
	{
		var main:Bool = (	this.menuName == "MainMenu" 
							|| this.menuName == "Hud" 
							|| this.menuName == "CountryMenu" 
							|| this.menuName == "SplashMenu" 
							|| this.menuName == "TutorialMenu"
							|| this.menuName == PassportStamp.MENU_NAME
							|| this.menuName == PassportBook.MENU_NAME
						);
		var confirmation:Bool = (
									this.menuName == TeacherIdConfirmation.LAYOUT
									|| this.menuName == StudentIdConfirmation.LAYOUT
								);
		
		return ( !main && !confirmation);
	}

	private function updateButtonPointer( parent:DisplayObject )
	{
		if ( parent.__children == null )
		{
			return;
		}
		
		for ( child in parent.__children )
		{
			if ( Std.is(child, GraphicButton) )
			{
				var sprite:OPSprite = cast child;
				sprite.cursor = MouseCursor.POINTER;
			}			
		}
	}
	
	/**
	 * Capitalize strings for titles and labels
	 * ( Added since recipe & ingredient info are stored in lowercase.)
	 */
	public function capitalize( string:String ):String
	{
		var substrings:Array<String> = string.split( " " );
		var title:String = "";
		for ( substring in substrings )
		{
			var firstChar = substring.charAt( 0 ).toUpperCase();
			var restOfWord = substring.substring( 1 );
			var newStr:String = firstChar + restOfWord + " ";
			title += newStr;
		}
		
		return title.trim();
	}
	
	/**
	 *  To override for cleanup; invoked on removed from stage
	 */
	public function dispose():Void
	{
		
	}
}