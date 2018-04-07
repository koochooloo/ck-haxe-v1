//
// Copyright (C) 2006-2017, 1st Playable Productions, LLC. All rights reserved.
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

package com.firstplayable.hxlib.media;

import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.events.VolumeChangedEvent;
import openfl.media.SoundTransform;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.NetStatusEvent;
import openfl.net.NetConnection;
import openfl.net.NetStream;

//Needed in the original Video class to access members of __stream.
//We need it too.
@:access(openfl.net.NetStream)

/*
 * Class that wraps the setup/handling of video playback
 * inside of a DisplayObjectContainer that you can add 
 * to the scene, and use via a simplified interface.
 * 
 * Currently only supports the handling of a single
 * video file specified upon construction.
 * Could be updated to support playing multiple files.
 */
class VideoPlayer extends DisplayObjectContainer 
{
	private var m_nc:NetConnection;
	private var m_ns:NetStream;
	private var m_vid:OPVideo;
	
	private var m_fileName:String;
	private var m_videoWidth:Float;
	private var m_videoHeight:Float;
	private var m_onStopped:Void->Void;
	private var m_mimeType:String;
	
	private var m_connected:Bool;
	private var m_pendingPlay:Bool;
	
	//settings
	private var m_volume:Float;
	public var volume(get, set):Float;

	public function new(filename:String, startWidth:Float=320, startHeight:Float=240, onStopped:Void->Void = null, ?mimeType:String) 
	{
		super();
		
		m_nc = null;
		m_ns = null;
		m_vid = null;
		
		m_fileName = filename;		
		m_videoWidth = startWidth;
		m_videoHeight = startHeight;		
		m_onStopped = onStopped;
		m_mimeType = mimeType;
		
		m_connected = false;
		m_pendingPlay = false;
		
		m_volume = WebAudio.movieVolume;
		
		addEventListener(Event.ADDED_TO_STAGE, addedToStage);
	}
	
	private function addedToStage(e:Event)
	{
		visible = false;
		
		m_nc = new NetConnection();
		m_nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);	
		m_nc.connect(null);
		
		removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		
		//Catch whatever the current movie volume is, then listen to any further updates.
		m_volume = WebAudio.movieVolume;
		WebAudio.instance.event.addEventListener(VolumeChangedEvent.VOLUME_CHANGED_MOVIE, onVolumeChanged);
	}
	
	private function removedFromStage(e:Event)
	{
		WebAudio.instance.event.removeEventListener(VolumeChangedEvent.VOLUME_CHANGED_MOVIE, onVolumeChanged);
		
		if (m_nc != null)
		{
			m_nc.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		if(m_ns != null)
		{
			m_ns.close();
		}
		
		if(m_vid != null)
		{
			m_vid.clearVideo();
			removeChild(m_vid);
		}
		
		m_vid = null;
		m_ns = null;
		m_nc = null;
		
		m_connected = false;
		m_pendingPlay = false;
		
		removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
	}
	
	private function onNetStatus(evt:NetStatusEvent):Void
	{
		if (evt.info.code == NetConnection.CONNECT_SUCCESS)
		{
			m_connected = true;
			
			if (m_pendingPlay)
			{
				m_pendingPlay = false;
				setupStream();
			}
		}
		else if (evt.info.code == "NetStream.Play.Start")
		{
			if (m_vid != null)
			{
				log("Video: " + m_fileName + " started!");
				visible = true;
				//Video dimmensions should exist at this point.
				//Resize the video to fill space specified by this player
				m_vid.width = width;
				m_vid.height = height;
			}
			else 
			{
				warn("m_vid is null when NetStream.Play.Start received!");
			}

		}
		else if (evt.info.code == "NetStream.Play.Stop")
		{
			log("Video: " + m_fileName + "stopped!");
			if (m_onStopped != null)
			{
				m_onStopped();
			}
		}
		else
		{
			log(evt.info.code);
		}
	}
	
	/*
	 * Sets up the NetStream using the NetConnection setup by this class,
	 * as well as the provided movie file, and plays the movie.
	 */
	private function setupStream()
	{
		if (m_ns == null && m_vid == null)
		{
			m_ns = new NetStream(m_nc);
			#if (js && html5)
			if (m_mimeType != null && (m_ns.__video != null))
			{
				m_ns.__video.setAttribute("type", m_mimeType);
			}
			#end
			
			m_ns.soundTransform = new SoundTransform(m_volume);
			m_ns.play(m_fileName);
			
			m_vid = new OPVideo(cast m_videoWidth, cast m_videoHeight);
			
			m_vid.attachNetStream(m_ns);
			
			addChild(m_vid);
		}
		else 
		{
			warn("setupStream was called, but stream and video already exist!");
		}
	}
	
	public function play()
	{
		if (!m_connected)
		{
			m_pendingPlay = true;
		}
		else 
		{
			if (m_ns == null)
			{
				setupStream();
			}
			else
			{
				m_ns.close();
				m_ns.play(m_fileName);
			}	
		}
	}
	
	public function pause()
	{
		if (m_ns != null)
		{
			m_ns.pause();
		}	
	}
	
	public function resume()
	{
		if (m_ns != null)
		{
			m_ns.resume();
		}	
	}
	
	public function replay()
	{
		if (m_ns != null)
		{
			m_ns.pause();
			m_ns.seek(0);
			m_ns.resume();
		}	
	}
	
	public function get_volume():Float
	{
		return m_volume;
	}
	
	public function set_volume(newVolume:Float):Float
	{
		m_volume = newVolume;
		if (m_ns != null)
		{
			m_ns.soundTransform = new SoundTransform(m_volume);
		}
		return m_volume;
	}
	
	private function onVolumeChanged(e:VolumeChangedEvent)
	{
		volume = e.volume;
	}
	
}