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
package com.firstplayable.hxlib.app;

import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.app.Time;

using Lambda;

typedef UpdatePhaseId = Int;

typedef UpdateFunction = Updateable.UpdateContext -> Void;

@:allow( com.firstplayable.hxlib.app.MainLoop )
/**
 *  An UpdatePhase is a distinct phase of the game's MainLoop.  There is currently only one UpdatePhase
 *  (the GAME_LOGIC update phase), but more can be added, by adding their ids here, and adding them in
 *  MainLoop.new().  Each phase is independent, and will be updated in the order added to the MainLoop.
 * 
 *  As doUpdates() is called on each phase by the MainLoop, each function that is registered to be called
 *  during this phase's update will be called (in the order added).
 */
class UpdatePhase
{
    public static inline var NO_PHASE          : UpdatePhaseId =  -1;
	public static inline var SYSTEM            : UpdatePhaseId =   0;
    public static inline var GAME_LOGIC        : UpdatePhaseId =   1;
    public static inline var ANIMATION         : UpdatePhaseId =   2;
    public static inline var NUM_UPDATE_PHASES : UpdatePhaseId =   3;
    
    public var id( default, null ): UpdatePhaseId;
    
    /** If set to false, this update phase will not occur. */
    public var enabled( default, set ): Bool;
    
    /** The timestep at which this phase updates.
	 *  This is the difference in time between updates on Updateables.
	*/
    public var period( default, null ): Milliseconds; 
    
    /** The time for which this phase last updated (or is currently updating);
     *   the "current time", from the point of view of this phase. */
    public var now( default, null ): Milliseconds;
    
    /** The amount of time that has accumulated that we haven't updated for yet */
    public var timeLeft( default, null ): Milliseconds;
    
    /** @returns true iff we are currently executing the last update before rendering. */
    public var currentUpdateWillRender( get, null ): Bool;
    
    /** The amount of time that has passed between the last update and the previous update call; the delta time between the last two frames. 
	 *  This is the difference in time between updates on UpdatePhases.
	 *  If you're using this outside of this class, you're probably wrong. See @period instead.
	*/
    public var frameTime( default, null ):Milliseconds;
    
    public var updateFunctions( default, null ): List< UpdateFunction >;
    
    private function new( phaseId: UpdatePhaseId, updatePeriod: Milliseconds )
    {
        id = phaseId;
        enabled = true;
        period = updatePeriod;
        init();
        
        updateFunctions = new List < UpdateFunction >();
    }
    
    private function init(): Void
    {
        now = 0;
        timeLeft = 0;
    }
    
    // Registers the given function to be called during every update.
    // If the function is already registered, nothing happens; items in the update list are kept unique.
    // This function is only called via the interface in MainLoop, which is a friend of this class.
    private function runUpdateFunction( updateFunction: UpdateFunction ): Void
    {
        if ( !updateFunctions.has( updateFunction ) )
        {
            updateFunctions.push( updateFunction );
        }
    }
    
    // Unregisters the given function, stopping periodic calls to its update function.
    // If the function is not registered, nothing happens.
    // This function is only called via the interface in MainLoop, which is a friend of this class.
    private function stopUpdateFunction( updateFunction: UpdateFunction ): Void
    {
        updateFunctions.remove( updateFunction );
    }

    // This setter ensures that when an update phase is re-enabled, it is re-initialized.
    private function set_enabled( enable: Bool ): Bool
    {
        if ( enable )
        {
            init();
        }
        return( enabled = enable );
    }
    
    private function get_currentUpdateWillRender(): Bool
    {
        return( timeLeft - period < period );
    }

    /** Update this UpdatePhase.  This is called by MainLoop.doUpdate(). */
    private function update( aFrameTime:Milliseconds ): Void
    {
        frameTime = aFrameTime;
        
        // If this update phase is not enabled, do not update.
        if ( !enabled )
        {
            return;
        }

        // TODO: Currently, we do all the necessary updates for each phase /by phase/ --
        //   this may be pretty bad for some applications, if different phases have different update rates, but
        //   it will work for now!  Fixing it is probably more work than it's worth, especially given
        //   that we are only ever likely to use a single common update rate.

        // The following code is heavily inspired by that in the article "Fix Your Timestep!", available at
        //   http://gafferongames.com/game-physics/fix-your-timestep/
        // (The other half is in MainLoop.doUpdates().)

        timeLeft += aFrameTime;
        
        // The main loop's latest time increment has just been added to the amount of time left to be simulated:
        //    now we have to catch up this phase's "now" to closer to the global "now" (one time period at a time)
        while ( timeLeft >= period )
        {
            // Call each of the registered update functions
            for ( updateFuntion in updateFunctions )
            {
                updateFuntion( { phase: this } );
            }

            timeLeft -= period;
            now += period;
        }
    }
}