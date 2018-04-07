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
package com.firstplayable.hxlib.state;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import haxe.ds.IntMap;

class StateManager
{
    private static var m_rStates:IntMap<IGameState> = new IntMap();
    public static var currentState( default, null ):IGameState;
    
    /**
     * Deletes all current states and resets the StateManager. Will need to 
     * reset() StateManager if you want to add new states.
     */
    public static function reset( ):Void
    {
        m_rStates = new IntMap();
        currentState = null;
    }
    
    /**
     * Adds a game state to the manager. 
     * @param    rState
     */
    public static function addState( rState:IGameState ):Void
    {
        Debug.warn_if( rState == null, "[Warning] Attempted to add an invalid state" );
        
		if ( m_rStates.exists( rState.id ) )
		{
			if ( m_rStates.get( rState.id ) == rState )
			{
				Debug.warn( "[WARNING] State '" + rState + "' has already been added!" );
			}
			else
			{
				Debug.warn( "[WARNING] Tried to add state with id '" + rState.id + "' but that id already exists!" );
			}
			
			return;
		}
		
        m_rStates.set( rState.id, rState );
    }
	
	/**
	 * Creates a state and adds it to the manager.
	 * @param	id	Enum value; ie GameStates.SPLASH; optional if state enum set from class constructor.
	 * @param	t	State class; ie SplashState
	 * @usage	StateManager.createState( GameStates.SPLASH, SplashState );
	 */
	public static function createState( ?id:EnumValue, t:Class<IGameState> ):Void
	{
		var args:Array<Dynamic> = [];
		
		if ( id != null )
			args = [ id ];
		
		var state = Type.createInstance( t, args );
		addState( state );
	}
	
    /**
     * Gets a state by its ID
     * @param    stateId
     * @return
     */
    public static function getState( stateId:EnumValue ):IGameState
    {
        var stateIndex:Int = stateId.getIndex();
        
        if ( !m_rStates.exists( stateIndex ) )
        {
            Debug.warn( "[WARNING] Could not find a state with id '" + stateIndex + "'" );
            return null;
        }
        
        return m_rStates.get( stateIndex );
    }
    
    /**
     * Exits the current state, if one exists, and enters a state being managed by StateManager
     * @param    stateId     The ID of the state to enter()
     * @param    args        Any arguments that need to be passed to enter()
     */
    public static function setState( stateId:EnumValue, args:GameStateParams = null ):Void
    {
        var stateIndex:Int = stateId.getIndex();
        
        if ( !m_rStates.exists( stateIndex ) )
        {
            Debug.warn( "[WARNING] Attempted to set state to id '" + stateIndex + "' but that state can't be found!" );
            return;
        }
        
        if ( currentState != null )
        {
            currentState.exit( );
        }
        
        ResMan.instance.onSetState();
        
        currentState = m_rStates.get( stateIndex );
        currentState.enter( args );
    }
    
    /**
     * Exits the current state, if one exists, and enters a new state.
     * init() is not required to use replaceState()
     * @param    rState      The state to enter()
     * @param    args        Any arguments that need to be passed to enter()
     */
    public static function replaceState( rState:IGameState, args:GameStateParams = null ):Void
    {
        if ( rState == null )
        {
            Debug.log( "[WARNING] Attempted to add an invalid state!", Severity.Warn );
            return;
        }
        
        if ( currentState != null )
        {
            currentState.exit( );
        }
        
        currentState = rState;
        currentState.enter( args );
    }
}