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
using com.firstplayable.hxlib.utils.LambdaX;

@:generic
class ShuffleBag<T>
{
	private var m_currentItemIdx:Int;
	private var m_items:Array<T>;
	
	public function new() 
	{
		//Intentionally starting this at 0 so we get a shuffle the first time we try to pull
		m_currentItemIdx = 0;
		m_items = new Array<T>();
	}
	
	/**
	 * Adds an object to the bag
	 * @param	obj			The object to be added
	 * @param	frequency	(optional) The frequency with which to add the objects, defaults to 1 instance
	 */
	public function add( obj:T, frequency:Int = 1 ):Void
	{
		for ( i in 0...frequency )
		{
			m_items.push( obj );
		}
	}
	
	public var length( get, null ):Int;
	private function get_length():Int
	{
		return m_items.length;		
	}
	
	/**
	 * Shuffles the bag
	 */
	public function shuffle():Void
	{
		var lastItem:T = m_items[ 0 ];
		
		m_items.shuffle();
		m_currentItemIdx = m_items.length - 1;
		
		//One time check to try to prevent duplicate results
		//(Note) Not 100% guarantee because of duplicate entries, but will prevent bags with single frequeny from repeating
		if ( (m_items.length > 2) &&  (m_items[ m_currentItemIdx ] == lastItem) )
		{
			m_items[ m_currentItemIdx ] = m_items[ 0 ];
			m_items[ 0 ] = lastItem;
		}
		
	}
	
	/**
	 * Gets the next objects from the bag, if the bag has been exhausted, will automatically repopulate
	 * @return				The next objects from the bag
	 */
	public function next():T
	{	
		--m_currentItemIdx;
		
		if ( m_currentItemIdx < 0 )
		{
			if ( m_items.length == 0 )
			{
				Debug.log( "Attempted to pull an item from an empty ShuffleBag! Returning null..." );
				return null;
			}
			
			shuffle();
		}
		
		return m_items[ m_currentItemIdx ];
	}
	
	
	public function clear():Void
	{
		m_currentItemIdx = 0;
		m_items.splice( 0, m_items.length );
	}
}