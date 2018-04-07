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

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.loader.AssetDefs;
import haxe.io.Path;

import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
import sys.io.File;
import sys.FileSystem;
#end

class AssetBuildingMacro
{
	private static inline var HUSH:Bool = true;
	
	#if macro
	/**
	 * Traverses the provided directory to accumulate ResMan.instance.addRes() calls
	 * @param targetDirectory -- The directory to be traversed
	 * @return An array of ResMan.instance.addRes() expressions
	 */
	private static function addResInDirectory(targetDirectory:String, srcPrefix:String, 
		libraryPrefix:String = "", libraryHasExtension:Bool = false):Array<Expr>
	{
		if (!HUSH)
		{
			Debug.log("looking at path: " + targetDirectory);
		}
		
		var functionCalls:Array<Expr> = [];
		for (file in FileSystem.readDirectory(targetDirectory))
		{
			if (!HUSH)
			{
				Debug.log("looking at file: " + file);
			}
			
			var path:String = haxe.io.Path.join([targetDirectory, file]);
			if (!HUSH)
			{
				Debug.log("looking at path: " + path);
			}
			
			var actualPath:Path = new Path(path);
			var sourceName:String = srcPrefix + actualPath.file + "." + actualPath.ext;
			var libraryName:String = libraryPrefix + actualPath.file + ((libraryHasExtension) ? ("." + actualPath.ext) : "");
			
			// If we encounter a JSON file, bake the JSON
			if (actualPath.ext == "json")
			{
				var jsonContent:String = File.getContent(Path.join([targetDirectory, actualPath.file + ".json"]));
				functionCalls.push(macro com.firstplayable.hxlib.loader.ResMan.instance.addRes($v{libraryName}, {src: $v{sourceName}, content: $v{jsonContent}}));
			}
			// If we encounter a PNG file, just include the filename
			else
			{
				functionCalls.push(macro com.firstplayable.hxlib.loader.ResMan.instance.addRes($v{libraryName}, {src: $v{sourceName}}));
			}
		}
		
		return functionCalls;
	}
	#end
	
	/**
	 * In-place will generate ResMan.instance.addRes() calls for the contents of assets/2d and assets/layouts
	 * @return An block expression containing ResMan.instance.addRes() invocations
	 */
	macro public static function addResources():Expr
	{
		var expr2d:Array<Expr> = addResInDirectory(AssetDefs.ASSETS_2D_DIRECTORY, AssetDefs.BIN_2D_DIRECTORY, AssetDefs.BIN_2D_DIRECTORY, true);
		var exprLayouts:Array<Expr> = addResInDirectory(AssetDefs.ASSETS_LAYOUTS_DIRECTORY, AssetDefs.BIN_LAYOUTS_DIRECTORY);
		
		var functionCalls:Array<Expr> = expr2d.concat(exprLayouts);
		return macro $b{functionCalls};
	}
}
