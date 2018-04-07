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

import com.firstplayable.hxlib.app.Updateable;
import com.firstplayable.hxlib.app.MainLoop;
import com.firstplayable.hxlib.app.UpdatePhase;
import com.firstplayable.hxlib.utils.FTimer.FTimers;
import com.firstplayable.hxlib.utils.FTimer.OSTick;

import com.firstplayable.hxlib.app.Time.Milliseconds;
import com.firstplayable.hxlib.app.Time.MonotonicTime;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.Debug.*;

// This class is a port of the C++ Timer class from dslib.

// define the "debug_timers" flag to see timer debug output

private typedef FTimerID = Int;
typedef OSTick = Milliseconds;     // In this system, the concept of "OSTicks" and "Milliseconds" are equivalent.
typedef CallbackFunction = Dynamic;

typedef FTimerList = Array< FTimerEntry >;  // The type of the TimerEntryList.  It would actually be a List, but List lacks an "insert" function, which is necessary.
typedef OSTickRef = { tick: OSTick };   // A container for an OSTick, so that this Int type can be referenced indirectly

/// @file FTimer.hx
///
/// "Freezable" timer system, allowing creation of looping and non-looping timers
/// that call callback functions after (approximately) some given time.
///
/// @see FTimer.create function for a simple usage example.

/// The type to use when setting the "loop" boolean in "set", to enhance readability (see ONE_SHOT and LOOP in FTimer)
@:allow( com.firstplayable.hxlib.utils.FTimer )
abstract FTimerLoopStatus( Bool ) to Bool
{
	private inline function new( status: Bool ) { this = status; }
}

/// The type to use when setting the "freezable" boolean in "set", to enhance readability (see FREEZABLE and UNFREEZABLE in FTimer)
@:allow( com.firstplayable.hxlib.utils.FTimer )
abstract FTimerFreezableStatus( Int ) to Int
{
	private inline function new( status: Int ) { this = status; }
	@:to public inline function toBool(): Bool { return( this == 1 ); }
}

/*********************************************************************************//**
 *  A sorted list of FTimerEntry structures is used by the FTimers class to keep 
 *  track of each timed event that is currently scheduled to happen.
 */
class FTimerEntry
{
	public var triggerTime: OSTick;    ///< time at which to trigger the entry
	public var pData: FTimer;          ///< the FTimer this Entry is for

	/// Construct a timer entry.
    public inline function new ( aTriggerTime: OSTick, apTimerObject: FTimer )
    {
	    triggerTime = aTriggerTime;
        pData = apTimerObject;
    }
}

/******************************************************************************************//**
 *  The FTimer object contains the interface and all the data for a timer (except for its
 *  expiration time, which is maintained in an entry in a list in the FTimers class; this entry
 *  can be accessed via the m_entry in this class).
 * 
 *  A note on lifetime: FTimer objects will maintain their own existance as long as they are
 *  running (since there is a reference to every running timer in the global list of running
 *  timers).  If a timer is PAUSED, it is removed from the running timers list and might therefore
 *  be garbage collected at any time, if no other reference to it is maintained.
 */
@:allow( com.firstplayable.hxlib.utils.FTimers )
class FTimer
{
	/// Two constants to use when setting the "freezable" boolean in "set", to enhance readability.
	public static inline var UNFREEZABLE = new FTimerFreezableStatus( 0 );
	public static inline var FREEZABLE   = new FTimerFreezableStatus( 1 );
	
	public static inline var ONE_SHOT = new FTimerLoopStatus( false );
	public static inline var LOOP     = new FTimerLoopStatus( true );

	public static var ETERNITY:Float = Math.POSITIVE_INFINITY;

	public var callback: CallbackFunction;       // callback function to call when triggered
	public var associatedData: Array<Dynamic>;   // information to pass back to the callback function
	
	public var freezable( default, set ): Bool;
	public var loop: Bool;                       ///< if LOOP, repeat the entry periodically (until removed)

