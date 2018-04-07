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

package com.firstplayable.hxlib.loader;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.display.anim.importers.BehaviorDataWithParams;
import com.firstplayable.hxlib.loader.ResMan.LoadCall;
import com.firstplayable.hxlib.loader.ResMan.PathMap;
import com.firstplayable.hxlib.loader.ResMan.ResCollection;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;
import com.firstplayable.hxlib.utils.Version;

import flash.display.LoaderInfo;
import flash.events.IEventDispatcher;
import haxe.Json;
import haxe.ds.StringMap;
#if ( openfl < "6.0" )
import openfl.Assets.AssetType;
#else
import openfl.utils.AssetType;
#end
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

#if spritesheet
import com.firstplayable.hxlib.display.anim.importers.ZoeImporterPlus;
import spritesheet.Spritesheet;
import spritesheet.data.BehaviorData;
import spritesheet.data.SpritesheetFrame;
#end

/**
 * A load object with file info.
 */
typedef ResContext =
{
	var src:String;
	@:optional var rename:String;
	@:optional var type:AssetType;
	@:optional var content:Dynamic;
}

/**
 * A queued load call.
 */
typedef LoadCall =
{
	var name:String;
	var onComplete:Void->Void;
	@:optional var loadTime:Int;
}

/**
 * Used to modify path prefixes, eg if we want to point 
 * to a different source dir for art assets based on device resolution
 */
typedef PathMap =
{
	var search:String;
	var replace:String;
}

/**
 * A list of urls.
 */
typedef ResCollection = Array<String>;

//changes list details here: https://wiki.1stplayable.com/index.php/Web/Haxe/ResManUpdates
// phase 4
//TODO: object ref tracking (if ref-cnt = 0, delete resource?)
// later
//TODO: swf integration
//TODO: switch callbacks to event driven system
//TODO: getImage compatibility with spritesheets
//TODO: getMovieClip compatibility with spritesheets
//TODO: openfl.Assets integration?

//TODO: audit public API for arg sanity (in progress)
//TODO: all incoming names should go through verifyPath for pathmap manip / sanity? (completely inconsistent, not started)
//TODO: policy: private API uses error() rather than warn() on "should not happen" conditions?


/**
 * Manages resources for easy loading.
 */
class ResMan
{
	//singleton ResMan instance
	public static var instance( get, null ):ResMan;
	private static function get_instance( ):ResMan
	{
		if ( instance == null )
		{
			instance = new ResMan();
		}
		return instance;
	}
	
	//special ids for error assets
	public static inline var MISSING_IMAGE:String = "MISSING_IMAGE";
	public static inline var MISSING_IMAGE_DATA:String = "MISSING_IMAGE_DATA";
	public static inline var MISSING_SOUND:String = "MISSING_SOUND";
	public static inline var MISSING_TEXT:String = "MISSING_TEXT";
	public static inline var MISSING_SHEET:String = "MISSING_SHEET";
	//name of default special libs
	public static inline var DEFAULT_LIB:String = "DEFAULT";
	public static inline var SPRITESHEET_LIB:String = "SPRITESHEET";
	
	//maps a library to a list of urls
	private var m_collections:StringMap<ResCollection>;
	private var m_collectionsLoaded:StringMap<Bool>;
	//maps a url to a res load object
	private var m_assets:StringMap<ResContext>;
	//expected number of items to load
	private var m_expectedLoads:Int;
	//current number of items loaded
	private var m_numLoads:Int;
	//list of things to load and their callbacks
	private var m_loadOrder:Array<LoadCall>;
	//the current loading object
	private var m_curLoad:LoadCall;
	private var m_curLoadURI:String = null; // for debug purposes only
	
	private var m_pathMap:PathMap = null;
	
	//percentage load completion of the currently loading list, [0-1]
	public var completion( get, null ):Float;
	private function get_completion():Float
	{
		if ( m_expectedLoads > 0 )
		{
			return m_numLoads / m_expectedLoads;
		}
		return 0;
	}
	
	//allow for domain loading override
	public var uriprefix:String = "";
	
	// If null, this'll be turned into a default querystring cachebuster (?v=something);
	// if other, will be appended as-is.
	// This means empty string = suppress cache buster.
	public var urisuffix:String = null;
	
	/**
	 * Creates a new resource manager
	 */
	function new ()
	{
		m_collections = new StringMap();
		m_collectionsLoaded = new StringMap();
		m_assets = new StringMap();
		m_loadOrder = [];
		m_numLoads = 0;
		m_expectedLoads = 0;
		
		createMissingAssets();
	}
	
	/**
	 * setup - creates assets to use for missing cases 
	 */
	private function createMissingAssets():Void
	{
		//generate missing assets
		var redX:Sprite = new Sprite();
		redX.graphics.lineStyle( 3, 0xFF0000 );
		redX.graphics.lineTo( 20, 20 );
		redX.graphics.moveTo( 0, 20 );
		redX.graphics.lineTo( 20, 0 );
		
		var missData:BitmapData = new BitmapData( Std.int( redX.width ), Std.int( redX.height ) );
		missData.draw( redX );
		
		var missImage:Bitmap = new Bitmap( missData );
		missImage.name = "MISSING_IMAGE";
		
		//TODO: create whitenoise/tone here
		var missSound:Sound = new Sound();
		
		var missText:String = "FILE_NOT_FOUND";
		
		//add missing assets
		m_assets.set( MISSING_IMAGE, { src:MISSING_IMAGE, content:missImage } );
		m_assets.set( MISSING_IMAGE_DATA, { src:MISSING_IMAGE_DATA, content:missData } );
		m_assets.set( MISSING_SOUND, { src:MISSING_SOUND, content:missSound } );
		m_assets.set( MISSING_TEXT, { src:MISSING_TEXT, content:missText } );
		
		#if spritesheet
		m_assets.set( MISSING_SHEET + ".sheet", { src:MISSING_SHEET, content:createMissingSheet() } );
		#end
	}
	
