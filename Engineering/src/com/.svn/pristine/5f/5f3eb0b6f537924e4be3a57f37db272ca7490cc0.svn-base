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
package com.firstplayable.hxlib.utils;
import com.firstplayable.hxlib.app.Time.Milliseconds;
import haxe.Timer;

enum TimerStart
{
    Automatic;
    Manual;
}

/**
 * An advanced timer class.
 * This class is only supported on platforms that support events.
 */
class Delay
{
    /**
     * Delay (ms) between calls. Will not update the timer until it is started or restarted.
     */
    public var delay:Milliseconds;
    
    /**
     * Whether or not this timer is currently running.
     */
    public var isRunning(get, null):Bool;
    
    private function get_isRunning():Bool
    {
        return m_timer != null;
    }
    
    //members
    private var m_timer:Timer;
    private var m_triggerCount:Int;
    private var m_repeat:Int;
    private var m_onTrigger:Dynamic;
    private var m_onTriggerArgs:Array<Dynamic>;
    private var m_onComplete:Dynamic;
    private var m_onCompleteArgs:Array<Dynamic>;
    
    /**
     * Creates a new timer object.
     * @param    delay           Delay (ms) between calls.
     * @param    onTrigger       Function to call every delay interval.
     * @param    ?repeat         Number of times to trigger. Defaults to 1. A value <1 is infinite.
     * @param    ?triggerArgs    Arguments to pass to trigger function.
     * @param    ?onComplete     Function to call when the timer completes. A timer will never complete if
     *                           the repeat value is <1.
     * @param    ?completeArgs   Arguments to pass to complete function.
     * @param    ?startNow       If TimerStart.Automatically, imediately runs the timer. Otherwise, waits for start() to be called.
     */
    public function new( delay:Milliseconds, onTrigger:Dynamic, ?repeat:Int = 1, ?triggerArgs:Array<Dynamic>, ?onComplete:Dynamic, ?completeArgs:Array<Dynamic>, ?startNow:TimerStart ):Void
    {
        this.delay = delay;
        m_repeat = repeat;
        m_triggerCount = m_repeat;
        m_onTrigger = onTrigger;
        m_onTriggerArgs = triggerArgs;
        m_onComplete = onComplete;
        m_onCompleteArgs = completeArgs;
        //if anything other than Automatically including null, don't start
        if ( startNow == TimerStart.Automatic ) start();
    }
    
    /**
     * Start running the timer. Calling start() while the timer is already running will do nothing.
     */
    public function start():Void
    {
        if ( isRunning ) return;
        m_timer = new Timer( Std.int(delay) );
        //run is a dynamic function callback for Timer
        m_timer.run = onRun;
    }
    
    /**
     * Stops the timer.
     */
    public function stop():Void
    {
        if ( !isRunning ) return;
        m_timer.stop();
        m_timer = null;
    }
    
    /**
     * Stops and completes the timer (invokes onComplete function).
     */
    public function finish():Void
    {
        onTimerComplete();
    }
    
    /**
     * Resets the timer (and repeat count). Call start() to run it.
     */
    public function reset():Void
    {
        stop();
        m_triggerCount = m_repeat;
    }
    
    /**
     * Resets and starts the timer again.
     */
    public function restart():Void
    {
        reset();
        start();
    }
    
    /**
     * Change the trigger function and arguments. Calling setTrigger() while the timer is already 
     * running will do nothing.
     * @param    onTrigger    Function to call every delay interval.
     * @param    ?args        Arguments to pass to trigger function.
     */
    public function setTrigger( onTrigger:Dynamic, ?args:Array<Dynamic> ):Void
    {
        if ( isRunning ) return;
        m_onTrigger = onTrigger;
        m_onTriggerArgs = args;
    }
    
    /**
     * Change the complete function and arguments. Calling setComplete() while the timer is already
     * running will do nothing.
     * @param    complete    Function to call when the timer completes. A timer will never complete if
     *                       the repeat value (constructor) is <1.
     * @param    ?args       Arguments to pass to complete function.
     */
    public function setComplete( onComplete:Dynamic, ?args:Array<Dynamic> ):Void
    {
        if ( isRunning ) return;
        m_onComplete = onComplete;
        m_onCompleteArgs = args;
    }
    
    /**
     * Called constantly after every delay interval until completion count is reached.
     */
    private function onRun():Void
    {
        Reflect.callMethod( null, m_onTrigger, m_onTriggerArgs );
        --m_triggerCount;
        
        if ( m_triggerCount == 0 )
        {
            onTimerComplete();
        }
    }
    
    /**
     * Handles completion of a timer and stops it.
     */
    private function onTimerComplete():Void
    {
		stop();
		
        if ( m_onComplete != null )
        {
            Reflect.callMethod( null, m_onComplete, m_onCompleteArgs );
        }
    }
    
    /**
     * Calls a function after a delay. To pass function parameters, instantiate Delay instead.
     * @param    delay    The delay (ms) before invoking the function.
     * @param    invoke   The function to invoke after the delay.
     */
    public static inline function setTimeout( delay:Int, invoke:Void->Void ):Void
    {
        Timer.delay( invoke, delay );
    }
}