	public var isRunning( get, never ): Bool;
	public var isPaused( get, never ): Bool;
	public var timeUntil( get, never ): Milliseconds;
	public var elapsedTime( get, never ): Milliseconds;
	public var hasExpired( get, never ): Bool;
	public var expirationCount( default, null ): Int;    // A count of the number of times this timer has expired since its creation (or the last time this count was reset)

	//----- These two properties only function when in debug
	public var name( never, set ): String;
	public var print( never, set ): Bool;
	//-------------------------------------------
		
	private static var NOT_PAUSED = ETERNITY;

    private static var ms_nextId: FTimerID = 1;    ///< The unique ID that will be used for the next timer that is created.
	                                               // Start unique timer IDs at 1.

	
	private var m_id: FTimerID;             ///< A unique ID for this timer.

	private var m_entry: FTimerEntry;       ///< Points to the timer's entry in the Timers.m_entries[ m_freezable ].
										    ///<   m_entry == null indicates that the timer is not running 
										    ///<   (and there is therefore no entry for it in the m_entries lists).

	private var m_interval: Milliseconds;                    ///< length of time this timer is to run (in milliseconds)
	private var m_freezable: FTimerFreezableStatus; ///< if FREEZABLE, this timer is frozen by Timers.freezeAll().

	private var m_strictCumulativeInterval: Milliseconds;    ///< Used only if the timer is set to LOOP.
										   ///< Set to the current loop interval whenever activateStrictAccumulatedTimeMode() is called.
										   ///<    If still 0, we are using the default mode; looping timer is reset to expire based on the time it was
										   ///<      actually triggered.  Period will be constant, and a multiple of the frame time.
										   ///<    If > 0, we are using strict cumulative time mode; looping timer is reset to expire based on the time
										   ///<      that it was *previously set to expire*, plus this interval (in ms).
										   ///<      (The time set to expire and the actual trigger time may differ slightly, because timers are triggered
										   ///<      only every frame; these differences can accumulate over time, depending on how the timer is used.)
										   ///<      NOTE: This mode can still have an accumulated error of a bit less than 1%; since it is based on frames,
										   ///<            and only times to millisecond precision, extreme precision over long periods should not be expected.

	private var m_pausedIntervalLeft: Milliseconds;            ///< normally, ETERNITY; when individually paused, the amount of interval left to be timed.              

#if debug
	private var m_name: String;                  ///< A name for the timer, which can be used in Debug or Release builds.
	private var m_print: Bool;                   ///< Whether or not to print the timer, in debug.
#end
    
	/// The interface to use for the creation of a new Timer.  This does not start the Timer ticking.
	///
	/// Simple usage example:
	///
	///      // Somewhere in cpp:
	///      static void testTimerFunc( void * pData ) { doStuffWith( pData ); }
	///
	///      // In constructor initializer list;
	///      // creates a simple 7sec timer that calls testTimerFunc( this ).
	///      , m_myTestTimer( timer::create( &testTimerFunc, this, timer::Seconds( 7 ) ) )
	///
	///      // Later, in code, set it looping (if you like) and kick it off!
	///      m_myTestTimer->setLoop( true ); // optional
	///      m_myTestTimer->set(); // can specify time here instead of CIL if desired
	///
	public static function create( duration: Milliseconds = 0,
	                               callbackFunction: CallbackFunction, 
								   aAssociatedData: Array<Dynamic> = null,
								   aFreezable: FTimerFreezableStatus = FREEZABLE,
								   aLoop : FTimerLoopStatus = ONE_SHOT ): FTimer
	{
		return( new FTimer( duration, callbackFunction, aAssociatedData, aFreezable, aLoop ) );
	}
	
	/// start() is identical to create(), except that in addition, it automatically starts the created timer.
	public static function start ( duration: Milliseconds = 0,
								   callbackFunction: CallbackFunction, 
								   aAssociatedData: Array<Dynamic> = null,
								   aFreezable: FTimerFreezableStatus = FREEZABLE,
								   aLoop : FTimerLoopStatus = ONE_SHOT ): FTimer
	{
		var newTimer = new FTimer( duration, callbackFunction, aAssociatedData, aFreezable, aLoop );
		newTimer.set();
		return( newTimer );
	}