	#if spritesheet
	/**
	 * default spritesheet creation
	 * @return
	 */
	private function createMissingSheet():Spritesheet
	{
		var missData:BitmapData = cast m_assets.get( MISSING_IMAGE_DATA ).content;
		//frameInfo = [ frame0 pos, frame0 size, frame1 pos, frame1 size ]
		var frameInfo:Array<Int> = [ 0, Std.int( missData.width ), Std.int( missData.width * 0.1 ), Std.int( missData.width * 0.8 ) ];
		var missSheet:Spritesheet = new Spritesheet( missData, [
			new SpritesheetFrame( frameInfo[ 0 ], frameInfo[ 0 ], frameInfo[ 1 ], frameInfo[ 1 ] ),
			new SpritesheetFrame( frameInfo[ 2 ], frameInfo[ 2 ], frameInfo[ 3 ], frameInfo[ 3 ], frameInfo[ 2 ], frameInfo[ 2 ] )
		] );
		missSheet.addBehavior( new BehaviorData( "0", [ 0, 1 ], true, 6 ) );
		return missSheet;
	}
	#end
	
	//////////////////////////////
	//		PUBLIC FUNCS		//
	//////////////////////////////
	
	/**
	 * Registers a library and optional list to go with it. Mostly invoked from addRes().
	 * @param	lib		An Enum or String name of the library.
	 * @param	list	(opt) An array of load objects to regsiter.
	 */
	public function addLib( lib:Dynamic, list:Array<ResContext> = null ):ResCollection
	{
		var libName:String = Std.string( lib );
		
		var collection = m_collections.get( libName );
		if ( collection != null )
		{
			warn( "addLib - already exists: " + libName );
			return collection;
		}
		
		collection = [];
		m_collections.set( libName, collection );
		
		if ( list != null )
		{
			for ( res in list )
			{
				addRes( libName, res );
			}
		}
		
		return collection;
	}
	
	/**
	 * Adds a resource load object to a library. Creates the library if it doesn't exist.
	 * @param	name		An Enum or String name of the library. Use null if you don't want to peg a library.
	 * @param	res			The resource load object to add.
	 */
	public function addRes( aLibName:Dynamic, res:ResContext ):Void
	{
		var libName:String = ( aLibName != null ) ? Std.string( aLibName ) : DEFAULT_LIB;

		if ( warn_if( res == null, "addRes with null ResContext, ignoring; lib was: " + libName ) )
		{
			return;
		}
		
		if ( warn_if( res.src == null, "addRes with null ResContext.src, ignoring; lib was: " + libName ) )
		{
			return;
		}
		
		//if lib does not exist, create and use it
		var lib = m_collections.get( libName );
		if ( lib == null )
		{
			lib = addLib( libName );
		}

		res.src = verifyPath( res.src );
		
		//TODO: handle resource types in separate array structures

		// If the res.type is already set, trust it.
		// Otherwise use reasonable defaults.
		if ( res.type == null )
		{
			//infer resource type from extension
			// If "." is not found, will return whole string -- substring(-1+1) = substring(0)
			var ext:String = res.src.substring( res.src.lastIndexOf( "." ) + 1 );
			
			res.type = switch( ext.toLowerCase() )
				{
					case "png",
						 "jpg",
						 "gif":	AssetType.IMAGE;
					case "ogg",
						 "m4a",
						 "mp3",
						 "wav":	AssetType.SOUND;
					case "3ds": AssetType.BINARY;
					//case "swf":	AssetType.MOVIE_CLIP;
					case "bmp",
						 "tiff",
						 "swf":	null;
					default:	AssetType.TEXT;
				};
				
			if ( res.type == null )
			{
				warn( "Resource file extension not supported: " + ext );
				return;
			}
		}
		
		
		//register resource with library and assets
		var resKey:String = ( res.rename == null ) ? res.src : res.rename; // TODO verifyPath on res.rename?
		
		lib.push( resKey );
		
		var existingRes = m_assets.get( resKey );
		if ( existingRes != null )
		{
			if ( existingRes.src != res.src )
			{
				warn( "addRes - skipping duplicate key with new src: " + resKey + " at " + res.src + " vs old " + existingRes.src );
				return;
			}
			else if ( existingRes.content != null )
			{
				// This is common, when multiple libraries list the same resource.
				//log( "addRes - skipping duplicate key with same src but different data: " + resKey + " at " + res.src );
				return;
			}
			else
			{
				// This is also common for spritesheets: refilling a null res.content for same src.
				//log( "addRes - refilling duplicate key with same src but null data: " + resKey + " at " + res.src );
				// Fall through here.
			}
		}

		m_assets.set( resKey, res );
		//log( "asset '" + resKey + "' registered" );
	}
	
	/**
	 * Swaps a res with libName to the provided context.
	 * Useful for swapping things like paist menus etc.
	 * WARNING: Only tested with paist menus for now.
	 * Please note if you determine certain asset types do or do not work.
	 * @param	libName
	 * @param	res
	 */
	public function updateRes(libName:String, res:ResContext):Void
	{
		var lib = m_collections.get(libName);
		if (lib == null)
		{
			addRes(libName, res);
			return;
		}
		
		res.src = verifyPath( res.src );
		var resKey:String = ( res.rename == null ) ? res.src : res.rename; // TODO verifyPath on res.rename?
		
		var resIndex:Int = lib.indexOf(resKey);
		if (resIndex == -1)
		{
			Debug.warn("something's gone wrong. We have lib " + libName + ", but nothing tied to: " + resKey);
			return;
		}
		
		m_assets.set(resKey, res);
	}
	
