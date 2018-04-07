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

package game.ui.login;

import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.loader.ResMan;
import game.column_layout.ColumnSize;
import game.column_layout.IArrangeable;
import game.utils.StudentUtils;
import openfl.display.Bitmap;

class StudentButton extends GraphicButton implements IArrangeable
{
	private static inline var ASSET_PATH:String = "2d/Buttons/UserIcons/";
	
	private static inline var UP_SUFFIX:String = "_up";
	private static inline var DOWN_SUFFIX:String = "_down";
	private static inline var OVER_SUFFIX:String = "_over";
	
	public var color(get, set):StudentColor;
	public var number(get, set):StudentNumber;
	public var size(default, null):ColumnSize;
	
	private var m_color:StudentColor;
	private var m_number:StudentNumber;
	
	public function new(color:StudentColor, number:StudentNumber)
	{
		var up:Bitmap = ResMan.instance.getImage(ASSET_PATH + color + number + UP_SUFFIX);
		var down:Bitmap = ResMan.instance.getImage(ASSET_PATH + color + number + DOWN_SUFFIX);
		var over:Bitmap = ResMan.instance.getImage(ASSET_PATH + color + number + OVER_SUFFIX);
		
		var id:Int = StudentUtils.getIdFromColorAndNumber(color, number);
		
		super(up, down, over, null, null, null, id);
		
		m_color = color;
		m_number = number;
		size = ColumnSize.LARGE;
	}
	
	private function updateButton():Void
	{
		upState = ResMan.instance.getImage(ASSET_PATH + color + number + UP_SUFFIX);
		downState = ResMan.instance.getImage(ASSET_PATH + color + number + DOWN_SUFFIX);
		overState = ResMan.instance.getImage(ASSET_PATH + color + number + OVER_SUFFIX);
		disabledState = upState;
		
		id = StudentUtils.getIdFromColorAndNumber(color, number);
	}
	
	private function get_color():StudentColor
	{
		return m_color;
	}
	
	private function set_color(value:StudentColor):StudentColor
	{
		m_color = value;
		
		updateButton();
		
		return m_color;
	}
	
	private function get_number():StudentNumber
	{
		return m_number;
	}
	
	private function set_number(value:StudentNumber):StudentNumber
	{
		m_number = value;
		
		updateButton();
		
		return m_number;
	}
}