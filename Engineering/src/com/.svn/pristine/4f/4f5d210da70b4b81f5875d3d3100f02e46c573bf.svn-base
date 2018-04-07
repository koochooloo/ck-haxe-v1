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
package com.firstplayable.hxlib.events;
import openfl.events.Event;

class AnimEvent extends Event
{
    /**
     * Triggers when the current animation is completed.
     * Will not dispatch if the current animation is looping.
     * //TODO: do we want to dispatch when a looping anim is told to stop? -jm
     */
    public static inline var COMPLETE:String = "animcomplete";
    
    /**
     * Triggers when the final frame of all animation frames is reached; ie the final frame of a spritesheet.
     * Will not dispatch if the current animation is looping.
     */
    public static inline var LAST_FRAME:String = "animlastframe";
    
    public function new( type:String, bubbles:Bool = false, cancelable:Bool = false ) 
    {
        super( type, bubbles, cancelable );
    }
}