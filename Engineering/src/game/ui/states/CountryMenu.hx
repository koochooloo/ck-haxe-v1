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
import com.firstplayable.hxlib.state.StateManager;
import com.firstplayable.hxlib.StringToolsX;
import game.cms.Grade;
import game.cms.Question;
import game.cms.QuestionDatabase;
import game.controllers.FlowController;
import game.def.DemoDefs;
import game.def.GameState;
import game.net.NetAssets;
import game.ui.SpeckMenu;
import game.ui.VirtualScrollingMenu;
import game.utils.URLUtils;
import haxe.ds.Option;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
using StringTools; 

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

// A group of collected DisplayObjects that make up a "button"
//		IE - The parent panel, the label, the button itself, and a country object associated with it. 
typedef CountryGroup =
{
	panel:DisplayObjectContainer,
	label:TextField,
	button:GraphicButton,
	country:Country
}

/*
 * Handles the country selection menu, and the country information popup that follows it.
 * Hides/shows them appropriately, and passes along information to future menus about which country was selected.
 * Behaves as though it was part of the hud.
 * */
class CountryMenu extends SpeckMenu
{
	// ------ Static tunable vars:
	private static inline var PLACEHOLDER_BUTTON_SRC:String = "2d/Buttons/btn_country_up";
	private static inline var BAKED_BUTTON_SRC_PREFIX:String = "2d/UI/countries/flag_";
	private static inline var COMING_SOON_ALPHA:Float = 0.7;

	// ------ Member vars:
	private var m_countryListPanel:DisplayObjectContainer;
	private var m_scrollMenu:VirtualScrollingMenu;
	private var DEFAULT_SEARCH:String;
	private var m_fromGlobe = false;
	
	private var m_accessibleCountries:Array< Country >;
	private var m_comingSoonCountries:Array< Country >;
	private var m_offset:Float; // Offset for spacing out the new button placement 

	
	public function new() 
	{
		super( "CountryMenu" );

		// ---------------------------------------------------
		// Grab country list menu container from paist
		// ---------------------------------------------------
		m_countryListPanel = cast getChildByName( "group_countryPanel" );
		
		// ---------------------------------------------------
		// Rotate speech bubble
		// --------------------------------------------------- 
		var popupPanel:DisplayObjectContainer = cast getChildByName( "popup_about" );
		var bubble:OPSprite = cast popupPanel.getChildByName( "bubble" );
		bubble.scaleX *= -1;
		bubble.x += bubble.width; 
		
		// ---------------------------------------------------
		// Set up search bar
		// --------------------------------------------------- 
		var searchBar:OPSprite = cast getChildByName( "ui_cSearch" );
		var searchText:TextField = cast getChildByName( "lbl_cSearch" );
		
		DEFAULT_SEARCH = searchText.text;
		searchText.selectable = true;
		searchText.type = TextFieldType.INPUT;
		searchText.addEventListener( Event.CHANGE, onTextUpdate );
		searchText.addEventListener( FocusEvent.FOCUS_IN, onFocusIn );
		searchText.addEventListener( FocusEvent.FOCUS_OUT, onFocusOut );
		
		// ---------------------------------------------------
		// Set up scroll menu
		// ---------------------------------------------------
		var paistGroup1:DisplayObjectContainer = cast getChildByName( "grp_country3" );
		var paistGroup2:DisplayObjectContainer = cast getChildByName( "grp_country4" );
		
		// Unique to country menu - groups needs to be children of the list submenu so they can fade in/out properly.
		// Because paist only allows one layer of nesting, we create the groups here.
		var refGroup1:DisplayObjectContainer = getRefGroup( paistGroup1, 1 );
		var refGroup2:DisplayObjectContainer = getRefGroup( paistGroup2, 2 );
		
		var scrollBounds:OPSprite = cast getChildByName( "spr_scrollBounds" );
		var scrollBar:OPSprite = cast getChildByName( "scrollHandle" );
		var scrollTrack:OPSprite = cast getChildByName( "spr_scrollBacking" );
		m_scrollMenu = new VirtualScrollingMenu( scrollBounds, Orientation.VERTICAL, refGroup1, refGroup2, scrollBar, scrollTrack  );
	
		sortCountries();
		m_countryListPanel.addChild( m_scrollMenu );
		buildCountryList( DEFAULT_SEARCH );
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
		
		// Country list X button: return to main menu 
		if ( caller.name == "countriesQuit" ) 
		{
			SpeckGlobals.hud.mainMenuRef.resetGlobe();
			SpeckGlobals.hud.toggleSubMenu( this, false );
		}
		// Chef K popup X button: return to globe/country list
		else if ( caller.name == "btn_x" ) 
		{
			// Handle submenu + asset visibility
			toggleChef( false ); // Hide the character popup
			toggleCountryLock( false );	// Hide the country lock
			
			// Reset globe position
			SpeckGlobals.hud.mainMenuRef.resetGlobe();	

			// If we came from the country list, show it
			if ( !m_fromGlobe )
			{
				toggleCountryList( true );
			}
			// Otherwise, return to the splash menu
			else
			{
				m_fromGlobe = false;
				StateManager.setState( GameState.GLOBE );
			}
		}
		// Chef K popup check button: progress to country flow
		else if ( caller.name == "btn_check" ) 
		{
			// Handle submenu visibility
			var popupPanel:DisplayObjectContainer = cast getChildByName( "popup_about" );
			SpeckGlobals.hud.toggleSubMenu( popupPanel, false ); // Hide chef
			SpeckGlobals.hud.toggleSubMenu( m_countryListPanel, true ); // Show country list so it fades in next time we access this parent menu
			SpeckGlobals.hud.toggleSubMenu( this, false ); // Hide this parent menu, obscuring the country list
			
			// Handle flow - progress to next stage
			FlowController.goToNext(); 	

		}
		// Country flag button - show & edit popup with selected data
		else  
		{
			// Get the country from the button name 
			var country:Country = SpeckGlobals.dataManager.getCountry( caller.name );
			
			// Set new country param for flow
			FlowController.data.selectedCountry = country;
			
			// Show Chef K, hide country menu
			toggleCountryList( false );
			toggleChef( true, country );
			
			// Show lock screen and prevent button interaction if we have insufficient country data
			toggleCountryLock( !haveCountryData( country ) );
			
			// Adjust globe - country menu is present on the main menu
			SpeckGlobals.hud.mainMenuRef.focusInCountry( country.code );
			
			WebAudio.instance.play( "SFX/country1_click" );
			
			return;
		}
		
		WebAudio.instance.play( "SFX/button_click" );
	}
	
