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
package com.firstplayable.hxlib.text;
import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.Debug.warn;
import haxe.ds.EnumValueMap;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

typedef FontStruct =
{
	id:EnumValue,
	name:String,
	?size:Int,
	?color:Int,
	?bold:Bool
}

class FontMap
{
	private static var m_fontmap:EnumValueMap<EnumValue,TextFormat>;
	
	/**
	 * Initialize the font map.
	 * @param	fonts	An array of font data.
	 */
	public static function init( fonts:Array<FontStruct> ) 
	{
		m_fontmap = new EnumValueMap();
		
		for ( font in fonts )
		{
			m_fontmap.set( font.id, new TextFormat( font.name, font.size, font.color, font.bold ) );
		}
		
		//------------------------------------
		//HACK TO MAKE FONTS RENDER FIRST TIME
		var sample:FontStruct = fonts[ 0 ];
		
		//create a dummy field
		var field:TextField = new TextField();
		field.defaultTextFormat = m_fontmap.get( sample.id );
		field.text = " ";
		Application.app.addChild( field );
		var waitFrames:Int = 1;
		
		//field needs to exist and render for one frame
		field.addEventListener( Event.ENTER_FRAME,
			function( e:Event )
			{
				if ( waitFrames-- == 0 )
				{
					//clean up field
					Application.app.removeChild( field );
					field = null;
				}
			}, false, 0, true );
	}
	
	/**
	 * Request a text format resource from those available.
	 * @param	id
	 * @return
	 */
	public static function get( id:EnumValue ):TextFormat
	{
		var f:TextFormat = m_fontmap.get( id );
		
		if ( f == null )
		{
			warn( "TextFormat '" + id + "' does not exist! Did you call init() first?" );
			return new TextFormat();
		}
		
		return f;
	}
	
	/**
	 * Checks whether a font exists in the web browser.
	 * @param	id
	 * @return
	 */
	public static function isReadyInBrowser( id:EnumValue ):Bool
	{
		#if !js
			Debug.warn( "exists is not supported outside of js/html5 targets." );
			return false;
		#end
		
		var format:TextFormat = get( id );
		if ( format.size == null )
			format.size = 75;
		
		var ce:CanvasElement = cast Browser.document.createElement( "canvas" );
		var crc:CanvasRenderingContext2D = ce.getContext2d();
		crc.font = format.size + "px monospace";
		
		var glyphs:String = "abcdefghijklmnopqrstuvwxyz0123456789";
		var baseSize:Float = crc.measureText( glyphs ).width;
		
		crc.font = format.size + "px '" + format.font + "', monospace";
		var fontSize:Float = crc.measureText( glyphs ).width;
		
		return fontSize != baseSize;
	}
}