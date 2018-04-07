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

/**
 * A lock allows asynchronous dependencies to exist using a single variable.
 */
class Lock
{
	/**
	 * Whether or not this is locked.
	 */
	public var isLocked(get, null):Bool;
	private var m_lock:Int;
	
	/**
	 * Creates a new lock.
	 */
	public function new() 
	{
		m_lock = 0;
	}
	
	// if lock is anything other than 0, return true;
	private function get_isLocked():Bool
	{
		return m_lock > 0;
	}
	
	/**
	 * Adds one lock.
	 */
	public function set():Void
	{
		++m_lock;
	}
	
	/**
	 * Releases one lock.
	 */
	public function release():Void
	{
		--m_lock;
		if ( m_lock < 0 ) m_lock = 0;
	}
	
	/**
	 * Releases all locks.
	 */
	public function free():Void
	{
		m_lock = 0;
	}
}