	// Construct a new FTimer
	public function new( duration:   Milliseconds = 0,
                         callbackFunction: CallbackFunction,
	                     aAssociatedData: Array<Dynamic> = null,
                         aFreezable: FTimerFreezableStatus = FREEZABLE, 
						 aLoop:      FTimerLoopStatus = ONE_SHOT )
    {
		m_id = ms_nextId++;
		m_entry = null;   // init to "no entry"
		callback = callbackFunction;
		associatedData = aAssociatedData;
		m_interval = duration;
		m_freezable = aFreezable;
		loop = aLoop;
		m_strictCumulativeInterval = 0;   // Do not use strict accumulated time mode, by default.
		m_pausedIntervalLeft = NOT_PAUSED;
		expirationCount = 0;
#if debug_timers
		m_name = "";
		m_print = true;
#end
	}

	/// Set the time, and start the timer running. (Will WARN if msec is 0; use "1 msec" for "next frame".)
	/// If no time is given, start the timer and use the last set time.
	/// If timer is already running, will restart it with the given interval.  If paused, it will be unpaused.
	public function set( ?msec: Milliseconds ): Void
    {
		if ( m_freezable && !FTimers.instance.m_notFrozen )
		{
			warn( "Tried to set a frozen timer!  Ignored." );
			return;
		}

		if ( msec == 0 )
		{
			warn( "Set timer expicitly with duration of zero!" );
		}
		FTimers.instance.baseSet( (msec == null) ? m_interval : msec, this );
   }

	/// Indicates if this timer has ever been set before and has yet to expire.
	public inline function isSet(): Bool { return !( !isRunning && !isPaused ); }

	/// Set whether or not the Timers->freezeAll() function will freeze this timer.
	/// NOTE: setFreezable will not do nothing but WARN if the timer is running!
    public function set_freezable( aFreezable: Bool ): Bool
    {
		// If timer is running, WARN and return.
		if(    m_entry != null
		    || !FTimers.instance.m_notFrozen )         
		{
			warn( "Cannot set freezable status of Timer; the timers are frozen, or it is running!" );
			return m_freezable;
		}
		return( m_freezable = (aFreezable) ? FREEZABLE : UNFREEZABLE );
    }

	// See m_strictCumulativeInterval, below.  Only makes a difference over multiple loops.
	public function activateStrictAccumulatedTimeMode(): Void
	{
		if ( loop != LOOP || m_interval == 0 )
		{
			warn( "Activating Strict Accumulated Time Mode only makes sense for looping timers that have their period set!" );
		}

		m_strictCumulativeInterval = m_interval;
	}

	/// Cancel a timer before it expires.  Unpauses the timer, if paused.
	/// Clear is the one function that *will* work on a frozen timer.
	public inline function clear(): Void
	{
		clearWithClearPause( true );
	}

	/// Pause the timer.  This pauses only this timer, and is completely independent of global "freezing"
	/// functionality (except in that frozen timers cannot be paused until they are unfrozen).
	public function pause(): Void
    {
		if( isRunning )
		{
			// save the amount of time that the timer has left to run in m_pausedIntervalLeft
			// Also, marks the timer as "paused".
			m_pausedIntervalLeft = m_entry.triggerTime - MonotonicTime.get();

			// and remove it from the timer lists.
			clearWithClearPause( false );
#if debug_timers
			if( m_print ) { log( m_name + " Timer Paused." ); }
		}
		else
		{
			if( m_print ) { log( "Timer " + m_name + " cannot be paused; not running."); }
#end
		}
   }
   
