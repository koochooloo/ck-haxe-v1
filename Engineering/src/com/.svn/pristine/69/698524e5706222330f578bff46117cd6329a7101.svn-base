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
package com.firstplayable.hxlib.io;
import lime.system.System;
import openfl.Assets;
import openfl.utils.ByteArray;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

/**
 * Read/write files to devices/hdd.
 */
class FileIO
{
	//TODO: check READ/WRITE permission settings and error accordingly
	
    /**
     * Writes a file to the system.
     * @param file	File name to write. Currently cannot include a directory. ie, "abc.txt"
	 * 				TODO: allow directory
     * @param data	Content to write.
	 * @param overwrite		True to always write, even if file exists.
	 * @return true if success, false if failed.
     */
    public static function write( file:String, data:ByteArray, overwrite:Bool = true ):Bool
    {
		#if cpp
        var path:String = System.applicationStorageDirectory + file;
		
		try {
			if ( overwrite || !FileSystem.exists( path ) )
			{
				//TODO: print out message for case !overwrite && exists()
				File.saveBytes( path, data ); //write to file
			}
		} catch ( e:Dynamic ) {
			trace( "failed to write file (" + path + ")..." );
			trace( e );
			return false;
		}
		
		return true;
		#else
			#error "Not implemented"
		#end
		
		return false;
    }
    
    /**
     * Reads a file from the system.
     * @param file	File name to read. Can include directories. ie, "data/abc.txt".
	 * @param fromAssets	True to load from Assets path, false to load from application storage.
     * @return null if failed
     */
    public static function read( file:String, fromAssets:Bool = false ):ByteArray
    {
		var bytes:ByteArray = null;
		var path:String = "";
		
		#if cpp
		try {
			if ( !fromAssets )
			{
				path = System.applicationStorageDirectory + file;
				bytes = ByteArray.fromBytes( File.getBytes( path ) );
			}
			else
			{
				path = file;
				// assets is protected and not accessible via file system
				bytes = Assets.getBytes( file );
				
				// trace error since getBytes doesn't throw one
				if ( bytes == null )
					trace( "failed to read file (" + path + ")..." );
			}
		} catch ( e:Dynamic ) {
			trace( "failed to read file (" + path + ")..." );
			trace( e );
		}
		#else
			#error "Not implemented"
		#end
		
        return bytes;
    }
	
	/**
	 * Copies a source file to a destination.
	 * @param	srcFile		File name to read. Can include directories. ie, "data/abc.txt".
	 * @param	destFile	File name to write. Currently cannot include a directory. ie, "abc.txt"
	 * @param	fromAssets	True to copy from Assets file, false to copy from application storage.
	 * @param	overwrite	True to always write, even if file exists.
	 * @return	true if success, false if failed.
	 */
	public static function copy( srcFile:String, destFile:String, fromAssets:Bool = false, overwrite:Bool = true ):Bool
	{
		#if cpp
		var content:ByteArray = read( srcFile, fromAssets );
		if ( content == null )
		{
			trace( "copy failed" );
			return false;
		}
		
		var ok:Bool = write( destFile, content, overwrite );
		if ( !ok )	trace( "copy failed" );
		return ok;
		#else
			#error "Not implemented"
		#end
		
		return false;
	}
}