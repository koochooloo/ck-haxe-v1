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
import Random;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import flash.display.DisplayObjectContainer;
import game.Country;
import game.DataManager;
import game.controllers.FlowController;
import game.def.DemoDefs;
import game.def.GameState;
import game.net.NetAssets;
import game.ui.SpeckMenu;
import openfl.display.Bitmap;
import openfl.text.TextField;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

using StringTools;

class FlagGameMenu extends SpeckMenu
{
	// ------ Static tunable vars:
	private static inline var FADE_ALPHA:Float = 0.5;
	private static inline var CORRECT:String = "That is correct!";
	private static inline var INCORRECT:String = "Try again!";
	
	private static inline var NUM_DISTRACTORS:Int = 3;
	
	// ------ Member vars:
	private var m_flags:Array< GraphicButton >;
	
	public function new( p:GameStateParams ) 
	{
		super( "FlagGameMenu" );
		
		// Initialize members
		m_flags = new Array();
		
		// Set up question text
		var dialogue:TextField = cast getChildByName( "lbl_flag" );
		var bubble:OPSprite = cast getChildByName( "ui_help" );
		dialogue.text = "Can you guess which of these flags belongs to " + capitalize( FlowController.data.selectedCountry.name ) + "?";
		bubble.scaleY *= -1;
		bubble.y += bubble.height * 0.75;
		
		// Set up answers
		if (Tunables.USE_DATABASE_RESOURCES)
		{
			drawAnswersFromDatabase();
		}
		else
		{
			drawAnswers(); 
		}
		
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		if ( caller.name == capitalize( FlowController.data.selectedCountry.name ) ) 
		{
			// Correct answer behavior
			
			WebAudio.instance.play( "SFX/quiz_true_click" );
			
			for ( flag in m_flags )
			{
				if ( flag != caller )
				{
					var panel:DisplayObjectContainer = cast getChildByName( "panel_flag" + flag.id );
					panel.alpha = FADE_ALPHA;
					flag.alpha = FADE_ALPHA;
					flag.enabled = false;
				}
			}
			
			for ( i in 0...4 )
			{
				// Display country names
				var panel:DisplayObjectContainer = cast getChildByName( "panel_flag" + (i + 1) );
				var label:TextField = cast panel.getChildByName( "countryName" + (i + 1) );
				label.visible = true;
			}
			
			// Display CA text 
			var dialogue:TextField = cast getChildByName( "lbl_flag" );
			dialogue.text = CORRECT;
			
			return;
		}
		else
		{
			// Incorrect answer behavior 
			
			WebAudio.instance.play( "SFX/quiz_false_click" );
			
			var panel:DisplayObjectContainer = cast getChildByName( "panel_flag" + caller.id );
			caller.alpha = FADE_ALPHA;
			panel.alpha = FADE_ALPHA;
			caller.enabled = false;
			
			// Display country name
			var label:TextField = cast panel.getChildByName( "countryName" + caller.id );
			label.visible = true;
			label.alpha = FADE_ALPHA;
		
			// Display IA text
			var dialogue:TextField = cast getChildByName( "lbl_flag" );
			dialogue.text = INCORRECT;
			
			return;
		}
		
		WebAudio.instance.play( "SFX/button_click" );	
	}
	
