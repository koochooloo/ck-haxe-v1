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
import assets.SoundLib;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.display.SpriteBoxData;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.Country;
import game.cms.Question;
import game.cms.QuestionDatabase;
import game.cms.QuestionQuery;
import game.controllers.FlowController;
import game.def.GameState;
import game.net.NetAssets;
import game.ui.SpeckMenu;
import haxe.ds.Option;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.display.Bitmap;
import openfl.text.TextFieldAutoSize;

using StringTools;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

// A parent group that contains button elements. 
typedef CountryIntroGroup =
{
	panel:DisplayObjectContainer,
	label:TextField,
	button:GraphicButton,
	country:Country
}

class CountryIntroMenu extends SpeckMenu
{
	// ------ Static tunable vars:
	private static var TEXT_POS:Float;
	private static var SCROLLHEIGHT:Float;
	
	// ------ Member vars:
	private var m_factPos:Int; // Position in the paging list of facts
	private var m_VO:String; // Hello or Story VO, depending on which dataset we are using
	
	private var m_countryImage:OPSprite;
	
	public function new(p:GameStateParams)
	{
		super("CountryIntroMenu");
		
		var country:Country = FlowController.data.selectedCountry;
		
		var scrollBounds:OPSprite = cast getChildByName( "spr_scrollBounds" );
		TEXT_POS = scrollBounds.y;
		SCROLLHEIGHT = scrollBounds.height;
		
		// Get "Hello" audio, hide audio button otherwise
		var soundURL:String = "SFX/Hello/" + country.code + "_Hello";
		if ( SoundLib.SOUNDS.indexOf( soundURL ) >= 0 )
		{
			m_VO = soundURL;
		}
		else
		{
			hideObject( "vo_hello" );
		}
		
		m_countryImage = null;
		
		displayData( country );
	}
	
	public function release():Void
	{
		removeChild(m_countryImage);
		m_countryImage = null;
	}
	
	private function displayData( country:Country ):Void
	{	
		var countryImage:Bitmap;
		var countryText:TextField = cast getChildByName("lbl_fact");

		// Display country facts list
		initFactPaging( country );
		
		// Get country image
		if (Tunables.USE_DATABASE_RESOURCES)
		{
			var imageUrl:String = country.coverImage;
			if (!NetAssets.instance.isAssetLoaded(imageUrl))
			{
				//If the asset hasn't been loaded yet, show a placeholder first.
				countryImage = ResMan.instance.getImage("2d/UI/countries/country_loading");
				showCountryImage(countryImage);
			}
			
			NetAssets.instance.getImage(imageUrl, showCountryImage);
		}
		else
		{
			var countryFileName:String = StringTools.replace( country.name, " ", "_" ); 
			countryImage = ResMan.instance.getImage("2d/UI/countries/country_" + countryFileName);
			showCountryImage(countryImage);
		}
		
		// Replace country title 
		var countryTitle:TextField = cast getChildByName("headerText_country");
		countryTitle.text = capitalize( country.name );
		
		// Add text scrolling
		var scrollMgr:TextScrollingManager = new TextScrollingManager( this, countryText, countryText.x, countryText.y, countryText.width, SCROLLHEIGHT );
		this.addChild( scrollMgr );
	}
	
	/**
	 * Function for showing the country image.
	 * @param	countryImage
	 */
	private function showCountryImage(countryImage:Bitmap):Void
	{
		if (countryImage == null)
		{
			Debug.log("null image passed in...");
			return;
		}
		
		if (m_countryImage != null)
		{
			removeChild(m_countryImage);
			m_countryImage = null;
		}
		
		//=============================================
		// Reference Image
		//=============================================
		var paistImageRef:OPSprite = cast getChildByName( "countryImage" );
		var paistPanelRef:OPSprite = cast getChildByName( "pnl_woodPanel" );
		var refWidth:Float = paistImageRef.width;
		var refHeight:Float = paistImageRef.height;
		
		// Get position - paist ref is bottom center anchored, this is top left
		var posX:Float = paistImageRef.x;
		var posY:Float = paistImageRef.y;
		
		if (!Tunables.USE_DATABASE_RESOURCES)
		{
			posX += refWidth/2;
			posY += refHeight;
		}
		
		//=============================================
		// Create the image
		//=============================================
		var countrySprite:OPSprite = new OPSprite( countryImage );
		countrySprite.width = refWidth;
		countrySprite.height = refHeight;
		countrySprite.x = posX;
		countrySprite.y = posY;
		this.addChild( countrySprite );
		
		m_countryImage = countrySprite;
	}
	
	private function initFactPaging( country:Country ):Void
	{
		if ( country.facts.length > 0 )
		{
			m_factPos = 0;
			displayFact( country );
					
			// Since we're starting at zero, disable the left arrow
			var prev:GraphicButton = cast getChildByName( "btn_factPrevious" );
			prev.enabled = false;
			
			// If we only have one fact, disable the right arrow as well
			if ( country.facts.length == 1 )
			{
				var next:GraphicButton = cast getChildByName( "btn_factNext" );
				next.enabled = false;
			}
		}
		else
		{
			var countryText:TextField = cast getChildByName("lbl_fact");
			var prev:GraphicButton = cast getChildByName( "btn_factPrevious" );
			var next:GraphicButton = cast getChildByName( "btn_factNext" );
			countryText.text = "No data available for " + capitalize( country.name );
			prev.enabled = false;
			next.enabled = false;
		}
	}
	
	override public function onButtonHit( ?caller:GraphicButton )
	{
		super.onButtonHit(caller);	
		
		var country:Country = FlowController.data.selectedCountry;

		var prev:GraphicButton = cast getChildByName( "btn_factPrevious" );
		var next:GraphicButton = cast getChildByName( "btn_factNext" );
	
		if (caller.name == "btn_factNext")
		{
			if ( m_factPos < country.facts.length - 1 )
			{
				m_factPos++; 
				displayFact( country );
			}
		}
		else if (caller.name == "btn_factPrevious")
		{			
			if ( m_factPos > 0 )
			{
				m_factPos--;
				displayFact( country );
			}
		}
		else if ( caller.name == "vo_hello" )
		{
			WebAudio.instance.playVO( m_VO );
			return;
		}
		
		WebAudio.instance.play( "SFX/button_click" );
		
		// Update if the forward/backward buttons are enabled based on new position in the fact list
		if ( m_factPos == 0 )
		{
			prev.enabled = false;
		}
		else
		{
			prev.enabled = true;
		}
		
		if ( m_factPos == country.facts.length - 1 )
		{
			next.enabled = false;
		}
		else
		{
			next.enabled = true;
		}
	}
	
	// Replace country description
	private function displayFact( country:Country ):Void
	{
		var countryText:TextField = cast getChildByName("lbl_fact");
		countryText.text = country.facts[ m_factPos ];
		countryText.autoSize = TextFieldAutoSize.LEFT;
		
		// Reset text pos
		countryText.y = TEXT_POS;
	}
	
	private function getQuestionData( country:Country ):Question
	{		
		// Query the question database for this country's question set
		var questionSet:Array< Question > = QuestionDatabase.instance.query().aboutCountry( country.name ).finish();
		
		// Get the fact and image for the country
		return questionSet[0]; // Arbitrarily grab from first item - TODO, loop and test Some( img/fact ) to try to get a value?
	}
}