	/**
	 * Loads a library or single asset by name. This method is asynchronous.
	 * Subsquent calls to load while currently loading will push the next items onto a list.
	 * @param	name		String or Enum name of the library or asset.
	 * @param	onComplete	(opt) callback invoked when all loading is complete.
	 */
	public function load( name:Dynamic, onComplete:Void->Void = null ):Void
	{
		var resOrLibName = Std.string( name ); // TODO verifyPath?
		var loadCall:LoadCall = { name:resOrLibName, onComplete:onComplete };

		if ( m_collections.exists( resOrLibName ) )
		{
			// TODO: possibly unintuitive, load actually happens later?
			m_collectionsLoaded.set( resOrLibName, true ); // may set repeatedly
			//trace( "ResMan: set collection " + resOrLibName + " status loading/loaded." );
		}

		//if currently loading, push requested load call to end of queue
		if ( m_curLoad != null )
		{
			m_loadOrder.push( loadCall );
			return;
		}
		
		/**
		 * if nothing in queue, load. otherwise grab next load.
		 *   if list is empty, then this is the first load (nothing is loading).
		 *   if list is not empty, then we previously hit the above if-statement,
		 *     so we're returning to load the next item in the list.
		 */
		m_curLoad = ( m_loadOrder.length == 0 ) ? loadCall : m_loadOrder.shift();
		
		//carry on with loading
		var lib:ResCollection = getLoadList( m_curLoad.name );
		m_expectedLoads = lib.length;
		
		//log( "Loading: " + m_curLoad.name );
		m_curLoad.loadTime = Lib.getTimer();
		
		//nothing found to load
		if ( lib.length == 0 )
		{
			warn( "Cannot load empty or nonexistent asset / library: " + resOrLibName );
			checkLoadProgress();
			return;
		}
		
		//try load
		for ( res/*:String*/ in lib )
		{
			if ( isLoaded( res ) )
			{
				//log( "Resource already loaded; skipping '" + res + "'" ); // common with overlapping libs
				--m_expectedLoads;
				continue;
			}
			
			loadRes( m_assets.get( res ) );
		}
		
		//everything already loaded
		if ( m_expectedLoads == 0 )
		{
			log( "Asset / library is already loaded: " + resOrLibName );
			checkLoadProgress();
			return;
		}
	}
	
	/**
	 * Unloads a library or single asset by name. This method is synchronous.
	 * @param	name		String or Enum name of the library or asset.
	 * @param	safe		true (default) to check other asset libraries for references; avoids unload if references still exist
	 */
	//TODO: add ref count tracking before unload
	public function unload( name:Dynamic, safe:Bool = true ):Void
	{
		var resOrLibName:String = Std.string( name );
		var lib:ResCollection = getLoadList( resOrLibName );
		
		//log( "ResMan.unload attempt on " + resOrLibName );
		
		//nothing to unload
		if ( lib.length == 0 )
		{
			log( "Asset / library cannot be unloaded (empty or doesn't exist): " + resOrLibName );
			return;
		}
		
		for ( res/*:String*/ in lib )
		{
			var resContext = m_assets.get( res );
			if ( resContext == null )
			{
				// A null value in m_assets map shouldn't occur.  Discard.
				m_assets.remove( res );
				continue;
			}
			if ( resContext.content == null )
			{
				continue; //already unloaded
			}

			// Search for other references.
			if ( safe )
			{
				var foundOtherLiveRef = false;
				for ( otherName in m_collections.keys() )
				{
					if ( otherName == resOrLibName )
					{
						// Don't search ourselves (if we're a lib).
						continue;
					}
					
					var loaded = m_collectionsLoaded.get( otherName );
					if ( loaded == null || loaded == false )
					{
						// Don't search unloaded libs;
						// by definition they're not holding a ref.
						continue;
					}
					
					var otherLib:ResCollection = getLoadList( otherName );
					var foundLoc = otherLib.indexOf( res );
					if ( foundLoc >= 0 ) // TODO this is O(N*M) stringcompares, yuck
					{
						//log( "ResMan: unload skipped, still ref'd " + res + " in lib " + otherName ); // common
						foundOtherLiveRef = true;
						break; // Found a probably-live reference. Stop searching.
					}
				}
				
				if ( foundOtherLiveRef )
				{
					// Don't unload this.  Next resource.
					continue;
				}
			
			}
			
			//log( "ResMan.unload res: " + res );
			
			//unload & cleanup
			switch( resContext.type )
			{
				case AssetType.IMAGE:
					var loader = StdX.as( resContext.content, Loader );
					if ( loader != null )
					{
						var img = StdX.as( loader.content, Bitmap );
						loader.unload();
						if ( img != null )
						{
							// TODO: this seems dangerous, what if someone else 
							// has a ref to img.bitmapData?  Should just null?
							img.bitmapData.dispose();
						}
					}
				
				case AssetType.SOUND, AssetType.MUSIC:
					var loader:Sound = cast resContext.content;
					loader.close();
				
				case AssetType.TEXT:
					//special case for unloading spritesheets
					if ( ( resContext.src != null ) && ( resContext.src.indexOf( ".json" ) > -1 ) )
					{
						var sheet:ResContext = m_assets.get( res + ".sheet" );
						if ( sheet != null )
						{
							sheet.content = null;
						}
					}
				default:
					warn( "Tried to unload unsupported resource type: " + Std.string( resContext.type ) );
			}
			
			resContext.content = null;
		}
		
		if ( m_collections.exists( resOrLibName ) )
		{
			m_collectionsLoaded.set( resOrLibName, false );
		}
		
		log( "Unloading complete: " + resOrLibName );
	}
	
