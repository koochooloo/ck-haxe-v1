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

package game.utils.audio;

import com.firstplayable.hxlib.audio.WebAudio;
import haxe.ds.Option;

class AudioQueueBuilder
{
	private var m_ids:Array<String>;
	private var m_callback:Option<Void->Void>;
	private var m_volume:Float;
	private var m_shouldDuckBGM:Bool;
	
	private function new()
	{
		m_ids = [];
		m_callback = None;
		m_volume = WebAudio.volume;
		m_shouldDuckBGM = false;
	}
	
	public function enqueue(id:String):AudioQueueBuilder
	{
		m_ids.push(id);
		
		return this;
	}
	
	public function onComplete(callback:Void->Void):AudioQueueBuilder
	{
		m_callback = Some(callback);
		
		return this;
	}
	
	public function volume(value:Float):AudioQueueBuilder
	{
		m_volume = value;
		
		return this;
	}
	
	public function duckBGM(value:Bool):AudioQueueBuilder
	{
		m_shouldDuckBGM = value;
		
		return this;
	}
	
	@:access(game.utils.audio.AudioQueue)
	public function finish():AudioQueue
	{
		return new AudioQueue(m_ids.copy(), m_callback, m_volume, m_shouldDuckBGM);
	}
	
	public static function make():AudioQueueBuilder
	{
		return new AudioQueueBuilder();
	}
}