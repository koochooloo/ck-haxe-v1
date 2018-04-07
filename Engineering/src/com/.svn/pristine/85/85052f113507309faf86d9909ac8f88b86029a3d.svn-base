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

package com.firstplayable.hxlib.display;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.display.Params;
import com.firstplayable.hxlib.loader.SpriteDataManager;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import spritesheet.data.BehaviorData;

enum ParamBoxType
{
	VULNERABLE;
	ATTACK;
	ATTACK_SELECT;
}

class ParamBoxData
{
	public var type( default, null):ParamBoxType;
	public var box( default, null ):Rectangle;
	public var id( default, null):Int;
	public var frame(default, null):Int;
	public var endFrame(default, null):Int;
	
	public static inline var DEBUG_BOX_ALPHA:Float = 0.3;
	
	public static function getParamBoxNameFromType(boxType:ParamBoxType):String
	{
		switch(boxType)
		{
			case VULNERABLE: return Params.VULNERABLE_BOX;
			case ATTACK: return Params.ATTACK_BOX;
			case ATTACK_SELECT: return Params.ATTACK_SELECT_BOX;
		}
	}
	
	public static function getDebugColorForBoxType(boxType:ParamBoxType):Int
	{
		switch(boxType)
		{
			case VULNERABLE: return 0x80FFFF;
			case ATTACK: return 0xFF0000;
			case ATTACK_SELECT: return 0xFF8000;
		}
	}

	public function new( tp:ParamBoxType, bx:Rectangle, i:Null<Int>, fr:Null<Int>, endFr:Null<Int> ) 
	{
		type = tp;
		box = ( bx != null ) ? bx : new Rectangle();
		id = (i != null) ? i : Params.NO_ID;
		frame = (fr != null) ? fr : Params.NO_FRAME;
		endFrame = (endFr != null) ? endFr : Params.NO_FRAME;
	}
	
	public function copy():ParamBoxData
	{
		return new ParamBoxData( type, box.clone(), id, frame, endFrame );
	}
	
	public function toString():String
	{
		return '[ParamBoxData type=$type box=$box id=$id frame=$frame endFrame=$endFrame]';
	}
	
	public function print():Void
	{
		Debug.log( toString() );
	}
}