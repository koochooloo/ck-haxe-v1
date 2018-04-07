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
package com.firstplayable.hxlib.display.anim;
import com.firstplayable.hxlib.display.anim.ActuateChain.ActuateAnim;
import motion.Actuate;
import motion.easing.IEasing;
import motion.easing.Linear;

/**
 * See Actuate.tween for params. onComplete will trigger per animation.
 */
typedef ActuateAnim =
{
	target:Dynamic,
	duration:Float,
	properties:Dynamic,
	?ease:IEasing,
	?onComplete:Void->Void
}

class ActuateChain
{
	public static var create( get, null ):ActuateChain;
	private static function get_create():ActuateChain
	{
		return new ActuateChain();
	}
	
	private var m_iter:Int;
	private var m_tweens:Array<ActuateAnim>;
	private var m_onComplete:Void->Void;
	
	public function new()
	{
		m_iter = -1;
	}
	
	/**
	 * Calls a tween sequence via Actuate.
	 * @param	tweens		ordered list of animations.
	 * @param	onComplete	triggered when sequence completes.
	 */
	public function tween( tweens:Array<ActuateAnim>, ?onComplete:Void->Void ):Void
	{
		m_tweens = tweens;
		m_onComplete = onComplete;
		next();
	}
	
	/**
	 * next animation call
	 */
	private function next():Void
	{
		++m_iter;
		
		//if there was a last animation and it has onComplete, call it.
		if ( m_iter > 0 )
		{
			var lastAnim:ActuateAnim = m_tweens[ m_iter - 1 ];
			
			if ( lastAnim.onComplete != null )
			{
				lastAnim.onComplete();
			}
		}
		
		//if we still have more animations, play them.
		if ( m_iter < m_tweens.length )
		{
			var curAnim:ActuateAnim = m_tweens[ m_iter ];
			if ( curAnim.ease == null )
			{
				curAnim.ease = Linear.easeNone;
			}
			
			Actuate.tween( curAnim.target, curAnim.duration, curAnim.properties )
				.ease( curAnim.ease )
				.onComplete( next );
		}
		//sequence completed
		else if ( m_onComplete != null )
		{
			m_onComplete();
		}
	}
}