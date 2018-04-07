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
package com.firstplayable.hxlib.io;
import com.firstplayable.hxlib.state.StateManager;
import com.firstplayable.hxlib.utils.GUID;

class GameSaveVersion
{
    public static inline var LATEST:Float = VER_102;
    public static inline var VER_101:Float = 1.01;
    public static inline var VER_102:Float = 1.02;
    public static inline var VER_103:Float = 1.03;
}

typedef SavedState = 
{
	var gameMenuName:String;
	var gameStateName:String;
	var timestamp:String;
};

//TODO: can we add a save slot size property like dslib to assist with verification? -jm (also Leander)
class GameSave implements Dynamic
{
	private static inline var STATE_HISTORY_SIZE:Int = 30;
	
    /**
     * The game save data version. This value is defaulted to the latest save version.
     */
    public var version:Float;
    
    /**
     * An identifier for noting which game product this game save is associated with.
     */
    public var productName:String;
    
    /**
     * The name of the profile data, often used as the game save's file name.
     */
    public var profileName:String;
    
    /**
     * A unique id number representing this profile. Example use: The profile's save 
     * slot number, or the number of total profiles including this one.
     */
    public var profileId:Int;
    
    /**
     * The latest timestamp for the game save (last saved) [YYYY-MM-DD HH:MM:SS].
     */
    public var timestamp:String;
    
    /**
     * A user name to be associated with this game save. This is different from profileName, 
     * but the values can be the same.
     */
    public var user:String;
    
    /**
     * The UUID (universally unique id) for this game save object. This id is generated when 
     * the save game is created and will never change.
     */
    public var guid( default, null ):String;
    
	/**
	 * A debug info string for tracking the console log or other debug info.
	 */
	public var debugInfo:String;
	
	private var m_savedStates:Array<SavedState>;
	
    /**
     * Creates a new empty GameSave object.
     */
    public function new() 
    {
        //set defaults
        profileName = "1p-GameSave" + Std.random( 1000 );
        productName = profileName;
        user = "User-1";
        profileId = -1;
		debugInfo = "";
        
        //keep our version up to date
        version = GameSaveVersion.LATEST;
        timestamp = Date.now().toString();
        //create a uuid
        guid = GUID.create();
		
		m_savedStates = [];
    }
	
	public function saveGameStateEntry( menuName:String ):Void
	{
		if ( m_savedStates.length >= STATE_HISTORY_SIZE )
		{
			m_savedStates.shift();
		}
		m_savedStates.push( {gameMenuName:menuName, gameStateName:StateManager.currentState.name, timestamp:Date.now().toString()} );
	}
}