	//=============================================
	// Menu display
	//=============================================
	
	/**
	 * Toggles the scrolling country list
	 */
	public function toggleCountryList( show:Bool ):Void
	{
		if ( show )
		{
			SpeckGlobals.hud.toggleSubMenu( m_countryListPanel, true );
		}
		else
		{
			SpeckGlobals.hud.toggleSubMenu( m_countryListPanel, false );
		}
	}
	
	/**
	 * Toggles Chef K country info popup
	 */
	public function toggleChef( show:Bool, ?selectedCountry:Country ):Void
	{
		// Get paist assets 
		var popupPanel:DisplayObjectContainer = cast getChildByName( "popup_about" );
		var dialogue:TextField = cast popupPanel.getChildByName( "lbl_about" );
				
		if ( show && selectedCountry != null )
		{
			popupPanel.visible = true;
			SpeckGlobals.hud.toggleSubMenu( popupPanel, true );
			
			// Update dialogue
			var pop:String = StringToolsX.commaFormat(selectedCountry.population);
			var about:String = capitalize( selectedCountry.name ) + "'s capital city is " + selectedCountry.capital + 
				   ". The population is " + pop + ".";
			dialogue.text = about;
		}
		else
		{
			SpeckGlobals.hud.toggleSubMenu( popupPanel, false );
		}
	}
	
	/**
	 * Toggles "Coming soon!" lock asset and associated button interaction
	 */
	private function toggleCountryLock( visible:Bool ):Void
	{
		// Toggle "coming soon" lock visibility
		var popupPanel:DisplayObjectContainer = cast getChildByName( "popup_about" );
		var lock:GraphicButton = cast popupPanel.getChildByName( "btn_comingSoon" );
		lock.visible = visible;
		
		// Check button visibility is opposite that of the lock button
		//		If lock is visible, check is hidden to prevent user progression.
		var check:GraphicButton = cast popupPanel.getChildByName( "btn_check" );
		check.visible = !visible;
	}
	
