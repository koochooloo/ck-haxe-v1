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
import haxe.Timer;
import haxe.ds.Option;

using game.utils.OptionExtension;

class AudioQueue
{
	private var m_ids:Array<String>;
	private var m_callback:Option<Void->Void>;
	private var m_volume:Float;
	private var m_shouldDuckBGM:Bool;
	
	// Pause-related vars - TODO neater soln?
	private static inline var AUDIO_DELAY:Int = 1000; // ms
	private var m_firstId:String;
	private var m_currentId:String;
	
	private function new(ids:Array<String>, callback:Option<Void->Void>, volume:Float, shouldDuckBGM:Bool)
	{
		m_ids = ids;
		m_firstId = ids[0];
		m_callback = callback;
		m_volume = volume;
		m_shouldDuckBGM = shouldDuckBGM;
	}
	
	public function trigger():Void
	{
		var areRemainingIds:Bool = (m_ids.length > 0);
		if (areRemainingIds)
		{
			m_currentId = m_ids.shift();
			
			// Add timer between sequential audio
			// TODO - more elegant webaudio soln?
			if ( m_currentId != m_firstId )
			{
				Timer.delay( playCurrentAudio, AUDIO_DELAY );
			}
			else
			{
				playCurrentAudio();
			}
		}
		else
		{
			m_callback.flatMap(function(callback){
				callback();
				
				return Some(callback);
			});
		}
	}
	
	private function playCurrentAudio():Void
	{
		WebAudio.instance.playVO(m_currentId, trigger, m_volume, m_shouldDuckBGM);
	}
}