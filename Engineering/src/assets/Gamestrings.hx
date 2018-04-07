//
// Copyright (C) 2014, 1st Playable Productions, LLC. All rights reserved.
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

package assets;

import assets.Gamestrings.GamestringsXmlElement;
import assets.strings.PaistStrings.PaistStringsValues;
import assets.strings.PaistStrings.PaistStringsXmlElement;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.utils.IGamestrings;
import haxe.ds.StringMap;

class GamestringsXmlElement
{
	public var id( default, null ):String;
	public var english( default, null ):String;
	public function new(id:String, english:String)
	{
		this.id = id;
		this.english = english;
	}
}

class Gamestrings implements IGamestrings
{
	private static inline var TOKEN_PREFIX:String = "TOKEN__";
	
	private var m_stringMap:StringMap<GamestringsXmlElement>;
	private var m_tokenMap:StringMap<String>;
	
	public function new()
	{
		m_stringMap = new StringMap<GamestringsXmlElement>();
		m_tokenMap = new StringMap<String>();
		initStrings();
	}
	
	public function has( id:String ):Bool
	{
		return m_stringMap.exists( id );
	}
	
	public function get( id:String ):String
	{
		var strings:GamestringsXmlElement = m_stringMap.get( id );
		var retVal:String = id;
		if ( strings != null )
		{
			retVal = strings.english;
			if ( retVal.indexOf( TOKEN_PREFIX ) != -1 )
			{
				retVal = replaceTokens( retVal );
			}
		}
		return retVal;
	}
	
	// TODO: this could maybe be public?
	private function replaceTokens( str:String ):String
	{
		var tokenPattern:String = TOKEN_PREFIX + "[A-Za-z0-9_]+";
		var tokenRegex:EReg = new EReg( tokenPattern, "" );
		var matched:Bool = tokenRegex.match( str );
		while ( matched )
		{
			var token:String = tokenRegex.matched( 0 );
			var match:Dynamic = tokenRegex.matchedPos();
			var tokenVal:String = getTokenVal( token );
			if ( tokenVal == token )
			{
				Debug.warn( "Could not find value for token '" + token + "'" );
				tokenVal = " ";
			}
			
			str = str.substr( 0, match.pos ) + tokenVal + str.substr( match.pos + match.len );
			matched = tokenRegex.match( str );
		}
		
		return str;
	}
	
	public function setToken( tokenId:String, tokenVal:String ):Void
	{
		if ( m_tokenMap.exists( tokenId ) )
		{
			Debug.log( "Token with ID '" + tokenId + "' already exists; it will be overwritten" );
		}
		m_tokenMap.set( tokenId, tokenVal );
	}
	
	private function getTokenVal( token:String ):String
	{
		return m_tokenMap.exists( token ) ? m_tokenMap.get( token ) : token;
	}
	
	private function initStrings():Void
	{
		// TODO: this is leftover from Gizmo, whichc merged strings from two sources;
		// we can probably revert to what eg Leroy did to simplify things
		
		// Strings come from two different sources (those editable by SMEs, and
		// those only editable by devs). Merge the two together so
		// we can access all from one location
		var paistStrs:StringMap<PaistStringsXmlElement> = PaistStringsValues.getValues();
		for ( key in paistStrs.keys() )
		{
			var val:PaistStringsXmlElement = paistStrs.get( key );
			var newVal:GamestringsXmlElement = new GamestringsXmlElement( val.stringid, val.english );
			// Don't check exists here, as we assume that there aren't dupe IDs in a single sheet
			m_stringMap.set( key, newVal );
		}
	}
}