	/**
	 * Returns true if there is sufficient data for the country. 
	 * TODO: DETERMINE DATA PREFERENCES. This currently filters by demo countries.
	 */ 
	private function haveCountryData( country:Country ):Bool
	{
		#if debug
		// TODO TEMPORARY - allow all Demos viewers to view all countries (HTML5)
		if ( URLUtils.didProvideURL( "demos.1stplayable.com" ) )
		{
			return true;
		}
		#end
		
		// Check if there is question data for the country (pilot flow)
		var hasQuestions:Bool;
		if ( FlowController.currentMode == FlowMode.PILOT )
		{
			var grade:Grade = switch ( SpeckGlobals.teacher )
			{
				case Option.Some( t ):  t.grade;
				case None:	Grade.FIRST; // Arbitrary default?
			}
			
			var questionSet:Array< Question > = QuestionDatabase.instance.query().aboutCountry( country.name ).forGrade( grade ).finish();
			hasQuestions = questionSet.length > 0;

			if ( hasQuestions)
			{
				// Grab question week for sorting.
				// ASSUMES ALL QUESTIONS FOR A GIVEN COUNTRY SHARE THE SAME CURRICULAR WEEK.
				switch ( questionSet[0].week ) 
				{
					case Some( num ): country.pilotWeek = num;
					case None: Debug.log( "No pilot week for " + country.name );
				}
			}

		}
		else // Consumer mode
		{
			hasQuestions = true;
		}
		
		// Check if the country has recipes
		var hasRecipes:Bool = country.recipes.length > 0;
		return hasQuestions && hasRecipes;
	}

	public function displayPopupFromGlobe():Void
	{	
		m_countryListPanel.visible = false;
		toggleCountryList( false );
		toggleChef( true, FlowController.data.selectedCountry );
		toggleCountryLock( !haveCountryData( FlowController.data.selectedCountry ) );
		
		// Flag that we came from globe interaction so we know how to exit the character menu
		//		( If the country is selected from the globe, it shouldn't return to the country list)
		m_fromGlobe = true;
		
		// Set appropriate consumer path if we are in the consumer flow mode.
		if ( FlowController.currentMode == FlowMode.CONSUMER )
		{
			FlowController.setPath( FlowPath.CONSUMER_COUNTRY );
		}
	}

	//=============================================
	// Search functionality
	//=============================================
	
	// Update display list as user is typing
	private function onTextUpdate( e:Event ):Void 
	{
		var searchTerms:TextField = cast e.target; 
		buildCountryList( searchTerms.text );
	}
	
	// Hide default "search" text when the user clicks the search bar
	private function onFocusIn( e:FocusEvent ):Void
	{
		var searchTerms:TextField = cast e.target; 
		if ( searchTerms.text == DEFAULT_SEARCH )
		{
			searchTerms.text = "";
		}
	}
	
	// Show default "search" text when the user clicks away from the search bar
	private function onFocusOut( e:FocusEvent ):Void
	{
		var searchTerms:TextField = cast e.target; 
		if ( searchTerms.text == "" )
		{
			searchTerms.text = DEFAULT_SEARCH;
		}
	}
	
	// Reset search/country list when closing menu
	public function resetSearch():Void
	{
		var searchText:TextField = cast getChildByName( "lbl_cSearch" );
		searchText.text = DEFAULT_SEARCH;
		buildCountryList( searchText.text );
	}
	
	//=============================================
	// Scroll helpers
	//=============================================
	
	/**
	 * Sort countries and add data to the scrolling menu
	 */
	private function buildCountryList( filter:String ):Void
	{	
		m_scrollMenu.reset();
		addCountryData( filter, m_accessibleCountries, false );
		addCountryData( filter, m_comingSoonCountries, true );
		m_scrollMenu.reInit();
		
		reparentScrollMasks();
	}
	
