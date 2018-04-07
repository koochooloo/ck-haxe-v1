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

import com.firstplayable.hxlib.audio.AudioObject;
import haxe.ds.StringMap;

class AudioXmlElement
{
	public var soundid( default, null ):String;
	public var url( default, null ):String;
	public var bus( default, null ):String;
	public var volume( default, null ):String;
	public var repeat( default, null ):String;
	public var maxinstances( default, null ):String;
	public var effect( default, null ):String;
	public var interrupt( default, null ):InterruptType;
	
	public function new( soundid:String, url:String, bus:String, volume:String, repeat:String, maxinstances:String, effect:String, interrupt:String )
	{
		this.soundid = soundid;
		this.url = url;
		this.bus = bus;
		this.volume = volume;
		this.repeat = repeat;
		this.maxinstances = maxinstances;
		this.effect = effect;
		
		this.interrupt = ( interrupt == InterruptType.INTERRUPTABLE.getName() )
						? InterruptType.INTERRUPTABLE
						: InterruptType.SEQUENTIAL;
	}
}