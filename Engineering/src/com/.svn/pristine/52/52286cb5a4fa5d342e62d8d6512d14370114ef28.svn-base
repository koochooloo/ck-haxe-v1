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

#if macro
package com.firstplayable.hxlib.debug.menuEdit;
import haxe.io.Path;
import com.firstplayable.hxlib.utils.ArrayTools;
import haxe.macro.Expr;
import haxe.ds.StringMap;
import haxe.macro.Expr.Access;
import sys.io.File;
import haxe.macro.Expr.FieldType;
import haxe.Json;
import com.firstplayable.hxlib.debug.menuEdit.MenuDefs;
import sys.FileSystem;
import haxe.macro.Context;
import haxe.macro.Expr.Field;

class BuildMenus
{
	private static inline var HUSH:Bool = true;
	
	/**
	 * Recursive function that iterates through layouts, buidling an array
	 * of layout files as it goes.
	 * @param	subPath
	 * @return
	 */
	private static function getLayoutsHelper(subPath:String):Array<String>
	{
		if (!HUSH)
		{
			Debug.log("looking at path: " + subPath);
		}
		
		var layoutNames:Array<String> = [];
		for (file in sys.FileSystem.readDirectory(subPath))
		{
			if (!HUSH)
			{
				Debug.log("looking at file: " + file);
			}
			var path:String = haxe.io.Path.join([subPath, file]);
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
				if (Path.extension(path) == "json")
				{
					if (!HUSH)
					{
						Debug.log("Is a json file! adding: " + file);
					}
					var actualPath:Path = new Path(path);
					var menuName:String = actualPath.file;
					
					layoutNames.push(menuName);
				}
				else
				{
					if (!HUSH)
					{
						Debug.log("wasn't a json...");
					}
				}
			}
			else
			{
				if (!HUSH)
				{
					Debug.log("Is a directory, recursing...");
				}
				var subPath:String = Path.join([subPath, file]);
				subPath = haxe.io.Path.addTrailingSlash(subPath);
				var subLayouts:Array<String> = getLayoutsHelper(subPath);
				layoutNames = layoutNames.concat(subLayouts);
			}
		}
		
		return layoutNames;
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
		
		var layouts:Array<String> = [];
		var layoutsExpressions:Array<Expr> = [];
		
		if (!FileSystem.exists(MenuDefs.menuLayoutsFilePath))
		{
			var cwd:String = Sys.getCwd();
			Debug.warn("no layout directory at: " + cwd + MenuDefs.menuLayoutsFilePath);
		}
		else
		{
			layouts = getLayoutsHelper(MenuDefs.menuLayoutsFilePath);
		
			for (layout in layouts)
			{
				if (!HUSH)
				{
					Debug.log("menu found: " + layout);
				}
				layoutsExpressions.push(macro $v{layout});
			}
		}
		
		var layoutExpMacro:Expr = null;
		if (layoutsExpressions.length > 0)
		{
			layoutExpMacro = macro $a{layoutsExpressions};
		}
		else
		{
			Debug.warn("no menus found!");
		}
		
		fields.push({
			name:  "ALL_LAYOUTS",
			doc: "Array of all paist layout names.",
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FVar(macro:Array<String>, layoutExpMacro), 
			pos: Context.currentPos(),
		});
		
		return fields;
	}
}
#end
