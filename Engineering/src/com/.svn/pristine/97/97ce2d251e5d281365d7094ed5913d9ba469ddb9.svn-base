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
package com.firstplayable.hxlib.display.anim.importers;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.display.SpritesheetWithParams;
import com.firstplayable.hxlib.loader.ResMan;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import spritesheet.data.BehaviorData;
import spritesheet.data.SpritesheetFrame;
import spritesheet.Spritesheet;

/**
 * ORIGINALLY TAKEN FROM ZoeImporter in OpenFL Spritesheet package.
 * Modified to use bitmaps instead of assume Assets library by Jon Meschino.
 * 
 * This is a class used to parse a json file exported from Zoe into 
 * a Spritesheet object to be used with Joshua Granick's fantastic
 * sprite sheet library avialable on haxelib.
 * 
 * Zoe: http://easeljs.com/zoe.html
 * Spritesheet: http://lib.haxe.org/p/spritesheet
 * Joshua Granick: http://www.joshuagranick.com
 * Dean Nicholls: http://www.deannicholls.co.uk
 * 1st Playable: http://www.1stplayable.com
 * 
 * @author 1st Playable
 */
class ZoeImporterPlus
{
	public static function parse ( data:Dynamic, basePath:String ):Spritesheet
	{
		var padding:Int = 2; //< mostly paranoia, but this is default TP padding, so let's preserve here as well
		
		var json:Dynamic = null;
		if ( Std.is( data, String ) )
		{
			// String rep.  Need to parse.
			json = Json.parse( data );
		}
		else
		{
			// Anonymous structure?  Already parsed for us, woot.
			json = data;
		}
		
		var images:Array<Dynamic> = StdX.as( Reflect.field( json, "images" ), Array );
		if ( images == null )
		{
			Debug.warn( "Spritesheet 'images' array not found (aborting), basePath: " + basePath );
			return null;
		}
		if ( images.length < 1 )
		{
			Debug.warn( "Spritesheet 'images' array empty (aborting), basePath: " + basePath );
			return null;
		}
		
		var sheetsData:Array<BitmapData> = [];
		for ( image in images )
		{
			sheetsData.push( ResMan.instance.getImageData( basePath + Std.string( image ) ) );
		}
		
		var jsonFrames:Array<Dynamic> = StdX.as( Reflect.field( json, "frames" ), Array );
		if ( jsonFrames == null )
		{
			Debug.warn( "Spritesheet 'frames' not found (aborting), first image: " + Std.string( images[0] ) );
			return null;
		}
		
		var frames:Array<SpritesheetFrame> = [];
		
		for ( frameIter in jsonFrames )
		{
			var frame:Array<Dynamic> = StdX.as( frameIter, Array );
			if ( ( frame == null ) || ( frame.length < 7 ) )
			{
				Debug.warn( "Spritesheet has malformed 'frames' entry (aborting); first image: " + Std.string( images[0] ) + ", offending frame: " + Std.string( frame ) );
				return null;
			}
			// TODO: frame[0..6] type checks?
			
			var sheetIdx:Int = frame[4];
			var sheetYOffset:Int = 0;
			
			for ( i in 0...sheetIdx )
			{
				sheetYOffset += Std.int( sheetsData[ i ].height );
			}
			
			var x:Int = frame[0];
			var y:Int = Std.int( frame[1] + sheetYOffset + ( padding * sheetIdx ) );
			var width:Int = frame[2];
			var height:Int = frame[3];
			var offsetX:Int = Std.int( -frame[5] );
			var offsetY:Int = Std.int( -frame[6] );
			
			frames.push( new SpritesheetFrame( x, y, width, height, offsetX, offsetY ) );
		}
		
		var bigW:Int = 0;
		var bigH:Int = 0;
		
		for( sheetData in sheetsData )
		{
			if ( sheetData.width > bigW )
			{
				bigW = Std.int( sheetData.width );
			}
			
			bigH += Std.int( sheetData.height ) + padding;
		}
		
		var bigsheet:BitmapData = null;
		
		//stitch together multiple sheets
		if ( sheetsData.length > 1 )
		{
			bigsheet = new BitmapData( bigW, bigH, true, 0xFFFFFF00 );
			
			var curH:Int = 0;
			for( sheetData in sheetsData )
			{
				bigsheet.copyPixels( sheetData, new Rectangle( 0, 0, sheetData.width, sheetData.height ), new Point( 0, curH ) );
				curH += Std.int( sheetData.height ) + padding;
			}
		}
		//only one sheet, no stitching needed so just pass it through
		else
		{
			bigsheet = sheetsData[ 0 ];
		}
		
		//compiled sheet of multipacked resources
		var spritesheet:Spritesheet = new SpritesheetWithParams( bigsheet, frames );
		
		// Populate the array of behaviors from the frames specified in the states list in the json file
		var animNames:Array<String> = Reflect.fields( json.animations );
		for ( animName in animNames )
		{
			// Updated for new TexturePacker compatibility.
			// See https://github.com/jgranick/spritesheet/blob/ebb74d0450308bc40ac99fda849c1c7678b8bbd0/spritesheet/importers/ZoeImporter.hx#L73
			// ...but we took a slightly simpler approach.
			var state = Reflect.field( json.animations, animName );
			var behaviorJsonFrames = Reflect.field( state, "frames" );
			var behaviorFrames:Array<Dynamic> = null;
			if ( Std.is( behaviorJsonFrames, Array ) )
			{
				behaviorFrames = cast behaviorJsonFrames;
			}
			else if ( Std.is( state, Array ) )
			{
				behaviorFrames = cast state;
			}
			else
			{
				Debug.warn( "Unable to find frames in spritesheet for anim (format change?): " + Std.string( animName ) );
			}
			
			// Check for any offsets.
			var behaviorFramesInt:Array<Int> = cast behaviorFrames;
			var hasAnyOffsets:Bool = false;
			for ( frameIter in behaviorFramesInt )
			{
				var frameIdx:Int = cast frameIter;
				var ssFrame:SpritesheetFrame = frames[ frameIdx ];
				if ( ssFrame != null )
				{
					if ( ssFrame.offsetX != 0 || ssFrame.offsetY != 0 )
					{
						hasAnyOffsets = true;
						break;
					}
				}
			}
			
			// Check for params data.
			var params:Dynamic = Reflect.field( state, "params" );
			var behavior:BehaviorData = null;
			if ( hasAnyOffsets || params != null )
			{
				behavior = new BehaviorDataWithParams( params, frames, animName, behaviorFramesInt, true, 48 );
			}
			else
			{
				behavior = new BehaviorData( animName, behaviorFramesInt, true, 48 ); // why is this fixed to 48 FPS?
			}
			spritesheet.addBehavior( behavior );
			
		}
		
		// Name the spritesheet object
		var spritesheetName:String = Std.string( images[0] ).split(".")[0];
		spritesheet.name = ( spritesheetName.length > 0 ) ? spritesheetName : "undefined";
		return spritesheet;
	}
}