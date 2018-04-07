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
import motion.Actuate;
import motion.actuators.GenericActuator;

typedef SyncInfo =
{
	delay:Int,
	?trigger:Dynamic,
	?params:Array<Dynamic>
}

class SoundSync
{
	//track actuators for control over these timers
	private var m_actuators:Array<GenericActuator<Dynamic>>;
	//info
	private var m_infos:Array<SyncInfo>;
	private var m_defaultTrigger:Dynamic;
	
	/**
	 * 
	 * @param	infos
	 */
	public function new( infos:Array<SyncInfo> ) 
	{
		m_actuators = [];
		m_infos = infos;
	}
	
	/**
	 * Start timing sequence.
	 */
	public function play():Void
	{
		for ( info in m_infos )
		{
			var act:GenericActuator<Dynamic> =
				Actuate.timer( info.delay / 1000 )
					.onComplete( onTrigger, [ info ] );
			m_actuators.push( act );
		}
	}
	
	/**
	 * Stops timing sequence.
	 */
	public function stop():Void
	{
		for ( act in m_actuators )
		{
			Actuate.stop( act );
		}
		
		m_actuators = [];
	}
	
	/**
	 * Pauses timing sequence.
	 */
	public function pause():Void
	{
		for ( act in m_actuators )
		{
			Actuate.pause( act );
		}
	}
	
	/**
	 * Resumes timing sequence.
	 */
	public function resume():Void
	{
		for ( act in m_actuators )
		{
			Actuate.resume( act );
		}
	}
	
	/**
	 * Stops current timing sequence and restarts.
	 */
	public function replay():Void
	{
		stop();
		play();
	}
	
	/**
	 * Callback for timers which trigger provided functions and params.
	 * @param	info
	 */
	private function onTrigger( info:SyncInfo ):Void
	{
		Debug.log( "triggered " + m_infos.indexOf( info ) );
		
		if ( info.trigger != null )
		{
			Reflect.callMethod( null, info.trigger, info.params );
		}
	}
	
	//TODO: startAt()
}