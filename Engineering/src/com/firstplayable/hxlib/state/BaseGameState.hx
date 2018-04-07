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
import com.firstplayable.hxlib.state.IGameState.GameStateParams;

class BaseGameState implements IGameState
{
	/**
	 * The state id as an enum value.
	 */
	public var state( default, null ):EnumValue;
	/**
	 * The state id as an Int.
	 */
    public var id( get, never ):Int;
	/**
	 * The state id as a String.
	 */
    public var name( get, never ):String;
	/**
	 * True if init has been invoked.
	 */
	private var m_isInitialized:Bool;
	
	private function get_id():Int { return state.getIndex(); }
    private function get_name():String { return state.getName(); }
	
	/**
	 * Constructs new state.
	 * @param	stateId
	 */
	public function new( stateId:EnumValue ) 
	{
		state = stateId;
		//Debug.log( "state created '" + name + "'" ); // hush; always emits on startup
	}
	
	/**
	 * Initialize state objects, etc - particularly those that take up lots of memory or require loading.
	 * Prefer to do these heavier operations in init rather than the constructor. Init will be invoked once from enter.
	 * Override this function!
	 */
	public function init():Void
	{
		m_isInitialized = true;
		//Debug.log( "state initialized '" + name + "'" ); // hush; paired with first enter, redundant
	}
	
	/**
	 * Triggers every time the state is entered (via StateManager). On first entry, will invoke init.
	 * Override this function!
	 * @param	p	Pass any amount of parameters via an object; ie p.myInfo
	 */
	public function enter( p:GameStateParams ):Void
	{
		Debug.log( "state entered '" + name + "'" );
		
		if ( !m_isInitialized )
		{
			init();
		}
	}
	
	/**
	 * Triggered every time the state is exited (via StateManager).
	 * Override this function!
	 */
	public function exit():Void
	{
		Debug.log( "state exited '" + name + "'" );
	}
	
	/**
	 * A function to handle cleanup. If used, this should unload and destroy all class objects.
	 * Init will be invoked again on next enter call.
	 * Override this function!
	 */
	public function dispose():Void
	{
		m_isInitialized = false;
		Debug.log( "state disposed '" + name + "'" );
	}
}