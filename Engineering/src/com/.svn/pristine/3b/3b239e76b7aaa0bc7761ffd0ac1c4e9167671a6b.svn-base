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

package com.firstplayable.hxlib.loader;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.loader.ResMan;

enum LibraryType
{
	PAIST;				//Libraries formed via PaistManifest
	SPRITESHEET;		//A Library with an Image file tied to it's json data file
	SPRITESHEET_IMAGE;
	SPRITESHEET_DATA;
	LAYOUT;
	AUDIO;
	BITMAP_FONT;
}

/**
 * A definition of a given library used by this class.
 */
typedef LibraryDef =
{
	name:String,
	type:LibraryType
}

/**
 * Class that loads the provided collection of libraries in order, 
 * runs a callback whenever each asset loads, as well as an aditional callback
 * when all assets complete.
 */
class LibraryLoader
{
	private static inline var HUSH:Bool = true;
	
	/**
	 * Helper function that determines if a provided object is a Library list.
	 * @param	object
	 * @return
	 */
	public static function isLibraryList(object:Dynamic):Bool
	{
		if (object == null)
		{
			return false;
		}
		
		if (Std.is(object, List))
		{
			var castList:List<Dynamic> = cast object;
			var firstElement:Null<Dynamic> = castList.first();
			if (firstElement != null)
			{
				/**
				 * Will be considered a LibraryDef if it has exactly two fields,
				 * a string and a LibraryType called name, and type.
				 */
				var fields:Array<String> = Reflect.fields(firstElement);
				if (fields.length != 2)
				{
					return false;
				}
				
				if (!Reflect.hasField(firstElement, "name"))
				{
					return false;
				}
				
				var myName:Dynamic = Reflect.field(firstElement, "name");
				if (!Std.is(myName, String))
				{
					return false;
				}
				
				if (!Reflect.hasField(firstElement, "type"))
				{
					return false;
				}
				
				var myType:Dynamic = Reflect.field(firstElement, "type");
				if (Std.is(myType, LibraryType))
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * Recursively pops off and loads the next file, calling "callback" when done.
	 * @param	libraries
	 * @param	updateCallback (float is the percentage of load complete expressed from 0 to 1)
	 * @param	callback
	 */
	public static function loadLibraries(libraries:List<LibraryDef>, updateCallback:Float->Void, completeCallback:Void -> Void):Void
	{
		var numLibraries:Int = libraries.length;
		loadLibrariesHelper(libraries, updateCallback, completeCallback, numLibraries);
	}
	
	/**
	 * Helper function for loadLibraries that handles tracking load progress
	 * @param	libraries
	 * @param	updateCallback
	 * @param	completeCallback
	 * @param	totalLibraries
	 */
	private static function loadLibrariesHelper(libraries:List<LibraryDef>, 
		updateCallback:Float->Void, completeCallback:Void -> Void,
		totalLibraries:Int):Void
	{
		if (libraries.length == 0)
		{
			if (!HUSH)
			{
				Debug.log("Finished loading " + totalLibraries + " libraries!");
			}
			
			if (completeCallback != null)
			{
				completeCallback();
			}
		}
		else
		{
			if (updateCallback != null)
			{
				updateCallback(1 - (libraries.length / totalLibraries));
			}
			
			var nextLibrary:LibraryDef = libraries.pop();
			if (!HUSH)
			{
				Debug.log("Loading: " + Std.string(nextLibrary));
			}
			var loadCallback:Void -> Void = function(){loadLibrariesHelper(libraries, updateCallback, completeCallback, totalLibraries); };
			switch(nextLibrary.type)
			{
				case PAIST:
				{
					ResMan.instance.load(nextLibrary.name, loadCallback);
				}
				case SPRITESHEET:
				{
					ResMan.instance.load(nextLibrary.name, loadCallback);
				}
				case SPRITESHEET_IMAGE:
				{
					ResMan.instance.load(nextLibrary.name, loadCallback);
				}
				case SPRITESHEET_DATA:
				{
					ResMan.instance.load(nextLibrary.name, loadCallback);
				}
				case LAYOUT:
				{
					ResMan.instance.load(nextLibrary.name, loadCallback);
				}
				case AUDIO:
				{
					WebAudio.instance.load([nextLibrary.name], loadCallback);
				}
				case BITMAP_FONT:
				{
					ResMan.instance.load(nextLibrary.name, loadCallback);
				}
			}
		}
	}
	
	/**
	 * Unloads the provided list of libraries
	 * TODO: For PAIST, SPRITESHEET, and SPRITESHEET_DATA libraries:
	 * currently our pipeline does NOT support reloading these assets
	 * once they have been unloaded. A log statement has been added
	 * as a reminder of this.
	 * @param	libraries
	 */
	public static function unloadLibraries(libraries:List<LibraryDef>):Void
	{
		for (library in libraries)
		{
			if (!HUSH)
			{
				Debug.log("Unloading: " + Std.string(library.name));
			}
			
			switch(library.type)
			{
				case PAIST: 
				{
					if (!HUSH)
					{
						Debug.log("NOTE: This menu and its assets will no longer be loadable.");
					}
					ResMan.instance.unload(library.name);
				}
				case SPRITESHEET: 
				{
					if (!HUSH)
					{
						Debug.log("NOTE: This Spritesheet will no longer be loadable.");
					}
					ResMan.instance.unload(library.name);
				}
				case SPRITESHEET_IMAGE: 
				{
					ResMan.instance.unload(library.name);
				}
				case SPRITESHEET_DATA: 
				{
					if (!HUSH)
					{
						Debug.log("NOTE: This Spritesheet will no longer be loadable.");
					}
					ResMan.instance.unload(library.name);
				}
				case LAYOUT:
				{
					ResMan.instance.unload(library.name);
				}
				case AUDIO:
				{
					WebAudio.instance.unload([library.name]);
				}
				case BITMAP_FONT:
				{
					ResMan.instance.unload(library.name);
				}
			}
			
		}
	}
	
}