	/**
	 * Finds an image by name as a Bitmap.
	 * @param	name			The name of the image to find.
	 * @param	byRef	optional; true (default) to get the instance, false to get a new *SHALLOW* clone, reusing any cached BitmapData.
	 * @return
	 */
	public function getImage( name:String, byRef:Bool = true ):Bitmap
	{
		// name verified in getImageUnsafe()
		var image:Bitmap = getImageUnsafe( name, byRef );
		
		if ( image == null )
		{
			//error finding resource
			warn( "Image not found: " + Std.string( name ) );
			image = cast m_assets.get( MISSING_IMAGE ).content;
			if ( ! byRef && ( image != null ) )
			{
				image = new Bitmap( image.bitmapData );
				image.name = name;
			}
			
		}
		
		return image;
	}
	
	/**
	 * Like getImage(), but returns null and doesn't warn() if the image is not found.
	 * Use in cases where you expect (and are ok with) the possibility of the image not existing.
	 * @param	byRef	optional; true (default) to get the instance, false to get a new *SHALLOW* clone, reusing any cached BitmapData.
	 */
	public function getImageUnsafe( name:String, byRef:Bool = true ):Bitmap
	{
		name = verifyPath( name );
		
		var image:Bitmap = null;
		var res:ResContext = m_assets.get( name );
		
		// resource exists
		if ( res != null )
		{
			if ( Std.is( res.content, Loader ) )
			{
				var loader:Loader = cast res.content;
				image = StdX.as( loader.content, Bitmap );
			}
			else if ( Std.is( res.content, Bitmap ) )
			{
				image = cast res;
			}
			
			if ( image != null )
			{
				if ( ! byRef )
				{
					// Wants a copy.
					image = new Bitmap( image.bitmapData );
					image.name = name;
				}
			}
			else
			{
				// Image still null.  BitmapData?
				var bitmapData = StdX.as( res.content, BitmapData );
				if ( bitmapData != null )
				{
					// No byRef semantics here, a copy for everyone.
					image = new Bitmap( bitmapData );
					image.name = name;
				}
			}
		}
		
		#if spritesheet
		if ( image == null )
		{
			// Image still null (no res, res not yet loaded, or unknown type).
			// See if it lives in a spritesheet.
			var sheetName:String = The.resourceMap.getSheetPath( name );
			if ( sheetName != The.resourceMap.INVALID )
			{
				image = getFrameFromSheet( name, sheetName, byRef, false /* false = unsafe */ );
			}
		}
		#end
		
		return image;
	}
	
	/**
	 * @see getImage, but returns an OPSprite (composite object / DisplayObjectContainer) that obeys refpt/bbox/etc.
	 * @return OPSprite instance, possibly broken image, never null.
	 */
	public function getSprite( name:String, byRef:Bool = true ):OPSprite
	{
		var bitmapData:BitmapData = doGetImageData( name, byRef, true /* true = safe */ );
		var sprite:OPSprite = OPSprite.create( bitmapData );
		sprite.name = name;
		return sprite;
	}

	/**
	 * @see getImage, but returns an OPSprite (composite object / DisplayObjectContainer) that obeys refpt/bbox/etc.
	 * @return OPSprite instance or null.
	 */
	public function getSpriteUnsafe( name:String, byRef:Bool = true ):OPSprite
	{
		var bitmapData:BitmapData = doGetImageData( name, byRef, false /* false = unsafe */ );
		if ( bitmapData != null )
		{
			var sprite:OPSprite = OPSprite.create( bitmapData );
			sprite.name = name;
			return sprite;
		}
		
		return null;
	}

	
	#if spritesheet
	/*
	 * TODO: bool args to flags
	 * @param	byRef	true to get cached instance (TODO), false to get a new *SHALLOW* clone, reusing any cached BitmapData.
	 * @param   safe    true to get missing image data if missing, false to return null if missing
	 */
	private function getFrameFromSheet( frameName:String, sheetName:String, byRef:Bool, safe:Bool ):Bitmap
	{
		// TODO (likely breaks existing code): avoid new Bitmap if byRef=true?
		// Always get a ref to existing BitmapData.  If client wanted a deep copy, can do so using getFrameDataFromSheet( ..., false ).
		var image:Bitmap = new Bitmap( getFrameDataFromSheet( frameName, sheetName, true /* true = byRef */, safe /* true = safe */ ) );
		if ( image != null )
		{
			image.name = sheetName + "--" + frameName;
		}
		return image;
	}
	