	/**
	 * Sort countries into two lists based on availability, then alphabetize them.
	 */ 
	private function sortCountries():Void
	{
		m_accessibleCountries = new Array();
		m_comingSoonCountries = new Array();
		
		for ( country in SpeckGlobals.dataManager.allCountries )
		{
			if ( haveCountryData( country ) )
			{
				m_accessibleCountries.push( country );
			}
			else
			{
				m_comingSoonCountries.push( country ); 
			}
		}
		
		// Sort lists alphabetically if in consumer flow
		if ( FlowController.currentMode == FlowMode.CONSUMER )
		{
			m_accessibleCountries.sort( Country.sortAlpha );
		}
		// Sort the accessible countries list by pilot week if in pilot flow
		else if ( FlowController.currentMode == FlowMode.PILOT )
		{
			m_accessibleCountries.sort( Country.sortWeek );
		}
		
		// Always sort "COMING SOON!" countries alphabetically
		m_comingSoonCountries.sort( Country.sortAlpha );			

	}
	
	/**
	 * Creates a display object container for scroll reference, from paist reference 
	 * Specifically copies DOC with textfield and button children
	 */
	private function getRefGroup( paistGroup:DisplayObjectContainer, itemNum:Int ):DisplayObjectContainer
	{
		var newGroup:DisplayObjectContainer = new DisplayObjectContainer();
		m_countryListPanel.addChild( newGroup );
		
		var paistLocRef:DisplayObject = cast m_countryListPanel.getChildByName( "btn_group_country" + itemNum );
		newGroup.x = paistLocRef.x;
		newGroup.y = paistLocRef.y;

		var paistButton:GraphicButton = cast paistGroup.getChildByName( "btn_country" + (itemNum + 2) );
		var paistLabel:TextField = cast paistGroup.getChildByName( "countryName" + (itemNum + 2) );
		
		newGroup.addChild( paistButton );
		newGroup.addChild( paistLabel );
		
		var newButton:GraphicButton = cast newGroup.getChildByName( "btn_country" + (itemNum + 2) );

		return newGroup;
	}
	
	/** 
	 * Get flags and country labels for the scrolling items
	 * */
	private function addCountryData( filter:String, list:Array<Country>, comingSoon:Bool ):Void
	{
		for ( country in list )
		{
			var hasFilter:Bool = (filter == DEFAULT_SEARCH) || (country.name.toLowerCase().indexOf( filter.toLowerCase() ) >= 0); 
			
			if ( hasFilter )
			{
				// ---------------------------------------------------
				// Set button label
				// ---------------------------------------------------
				var label:String = capitalize( country.name );
				
				// ---------------------------------------------------
				// Get button
				// ---------------------------------------------------
				var btnSrc:Bitmap = null;
				if (Tunables.USE_DATABASE_RESOURCES)
				{
					NetAssets.instance.getImage(country.flagImage, function(newImage:Bitmap){ // Grab flag image from database
						btnSrc = newImage;
					});
				}
				if ( btnSrc == null ) // If no db image or not using db images
				{
					var countryFileName:String = StringTools.replace(country.name, " ", "_");
					btnSrc = ResMan.instance.getImageUnsafe( BAKED_BUTTON_SRC_PREFIX + countryFileName ); // Use baked assets
					if ( btnSrc == null )
					{
						btnSrc = ResMan.instance.getImage( PLACEHOLDER_BUTTON_SRC ); // Use placeholder if no baked asset
					}
				}
				
				m_scrollMenu.addData( null, btnSrc, null, label );
			}
		}
	}
	
	/**
	 *  Reparents scroll masks that add an artificial "fade" effect
	 */
	private function reparentScrollMasks()
	{
		var top:OPSprite = cast m_countryListPanel.getChildByName( "countryPanel_top" );
		top.mouseEnabled = false;
		top.mouseChildren = false;
		m_countryListPanel.addChildAt( top, m_countryListPanel.numChildren );
		
		var quit:GraphicButton = cast m_countryListPanel.getChildByName( "countriesQuit" );
		m_countryListPanel.addChildAt( quit, m_countryListPanel.numChildren );
	}
	
	override public function dispose()
	{
		m_countryListPanel = null;
		m_scrollMenu.reset();
		m_accessibleCountries = [];
		m_comingSoonCountries = [];
	}
}