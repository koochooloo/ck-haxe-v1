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
package com.firstplayable.hxlib.debug;
import com.firstplayable.hxlib.utils.MacroUtils;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.Lib.getTimer;
import openfl.text.TextField;
import openfl.text.TextFormat;

class DebuggerPanel extends MovieClip
{
    private var m_debugField:TextField;
    private var m_mouseField:TextField;
    private var m_traceField:TextField;
    
    private var m_buildStamp:String;
    private var m_debugMode:String;
    private var m_fps:Float;
    private var m_mousePos:Point;
    
    //for fps
    private var m_startTime:Int;
    private var m_frameCnt:Int;
    
    private var secs:Int;
	
	//using this to trace the debug statements
	private static var m_sBuffer:StringBuf = new StringBuf();
    
    public function new()
    {
        super();
        var isDebug:Bool = false;
        #if debug
            isDebug = true;
        #end
        
        m_buildStamp = MacroUtils.getBuildDate();
        m_debugMode = isDebug ? "Debug" : "Release";
        m_fps = 0;
        m_mousePos = new Point();
        
        var f:TextFormat = new TextFormat( null, 12, 0xFFFFFF );
        m_debugField = new TextField();
        m_debugField.defaultTextFormat = f;
        m_debugField.mouseEnabled = false;
        
        m_mouseField = new TextField();
        m_mouseField.defaultTextFormat = f;
        m_mouseField.mouseEnabled = false;
		
		//Initializing
		m_traceField = new TextField();
		m_traceField.defaultTextFormat = f;
		m_traceField.mouseEnabled = false;
		m_traceField.wordWrap = true;
        
        m_startTime = getTimer();
        m_frameCnt = 0;
        secs = 0;
        
        updateText();
		
		//Random offsets. Modify it if needed to better suit a cross platform library. 
        m_debugField.width = m_debugField.textWidth;
        m_debugField.height = m_debugField.textHeight * m_debugField.numLines;
		
		m_traceField.y = m_debugField.height;
		m_traceField.width = m_debugField.width;
		m_traceField.height = 25;
		
        redraw();
        
        mouseEnabled = false;
        addChild( m_debugField );
        addChild( m_mouseField );
        addChild( m_traceField );
        start();
    }
    
    private function redraw():Void
    {
        graphics.clear();
        
        graphics.beginFill( 0x000000, 0.5 );
        graphics.drawRect( 0, 0, 200, m_debugField.height );
        graphics.endFill();
        
        //Another rectagular fill for it.
        graphics.beginFill ( 0x000001, 0.2 );
        graphics.drawRect( m_traceField.x, m_traceField.y, 200, m_traceField.height );
        graphics.endFill();
    }
    
    private function updateText():Void
    {
        var m:Int = Std.int( secs / 60 );
        var s:Int = secs % 60;
        m_debugField.text = "T: " + m + "m " + s + "s        FPS: " + m_fps + "\nv" + m_buildStamp + " - " + m_debugMode;
		
		if ( m_sBuffer.toString() != "" )
		{
            //if the string has not changed, you don't have to update it
			if ( m_debugField.text != m_sBuffer.toString() )
			{
				//Clean the buffer if the string has changed.
				m_traceField.text = m_sBuffer.toString();
                m_traceField.height = m_traceField.textHeight + 10;
				m_sBuffer = new StringBuf();
                redraw();
			}
		}
    }
    
    private function start():Void
    {
        mouseEnabled = false;
        addEventListener( Event.ENTER_FRAME, updateTime );
    }
    
    private function updateMouse():Void
    {
        m_mousePos.x = Std.int( stage.mouseX / stage.scaleX );
        m_mousePos.y = Std.int( stage.mouseY / stage.scaleY );
        if ( !m_mouseField.visible ) return;
        
        m_mouseField.x = m_mousePos.x + 15; //account for cursor width
        m_mouseField.y = m_mousePos.y - 5;
        m_mouseField.text = "x: " + m_mousePos.x + "\ny: " + m_mousePos.y;
        
        if ( m_mouseField.x + m_mouseField.textWidth > stage.stageWidth / stage.scaleX )
        {
            m_mouseField.x = m_mousePos.x - m_mouseField.textWidth;
        }
        
        if ( m_mouseField.y + m_mouseField.textHeight > stage.stageHeight / stage.scaleY )
        {
            m_mouseField.y = m_mousePos.y - 50;
        }
    }
    
    private function updateTime( e:Event ):Void
    {
        //ellapsed time (s) from the last frame
        var ellapsedTime:Float = ( getTimer() - m_startTime ) / 1000;
        ++m_frameCnt;
        
        //one second has passed
        if ( ellapsedTime > 1 )
        {
            ++secs;
            m_fps = ( Std.int( ( m_frameCnt / ellapsedTime ) * 10 ) / 10 );
            updateText();
            
            //reset
            m_startTime = getTimer();
            m_frameCnt = 0;
            
            m_mouseField.visible = ( m_mousePos.x + m_mousePos.y ) != 0;
        }
        
        updateMouse();
    }
	
	public static function log( s:String ):Void
	{
		m_sBuffer.add( s + "\n");
	}
}