	/*
	 * TODO: bool args to flags
	 * @param	byRef	true to get the instance, false to get a new deep clone.
	 * @param   safe    true to get missing image data if missing, false to return null if missing
	 */
	private function getFrameDataFromSheet( frameName:String, sheetName:String, byRef:Bool, safe:Bool ):BitmapData
	{
		var frameData:BitmapData = null;
		
		// Always getSpritesheetUnsafe with byRef=true, we'll copy later if needed.
		// Cloning the spritesheet would be really heavy!  We're generally only looking to clone the sprite itself.
		var sheet:Spritesheet = getSpritesheetUnsafe( sheetName, true );
		if ( sheet != null )
		{
			var data:BehaviorData = sheet.behaviors.get( frameName );
			if ( data != null ) // verifies frameName
			{
				var animFrameIndex:Int = 0; //< assume a 1-1 mapping of name -> frame
				frameData = BehaviorDataWithParams.getCacheData( data, sheet, animFrameIndex );
			}
		}
		
		if ( safe && ( frameData == null ) )
		{
			//error finding resource
			warn( "Image '" + frameName + "' not found in sheet: " + sheetName );
			frameData = cast m_assets.get( MISSING_IMAGE_DATA ).content;
		}

		if ( ! byRef && ( frameData != null ) )
		{
			frameData = frameData.clone();
		}
		
		return frameData;
	}
	#end
	

	private function doGetImageData( name:String, byRef:Bool, safe:Bool ):BitmapData
	{
		name = verifyPath( name );
		
		var bitmapData:BitmapData = null;
		var res:ResContext = m_assets.get( name );
		
		//resource exists
		if ( res != null )
		{
			if ( Std.is( res.content, Loader ) )
			{
				var loader:Loader = cast res.content;
				var bitmap = StdX.as( loader.content, Bitmap );
				if ( bitmap != null )
				{
					bitmapData = bitmap.bitmapData;
				}
			}
			else if ( Std.is( res.content, Bitmap ) )
			{
				// TODO: it's a little ridiculous that BitmapData_onLoad
				// encapsulates this and we just throw away the Bitmap
				// shell; avoid wrapping it in the first place.
				var bitmap:Bitmap = cast res.content;
				bitmapData = bitmap.bitmapData;
			}
			else if ( Std.is( res.content, BitmapData ) )
			{
				bitmapData = cast res.content;
			}
		}

		#if spritesheet
		if ( bitmapData == null )
		{
			// BitmapData still null (no res, res not yet loaded, or unknown type).
			// See if it lives in a spritesheet.
			var sheetName:String = The.resourceMap.getSheetPath( name );
			if ( sheetName != The.resourceMap.INVALID )
			{
				// Always getFrameDataFromSheet with byRef=true, we'll copy later if needed.
				bitmapData = getFrameDataFromSheet( name, sheetName, true /* true = byRef */, safe );
			}
		}
		#end
		
		if ( safe && ( bitmapData == null ) )
		{
			//error finding resource
			warn( "ImageData not found: " + name );
			bitmapData = cast m_assets.get( MISSING_IMAGE_DATA ).content;
		}
		
		if ( ! byRef && ( bitmapData != null ) )
		{
			bitmapData = bitmapData.clone();
		}
		
		return bitmapData;
	}
	
	/**
	 * Finds an image by name as a BitmapData.
	 * Note: byRef=false is only needed if you intend to edit the bitmap data without
	 * changing the original. If simply making a new bitmap with this data, use the original.
	 * @param	name			The name of the image to find.
	 * @param	byRef	optional; true (default) to get the instance, false to get a new deep clone.
	 * @return
	 */
	public function getImageData( name:String, byRef:Bool = true ):BitmapData
	{
		return doGetImageData( name, byRef, true /* true = safe */ );
	}
	
	/**
	 * @see getImageData, but may return null if resource is not found.
	 */
	public function getImageDataUnsafe( name:String, byRef:Bool = true ):BitmapData
	{
		return doGetImageData( name, byRef, false /* false = unsafe */ );
	}
	
	/**
	 * Finds a sound by name as a Sound.
	 * @param	name		The name of the sound to find.
	 * @return
	 */
	public function getSound( name:String ):Sound
	{
		name = verifyPath( name );
		var res:ResContext = m_assets.get( name );
		
		//resource exists and is loaded
		if ( ( res != null ) && Std.is( res.content, Sound ) )
		{
			return res.content;
		}
		
		//error finding resource
		warn( "Sound not found: " + name );
		return cast m_assets.get( MISSING_SOUND ).content;
	}
	
	/**
	 * Finds a file (content) by name as a ByteArray.
	 * @param	name		The name of the file content to find.
	 * @return
	 */
	public function getBytes( name:String ):ByteArray
	{
		name = verifyPath( name );
		var res:ResContext = m_assets.get( name );
		
		//resource exists
		if ( res != null )
		{
			//file was loaded normally
			if ( Std.is( res.content, URLLoader ) )
			{
				var urlLoader:URLLoader = cast res.content;
				if ( urlLoader.dataFormat == URLLoaderDataFormat.BINARY )
				{
					return cast urlLoader.data;
				}
				else
				{
					log( "Incorrect dataformat " + Std.string( urlLoader.dataFormat ) + " for: " + name );
				}
			}
		}
		
		//error finding resource
		warn( "Bytes not found or not loaded: " + name );
		return new ByteArray(); // TODO: MISSING_BYTES?
	}	
	
	/**
	 * Finds a file (content) by name as a String.
	 * @param	name		The name of the file content to find.
	 * @return
	 */
	public function getText( name:String ):String
	{
		name = verifyPath( name );
		var res:ResContext = m_assets.get( name );
		
		//resource exists
		if ( res != null )
		{
			//content prop set in load object
			if ( Std.is( res.content, String ) )
			{
				return res.content;
			}
			//file was loaded normally
			else if ( Std.is( res.content, URLLoader ) )
			{
				var urlLoader:URLLoader = cast res.content;
				// urlLoader.data could be a ByteArray for URLLoaderDataFormat.BINARY,
				// or URLVariables for URLLoaderDataFormat.VARIABLES,
				// but we're using default text.  If this changes, we'll get an
				// interesting string here, but not null.  (Maybe "null", though.)
				return Std.string( urlLoader.data );
			}
		}
		
		//error finding resource
		warn( "Text not found or not loaded: " + name );
		return cast m_assets.get( MISSING_TEXT ).content;
	}
	
