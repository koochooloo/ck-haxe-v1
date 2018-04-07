//
// Copyright (C) 2015, 1st Playable Productions, LLC. All rights reserved.
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

package game.column_layout;

import com.firstplayable.hxlib.debug.tunables.Tunables;
import openfl.geom.Point;

class ColumnLayoutParamsBuilder
{
	private var m_items:Array<IArrangeable>;
	private var m_align:ColumnAlignment;
	private var m_start:Point;
	private var m_mediumWidth:Float;
	private var m_largeWidth:Float;
	private var m_gutterWidth:Float;
	private var m_height:Float;
	
	private function new(items:Array<IArrangeable>)
	{
		m_items = items;
		m_align = ColumnAlignment.LEFT;
		m_start = new Point(0, 0);
		m_mediumWidth = 0;
		m_largeWidth = 0;
		m_gutterWidth = 0;
		m_height = 0;
	}
	
	public function align(value:ColumnAlignment):ColumnLayoutParamsBuilder
	{
		m_align = value;
		return this;
	}
	
	public function start(value:Point):ColumnLayoutParamsBuilder
	{
		m_start = value;
		return this;
	}
	
	public function mediumWidth(value:Float):ColumnLayoutParamsBuilder
	{
		m_mediumWidth = value;
		return this;
	}
	
	public function largeWidth(value:Float):ColumnLayoutParamsBuilder
	{
		m_largeWidth = value;
		return this;
	}
	
	public function gutterWidth(value:Float):ColumnLayoutParamsBuilder
	{
		m_gutterWidth = value;
		return this;
	}
	
	public function height(value:Float):ColumnLayoutParamsBuilder
	{
		m_height = value;
		return this;
	}
	
	public function finalize():ColumnLayoutParams
	{
		var params:ColumnLayoutParams = 
		{
			items: m_items,
			align: m_align,
			start: m_start,
			mediumWidth: m_mediumWidth,
			largeWidth: m_largeWidth,
			gutterWidth: m_gutterWidth,
			height: m_height
		};
		
		return params;
	}
	
	public static function build(items:Array<IArrangeable>):ColumnLayoutParamsBuilder
	{
		return new ColumnLayoutParamsBuilder(items);
	}
}