	private function drawAnswers():Void
	{
		var country:Country = FlowController.data.selectedCountry;
		
		// Arrays to collect images and to check against already selected images
		var flagImgs:Array< Bitmap > = new Array(); 
		var flagNames:Array< String > = new Array(); 
		
		// Get the current ( correct ) country flag image
		var flagName = StringTools.replace( country.name, "_", " " );
		var correctImg:Bitmap = ResMan.instance.getImage( "2d/UI/countries/flag_" + flagName ); 
		correctImg.name = country.name;
		flagImgs.push( correctImg );
		flagNames.push( correctImg.name );
		
		// Get three other country flag images
		var countryName:String = correctImg.name; 
		for ( i in 0...3 )
		{
			var n:Int = 0;
			
			while ( flagNames.indexOf( countryName ) >= 0 )
			{
				countryName = DemoDefs.DEMOCOUNTRIES[ n ]; // TODO: search dataManager.allCountries, randomize index
				n++; 
			}
			
			var imgName:String = StringTools.replace( countryName, " ", "_");
			var flagImg:Bitmap = ResMan.instance.getImage( "2d/UI/countries/flag_" + imgName );
			flagImg.name = capitalize( countryName );
			
			flagImgs.push( flagImg );
			flagNames.push( flagImg.name );
		}
		
		// Shuffle flags for randomized CA/IA positions
		Random.shuffle( flagImgs );
		
		// Replace the buttons in paist with the flag assets
		for ( i in 0...4 )
		{ 
			var panel:DisplayObjectContainer = cast getChildByName( "panel_flag" + (i + 1) );
			var panelImg:OPSprite = cast panel.getChildByName( "countryPanel" + (i + 1) );
			var img:OPSprite = cast panel.getChildByName( "country" + (i + 1) );
			var flag:GraphicButton = new GraphicButton( flagImgs[i], flagImgs[i], flagImgs[i], flagImgs[i], null, onButtonHit, (i + 1) );
			var label:TextField = cast panel.getChildByName( "countryName" + (i + 1) );
			panel.addChild( flag );
			flag.width = img.width;
			flag.height = img.height;
			flag.x = img.x + img.width/2;
			flag.y = img.y + img.height;
			flag.name = capitalize( flagImgs[i].name );
			m_flags.push( flag );
			label.text = capitalize( flag.name ); 
			label.visible = false;
			panel.alpha = 0;
		}
		
		showMenu();
	}
	
	private function drawAnswersFromDatabase():Void
	{
		var correctCountry:Country = FlowController.data.selectedCountry;
		
		var questionCountries:Array<Country> = [correctCountry];
		
		//======================================
		// Determine 3 random countries
		//======================================
		
		var countryList:Array<Country> = [];
		for (country in SpeckGlobals.dataManager.allCountries)
		{
			if (country.id == correctCountry.id)
			{
				continue;
			}
			
			countryList.push(country);
		}
		
		for (i in 0...NUM_DISTRACTORS)
		{
			var nextCountry:Country = Random.fromArray(countryList);
			questionCountries.push(nextCountry);
			countryList.remove(nextCountry);
		}
		
		questionCountries = Random.shuffle(questionCountries);
		
		//=======================================
		// Create the Flags for each of the countries
		//=======================================
		for (i in 0...(NUM_DISTRACTORS + 1))
		{
			var country:Country = questionCountries[i];
			
			//Set to the default image first
			var flagImg:Bitmap = ResMan.instance.getImage( "2d/UI/recipesLarge/loading");
			
			var panel:DisplayObjectContainer = cast getChildByName( "panel_flag" + (i + 1) );
			var panelImg:OPSprite = cast panel.getChildByName( "countryPanel" + (i + 1) );
			var img:OPSprite = cast panel.getChildByName( "country" + (i + 1) );
			var flag:GraphicButton = new GraphicButton( flagImg, flagImg, flagImg, flagImg, null, onButtonHit, (i + 1) );
			var label:TextField = cast panel.getChildByName( "countryName" + (i + 1) );
			panel.addChild( flag );
			flag.width = img.width;
			flag.height = img.height;
			flag.x = img.x + img.width/2;
			flag.y = img.y + img.height;
			flag.name = capitalize( country.name );
			//Disable the button until it's loaded
			flag.enabled = false;
			m_flags.push( flag );
			label.text = capitalize( flag.name ); 
			label.visible = false;
			panel.alpha = 0;
			
			//Try to load the flag from the database
			NetAssets.instance.getImage(country.flagImage, function(newImage:Bitmap){
				if (newImage == null)
				{
					newImage = ResMan.instance.getImage( "2d/Buttons/btn_country_up" );
				}
				
				flag.upState = newImage;
				flag.downState = newImage;
				flag.overState = newImage;
				flag.disabledState = newImage;
				
				flag.width = img.width;
				flag.height = img.height;
				
				flag.x -= flag.width / 2;
				flag.y -= flag.height;
				
				flag.enabled = true;
			});
		}
		
		showMenu();
	}
	
	override public function dispose()
	{
		m_flags = [];
	}
}