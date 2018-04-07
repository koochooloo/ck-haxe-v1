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
package com.firstplayable.hxlib.display;
import com.firstplayable.hxlib.app.Application;
import motion.Actuate;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

//TODO: support docking/y-pos via setGravity
//TODO: cancel support
/**
 * Initial approach at replicating Android Toasts for openfl.
 * Loosely based from https://developer.android.com/reference/android/widget/Toast.html
 */
class Toast extends Sprite
{
	// toast short time (secs)
	public static inline var LENGTH_SHORT:Float = 2.0;
	// toast long time (secs)
	public static inline var LENGTH_LONG:Float = 5.0;
	
	// time it takes toast to fade in/out
	private static inline var FADE_TIME:Float = 0.3;
	// offset from the bottom of the screen (px)
	private static inline var OFF_FROM_BOT:Int = 25;
	// backing fill color
	private static inline var BACK_COLOR:Int = 0x616161;
	// text color
	private static inline var FONT_COLOR:Int = 0xffffff;
	// text size
	private static inline var FONT_SIZE:Int = 22;
	
	// allows for queuing up Toasts
	private static var m_queue:Array<Toast> = [];
	// track if Toast is in progress
	private static var isToasting:Bool = false;
	
	// cache toast length
	public var duration(default,null):Float;
	
	/**
	 * Creates a new Toast and shows it.
	 * @param	t	Text to display.
	 * @param	l	Length of time to show for. Defaults to Toast.LENGTH_SHORT.
	 * @param	b	(optional) background color
	 * @param	f	(optional) text format
	 * @usage 	Toast.makeText( "This is Toast!", Toast.LENGTH_SHORT ).show();
	 */
	public static function makeText( t:String, l:Float = LENGTH_SHORT, ?b:Int, ?f:TextFormat ):Toast
	{
		return new Toast( t, l, b, f );
	}
	
	/**
	 * Creates a new Toast.
	 * @param	t	Text to display.
	 * @param	l	Length of time to show for. Defaults to Toast.LENGTH_SHORT.
	 * @param	b	(optional) background color
	 * @param	f	(optional) text format
	 */
	public function new( t:String, l:Float = LENGTH_SHORT, ?b:Int, ?f:TextFormat ) 
	{
		super();
		
		// min toast time
		var timeFading = FADE_TIME * 2;
		if ( l < timeFading )
		{
			l = timeFading;
		}
		
		duration = l;
		
		if ( b == null )
		{
			b = BACK_COLOR;
		}
		
		if ( f == null )
		{
			f = new TextFormat( null, FONT_SIZE, FONT_COLOR );
		}
		
		// create message text
		var msg:TextField = new TextField();
		msg.defaultTextFormat = f;
		msg.text = t;
		msg.autoSize = TextFieldAutoSize.CENTER;
		msg.x -= msg.width / 2;
		msg.y -= msg.height / 2;
		
		addChild( msg );
		
		// create text border
		var b:Dynamic = { x:0, y:0, w:0, h:0 };
		b.x = -msg.width / 2 - f.size * 1.5;
		b.y = -msg.height / 2 - f.size / 2;
		b.w = msg.width + f.size * 3;
		b.h = msg.height + f.size;
		
		// draw text border
		graphics.beginFill( b );
		graphics.drawRoundRect( b.x, b.y, b.w, b.h, b.h, b.w );
		graphics.endFill();
		
		// position toast element (bottom/center)
		x = Application.app.targetSize.x / 2;
		y = Application.app.targetSize.y - height - OFF_FROM_BOT;
	}
	
	/**
	 * Show the toast for a period of time before it goes away.
	 * @param	interrupt	(optional) whether to interrupt the current toast queue
	 */
	public function show( interrupt:Bool = false ):Void
	{
		//clear the current queue
		if ( interrupt && isToasting && m_queue.length > 0 )
		{
			m_queue.splice( 1, m_queue.length );
			m_queue[ 0 ].done();
		}
		
		m_queue.push( this );
		nextToast();
	}
	
	/**
	 * Stops the active Toast early.
	 */
	public static function stop():Void
	{
		if ( isToasting && m_queue.length > 0 )
		{
			var curToast:Toast = m_queue[ 0 ];
			Actuate.stop( curToast );
		}
	}
	
	/**
	 * Fades out and removes toast.
	 */
	private function hide():Void
	{
		alpha = 1.0;
		Actuate.tween( this, FADE_TIME, { alpha:0 } )
			.onComplete( done );
	}
	
	/**
	 * Current toast done.
	 */
	private function done():Void
	{
		isToasting = false;
		Lib.current.stage.removeChild( this );
		m_queue.shift();
		nextToast();
	}
	
	/**
	 * Kicks off next Toast if there is one.
	 */
	private static function nextToast():Void
	{
		if ( !isToasting && m_queue.length > 0 )
		{
			isToasting = true;
			
			var toast:Toast = m_queue[ 0 ];
			Lib.current.stage.addChild( toast );
			
			toast.alpha = 0;
			
			// intro animation
			Actuate.tween( toast, FADE_TIME, { alpha:1.0 } );
			// basically a timer to track the whole duration
			// we register it on toast (vs timer) so we have an easy reference to kill it later
			Actuate.tween( toast, toast.duration - FADE_TIME, {}, false )
				.onComplete( toast.hide );
		}
	}
}