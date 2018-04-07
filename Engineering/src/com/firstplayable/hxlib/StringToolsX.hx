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
package com.firstplayable.hxlib;
import haxe.crypto.Base64;
import haxe.io.Bytes;

/**
 * ...
 * @author 1st Playable Productions, LLC
 */
class StringToolsX extends StringTools
{
	/**
	 * Generates a random base 64 string of specified length.
	 * @param len	the number of bits
	 * @return	ie, "7Ya4VbkVXy3ZKw/mSg0RmPSdfEAI13rkS+OrJoLYa2Q="
	 */
	public static function randBase64( len:Int = 32 ):String
	{
		var bytes:Bytes = Bytes.alloc( len );
		for ( i in 0...bytes.length )
		{
			bytes.set( i, Std.random( 256 ) );
		}
		return Base64.encode( bytes );
	}

	/**
	 * Generates a random base 35 string (A-Z,1-9).
	 * @param len	Length of the string
	 * @return	ie, "LJKGF65JKG"
	 */
	public static function randBase35( len:Int ):String
	{
		var base:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";

		var ret:String = "";

		for ( i in 0...len )
		{
			ret += base.charAt(Std.random(base.length));
		}

		return ret;
	}

	/**
	 * Generates a random base 32 string (A-Z,2-9 minus I and O).
	 * @param len	Length of the string
	 * @return	ie, "LJKGF65JKG"
	 */
	public static function randBase32( len:Int ):String
	{
		var base:String = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

		var ret:String = "";

		for ( i in 0...len )
		{
			ret += base.charAt(Std.random(base.length));
		}

		return ret;
	}
	
	/**
	 * Applies comma formatting (US) to a number and returns a string.
	 * @param	num		Number to be converted; ie 10123123.
	 * @return	comma formatted string; ie "10,123,123".
	 */
	// TODO: test/profile which method works better -jm
	public static function commaFormat( num:Int ):String
	{
		// method 1
		var s:Array<String> = Std.string( num ).split( "" );
		var i:Int = s.length - 3;
		
		while ( i > 0 )
		{
			s.insert( i, "," );
			i -= 3;
		}
		
		return s.join( "" );
		
		// method 2
		/*var s:String = Std.string( num );
		var result:String = "";
		while ( s.length > 3 )
		{
			result = "," + s.substr( -3 ) + result;
			s = s.substr( 0, s.length - 3 );
		}
		result = s + result;
		return result;*/
	}
}
