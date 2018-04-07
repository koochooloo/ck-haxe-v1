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

package game.cms;

import haxe.ds.Option;
import com.firstplayable.hxlib.utils.MathUtils;

class Dataset<T>
{
	public var item(get, never):T;
	
	private var m_index:Int;
	private var m_data:Array<T>;
	
	private function new(data:Array<T>)
	{
		m_index = 0;
		m_data = data.copy();
	}
	
	public function reset():Void
	{
		m_index = 0;
	}
	
	public function goToPreviousItem():Void
	{
		m_index = MathUtils.max(m_index - 1, 0);
	}
	
	public function goToNextItem():Void
	{
		m_index = MathUtils.min(m_index + 1, m_data.length - 1);
	}
	
	public function onFirstItem():Bool
	{
		return (m_index == 0);
	}
	
	public function onLastItem():Bool
	{
		return (m_index == (m_data.length - 1));
	}
	
	private function get_item():T
	{
		return m_data[m_index];
	}
	
	public static function make<T>(data:Array<T>):Option<Dataset<T>>
	{
		if (data.length > 0)
		{
			var set = new Dataset(data);
			return Some(set);
		}
		
		return None;
	}
}