	/// Resume the ticking of a paused timer.  (Frozen timers cannot be unpaused.)
    public function unpause(): Void
	{
		// If paused and not frozen,
        if(    m_pausedIntervalLeft != NOT_PAUSED
            && ( ! m_freezable.toBool() || FTimers.instance.m_notFrozen ) )
        {
            if( m_entry != null ) { error( "m_entry != null" ); }
         
            var saveTheInterval: Milliseconds = m_interval;            // Save the m_interval so it can be restored two lines later
            FTimers.instance.baseSet( m_pausedIntervalLeft, this );    // Set the timer to the remaining time
            m_interval = saveTheInterval;                              // restore the m_interval (re-set by baseSet).
            m_pausedIntervalLeft = NOT_PAUSED;    // Mark the Timer as "not paused".
#if debug_timers
            if( m_print ) { log( m_name + " Timer Unpaused." ); }
		}
		else
		{
		    if ( m_print ) { log( "Timer " + m_name + " is not paused, or is frozen, so cannot be unpaused." ); }
#end
        }
   }
   
	/// Return true if the timer is paused.
    private inline function get_isPaused(): Bool
    {
		return( m_pausedIntervalLeft != NOT_PAUSED );
	}

	/// Get the number of milliseconds until the timer expires, assuming that the timer is running.
	/// If the timer has expired, or has never been set, 0 is returned.
	private function get_timeUntil(): Milliseconds
    {
		// If timer is in the running timer list,
		if( m_entry != null )
		{
			var now: OSTick = MonotonicTime.get();
			var freezeInterval: OSTick =
				  if( m_freezable && !FTimers.instance.m_notFrozen )
				  {
				  	  // Timer is currently frozen;
				      now - FTimers.instance.m_frozenSince;
				  }
				  else
				  {
				  	  0;
				  }

			var time: Milliseconds = m_entry.triggerTime - now + freezeInterval;

			return( (time > 0) ? time : 0 );
		}
		else if( m_pausedIntervalLeft != NOT_PAUSED )
		{
			return( m_pausedIntervalLeft );
		}
		else
		{
			// Timer has expired, or not been set.  Return "0".
			return( 0 );
		}
    }

	/// Get the amount of time that the timer for this event has been running (in msec), not including time
	///   that it has been paused or frozen.  If the timer has expired, the time the timer was last
	///   set to (or initialized to during construction) is returned.  If the timer was not explicitly
	///   initialized during construction and has not yet been set, this will be 0.
	private inline function get_elapsedTime(): Milliseconds
	{
		return( m_interval - timeUntil );
	}

	/// Indicates whether the specified timer is currently "running".  A timer is "running" if it has
	/// been set, has not yet expired, and is neither Paused nor Frozen.
	/// Note that when a TimerObject is constructed, it starts not running.
	private function get_isRunning(): Bool
	{
		return(    m_entry != null
				&& (! m_freezable.toBool() || FTimers.instance.m_notFrozen ) );
	}

	/// Returns true if this timer has been started, and has subsequently expired.  (Equivalent to (getExpirationCount() > 0).)
	private inline function get_hasExpired(): Bool  { return expirationCount > 0; }

#if debug
	/// In Debug only, give the timer a name, so you can identify it when it prints out information.
	private inline function set_name( name: String ): String { m_name = name; return m_name; }
	/// Call setPrint( false ) to hide all the output from this timer, if you are displaying all timers.
	private inline function set_print( print: Bool ): Bool { m_print = print; return m_print; }
#else
	private inline function set_name( name: String ): String { return name; }
	private inline function set_print( print: Bool ): Bool { return print; }
#end

