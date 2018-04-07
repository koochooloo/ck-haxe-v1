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

import com.firstplayable.hxlib.Debug.*;

/**
 * A cute little state machine that essentially just maps EnumValues to functions
 * 
 * @example of how a class might use TinyStateMachine:
 * 
 * enum MyStates
    {
        INTRO;
        STEP1;
        STEP2;
        OUTRO;
    }
    
    var sm:TinyStateMachine = new TinyStateMachine( MyStates );
    sm.registerStateFunction( MyStates.INTRO, foo, [ "bar", true ] );
    sm.goto( MyStates.INTRO );
 */
class TinyStateMachine
{
    private var m_functions:Array<Dynamic>;        // maps EnumValue.getIndex() -> functions
    private var m_args:Array<Array<Dynamic>>;    // maps EnumValue.getIndex() -> array of arguments
    private var m_states:Enum<Dynamic>;            // the specific Enum whose EnumValues will be mapped

    private var m_currStateIndex:Int;    // The index of the current state, eg the value returned from EnumValue.getIndex()
    private var m_numStates:Int;        // The total number of EnumValues in m_states
    
    public var currState( default, null ):EnumValue;
    
    public function new<T>( states:Enum<T> ) 
    {
        m_functions = new Array();
        m_args = new Array();
        m_states = states;
        m_currStateIndex = -1;
        currState = null;
        
        // Figure out how many states there are
        var allStates:Array<String> = Type.getEnumConstructs( states );
        m_numStates = allStates.length;
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    /**
     * Maps a state to the function that should be called when we go to that state. 
     * 
     * @param    state    - EnumValue representing the state; must belong to the Enum passed on construction
     * @param    func    - The function to call
     * @param    ?args    - Optional arguments that should be passed to func. You are responsible for ensuring number/type match.
     * 
     * @return    true, if the function is successfully registered; false otherwise
     */
    public function registerStateFunction( state:EnumValue, func:Dynamic, ?args:Array<Dynamic> ):Bool
    {
        // Ensure we were passed a valid funtion
        if ( !Reflect.isFunction( func ) )
        {
            warn( "Trying to register a NULL function!!" );
            return false;
        }

        // Ensure our EnumValue is the correct Enum type
        if ( Type.getEnum( state ) != m_states )
        {
            warn( "Trying to register a function to an EnumValue of the wrong type; expected " + m_states );
            return false;
        }

        // Register the function (but only if nothing else has been registered to this EnumValue already)
        var enumIndex:Int = state.getIndex();
        if ( m_functions[ enumIndex ] == null )
        {
            m_functions[ enumIndex ] = func;
            m_args[ enumIndex ] = args;
            return true;
        }

        warn( state + " already has a function registered!!" );
        return false;
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    /**
     * Checks whether there are more states left to iterate through
     * @return - true if there are more states (gotoNext() is expected to succeed); 
     *             false, otherwise
     */
    public function hasMoreStates():Bool
    {
        return m_currStateIndex < m_numStates - 1;
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    /**
     * Go to a specific state
     * @param    state - the state you wish to go to; must belong to the Enum you passed on construction
     * @return    true, if the function state maps to was successfully called; false otherwise
     */
    public function goto( state:EnumValue ):Bool
    {
        // Ensure our EnumValue is the correct Enum type
        if ( Type.getEnum( state ) != m_states )
        {
            warn( "Can't goto() state; EnumValue of the wrong type; expected " + m_states );
            return false;
        }
        
        m_currStateIndex = state.getIndex();
        currState = state;
        return gotoShared();
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    /**
     * Go to the next state. 
     * 
     * States are ordered by the original syntactic position of the EnumValues in the Enum. 
     * The index of the first declared is 0, the next one is 1 etc.
     * 
     * @return true, if the function the next state maps to was successfully called; false otherwise
     */
    public function gotoNext():Bool
    {
        ++m_currStateIndex;
        currState = ( m_currStateIndex < m_numStates ) ? m_states.createByIndex( m_currStateIndex ) : null;
        
        return gotoShared();
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    /**
     * Helper for goto() and gotoNext().
     * @return true, if the state function was successfully called; false otherwise
     */
    private function gotoShared():Bool
    {
        var func:Dynamic = m_functions[ m_currStateIndex ];
        
        if ( func != null )
        {
            var args:Dynamic = m_args[ m_currStateIndex ];
            
            try
            {
                Reflect.callMethod( null, func, args );
            }
            catch ( unknown:Dynamic )
            {
                warn( "Could not call state function for state id " + m_currStateIndex + "; most likely an argument mismatch" );
                return false;
            }
            
            return true;
        }
        
        // We don't have a function to call
        if ( m_currStateIndex >= m_numStates )
        {
            log( "There are no more states." );
        }
        else
        {
            warn( "No function registered to this state" );
        }
        
        return false;
    }
    
}