	/**
	 * Finds json (content), parses if needed.
	 * @param	name		The name of the file content to find.
	 * @return  a Dynamic json structure, or null.
	 */
	public function getJson( name:String ):Dynamic
	{
		name = verifyPath( name );
		var res:ResContext = m_assets.get( name );
		
		//resource exists
		var json:Dynamic = null;
		if ( res != null )
		{
			//content prop set in load object (String)
			if ( Std.is( res.content, String ) )
			{
				Debug.log( "Slow Json.parse, convert to anonymous structure if possible: " + name );
				json = Json.parse( res.content );
				if ( json != null )
				{
					// TODO: Cache this parse?
					//res.content = json;
				}
			}
			//file was loaded normally
			else if ( Std.is( res.content, URLLoader ) )
			{
				var urlLoader:URLLoader = cast res.content;
				// urlLoader.data could be a ByteArray for URLLoaderDataFormat.BINARY,
				// or URLVariables for URLLoaderDataFormat.VARIABLES,
				// but we're using default text.  If this changes, we'll get an
				// interesting string here, but not null.  (Maybe "null", though.)
				json = Json.parse( Std.string( urlLoader.data ) );
				if ( json != null )
				{
					// TODO: Cache this parse, drop urlLoader?
					//res.content = json;
				}
			}
			//content prop set in load object (anonymous structure)
			else if ( res.content != null )
			{
				json = res.content;
			}
		}
		
		return json;		
	}
	
	
	/**
	 * NOT IMPLEMENTED!
	 * Finds a movie clip by name as a MovieClip.
	 * @param	name			The name of the clip to find.
	 * @param	byRef	optional; true (default) to get the instance, false to get a new deep clone.
	 * @return
	 */
	public function getMovieClip( name:String, byRef:Bool ):MovieClip
	{
		warn( "NOT IMPLEMENTED" );
		//TODO: don't forget #if swf define
		
		//error finding resource
		warn( "MovieClip not found: " + Std.string( name ) );
		return null;
	}
	
	/**
	 * Converts a Paist menu name into its json file url.
	 * @param	name	The name of the menu, String or Enum.
	 * @return	Url of json file representing Paist menu; "" if not found.
	 */
	public function getPaistFileByName( name:Dynamic ):String
	{
		// TODO: identify whether we'd ever need to verifyPath here
		var libName:String = name;
		var lib:ResCollection = m_collections.get( libName );
		
		if ( lib == null )
		{
			warn( "Paist library not found: " + libName );
			return "";
		}
		
		for ( res/*:String*/ in lib )
		{
			//layouts/ should only contain .json files, but we can add a .json check if needed
			if ( res.indexOf( "layouts/" ) > -1 )
			{
				return res;
			}
		}
		
		//error finding resource
		warn( "Paist menu does not contain layout info: " + libName );
		return "";
	}
	
#if spritesheet
	/**
	 * Finds or creates a spritesheet by name as a Spritesheet.
	 * @param	name			Name of the spritesheet's json file.
	 * @param	byRef	optional; true (default) to get the instance, false to reload from scratch (note difference: reload vs clone)
	 * @return
	 */
	public function getSpritesheet( name:String, byRef:Bool = true ):Spritesheet
	{
		var sheet:Spritesheet = getSpritesheetUnsafe( name, byRef );
		
		if ( sheet != null )
		{
			return sheet;
		}
		else
		{
			//error finding resource
			log( "Spritesheet not found or not loaded: " + Std.string( name ) );

			if( byRef )
			{
				return cast m_assets.get( MISSING_SHEET ).content;
			}
			else
			{
				return createMissingSheet();
			}
		}
	}
	
	/**
	 * Like getSpritesheet(), but returns null when the spritesheet doesn't exist
	 * @param	byRef	optional; true (default) to get the instance, false to reload from scratch (note difference: reload vs clone)
	 */
	public function getSpritesheetUnsafe( name:String, byRef:Bool = true ):Spritesheet
	{
		// TODO verifypath?
		
		var sheetName:String = name + ".sheet";
		var res:ResContext = m_assets.get( sheetName );
		
		// spritesheet resource exists and is loaded
		if ( ( res != null ) && Std.is( res.content, Spritesheet ) )
		{
			if ( byRef )
			{
				//log( 'cache hit (byRef): $sheetName' );
				return cast res.content;
			}
			else
			{
				//log( 'cache hit->miss (!byRef): $sheetName' );
				// TODO: makesheet is heavy.  It'd be nice to have a .clone() instead.
				return makeSheet( name );
			}
		}
		else if ( res != null )
		{
			//log( 'cache miss with non-null res on $sheetName: $res.content' );
		}
		else
		{
			//log( 'cache miss with null res on $sheetName' );
		}
		//else resource does not exist, so make one
		
		//json is good, register new sheet
		if ( isLoaded( name ) )
		{
			var s:Spritesheet = makeSheet( name );
			if ( byRef )
			{
				// Only store res if this was not a deep reload.
				//log( 'cache miss->add (byRef): $sheetName' );
				addRes( SPRITESHEET_LIB, { src:sheetName, content:s } );
			}
			else
			{
				//log( 'cache miss->noadd (!byRef): $sheetName' );
			}
			return s;
		}
		//else cannot make sheet
		
		return null;
	}
	
