//
// Copyright (C) 2006-2016, 1st Playable Productions, LLC. All rights reserved.
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
package com.firstplayable.hxlib.utils.json;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.NinePatchPanel;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.display.anim.SpritesheetAnim;
import com.firstplayable.hxlib.display.bitmapFont.BitmapFont;
import com.firstplayable.hxlib.display.bitmapFont.BitmapTextAlign;
import com.firstplayable.hxlib.display.bitmapFont.BitmapTextField;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.utils.ColorUtils;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;
import com.firstplayable.hxlib.utils.json.JsonUtils.*;
import haxe.io.Path;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import spritesheet.Spritesheet;

using StringTools;

/**
 * Functions to populate GenericMenus from JSON data created in Paist
 */
class JsonMenuMakerDirectory extends JsonBaseMakerDirectory
{
	private static inline var HUSH:Bool = false;
	
    public function new() 
    {
        super();
        
        registerMakerFunc( "spriteObject", makeSprite );
        registerMakerFunc( "button", makeButton );
        registerMakerFunc( "label", makeTextField );
        registerMakerFunc( "panel", makePanel );
        registerMakerFunc( "borderPanel", makeBorderPanel );
	registerMakerFunc( "ninePatchPanel", makeNinePatchPanel );
    }
    
    /**
     * Creates a Panel (essentially just a container for grouping objects)
     * @param    metaData - JSON data describing the panel's properties
     * @return    a Sprite
     */
	public function makePanel( metaData:Dynamic ):DisplayObject
	{
		var panel:Sprite = new Sprite();
		
		var resource:String = getValueRecursively( "resource", metaData );
		if ( resource != null )
		{
			var panelImg:OPSprite = ResMan.instance.getSprite( resource );
			panel.addChild( panelImg );
		}
		else
		{
			var boundingBoxData:Array<Int> = getValueRecursively( "boundingBox", metaData );
			if (boundingBoxData != null)
			{
				var boundingBox:DisplayObject = createReferenceZone(boundingBoxData);
				if (boundingBox != null)
				{
					panel.addChild( boundingBox );
				}
			}
		}
		
		return panel;
	}
	
	/**
	 * Makes a display object shape for the specified dimmensions
	 * @param	boundingBoxData
	 * @return
	 */
	private function createReferenceZone(boundingBoxData:Array<Int>):DisplayObject
	{
		if (boundingBoxData == null)
		{
			Debug.warn("null bounding box supplied to createReferenceZone...");
			return null;
		}
		
		if (boundingBoxData.length != 4)
		{
			Debug.warn("incorrectly sized array passed as bounding box. Should be 4, was: " + boundingBoxData.length);
			return null;
		}
		
		var boxObj:Shape = new Shape();
		
		boxObj.graphics.beginFill( 0xFF80C0, 0 );
		boxObj.graphics.drawRect( boundingBoxData[0], boundingBoxData[1], boundingBoxData[2], boundingBoxData[3] );
		boxObj.graphics.endFill();
		
		boxObj.visible = false;
		
		return boxObj;
	}
	
	/**
     * Creates a Border Panel (essentially just a container for grouping objects)
     * @param    metaData - JSON data describing the panel's properties
     * @return    a Sprite
     */
    public function makeBorderPanel( metaData:Dynamic ):DisplayObject
    {
        return makePanel( metaData );
    }
	
	/**
     * Creates a Nine Patch Panel container, which has a nine-patch asset scaled to the proper size.
     * @param    metaData - JSON data describing the panel's properties
     * @return    a Sprite
     */
	public function makeNinePatchPanel(metaData:Dynamic):DisplayObject
	{
		var boundingBoxData:Array<Int> = getValueRecursively( "boundingBox", metaData );
		if (boundingBoxData == null)
		{
			Debug.warn("FAILURE: no bounding box data in " + metaData);
			return null;
		}
		if (boundingBoxData.length != 4)
		{
			Debug.warn("incorrectly sized array passed as bounding box. Should be 4, was: " + boundingBoxData.length);
			return null;
		}
		
		var panel:NinePatchPanel = null;
		
		var resource:String = getValueRecursively( "resource", metaData );
		if ( resource != null )
		{
			panel = new NinePatchPanel(resource, boundingBoxData[2], boundingBoxData[3]);
		}
		else
		{
			panel = new NinePatchPanel(boundingBoxData[2], boundingBoxData[3]);
		}
		
		return panel;
	}
    
