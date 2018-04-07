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
import openfl.media.Sound;
#if js
#if ( lime > "3.0" )
import lime.media.howlerjs.Howl;
#else
import howler.Howl;
#end
#end
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

class WebAudioObject
{
	#if js
	public var id( default, null ):String;
	public var sound( default, null ):Howl;
	
	public function new( sndID:String, snd:Howl ):Void
	{
		id = sndID;
		sound = snd;
	}
	
	public static function isValid( sound:WebAudioObject ):Bool
	{
		return ( sound != null && sound.sound != null );
	}
	
	#else //if js
	
	public var id(default, null):String;
	public var sound:Sound;
	public var channel:SoundChannel;
	public var transform:SoundTransform;
	public var pausePosition:Float;
	public var callbacks:Array<Dynamic->Void>;
	
	public function new( sndID:String, snd:Sound ): Void
	{
		id = sndID;
		sound = snd;
		channel = null;
		transform = new SoundTransform();
		pausePosition = 0.0;
		callbacks = new Array();
	}
	
	public static function isValid( snd:WebAudioObject ):Bool
	{
		return (snd != null && snd.sound != null);
	}
	#end  //if js

}