	/**
	 * Makes a new sprite sheet.
	 * @param	name	name of the sheet to make
	 * @return
	 */
	private function makeSheet( name:String ):Spritesheet
	{
		// Get and parse json.
		var json:Dynamic = getJson( name );
		if ( json == null )
		{
			// Couldn't find sheet, or not expected type.  Don't bother to hand along, sheet won't be made.
			return null;
		}
		
		name = verifyPath( name );
		var resContext = m_assets.get( name );
		
		var srcPath:String = "";
		if ( ( resContext != null ) && ( resContext.src != null ) )
		{
			srcPath = resContext.src;
		}
		
		// If slash is not found (pos = -1), basePath will be empty substring (endIndex = -1 + 1).
		var basePath:String = srcPath.substring( 0, srcPath.lastIndexOf( "/" ) + 1 );
		return ZoeImporterPlus.parse( json, basePath );
	}
#end // #if spritesheet
	
	public function isAnim( name:String ):Bool
	{
		#if spritesheet
		name = verifyPath( name );
		var sheetName:String = The.resourceMap.getSheetPath( name );
		var sheet:Spritesheet = getSpritesheetUnsafe( sheetName, true );
		
		if ( sheet != null )
		{
			var data:BehaviorData = sheet.behaviors.get( name );
			
			if ( data != null )
			{
				return ( data.frames.length > 1 );
			}
		}
		#end
		
		return false;
	}
	
	
	/**
	 * Checks whether an asset exists at all. If type is specified, then checks if it exists as a specific type.
	 * @param	name	The name of the asset to check for.
	 * @param	type	If specified, additionally checks that the object matches the type.
	 * 					For items that live in a spreadsheet, type must be null
	 * @return
	 */
	public function isRegistered( name:String, type:AssetType = null ):Bool
	{
		name = verifyPath( name );
		
		var asset:ResContext = m_assets.get( name );
		if ( ( asset != null ) && ( ( type == null ) || ( asset.type == type ) ) )
		{
			// Found and don't care about type, or found and matching type.
			return true;
		}
		else if ( ( type == null ) || ( type == AssetType.IMAGE ) )
		{
			// Not found or not matching type. Check for a spritesheet.
			var sheetName:String = The.resourceMap.getSheetPath( name );
			return ( sheetName != The.resourceMap.INVALID );
		}
		
		return false;
	}
	
	/**
	 * Checks whether the asset is loaded (ready for use).
	 * @param	name	The name of the asset to check for.
	 * @return
	 */
	public function isLoaded( name:String ):Bool
	{
		name = verifyPath( name );
		var asset:ResContext = m_assets.get( name );
		return ( ( asset != null ) && ( asset.content != null ) );
	}
	