    /// Cancel a timer before it expires.  Unpauses the timer, if requested.
    private function clearWithClearPause( clearPause: Bool ): Void
    {
	    if( m_entry != null )
        {
            var entries: FTimerList = FTimers.instance.m_entries[ m_freezable ];
            var pTriggerTimeToAdjust: OSTickRef = ( m_freezable ) ? FTimers.instance.m_nextFreezableTriggerTime
                                                                  : FTimers.instance.m_nextUnfreezableTriggerTime;
            entries.remove( m_entry );
            m_entry = null;

            if( clearPause )
            {
                // Unpause the timer
                m_pausedIntervalLeft = NOT_PAUSED;
            }

#if debug_timers
            if ( m_print && m_pausedIntervalLeft == NOT_PAUSED ) { log( "Cleared " + m_name + " Timer."); }
#end
            //if this is the last active timer in the list
            if ( entries.length == 0 )
            {
                //reset trigger time
                pTriggerTimeToAdjust.tick = ETERNITY;
            }
            else  //there are other entries
            {
                //set trigger time to the next timer which will fire
                pTriggerTimeToAdjust.tick = entries[ 0 ].triggerTime;
            }
        }
        else if( clearPause )
        {
            if( m_pausedIntervalLeft != NOT_PAUSED )
            {
                m_pausedIntervalLeft = NOT_PAUSED;
#if debug_timers
                if( m_print && m_pausedIntervalLeft == NOT_PAUSED ) { log( "Cleared " + m_name + " Timer, which was paused."); }
            }
            else
            {
                if( m_print ) { log( "Cleared already clear " + m_name + " Timer." ); }
#end
            }
        }
    }

	/// Reset the recorded number of times this timer has expired since its creation to zero.
	public function resetExpirationCount(): Void
	{
		expirationCount = 0;
	}

#if debug
    public function toString(): String
	{
		var buffer: StringBuf = new StringBuf();
		#if debug_timers
			if( m_name != "" )
			{
				buffer.add( "Timer \"" + m_name + "\":" );
			}
			else
			{
				buffer.add( "Timer " );
			}
		#else
			buffer.add( "Timer " );
		#end
		if( m_freezable && FTimers.instance.areFrozen )
		{
			buffer.add( "  (*FROZEN*)" );
		}
		if( m_pausedIntervalLeft == NOT_PAUSED )
		{
			var timeLeft: Milliseconds = timeUntil;
			if( timeLeft == 0 )
			{
				buffer.add( "  (expired) " );
			}
			else
			{
				buffer.add( "  (expires in " + timeLeft + " msec, on tick " + (m_entry.triggerTime) + ") " ); 
			}
		}
		else
		{
			buffer.add( "  (*PAUSED*, " + m_pausedIntervalLeft + " msec remaining) " );
		}
		
		buffer.add(   (m_freezable ? "(FREEZABLE)" : "(NOT_FREEZABLE)" ) 
		            + (loop ? " (LOOP)" : " (ONE-SHOT)") );

		// DETAILS( NL + TAB_IN + "Calls function " + aTimerObject.callback + " with data at " + aTimerObject.associatedData );
		// DETAILS(                 "Interval: " + aTimerObject.m_interval + " msec" + SL );
		return( buffer.toString() );
	}
#end

}

/******************************************************************************************//**
 *  The Timer singleton enables the setting of an arbitrary number of timed events.
 *  These events are defined by a callback function and (optionally) an identifying
 *  piece of data; when the time for an event has elapsed, the callback function is
 *  called with the peiece of data passed as its parameter (as, or via, a void*).
 *  The event is then permanently deleted, unless the "loop" parameteter is set to true;
 *  in that case, the timer is reset, and the event repeats periodically.
 *
 *  The resolution of timed events is only as good as the frame update rate, since
 *  the check for expired timers is designed to be done during update().  This makes the
 *  timers only good for measuring times to a resolution of a 60th of a second or two,
 *  but has the advantage that timer callback functions have no synchronization issues with
 *  the rest of the project's code.  The other advantage over the SDK "Alarm" system, which
 *  has similar functionality, is that Timer takes care of memory allocation internally.
 *  
 *  Timers support individual pausing, and freezing of all timers that are not marked "unfreezable"
 *  (making the "PAUSE" button for a game easy to implement, for example).
 */
@:allow( com.firstplayable.hxlib.utils.FTimer )
class FTimers implements Updateable
{
	//====================================================================================================
	// Timers singleton

	public static var instance: FTimers;
	
	public var areFrozen( get, never ): Bool;
	
	/// A sorted list of all the timers that are set to trigger (aka all the "running" timers).
	/// The entry that will be triggered next is always at the beginning of the list.
	/// This array is indexed on FreezableStatus: there are two lists, one for unfreezable (0) and one for freezable (1) timers.
	private var m_entries: Array< FTimerList >;