    /**
     * Creates an image (may or may not have an animation)
     * @param    metaData - JSON data describing the sprite's properties
     * @return    one of: an Anim from IFL data; an Anim from a spritesheet; or a non-animated Bitmap
     */
    public function makeSprite( metaData:Dynamic ):DisplayObject
    {
      var resource:String = getValueRecursively( "resource", metaData );
      return createDisplayObject( resource, metaData );
   }
    
    /**
     * Helper function for makeSprite() and makeButton() that's used to create a DisplayObject
     * @param    resource    - the path to the asset(s)
     * @param    metaData    - the JSON data that defines the sprite's properties
     * @return   a SpritesheetAnim or Bitmap
     */
    private function createDisplayObject( resource:String, metaData:Dynamic ):DisplayObject
    {
		// TODO: get rpjs working again
		if ( ( resource == null ) || ( resource.length == 0 ) )
		{
			// Suppress unnecessary warnings if the resource was empty
			// (likely placeholder sprite).
			resource = ResMan.MISSING_IMAGE_DATA;
		}
		
		
		var isAnim:Bool = ResMan.instance.isAnim( resource );
		
		if ( !isAnim )
		{
			//trace( "createDisplayObject: resource is: " + resource );
			return ResMan.instance.getSprite( resource );
		}
#if spritesheet
		else
		{
			resource = ResMan.instance.verifyPath( resource );
			var sheetName:String = The.resourceMap.getSheetPath( resource );
			if ( sheetName != The.resourceMap.INVALID )
			{
				var animName:String = resource;
				
				// As of hxlib rev 755, this used byRef=false.
				// Rationale was unclear, but may have had something to do with
				// multiple instances of the same anim in the same menu not working.
				//
				// I can't see any reason why this wouldn't work these days
				// (raw BitmapData should share nicely, and BitmapDataWithParams
				// should wrap uniquely as appropriate based on 
				// BehaviorDataWithParams.getCacheData doing the Right Thing).
				//
				// We're turning this on to see what breaks as of 2017-06-21, with
				// pumbaa and pebble being the primary in-flight projects at the moment.
				//
				// If this works, it'll allow more sharing of BehaviorDataWithParams
				// and more cache hits, and should mean fewer ResMan.makeSheet calls too.
				var sheet:Spritesheet = ResMan.instance.getSpritesheet( sheetName, true );
				var anim:SpritesheetAnim = new SpritesheetAnim( sheet );
				
				// go to the animation
				anim.gotoAndPlay( animName );
				return anim;
			}
			
		}
#end
		
		return null; //< should never actually hit this line
    }
	
	private function createBitmap( resource:String, metaData:Dynamic ):Bitmap // TODO BitmapData
    {
		return ResMan.instance.getImage( resource, false );
    }
	
    /**
     * Creates a GraphicButton; note that the handler will be assigned in JsonMenuPlugIn.finishProductAssembly()
     * @param    metaData    - the JSON data detailing the button's properties
     * @return    The GraphicButton
     */
    public function makeButton( metaData:Dynamic ):DisplayObject
    {
        var resource:String = getValueRecursively( "resource", metaData );
        
        var upSprite:Bitmap = createBitmap( resource + "_up", metaData ); // TODO BitmapData
		var downSprite:Bitmap = ResMan.instance.getImageUnsafe( resource + "_down", false );
		var overSprite:Bitmap = ResMan.instance.getImageUnsafe( resource + "_over", false );
		var disabledSprite:Bitmap = ResMan.instance.getImageUnsafe( resource + "_disabled", false );
		
        var idFromData:String = getValueRecursively( "id", metaData );
        var id:Int = ( idFromData == null ) ? 0 : Std.parseInt( idFromData );
        
        var btn:GraphicButton = new GraphicButton( upSprite, downSprite, overSprite, disabledSprite, null, null, id );
        
        if ( getValueRecursively( "enabled", metaData ) != null )
        {
            btn.enabled = false;
        }
        
        return btn;
    }
    
