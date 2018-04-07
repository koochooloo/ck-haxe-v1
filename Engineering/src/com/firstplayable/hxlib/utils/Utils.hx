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

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.events.IEventDispatcher;

using com.firstplayable.hxlib.StdX;
using Std;

/**
 * Class containing miscellaneous utility functions 
 */
class Utils
{
	/**
	 * Calls addEventListener() on an object after ensuring:
	 * 		1. the object is valid
	 * 		2. the object does not have another copy of the same listener on it
	 * @param	object				- the object to add an event listener to
	 * @param	eventType			- @see: openfl.events.EventDispatcher.hx
	 * @param	handler				- @see: openfl.events.EventDispatcher.hx
	 * @param	useCapture			- @see: openfl.events.EventDispatcher.hx
	 * @param	priority			- @see: openfl.events.EventDispatcher.hx
	 * @param	useWeakReference	- @see: openfl.events.EventDispatcher.hx
	 */
	public static function safeAddListener( object:IEventDispatcher, eventType:String, handler:Dynamic->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false ):Void
	{
		if ( object.isValid() && handler.isValid() )
		{
			// Previously, there was a call to object.removeEventListener() here, which was used to ensure
			//	that multiple instances of the listener were not registered. EventDispatcher now takes care
			//	of this check, so the call to removeEventListener() here is moot. 
			object.addEventListener( eventType, handler, useCapture, priority, useWeakReference );
		}
	}
	
	/**
	 * Calls removeEventListener() on an object after ensuring:
	 * 		1. the object is valid
	 * @param	object		- the object to add an event listener to
	 * @param	eventType	- @see: openfl.events.EventDispatcher.hx
	 * @param	handler		- @see: openfl.events.EventDispatcher.hx
	 */
	public static function safeRemoveListener( object:IEventDispatcher, eventType:String, handler:Dynamic->Void, useCapture:Bool = false ):Void
	{
		if ( object.isValid() )
		{
			object.removeEventListener( eventType, handler, useCapture );
		}
	}
	
	/**
	 * Calls removeChild() on an object's parent after ensuring:
	 * 		1. The object is valid
	 * 		2. The object's parent is valid
	 * @param	object		- the object to remove from it's parent
	 */
	public static function removeFromParent( object:DisplayObject ):Void
	{
		if ( object.isValid() && object.parent.isValid() )
		{
			object.parent.removeChild( object );
		}
	}
	
	public static function getIndexByName( parent:DisplayObjectContainer, childName:String ):Int
	{
		if ( parent.isValid() )
		{
			var child:DisplayObject = parent.getChildByName( childName );
			if ( child.isValid() )
			{
				return parent.getChildIndex( child );
			}
		}
		
		Debug.warn( "Can't get index of child named '" + childName + "'; it does not exist on the specified object" );
		return 0;
	}
}