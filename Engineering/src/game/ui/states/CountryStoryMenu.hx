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
import game.ui.TextScrollingManager;
import openfl.text.TextField;
import com.firstplayable.hxlib.display.OPSprite;
import game.Country;
import game.init.Display;
import game.ui.SpeckMenu;
import openfl.display.DisplayObjectContainer;
import com.firstplayable.hxlib.display.GraphicButton;
import game.controllers.FlowController;
import game.cms.Question;
import haxe.ds.Option;
import com.firstplayable.hxlib.audio.WebAudio;
import assets.SoundLib;
import com.firstplayable.hxlib.loader.ResMan;
import game.cms.QuestionDatabase;
import openfl.display.Bitmap;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import game.net.NetAssets;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.Debug.*;
import openfl.text.TextFieldAutoSize;
import openfl.display.DisplayObject;
using StringTools;

class CountryStoryMenu extends SpeckMenu
{
	private var m_VO:String;
	
	private static inline var S3_ASSET_URL:String = "https://chefk-prod.s3.amazonaws.com/curriculum/images/";
	private static inline var S3_SOUND_URL:String = "https://chefk-prod.s3.amazonaws.com/curriculum/audio/";
	private static inline var NO_DATA_TEXT:String = "No data available for this country.";

	public function new() 
	{
		super( "CountryStoryMenu" );
		
		var country:Country = FlowController.data.selectedCountry;
		
		// Replace header
		var header:TextField = cast getChildByName( "headerText_country" );
		header.text = capitalize( country.name );
		
		setUpData( country );
	}
	
	override public function onButtonHit( ?caller:GraphicButton )
	{
		super.onButtonHit(caller);	
	
		if ( caller.name == "vo_hello" )
		{
			WebAudio.instance.playVO( m_VO );
			return;
		}
		
		WebAudio.instance.play( "SFX/button_click" );
	}
	
	/**
	 * Set up story data for country as available. Missing pieces will default to consumer data. 
	 * Totally missing data (image+text) will display a message.
	 */
	private function setUpData( country:Country ):Void
	{
		// Get question data
		var data:Question = getQuestionData( country );
		var storyText:TextField = cast getChildByName( "lbl_fact" );
		
		if ( data != null )
		{
			// ----------------------------
			// Country Fact
			// ----------------------------
			switch ( data.countryFact )
			{
				case Some( fact ):
				{
					storyText.text = fact;
					setUpTextScrolling ( storyText );
				}
				
				case None: // No story - fall thru to consumer text
				{
					storyText.text = country.facts[0];
					setUpTextScrolling( storyText );
				}
			}
			
			// ----------------------------
			// Country Image
			// ----------------------------
			
			switch ( data.countryImage )
			{
				case Some( image ): // Image listed in spreadsheet (may still not exist, be correct filename, etc.)
				{
					showPilotImage( country, image );
				}
				case None: // No image listed in spreadsheet
				{
					showPilotImage( country, "NONE" );
				}
			}

			// ----------------------------
			// Country VO
			// ----------------------------
			
			// Get country VO, if applicable
			// Get story audio, hide audio button otherwise
			switch( data.countryFactVO )
			{
				case Some( vo ): 
				{
					var sndUrl = S3_SOUND_URL + vo;
					var sndId = 'Questions/${vo}';
					WebAudio.instance.multiRegister([sndUrl, sndUrl.replace(".ogg", ".mp3")], sndId);
					m_VO = sndId;
					WebAudio.instance.load([sndId]);
				}
				case None: 
				{
					m_VO = null;
					hideObject( "vo_hello" );
				}
			}
		}
		else 
		{	
			Debug.log( "No data available for country " + country.name );
			storyText.text = "No data available for country " + country.name;
			setUpTextScrolling( storyText );
		}
	}
	
	private function setUpTextScrolling( data:TextField ):Void 
	{
		data.autoSize = TextFieldAutoSize.CENTER;
		var scrollBounds:OPSprite = cast getChildByName( "spr_scrollBounds" );
		var scrollMenu:TextScrollingManager = new TextScrollingManager( this, data, scrollBounds.x, scrollBounds.y, scrollBounds.width, scrollBounds.height );
		this.addChild( scrollMenu );
	}
	
	private function showPilotImage( country:Country, image:String ):Void
	{	
		// Resize image IF IT EXISTS
		//var hasImage:Bool = ResMan.instance.getImageUnsafe("2d/Questions/" + image) != null;
		var imgUrl = S3_ASSET_URL + image + ".png";
		NetAssets.instance.getImage(imgUrl, onImgLoaded);
	}

	private function onImgLoaded( img:Bitmap ):Void
	{
		// Replace image
		var imgPnl:DisplayObjectContainer = cast getChildByName( "pnl_countryImage" );
		var backPnl:OPSprite = cast imgPnl.getChildByName( "pnl_woodPanel" );
        var refPt:DisplayObject = cast imgPnl.getChildByName( "refpt" );
		var imgRef:OPSprite = cast imgPnl.getChildByName( "countryImage" );
		var newImg:OPSprite = new OPSprite ( img );
		imgRef.visible = false;

		if ( newImg != null )
		{
			if ( newImg.width >= newImg.height ) // scale the larger side
			{
				var scaleRatioX = imgRef.width / newImg.width;
				newImg.scaleX = scaleRatioX;
				newImg.scaleY = scaleRatioX;
			}
			else
			{
				var scaleRatioY = imgRef.height / newImg.height;
				newImg.scaleY = scaleRatioY;
				newImg.scaleX = scaleRatioY;
			}
		}
		else
		{
			Debug.log( "No curricular image available." );
		}

		imgPnl.addChild( newImg );

		newImg.x = refPt.x;
		newImg.y = refPt.y;

	}
	
	private function getQuestionData( country:Country ):Question
	{		
		// Query the question database for this country's question set
		var questionSet:Array< Question > = QuestionDatabase.instance.query().aboutCountry( country.name ).finish();
		
		// Get the fact and image for the country
		return questionSet[0]; // Arbitrarily grab from first item - TODO, loop and test Some( img/fact ) to try to get a value?
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
		
		//=============================================
		// Reference Image
		//=============================================		
		var imgPnl:DisplayObjectContainer = cast getChildByName( "pnl_countryImage" );
		var paistImageRef:OPSprite = cast imgPnl.getChildByName( "countryImage" );
		var paistPanelRef:OPSprite = cast imgPnl.getChildByName( "pnl_woodPanel" );
		var refWidth:Float = paistImageRef.width;
		var refHeight:Float = paistImageRef.height;
		
		// Get position - paist ref is bottom center anchored, this is top left
		var posX:Float = paistImageRef.x;
		var posY:Float = paistImageRef.y;
		
		//=============================================
		// Create the image
		//=============================================
		var countrySprite:OPSprite = new OPSprite( countryImage );
		countrySprite.width = refWidth;
		countrySprite.height = refHeight;
		countrySprite.x = posX;
		countrySprite.y = posY;
		imgPnl.addChild( countrySprite );
		
		// Rotation code - unused but left commented in case it's needed for the future
		//countrySprite.rotation = IMG_ROTATION;
		//paistPanelRef.rotation = IMG_ROTATION;
		
		//paistPanelRef.width = countrySprite.width + CONSUMER_PNL_WIDTH_ADJUST;
		//paistPanelRef.height = countrySprite.height + CONSUMER_PNL_HEIGHT_ADJUST;
	}
	
}