    /**
     * Creates a TextField. See https://wiki.1stplayable.com/index.php/Web/Haxe/PaistIntegrationMDD/fonts for more information,
         * since A) Labels don't map perfectly to TextFields and B) TextFields don't behave 100% the same across platforms
	 * NOTE: the above link is probably really out dated at this point
	 * NOTE: we should really create a custom text class; TextField does not give us the kind of control we need =(
     * @param    metaData - JSON data decribing the TextField
     * @return    a TextField with various properties set
     */
    public function makeTextField( metaData:Dynamic ):DisplayObject
    {
		var fieldName:String = getValueRecursively( "name", metaData );
		var isBitmapFont:Bool = getValueRecursively( "bitmapFont", metaData );
		
		var tf:DisplayObject = null;
		
		if (isBitmapFont || ((fieldName != null) &&  (fieldName.indexOf("_bitmap_")) != -1))
		{
			tf = makeBitmapTextField(metaData);
		}
		else
		{
			tf = makeStandardTextField(metaData);
		}
		
		return tf;
    }
	
	/**
	 * Helper function for creating standard openfl TextFields
	 * @param	metaData
	 * @return
	 */
	private function makeStandardTextField(metaData:Dynamic):DisplayObject
	{
		var tf:TextField = new TextField();
        var shouldAutosize:Null<Bool> = getValueRecursively( "autoSize", metaData );
        
        setTextColor( tf, metaData );
        
        // Make sure this happens BEFORE setting the text
        setFormat( tf, metaData );
        
        if ( shouldAutosize != null && shouldAutosize )
        {
            // Using any TextFieldAutoSize value seems to behave as if LEFT was used
            // Also only really has an effect in Flash
            tf.autoSize = TextFieldAutoSize.LEFT;
        }
        else
        {
            setWordWrap( tf, metaData );
            setTextfieldSize( tf, metaData );
        }
        
        // Make sure this happens AFTER setting the font face/size
        var text:String = getValueRecursively( "text", metaData );
        if ( text == null )
        {
            text = "";
        }
		else
		{
			if ( The.gamestrings.has( text ) )
			{
				text = The.gamestrings.get( text );
			}
			else
			{
				if (!HUSH)
				{
					Debug.log( "Cannot find GameStrings ID: " + text );
				}
			}
		}
        tf.text = text;
		
		var clipOverflow:Null<Bool> = getValueRecursively( "clipOverflow", metaData );
		if ( clipOverflow == null || !clipOverflow )
		{
			var curNumLines:Int = tf.numLines;
			// Based on the height of this text field, how many lines do we expect to need to fit?
			var projNumLines:Int = Std.int( tf.height / tf.textHeight ) + 1;
			
			var newNumLines:Int = Std.int( Math.max( curNumLines, projNumLines ) );
			var newHeight:Float = tf.textHeight * newNumLines 					// height needed just for the text
								+ ( tf.textHeight / 2 * ( newNumLines - 1 ) );	// add'l height to account for space between lines
			
			//Debug.warn( "Changing height for '" + tf.text + "' from " + tf.height + " to " + newHeight );
			tf.height = newHeight;
		}
		
		var touchable:Null<Bool> = getValueRecursively( "touchable", metaData );
		tf.selectable = touchable != null && touchable;
		tf.mouseEnabled = touchable != null && touchable;
		
        return tf;
	}
	
