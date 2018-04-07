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

typedef GameStateParams =
{
	@:optional var args:Array<Dynamic>;
}

interface IGameState
{
    /**
     * Enum representation of game state.
     */
    public var state( default, null ):EnumValue;
    
    /**
     * Int representation of game state; returns state.getIndex().
     */
    public var id( get, never ):Int;
    
    /**
     * String representation of game state; returns state.getName().
     */
    public var name( get, never ):String;
    
    //flag for initialization of state
    private var m_isInitialized:Bool;
    
    //returns values from enum
    private function get_id():Int;
    private function get_name():String;
    
    /**
     * Handles initialization routine.
     */
    private function init():Void;
    
    /**
     * Handles any cleanup routine.
     */
    private function dispose():Void;
    
    /**
     * Called when entering a state
     * @param    args
     */
    public function enter( args:GameStateParams ):Void;
    
    /**
     * Called when exiting a state
     * @param    args
     */
    public function exit():Void;
}