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

//TODO: add binary string function?
class BitFlags
{
    private var m_flags:Int;
    
    /**
     * Creates a new BitFlags object.
     * @param   startFlags    Set a starting flags value.
     */
    public function new( startFlags:Int = 0 ) 
    {
        m_flags = startFlags;
    }
    
    /**
     * Converts this BitFlags object into an integer.
     * @return
     */
    public function int():Int
    {
        return m_flags;
    }
    
    /**
     * Adds flag(s) to the bit flags.
     * @param   flags   Flag value to add.
     */
    public function add( flags:Int ):Int
    {
        m_flags |= flags;
        return m_flags;
    }
    
    /**
     * Removes flag(s) from the bit flags.
     * @param   flags   Flag value to remove.
     */
    public function remove( flags:Int ):Int
    {
        m_flags &= ~flags;
        return m_flags;
    }
    
    /**
     * Checks if flag(s) are set.
     * @param   flags   Flag value to check for.
     * @return  true if flag(s) set, otherwise false.
     */
    public function has( flags:Int ):Bool
    {
        return ( m_flags & flags ) == flags;
    }
    
    /**
     * Checks if no flags are set.
     * @return  true if empty, otherwise false.
     */
    public function isEmpty():Bool
    {
        return m_flags == 0;
    }
    
    /**
     * Clears all flags.
     */
    public function clear():Int
    {
        m_flags = 0;
        return m_flags;
    }
    
    /**
     * Toggles flag(s) on or off.
     * @param   flags   Flag value to toggle.
     */
    public function toggle( flags:Int ):Int
    {
        m_flags ^= flags;
        return m_flags;
    }
    
    /**
     * Converts an int to a bit flag object.
     * @param   int     int to convert.
     * @return  a bit flag object.
     */
    public static function toFlag( int:Int ):BitFlags
    {
        return new BitFlags( int );
    }
}