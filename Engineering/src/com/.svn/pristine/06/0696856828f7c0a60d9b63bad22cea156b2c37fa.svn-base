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

enum VolumeType
{
	TYPE_SND;
	TYPE_BUS;
	TYPE_SEQ;
	TYPE_ALL;
}

// @:allow( com.firstplayable.hxlib.audio ) is used to mimic Flash namespace
@:allow( com.firstplayable.hxlib.audio )
class VolumeInfo
{
	private static inline var TYPE_ALL:String = "ALL";
	private static inline var TYPE_BUS:String = "BUS";
	private static inline var TYPE_SEQ:String = "SEQ";
	private static inline var TYPE_SND:String = "SND";
	
	private static inline var MUTE_FLAG:Bool = true;
	private static inline var NO_MUTE_FLAG:Bool = false;
	
	private var id( default, null ):String;
	private var type( default, null ):String;
	private var volume( default, set ):Float;
	private var isMuted( default, set ):Bool;
	private var isOverridable( default, set ):Bool;
	
	private function set_volume( volume:Float ):Float{ return this.volume = volume; }
	private function set_isMuted( isMuted:Bool ):Bool{ return this.isMuted = isMuted; }
	private function set_isOverridable( isOverridable:Bool ):Bool{ return this.isOverridable = isOverridable; }
	
	public function new( id:String, type:String, volume:Float, isMuted:Bool, isOverridable:Bool ) 
	{
		this.id = id;
		this.type = type;
		this.volume = volume;
		this.isMuted = isMuted;
		this.isOverridable = isOverridable;
	}
}