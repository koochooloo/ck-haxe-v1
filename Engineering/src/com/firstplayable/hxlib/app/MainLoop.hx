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

import com.firstplayable.hxlib.app.Time.Milliseconds;
import com.firstplayable.hxlib.app.Time.MonotonicTime;
import com.firstplayable.hxlib.app.UpdatePhase;
import com.firstplayable.hxlib.Debug.*;
import openfl.events.Event;
import openfl.Lib;

class MainLoop
{
    private static var updatePeriod: Milliseconds;
    
    /** The longest time from which we will attempt to smoothly recover (executing all the missed calls to the
     *   update functions).  The current value for MAX_FRAME_TIME is just a guess;  if the main loop
     *   ever permanently fails to catch up (which can theoretically happen!), decrease this! */
    public static inline var MAX_FRAME_TIME: Milliseconds = 250;
    
    /** The (theoretically) monotonic time for which the overall system last updated (or is currently) updating. */
    public static var now( default, null ): Milliseconds = 0;
    
    /** True iff MainLoop init() has completed. */
    private static var isReady( default, null ): Bool = false;
    
    /** True iff updates are currently being executed. */
    public static var isUpdating( default, null ): Bool = false;
    
    /** The current phase that is being executed; if updates are not currently being performed, returns UpdatePhase.NO_PHASE. */
    public static var currentPhase( default, null ): UpdatePhaseId = UpdatePhase.NO_PHASE;
    
    /** The time that updates last completed. */
    public static var lastUpdateTime( default, null ): Milliseconds = 0;
    
    /** The UpdatePhases of the MainLoop. */
    private static var m_phases( default, null ): Array< UpdatePhase >;

    /** @returns The UpdatePhase with the given UpdatePhaseId. */
    public static function getPhase( phaseId: UpdatePhaseId ): UpdatePhase
    {
        return ( isValid( phaseId ) ? m_phases[ phaseId ] : null );
    }
    
	/**
	 * Initializes MainLoop to update at given fps.
	 * @param	?fps	The framerate to run at. Defaults to use stage.frameRate.
	 */
    public static function init( ?fps:Float ): Void
    {
		if ( fps == null )
			fps = Lib.current.stage.frameRate; //defined in project settings
		
		updatePeriod = Math.ceil( 1000 / fps ); //convert fps to ms
		
        m_phases = new Array< UpdatePhase >();
        
        //---- All Update Phases must be initialized here, and their periods set ----
        // NOTE: If differing update periods are used for different phases, see the TODO in UpdatePhase.update()!
		m_phases.push( new UpdatePhase( UpdatePhase.SYSTEM,     updatePeriod ) );
        m_phases.push( new UpdatePhase( UpdatePhase.GAME_LOGIC, updatePeriod ) );
        m_phases.push( new UpdatePhase( UpdatePhase.ANIMATION,  updatePeriod ) );

        // Make sure all phases are initialized
        error_if( m_phases.length != UpdatePhase.NUM_UPDATE_PHASES, "Incorrect number of Update Phases initialized!" );
    
        for ( phaseId in 0...UpdatePhase.NUM_UPDATE_PHASES )
        {
            error_if( m_phases[ phaseId ] == null, "Update Phase " + phaseId + " is not initialized!" );
        }
        
        isReady = true;
		
		resume();
    }
	
	public static function pause():Void
	{
		Lib.current.stage.removeEventListener( Event.ENTER_FRAME, doUpdates );
	}
	
	public static function resume():Void
	{
		lastUpdateTime = MonotonicTime.get();
		
		Lib.current.stage.addEventListener( Event.ENTER_FRAME, doUpdates );
	}
    
    public static function isValid( phaseId: UpdatePhaseId ): Bool
    {
        if ( phaseId == UpdatePhase.NO_PHASE )
        {
            warn( "NO_PHASE cannot be used as an UpdatePhaseId in this context." );
            return false;
        }
        else if ( phaseId == UpdatePhase.NUM_UPDATE_PHASES )
        {
            warn( "NUM_UPDATE_PHASES cannot be used as an UpdatePhaseId." );
            return false;
        }
        return true;
    }

    /** Registers the update function of the given Updateable to be called during every update.
     *  If the function is already registered, nothing happens; items in the update list are kept unique. */
    public static function runUpdate( updateableObject: Updateable, phaseId: UpdatePhaseId = UpdatePhase.GAME_LOGIC ): Void
    {
        if ( !isReady )  { /*warn( "MainLoop.init() has not been run!" );*/ return; }

        // TODO: Add ability to add to list before/after particular other update call?
        //  (If so, should add to registerUpdateFunction, as well.)

        if ( exists( updateableObject ) )
        {
            runUpdateFunction( updateableObject.update, phaseId );
        }
    }
    
    /** Registers the update function of the given Updateable to be called during every update.
     *  If the function is already registered, nothing happens; items in the update list are kept unique. */
    public static function stopUpdate( updateableObject: Updateable, phaseId: UpdatePhaseId = UpdatePhase.GAME_LOGIC ): Void
    {
        if ( !isReady )  { warn( "MainLoop.init() has not been run!" ); return; }
        
        if ( exists( updateableObject ) )
        {
            stopUpdateFunction( updateableObject.update, phaseId );
        }
    }
    
    /** Registers the given function to be called during every update.
     *  If the function is already registered, nothing happens; items in the update list are kept unique. */
    public static function runUpdateFunction( updateFunction: UpdateFunction, phaseId: UpdatePhaseId = UpdatePhase.GAME_LOGIC ): Void
    {
        if ( !isReady )  { warn( "MainLoop.init() has not been run!" ); return; }
        
        if ( isValid( phaseId ) && exists( updateFunction ) )
        {
            m_phases[ phaseId ].runUpdateFunction( updateFunction );
        }
    }
    
    /** Registers the given function to be called during every update.
     *  If the function is already registered, nothing happens; items in the update list are kept unique. */
    public static function stopUpdateFunction( updateFunction: UpdateFunction, phaseId: UpdatePhaseId = UpdatePhase.GAME_LOGIC ): Void
    {
        if ( !isReady )  { warn( "MainLoop.init() has not been run!" ); return; }
        
        if ( isValid( phaseId ) && exists( updateFunction ) )
        {
            m_phases[ phaseId ].stopUpdateFunction( updateFunction );
        }
    }


    /** Update each UpdatePhase, in turn.  Called by an ENTER_FRAME event from the stage. */
    private static function doUpdates( e: Event ): Void
    {
        now = MonotonicTime.get();
        
        // The following code is heavily inspired by that in the article "Fix Your Timestep!", available at
        //   http://gafferongames.com/game-physics/fix-your-timestep/
        // (The other half is in UpdatePhase.update().)
        
        var frameTime = now - lastUpdateTime;

        // If we skipped ahead /too/ far, don't try to fully catch up (which might never happen -- positive feedback loop OF DOOM!)
        if ( frameTime > MAX_FRAME_TIME )
        {
            frameTime = MAX_FRAME_TIME;
        }

        isUpdating = true;
        
        for ( phase in m_phases )
        {
            currentPhase = phase.id;
            phase.update( frameTime );
        }
        
        lastUpdateTime = now;

        isUpdating = false;
        currentPhase = UpdatePhase.NO_PHASE;
    }
    
}