	/**
	 * Checks whether all elements of a library are loaded.
	 * @param	name	String or Enum name of the library to check for.
	 * @return
	 */
	public function isLibLoaded( name:Dynamic ):Bool
	{
		var libName:String = Std.string( name );
		
		var lib:ResCollection = m_collections.get( libName );
		
		if ( lib == null )
		{
			warn( "Library does not exist: " + libName );
			return false;
		}
		
		for ( res/*:String*/ in lib )
		{
			if ( !isLoaded( res ) )
			{
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Used to modify path prefixes, eg if we want to point 
	 * to a different source dir for art assets based on device resolution
	 * @param	s  - the part of the path to be replaced
	 * @param	r - the new path to use in place of "search"
	 */
	public function mapPathPrefix( s:String, r:String ):Void
	{
		if ( m_pathMap != null )
		{
			warn( "We are already mapping '" + m_pathMap.search + "' -> '" + m_pathMap.replace 
				+ "'; this will be overwritten with: '" + s + "' -> '" + r );
		}
		
		m_pathMap = { search:s, replace:r };
	}
	
	//////////////////////////////
	//		INTERNAL FUNCS		//
	//////////////////////////////
	
	/**
	 * Handles loading of resources.
	 * @param	res		The resource load object to load.
	 */
	private function loadRes( res:ResContext ):Void
	{
		if ( ( res == null ) || ( res.src == null ) || ( res.type == null ) )
		{
			warn( "ResMan: bad res passed to loadRes: " + Std.string( res ) );
			return;
		}
		
		
		var dispatcher:IEventDispatcher = null;
		var loader:Dynamic = null;
		switch ( res.type )
		{
			case AssetType.IMAGE:
			{
				var l:Loader = new Loader();
				dispatcher = l.contentLoaderInfo;
				loader = l;
			}
			case AssetType.SOUND, AssetType.MUSIC:
			{
				var s:Sound = new Sound();
				dispatcher = s;
				loader = s;
			}
			case AssetType.TEXT:
			{
				var t:URLLoader = new URLLoader();
				dispatcher = t;
				loader = t;
			}
			case AssetType.BINARY:
			{
				var t:URLLoader = new URLLoader();
				t.dataFormat = URLLoaderDataFormat.BINARY;
				dispatcher = t;
				loader = t;
			}
			default:
			{
				warn( "ResMan: unknown asset type: " + Std.string( res.type ) );
				return; // <-- EARLY EXIT ---------------------------------
			}
		}
		
		if ( dispatcher != null )
		{
			dispatcher.addEventListener( Event.COMPLETE, onLoadSuccess );
			dispatcher.addEventListener( IOErrorEvent.IO_ERROR, onLoadError );
		}
		
		//save the loader in our data set
		res.content = loader;
		if ( loader != null )
		{
			// Check to see if we need to craft a cache-busting querystring.
			if ( urisuffix == null )
			{
				var versionInfo:String = Version.versionInfo;
				if ( versionInfo != null && versionInfo.length > 0 )
				{
					// Let's just make this slightly easier to read...
					versionInfo = StringTools.replace( versionInfo, ":", "-" );
					versionInfo = StringTools.replace( versionInfo, "\t", "__" );
					versionInfo = StringTools.replace( versionInfo, " ", "_" );
					// but still urlEncode anyway, in case anything slipped through.
					urisuffix = "?v=" + StringTools.urlEncode( versionInfo );
				}
				else
				{
					// No version info.  Don't ask again.
					urisuffix = "";
				}
			}

			// Dynamic dispatch.  =(  Should be unnecessary, we know the type.
			var uri:String =
#if ios
			                 "assets/" + 
#end
			                 uriprefix + res.src + urisuffix;

			m_curLoadURI = uri;
			loader.load( new URLRequest( uri ) );
		}
	}
	
	/**
	 * Triggered when an io error occurs.
	 * @param	e	IOErrorEvent
	 */
	//TODO: extend UrlLoader to append a url variable
	private function onLoadError( e:IOErrorEvent ):Void
	{
		//TODO: find resource object, set .content back to null
		// (Don't do the above.  If the load failed, we might want to try it again.
		// IO_ERROR is not necessarily terminal.)
		
		var dispatcher = StdX.as( e.currentTarget, IEventDispatcher );
		if ( dispatcher != null )
		{
			dispatcher.removeEventListener( Event.COMPLETE, onLoadSuccess );
			dispatcher.removeEventListener( IOErrorEvent.IO_ERROR, onLoadError );
		}
		
		var loaderInfo:LoaderInfo = StdX.as( e.currentTarget, LoaderInfo );
		var url:String = ( loaderInfo != null ) ? loaderInfo.url : m_curLoadURI;
		
		--m_expectedLoads;
		warn( "Load failed from: " + Std.string( url ) + "\n" + Std.string( e.text ) );
		checkLoadProgress();
	}
	
	/**
	 * Triggered on successful load.
	 * @param	e	Event
	 */
	private function onLoadSuccess( e:Event ):Void
	{
		var dispatcher = StdX.as( e.currentTarget, IEventDispatcher );
		if ( dispatcher != null )
		{
			dispatcher.removeEventListener( Event.COMPLETE, onLoadSuccess );
			dispatcher.removeEventListener( IOErrorEvent.IO_ERROR, onLoadError );
		}
		
		var url:String = null;

		// This will only be LoaderInfo if coming from Loader (e.g. IMAGE);
		// for TEXT we'll get URLLoader, and for AUDIO we'll get Sound.
		var loaderInfo:LoaderInfo = StdX.as( e.currentTarget, LoaderInfo );
		if ( loaderInfo != null )
		{
			url = loaderInfo.url;
			var obj = StdX.as( loaderInfo.content, DisplayObject );
			if ( obj != null )
			{
				obj.name = url;
			}
		}

		++m_numLoads;
		//log( "load completed! '" + Std.string( url ) + "' (" + ( completion * 100 ) + "% of '" + m_curLoad.name + "')" );
		checkLoadProgress();
	}
	
	/**
	 * Checks if the current load request is finished.
	 */
	private function checkLoadProgress():Void
	{
		//done loading
		if ( m_numLoads == m_expectedLoads )
		{
			m_curLoad.loadTime = Lib.getTimer() - m_curLoad.loadTime;
			log( "loading completed for '" + m_curLoad.name + "', ms: " + m_curLoad.loadTime );
			
			if ( m_curLoad.onComplete != null )
			{
				m_curLoad.onComplete();
			}
			
			m_curLoad = null;
			m_expectedLoads = 0;
			m_numLoads = 0;
			
			//more to load
			if ( m_loadOrder.length > 0 )
			{
				var newLoad:LoadCall = m_loadOrder[ 0 ];
				load( newLoad.name, newLoad.onComplete );
			}
		}
	}
	
	/**
	 * Gets an array of each item needing to be loaded/unloaded.
	 * @param	name	Name of the item or library.
	 * @return
	 */
	private function getLoadList( name:Dynamic ):ResCollection
	{
		var resName:String = Std.string( name );
		
		//check if a library
		var list:ResCollection = m_collections.get( resName );
		if ( list != null )
		{
			//we are loading a list
			return list;
		}
		else if ( m_assets.exists( resName ) )
		{
			//we are loading a single asset
			return [ resName ];
		}
		else
		{
			//not a library or a single asset, list is empty.
			return [];
		}
	}
	
	
	public function verifyPath( path:String ):String
	{
		// Please keep this safe to apply repeatedly (idempotent).
		// Also, please avoid mutating any of the MISSING_* paths.
		if ( path == null )
		{
			path = "";
		}
		else if ( m_pathMap != null )
		{
			path = StringTools.replace( path, m_pathMap.search, m_pathMap.replace );
		}
		
		return path;
	}
	
	/** Release any cached data that we can safely recreate. **/
	public function clearCachedData():Void
	{
		//log( "ResMan: clearCachedData" );
		
		for ( res in m_assets )
		{
			if ( ( res != null ) && Std.is( res.content, Spritesheet ) )
			{
				// Release whole Spritesheet, including
				// behavior (BitmapDataWithParams) caches,
				// and frame (BitmapData) caches.
				//
				// It will be remade with makeSheet if needed (fixed as of 2017-06-09-1210).
				res.content = null;
			}
		}
		
	}

	/** See StateManager; callback for low-water point in state transition
	 * after previous state exit but before new state enter. */
	public function onSetState():Void
	{
		clearCachedData();
	}
	
}