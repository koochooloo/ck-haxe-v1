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
package com.firstplayable.hxlib.audio;

class TrackLabel
{
	public var name:String;
	public var start:Float;
	public var end:Float;
	
	/**
	 * Creates a new track label.
	 * @param	label	name of the label.
	 * @param	inSec	in point, in seconds.
	 * @param	outSec	out point, in seconds.
	 */
	public function new( label:String = "", inSec:Float = 0, outSec:Float = 0 )
	{
		name = label;
		start = inSec;
		end = outSec;
	}
	
	/**
	 * Parses Audacity track info.
	 * @param	data	loaded file data.
	 * @return
	 */
	public static function audacityImporter( data:String ):Array<TrackLabel>
	{
		var labels:Array<TrackLabel> = [];
		var tracks:Array<String> = data.split( "\n" );
		
		for ( track in tracks )
		{
			var trackInfo:Array<String> = track.split( "\t" );
			labels.push( new TrackLabel( Std.string( trackInfo[ 2 ] ), Std.parseFloat( trackInfo[ 0 ] ), Std.parseFloat( trackInfo[ 1 ] ) ) );
		}
		
		return labels;
	}
}