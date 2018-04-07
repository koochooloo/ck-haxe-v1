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

package game.ui.states;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.anim.SpritesheetAnim;
import com.firstplayable.hxlib.state.StateManager;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;
import game.def.GameState;
import game.states.SplashState;
import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.events.TimerEvent;
import openfl.text.TextField;
import openfl.utils.Timer;

using com.firstplayable.hxlib.utils.Utils;

class SplashMenu extends SpeckMenu
{
	private static inline var FADE_IN_TIME:Float = 0.5;
	private static inline var FILL_TIME:Float = 3;
	
	private static inline var QUIP_PREFIX:String = "DATABASE_LOAD_QUIP_";
	private static inline var LOADING_DOT_TIME_SECONDS:Float = 1.0;
	private static inline var MAX_DOTS:Int = 10;
	
	private var m_loadingText:TextField;
	
	private var m_loadingQuips:Array<String>;
	private var m_quipIdx:Int;
	
	private var m_dotTimer:Timer;
		
	public function new() 
	{
		super( "SplashMenu" );
		
		var welcome:TextField = cast getChildByName( "lbl_welcome" );
		welcome.alpha = 1;
		
		m_loadingText = getChildAs("lbl_loadingQuips", TextField);
		
		m_loadingText.text = The.gamestrings.get(QUIP_PREFIX + "1");
		
		//Make quips list
		m_loadingQuips = [];
		var quipIDX:Int = 2;
		while (The.gamestrings.has(QUIP_PREFIX + quipIDX))
		{
			var nextQuip:String = The.gamestrings.get(QUIP_PREFIX + quipIDX);
			m_loadingQuips.push(nextQuip);
			++quipIDX;
		}
		m_loadingQuips = Random.shuffle(m_loadingQuips);
		
		m_quipIdx = -1;
		
		m_dotTimer = new Timer(LOADING_DOT_TIME_SECONDS * 1000, MAX_DOTS);
		m_dotTimer.addEventListener(TimerEvent.TIMER, onDotTimerTic);
	}
	
	private function initButtons():Void
	{
		for ( i in 0...numChildren )
		{
			var child:DisplayObject = getChildAt( i );
			if ( Std.is( child, GraphicButton ) )
			{
				child.alpha = 0;
			}
		}
	}
	
	private function hideObjectForFadeIn( name:String ):Void
	{
		var obj:DisplayObject = getChildByName( name );
		if ( obj != null )
		{
			obj.alpha = 0;
			obj.visible = false;
		}
	}
	
	public function onShow():Void
	{
		
	}
	
	public function onLoadProgress(completion:Float)
	{
		++m_quipIdx;
		if (m_quipIdx >= m_loadingQuips.length)
		{
			m_quipIdx = 0;
			m_loadingQuips = Random.shuffle(m_loadingQuips);
		}
		
		m_loadingText.text = m_loadingQuips[m_quipIdx];
		
		m_dotTimer.reset();
		m_dotTimer.start();
	}
	
	private function onDotTimerTic(e:TimerEvent):Void
	{
		m_loadingText.text += ".";
	}
	
	public function onGameReady():Void
	{
		m_dotTimer.stop();
		m_dotTimer.removeEventListener(TimerEvent.TIMER, onDotTimerTic);
		m_dotTimer = null;
		
		m_loadingText.visible = false;
		
		for ( i in 0...numChildren )
		{
			var child:DisplayObject = getChildAt( i );
			if ( child.alpha == 0 )
			{
				child.visible = true;
				Actuate.tween( child, FADE_IN_TIME, { alpha:1 } );
			}
		}
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void 
	{
		super.onButtonHit( caller );
	}
}