	private var m_nextUnfreezableTriggerTime: OSTickRef;   ///< The soonest time that any of the unfreezable set timers will expire.
	private var m_nextFreezableTriggerTime: OSTickRef;     ///< The soonest time that any of the freezable set timers will expire.

	private var m_frozenSince: OSTick;                  ///< If the timers are frozen, the tick that they were frozen.
	private var m_notFrozen: Bool;                      ///< Whether or not the timers are frozen.  (Negative, for speed in update().)

	// Call this after making the Timers object, to init the static singleton reference
	public static function init(): FTimers
	{
		instance = new FTimers();
		MainLoop.runUpdate( instance, UpdatePhase.SYSTEM );
		return( instance );
	}
	
	/// Construct the Timers singleton.
	function new()
	{
		#if debug_timers
			log("Detailed timer debugging active.");
		#end
		m_nextUnfreezableTriggerTime = { tick: FTimer.ETERNITY };
		m_nextFreezableTriggerTime = { tick: FTimer.ETERNITY };
		m_frozenSince = 0;
		m_notFrozen = true;
		
		m_entries = new Array< FTimerList >();
		m_entries.push( new FTimerList() );
		m_entries.push( new FTimerList() );

        log("FTimer system initialized.");
    }
   
   	/// This function is called by the update() function, when it is determined that an unfreezable timer has triggered.

    /// Called whenever a timer expires; triggers (calls) its callback function, with its associated data (if any),
    /// and removes the timer from the timer list (or restarts it, if it is set to LOOP).
    private function trigger( entries: FTimerList, triggerTimeToAdjust: OSTickRef, now: OSTick ): Void
    {
		// don't try to trigger anything if we don't have any timers.
		if ( entries.length == 0 )
		{
			warn( "FTimers.trigger called with empty entries list, this means m_nextTriggerTime may be invalid, and the next trigger will trigger immediately on add.  Call Lan or Doug." );
			return;
		}

		// Trigger the entry on the front of the given list!
		var originalEntryRef: FTimerEntry = entries[ 0 ];
		var curTimerID: FTimerID = originalEntryRef.pData.m_id;

		// Increment the timer's expiration count
		++ originalEntryRef.pData.expirationCount;

#if debug_timers
        if ( originalEntryRef.pData.m_print ) { log( originalEntryRef.pData.m_name + " Timer triggered." ); }
#end
        // Call the timer's callback function, if it exists.
        if( originalEntryRef.pData.callback != null )
        {
            Reflect.callMethod( null, originalEntryRef.pData.callback, originalEntryRef.pData.associatedData );
        }
		
        // At this point, the timer may have been reset or removed by the callback function.
        // THE originalEntryRef IS STALE, AND MAY NO LONGER REFLECT THE FRIST ENTRY IN THE TIMER LIST.
        // THERE MAY EVEN BE NO ENTRIES LEFT IN THE LIST.

        // Check to be sure that the entry that was in front (that just triggered)
        //  is still the same one that we were working on before the callback.
        //  This could change, for example, if the timer object is destroyed by its own callback function.
        //  If it's still there and its expiration time hasn't yet been reset, destroy or reset the entry.
        if(    entries.length != 0
            && curTimerID == entries[ 0 ].pData.m_id
            && now >= entries[ 0 ].triggerTime )
        {
			var pNewFrontEntryData: FTimer = entries[ 0 ].pData;

            if( pNewFrontEntryData.loop )
            {
				// LOOP is set: restart this timer.
                if( pNewFrontEntryData.m_strictCumulativeInterval == 0 )
                {
                    // Standard ("STRICT INTERVAL") mode; simply reset with constant interval
                    baseSet( pNewFrontEntryData.m_interval, pNewFrontEntryData );
                }
                else // pNewFrontEntryData->m_strictCumulativeInterval != 0
                {
                    // "STRICT ACCUMULATED TIME" mode:
                    // Figure out and remove the "accumulation error" from the time interval, so that the next
                    //   trigger time takes the amount that we were just late in triggering into account in the
                    //   next trigger time's interval.
                    
                    var timeError: Milliseconds = (now - entries[ 0 ].triggerTime);
			        
                    // Note that this time is still only good to within a millisecond; sub-millisecond errors
                    //   will still be accumulating, here.  The Timer class doesn't support this usage very
                    //   well right now (but it could be further improved, at need, with a higher-resolution
                    //   set function).
                    baseSet( (pNewFrontEntryData.m_strictCumulativeInterval > timeError)
                                 ? pNewFrontEntryData.m_strictCumulativeInterval - timeError : 1,
                             pNewFrontEntryData );
                }
                // baseSet removes the existing entry for this timer, so we should not pop().
            }
            else
            {
				// Timer is done, and not looping, so remove it from the list of active timers.
                pNewFrontEntryData.m_entry = null;
                entries.shift();   // TODO: This is not as efficient as I'd like in this library code...
            }
        }

        // Update the given triggerTime.
        if( entries.length == 0 )
        {
            triggerTimeToAdjust.tick = FTimer.ETERNITY;
        }
        else
        {
            triggerTimeToAdjust.tick = entries[ 0 ].triggerTime;
        }
    }

