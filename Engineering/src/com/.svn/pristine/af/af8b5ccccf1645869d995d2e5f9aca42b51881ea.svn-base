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

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import sys.FileSystem;

/**
 * Contains a map of all of the sprite asset libraries
 * generated via AssetBuildingMacro
 */
class BuildOPAssetManifest
{
	private static inline var HUSH:Bool = true;
	
	/*
	 * Function that walks through the target directory generating a collection
	 * of all of the library names.
	 * @param	targetDirectory
	 * @return
	 */
	private static function getLibrariesHelper(targetDirectory:String, srcPrefix:String, 
		libraryPrefix:String = "", libraryHasExtension:Bool = false):Map<String, Bool>
	{
		if (!HUSH)
		{
			Debug.log("looking at path: " + targetDirectory);
		}
		
		//Because haxe doesn't have set T_T
		var libraryNames:Map<String, Bool> = new Map<String, Bool>();
		for (file in sys.FileSystem.readDirectory(targetDirectory))
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
			if (!sys.FileSystem.isDirectory(path))
			{
				if (!HUSH)
				{
					Debug.log("Not a directory! Validating...");
				}
				var extension = Path.extension(path);
				if ((extension == "json") || (extension == "png") )
				{
					var actualPath:Path = new Path(path);
					var libraryName:String = libraryPrefix + actualPath.file 
						+ ((libraryHasExtension) ? ("." + extension) : "");
					
					if (!libraryNames.exists(libraryName))
					{
						if (!HUSH)
						{
							Debug.log("Is a new library! adding: " + file);
						}
						libraryNames[libraryName] = true;
					}
					else
					{
						if (!HUSH)
						{
							Debug.log("already had library for: " + file);
						}
					}
				}
				else
				{
					if (!HUSH)
					{
						Debug.log("wasn't a json or a png...");
					}
				}
			}
		}
		
		return libraryNames;
	}
	
	/**
	 * Build the local configurator.
	 * @return
	 */
	public static function build():Array<Field>
	{	
		// get existing fields from the context from where build() is called
		var fields = Context.getBuildFields();
				
		//====================================================
		// Find all existing layout files
		//====================================================
		
		var assets:Map<String, Bool> = new Map<String, Bool>();
		var assetsExpressions:Array<Expr> = [];
		
		if (!FileSystem.exists(AssetDefs.ASSETS_2D_DIRECTORY))
		{
			var cwd:String = Sys.getCwd();
			Debug.warn("no layout directory at: " + cwd + AssetDefs.ASSETS_2D_DIRECTORY);
		}
		else
		{
			assets = getLibrariesHelper(AssetDefs.ASSETS_2D_DIRECTORY, AssetDefs.BIN_2D_DIRECTORY, AssetDefs.BIN_2D_DIRECTORY, true);
		
			for (asset in assets.keys())
			{
				if (!HUSH)
				{
					Debug.log("asset found: " + asset);
				}
				assetsExpressions.push(macro $v{asset} => $v{true});
			}
			
			assets = getLibrariesHelper(AssetDefs.ASSETS_LAYOUTS_DIRECTORY, AssetDefs.BIN_LAYOUTS_DIRECTORY);
		
			for (asset in assets.keys())
			{
				if (!HUSH)
				{
					Debug.log("asset found: " + asset);
				}
				assetsExpressions.push(macro $v{asset} => $v{true});
			}
		}
		
		var assetsExpMacro:Array<Expr> = [];
		if (assetsExpressions.length > 0)
		{
			assetsExpMacro = assetsExpressions;
		}
		else
		{
			Debug.warn("no menus found!");
		}
		
		fields.push({
			name:  "ALL_LIBRARIES",
			doc: "Map of all the asset libraries.",
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FVar(macro:Map<String, Bool>, macro $a{assetsExpMacro}),
			pos: Context.currentPos(),
		});
		
		return fields;
	}
}
#end