	/**
	 * Constructs an angelcode bitmap font field.
	 * @param	metaData
	 * @return
	 */
	private function makeBitmapTextField(metaData:Dynamic):DisplayObject
	{
		var angelCodeField:BitmapTextField = null;
		
		var fontName:String = getValueRecursively( "font", metaData );
		//Replace the filepath with .fnt to grab the xml data
		var fontPath:Path = new Path(fontName);
		fontName = "fnt/" + fontPath.file + ".fnt";
		var fontXMLString:String = ResMan.instance.getText(fontName);
		var fontXML:Xml = Xml.parse(fontXMLString);
		
		var fontBitmapName:String = "2d/" + fontPath.file + ".png";
		var fontImage:BitmapData = ResMan.instance.getImageData(fontBitmapName);
		
		var angelCodeFont:BitmapFont = BitmapFont.fromAngelCode(fontImage, fontXML);
		
		var text:String = getValueRecursively( "text", metaData );
		if ( text == null )
                {
                   text = "";
                }
		else
		{
			if ( The.gamestrings.has( text ) )
			{
				text = The.gamestrings.get( text );
			}
			else
			{
				if (!HUSH)
				{
					Debug.log( "Cannot find GameStrings ID: " + text );
				}
			}
		}
		
		angelCodeField = new BitmapTextField(angelCodeFont, text);
		angelCodeField.updateImmediately = false;
		
		var colorVal:Int = 0xFFFFFF;    // Default in Paist is white
        var color:Array<Dynamic> = getValueRecursively( "color", metaData );
        if ( color != null )
        {
            // Convert from individual 5-bit RGB vals to a single 24-bit value
            colorVal = ColorUtils.dsToHex( cast color[ 0 ], cast color[ 1 ], cast color[ 2 ] );
        }
		
		colorVal = colorVal | 0xFF000000;
		angelCodeField.useTextColor = true;
		angelCodeField.textColor = colorVal;
		
		var kerning:Null<Int> = getValueRecursively( "kerning", metaData );
		if (kerning != null)
		{
			angelCodeField.letterSpacing = kerning;
		}
		
		var lineSpacing:Null<Int> = getValueRecursively( "spacing", metaData );
		if (lineSpacing != null)
		{
			angelCodeField.lineSpacing = lineSpacing;
		}
		
		var wrap:Null<Bool> = getValueRecursively( "wrapOverflow", metaData );
		if (wrap != null)
		{
			angelCodeField.wordWrap = wrap;
		}
		else
		{
			angelCodeField.wordWrap = false;
		}
		
		var autoSize:Null<Bool> = getValueRecursively( "autoSize", metaData );
		if (autoSize != null)
		{
			angelCodeField.autoSize = autoSize;
		}
		if ((autoSize == null) || (!autoSize))
		{
			var size:Array<Dynamic> = getValueRecursively( "size", metaData );
			if ( size != null )
			{
				angelCodeField.autoSize = false;
				
				angelCodeField.width = cast size[ 0 ];
				angelCodeField.height = cast size[ 1 ]; // will scale the letter height
			}
		}
		
		var alignment:Array<Dynamic> = getValueRecursively( "textAlignment", metaData );
		if (alignment != null)
		{
			// We can only actually change the horizontal alignment (even though Paist allows us to set vertical as well)
			var horAlign:String = cast alignment[ 0 ];
			if ( horAlign == "center" )
			{
				angelCodeField.alignment = BitmapTextAlign.CENTER;
			}
			else if ( horAlign.indexOf( "right" ) != -1 )
			{
				angelCodeField.alignment = BitmapTextAlign.RIGHT;
			}
		}
		
		angelCodeField.updateImmediately = true;
		angelCodeField.forceGraphicUpdate();
		
		return angelCodeField;
	}
    
    /**
     * Helper function to set the wordWrap property of tf based on the value set in metaData
     */
    private function setWordWrap( tf:TextField, metaData:Dynamic ):Void
    {
        var wrap:Null<Bool> = getValueRecursively( "wrapOverflow", metaData );
		tf.wordWrap = wrap != null && wrap;
    }
    
    /**
     * Helper function to set the size of tf based on the values set in metaData.
     * Uses absolute position.
     */
    private function setTextfieldSize( tf:TextField, metaData:Dynamic ):Void
    {
        var size:Array<Dynamic> = getValueRecursively( "size", metaData );
        if ( size != null )
        {
            tf.width = cast size[ 0 ];
            tf.height = cast size[ 1 ]; // this will likely get overwritten, assuming "clip" is off
        }
    }
    