    /// Execute the callback function for any timers that have expired.
    /// This function must be called by each frame by the program's main loop, in order for the Timer class to work.

    /// If the current time is >= the time that the next timer expires in either list, trigger its event.
    public function update( UpdateContext ): Void
    {
		var now: OSTick = MonotonicTime.get();
		
        while( now >= m_nextUnfreezableTriggerTime.tick )
        {
            trigger( m_entries[ FTimer.UNFREEZABLE ], m_nextUnfreezableTriggerTime, now );
        }
        if( m_notFrozen )
        {
            while ( now >= m_nextFreezableTriggerTime.tick )
            {
				trigger( m_entries[ FTimer.FREEZABLE ], m_nextFreezableTriggerTime, now );
            }
        }
    }

	/// Freeze all freezable timers.
	/// Time does not pass for "frozen" timers, and they cannot be set or paused; getting their elapsed time will WARN.
    public function freezeAll(): Void
    {
        if( m_notFrozen )
        {
            // Set that we are frozen, and save the time that we were frozen.  That's it.
            m_notFrozen = false;
            m_frozenSince = MonotonicTime.get();
			#if debug_timers
				log("Timers Frozen.");
			#end
        }
		#if debug_timers
        else
        {
            log("Tried to freeze timers that were already frozen.");
        }
		#end
    }
   
	/// Unfreeze all freezable timers (if frozen).
    public function unfreezeAll(): Void
    {
        if( !m_notFrozen)
        {
            // don't perform this logic if we don't have any timers, otherwise we'll do undefined things
            if( !(m_entries[FTimer.FREEZABLE].length == 0) )
            {
                // Go through the list of frozen timers, and add the time that we were frozen to each timer's expiration time.
                var freezeInterval: OSTick = MonotonicTime.get() - m_frozenSince;
                for( i in m_entries[FTimer.FREEZABLE] )
                {
                    i.triggerTime += freezeInterval;
                }
                m_nextFreezableTriggerTime.tick = m_entries[FTimer.FREEZABLE][ 0 ].triggerTime;
            }

            // Set that we are no longer frozen.
            m_frozenSince = 0;
            m_notFrozen = true;
			#if debug_timers
				log("Timers unfrozen.");
			#end
        }
		#if debug_timers
        else
        {
            log("Tried to unfreeze timers that were not frozen.");
        }
		#end
    }
   
