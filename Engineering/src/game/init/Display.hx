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

package game.init;

import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.utils.Version;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFormat;

#if js
import js.html.Window;
import js.Browser;
#end


@:enum
abstract AssetSet( String )
{
	var FOUR_THREE = "2d/bg/4_3/";
	var SIXTEEN_NINE = "2d/bg/16_9/";
}

class Display
{
	private static inline var SCALE_PRECISION = 2;
	
	public static var assetSet( default, null ):AssetSet;
	
	private static var ms_versionStamp:Version;
	
	public static var appSize(get, null):Point;
	public static function get_appSize():Point
	{
		#if js
		var devicePixelRatio = 1;
		var width = (Browser.window.innerWidth * devicePixelRatio);
		var height = (Browser.window.innerHeight * devicePixelRatio);
		return new Point(width, height);
		#else
		return Application.app.appSize;
		#end
	}
	
	public static var targetSize(get, null):Point;
	public static function get_targetSize():Point
	{
		#if js
		return new Point(1366, 768);
		#else
		return Application.app.targetSize;
		#end
	}
	
	public static var scaleMode(get, null):ScaleMode;
	public static function get_scaleMode():ScaleMode
	{
		#if js
		return ScaleMode.FIT;
		#else
		return Application.app.scaleMode;
		#end
	}
	
	public static var scale(get, null):Float;
	public static function get_scale():Float
	{
		#if js
		var widthRatio:Float = (appSize.x / targetSize.x);
		var heightRatio:Float = (appSize.y / targetSize.y);
		
		return ( scaleMode == ScaleMode.FIT ) 
				? Math.min( widthRatio, heightRatio )	// FIT
				: Math.max( widthRatio, heightRatio );	// CROP
		#else
		return Application.app.scale;
		#end
	}
	
	public static function initLayers():Void
	{
		GameDisplay.addLayer( LayerName.BACKGROUND, makeGameLayer() );
		GameDisplay.addLayer( LayerName.PRIMARY, makeGameLayer() );
		GameDisplay.addLayer( LayerName.FOREGROUND, makeGameLayer() );
		GameDisplay.addLayer( LayerName.HUD, makeGameLayer() );
		GameDisplay.addLayer( LayerName.DEBUG, makeGameLayer() );
		
		printDebugInfo();
		addBuildstamp();
	}
	
	public static function updateLayers():Void
	{
		updateLayer(GameDisplay.getLayer(cast LayerName.BACKGROUND));
		updateLayer(GameDisplay.getLayer(cast LayerName.PRIMARY));
		updateLayer(GameDisplay.getLayer(cast LayerName.FOREGROUND));
		updateLayer(GameDisplay.getLayer(cast LayerName.HUD));
		updateLayer(GameDisplay.getLayer(cast LayerName.DEBUG));
	}
	
	public static function makeGameLayer():Sprite
	{
		var layer:Sprite = new Sprite();
		updateLayer(layer);
		return layer;
	}
	
	public static function updateLayer(layer:Sprite):Void
	{
		var appWidth:Float = appSize.x;
		var appHeight:Float = appSize.y;
		
		var assetWidth:Float = targetSize.x;
		var assetHeight:Float = targetSize.y;
		
		// Center the layer on the screen
		layer.x = ( appWidth / 2 ) - ( assetWidth * scale / 2 );
		layer.y = ( appHeight / 2 ) - ( assetHeight * scale / 2 );
		
		// Update the layer scaling
		#if js
		layer.scaleX = scale;
		layer.scaleY = scale;
		#else
		var newScale = scale * Math.round( scale * Math.pow(10, SCALE_PRECISION) ) / Math.pow(10, SCALE_PRECISION);
		layer.scaleX = newScale;
		layer.scaleY = newScale;
		#end
	}
	
	public static function resizeToFillScreen( obj:DisplayObject ):Void
	{
		if ( Debug.log_if( (obj == null), "Could not resize object; it was null" ) )
		{
			// EARLY RETURN -- no obj to scale
			return;
		}
		
		var newScale:Float = Application.app.calculateScale( ScaleMode.CROP ) / Application.app.scale;
		
		if ( obj.scaleX == newScale )
		{
			// EARLY RETURN -- we've already scaled this object
			return;
		}
		
		var origWidth:Float = obj.width;
		var origHeight:Float = obj.height;
		
		obj.scaleX = newScale;
		obj.scaleY = newScale;
		
		obj.x -= ( obj.width - origWidth ) / 2;
		obj.y -= ( obj.height - origHeight ) / 2;
		
		Debug.log( "\n newScale =	" +  newScale
				+ "\n origWidth =	" + origWidth
				+ "\n origHeight =	" + origHeight
				+ "\n obj.width =	" + obj.width
				+ "\n obj.height = 	" + obj.height
				);
	}
	
	private static function printDebugInfo():Void
	{
		Debug.log( "---- Game Display Info ----" );
		Debug.log( "appWidth  - " + Application.app.appSize.x );
		Debug.log( "appHeight - " + Application.app.appSize.y );
		Debug.log( "asset width  - " + Application.app.targetSize.x );
		Debug.log( "asset height - " + Application.app.targetSize.y );
		Debug.log( "scale - " + Application.app.scale );
		Debug.log( "---------------------------" );
	}
	
	private static function addBuildstamp():Void
	{
		ms_versionStamp = new Version();
		
#if (debug || build_cheats) 
		var format:TextFormat = ms_versionStamp.getTextFormat();
		format.size = 24;
		ms_versionStamp.setTextFormat( format );
		
		ms_versionStamp.y = Application.app.targetSize.y - ms_versionStamp.height - 10;
		GameDisplay.attach( LayerName.DEBUG, ms_versionStamp );
#else
		// Smaller buid stamp for the release version.
		//  TODO: Maybe lift this to hxlib Version as an option.
		var stamp = new TextField();
		var format:TextFormat = stamp.getTextFormat();
		format.size = 16;
		stamp.setTextFormat(format);

		var buildInfo:String = 'v${ms_versionStamp.buildVersion}.${ms_versionStamp.buildNum}';
		stamp.text = buildInfo;

		stamp.y = Application.app.targetSize.y - 20;

		GameDisplay.attach( LayerName.DEBUG, stamp );
#end
	}
	
	public static function updateStateStamp():Void
	{
		if ( !Tunables.SHOW_STATE_INFO )
		{
			// EARLY RETURN -- we're not supposed to show the state stamp
			return;
		}
	
		if ( ms_versionStamp == null )
		{
			addBuildstamp();
		}
		
		ms_versionStamp.text = Version.versionInfo + '\t' + SpeckGlobals.saveProfile.getCurrentStateString();
	}
}