    /**
     * Helper function to set the textColor property of tf based on the value set in metaData
     */
    private function setTextColor( tf:TextField, metaData:Dynamic ):Void
    {
        var colorVal:Int = 0xFFFFFF;    // Default in Paist is white
        var color:Array<Dynamic> = getValueRecursively( "color", metaData );
        if ( color != null )
        {
            // Convert from individual 5-bit RGB vals to a single 24-bit value
            colorVal = ColorUtils.dsToHex( cast color[ 0 ], cast color[ 1 ], cast color[ 2 ] );
        }
        
        tf.textColor = colorVal;
    }
    
    /**
     * Helper function to set the default TextFormat for tf based on the data in metaData.
     * The folowing will be set here:
     * - font face
     * - font size
     * - text alignment
     * The default system font will be used if no data is set for the font. 
     */
    private function setFormat( tf:TextField, metaData:Dynamic ):Void
    {
        var fontPath:String = null;
        
        // If these are null, default system font will be used
        var fontSize:String = null;
        var fontFace:String = null;
        
        var fontInfo:String = getValueRecursively( "font", metaData );
        
        // Set font face and size if a font was specified in the JSON data
        if ( fontInfo != null )
        {
			var type:String = ".fnt";
			var delim:String = "_";
			
			if ( fontInfo.indexOf( "ttf" ) > -1 )
			{
				type = ".ttf";
				delim = ":";
			}
			
            // Fonts will be named something like "<path>/LiberationSans-Bold_20.fnt" OR "<path>/LiberationSans-Bold.ttf:20"
            var info:Array<String> = fontInfo.split( delim );
            if ( info != null && info.length == 2 )
            {
                fontPath = info[ 0 ];
                fontSize = info[ 1 ];
                
				//remove extension from size, if there (.fnt)
				fontSize = fontSize.replace( type, "" );
				
				var lastSlash:Int = fontPath.lastIndexOf( "/" );
				
				// Strip path elements from font name, and remove extenstion
                if ( lastSlash != -1 )
                {
					fontPath = fontPath.substring( lastSlash + 1 );
                }
				#if js
					//TODO temp fix until Assets.getFont() works for JS target
					var lastPeriod:Null<Int> = fontPath.lastIndexOf( "." );

					if ( lastPeriod == -1 )
					{
						lastPeriod = null;
					}
					
					//lastPeriod null will act as last index of string
					fontFace = fontPath.substring( 0, lastPeriod );
				#else
					var font:Font = Assets.getFont( "fnt/" + fontPath );
				
					if( font != null )
					{
						fontFace = font.fontName;
					}
				#end
            }
        }
        
        var format:TextFormat = new TextFormat( fontFace, Std.parseInt( fontSize ) );
        setTextAlign( format, metaData );
        tf.defaultTextFormat = format;
        
        // This line is required for fonts to work in Flash -_-
        // but only if we have specified a font (since it will cause the default system font to no longer show)
        if ( fontFace != null )
        {
            tf.embedFonts = true;
        }
    }
    
    /**
     * Helper function for setFormat() that will set the text alignment for the TextField being created by makeTextField()
     * @param    format        - the TextFormat being created to be used as the defaultTextFormat
     * @param    metaData    - JSON data containing props for the TextField we are creating
     */
    private function setTextAlign( format:TextFormat, metaData:Dynamic ):Void
    {
        var alignment:Array<Dynamic> = getValueRecursively( "textAlignment", metaData );
        if ( alignment == null )
        {
            // EARLY RETURN
            return;
        }
        
        // We can only actually change the horizontal alignment (even though Paist allows us to set vertical as well)
        var horAlign:String = cast alignment[ 0 ];
        if ( horAlign == "center" )
        {
            format.align = TextFormatAlign.CENTER;
        }
        else if ( horAlign.indexOf( "right" ) != -1 )    // json will say "right or bottom"
        {
            format.align = TextFormatAlign.RIGHT;
        }
        // else LEFT (default)
    }
}