	/// Get whether the freezable timers are frozen or not.
	private inline function get_areFrozen(): Bool
	{
		return( !m_notFrozen );
	}

#if debug
    // Make a stream operator for the Timers class, which calls dumpActiveTimers.
    // Print out all the active timers.
    // Note: A timer is "active" if it is "in the timer lists".  That would be if it has been set, and is running, paused, or frozen, and is not expired.
    //       A timer is "running" if it has been set, has not expired, and is not paused or frozen.
    public function toString(): String
    {
	    if( m_entries[FTimer.UNFREEZABLE].length == 0 && m_entries[FTimer.FREEZABLE].length == 0 )
        {
            return( "(No timers active.)" );
        }
        else
        {
            var buffer: StringBuf = new StringBuf();
		    buffer.add( "\n-------------------------------------------------------------------" );
		    buffer.add( "\n Active Timers (at tick " + MonotonicTime.get() + ")" );
            if( areFrozen )
            {
                buffer.add( "  FROZEN (since tick " + m_frozenSince + ")" );
            }
		    buffer.add( "\n-------------------------------------------------------------------" );

            buffer.add( "\n " + m_entries[FTimer.UNFREEZABLE].length + " System Timer" + (m_entries[FTimer.UNFREEZABLE].length == 1 ? "" : "s") + " (not freezable)" );
            buffer.add( "\n-------------------------------------" );
            for( i in m_entries[FTimer.UNFREEZABLE] )
            {
				buffer.add( "\n    " + i.pData );
            }
			if ( m_entries[FTimer.UNFREEZABLE].length > 0 ) 
			{ 
				buffer.add( "\n-------------------------------------" );
			}
            buffer.add( "\n " + m_entries[FTimer.FREEZABLE].length + " Game Timer" + (m_entries[FTimer.FREEZABLE].length == 1 ? "" : "s") + " (freezable)" );
            buffer.add( "\n-------------------------------------" );
            for( i in m_entries[FTimer.FREEZABLE] )
            {
				buffer.add( "\n    " + i.pData );
            }
		    var result = buffer.toString();
		    return( result );
        }
    }
#end

	/// This set function is called by all the other public set functions, after figuring out the duration of the timer.
    private function baseSet( milliseconds: Milliseconds, pTimerData: FTimer ): Void
    {
#if debug_timers
        if( pTimerData.m_print ) { log( "Setting " + pTimerData.m_name + " Timer to expire in " + milliseconds + " milliseconds."); }
#end
        // Make a new timer::Entry
        var now: OSTick = MonotonicTime.get();
        var newTriggerTime: OSTick = now + milliseconds;
        var freezable: FTimerFreezableStatus = pTimerData.m_freezable;
      
        var newEntry = new FTimerEntry( newTriggerTime, pTimerData );

        var entries: FTimerList = m_entries[ freezable ];
        var pTriggerTimeToAdjust: OSTickRef = ( freezable ) ? m_nextFreezableTriggerTime : m_nextUnfreezableTriggerTime;

        // Erase any existing timer::Entry for this timer (resetting the timer, if it is active)
        if( pTimerData.m_entry != null )
        {
            entries.remove( pTimerData.m_entry );
         
            //if this is the last active timer in the list
            if ( entries.length == 0 )
            {
                //reset trigger time
                pTriggerTimeToAdjust.tick = FTimer.ETERNITY;
            }
            else  //there are other entries
            {
                //set trigger time to the next timer which will fire
                pTriggerTimeToAdjust.tick = entries[ 0 ].triggerTime;
            }
        }

        // Put the new entry into the proper position in the list (sorted by expiration time)
	    var insertPos = 0;
	    for ( i in 0...entries.length )
	    {
		     if ( entries[ i ].triggerTime >= newTriggerTime )
		     {
			      break;
		     }
		     else
		     {
			      ++ insertPos;
		     }
	    }
	    entries.insert( insertPos, newEntry );
	    pTimerData.m_entry = newEntry;

        // If this new entry is first in the list, set the next trigger time to be its trigger time.
        if( newTriggerTime < pTriggerTimeToAdjust.tick )
        {
            pTriggerTimeToAdjust.tick = newTriggerTime;
        }
        // Save the interval that was set, for later resets (and elapsedTime checks).
        pTimerData.m_interval = milliseconds;
        // Unpause the timer, if it is paused
        pTimerData.m_pausedIntervalLeft = FTimer.NOT_PAUSED;
    }
}
