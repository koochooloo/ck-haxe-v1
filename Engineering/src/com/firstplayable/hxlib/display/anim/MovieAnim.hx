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
package com.firstplayable.hxlib.display.anim ;
import com.firstplayable.hxlib.app.MainLoop;
import com.firstplayable.hxlib.app.Updateable;
import com.firstplayable.hxlib.app.UpdatePhase;
import com.firstplayable.hxlib.display.DisplayTools.Origin;
import com.firstplayable.hxlib.events.AnimEvent;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;

/**
 * An animation class based on the MovieClip API.
 */
class MovieAnim extends Sprite implements Updateable
{
    /** animation resource */
    private var m_animSrc:DisplayObjectContainer;
    
    /** denotes whether the animation is playing or stopped. */
    public var isPlaying(default, null):Bool;
    /** denotes whether the animation is set to looping. */
    public var isLooping(default, null):Bool;
    /** changes whether the animation uses smoothing or not. */
    public var smoothing(default, set):Bool;
    /** offset the asset relative to its size. */
    public var origin(default, set):Origin;
    /** the origin position, as a Point. */
    public var originPos(default, null):Point;
    
    //MovieClip vars
    /** current frame index. */
    public var currentFrame(default, null):Int;
    /** current frame's label. */
	public var currentFrameLabel(default, null):String;
	//public var currentLabel (default, null):String;             //don't use?
	//public var currentLabels (default, null):Array<FrameLabel>; //don't use?
    /** total number of frames registerd with this object. */
	public var framesLoaded(default, null):Int;
    /** the number of frames in the current animation. */
	public var totalFrames(default, null):Int;
    
    public function new()
    {
        super();
        
        currentFrame = 0;
        framesLoaded = 0;
        totalFrames = 0;
        originPos = new Point();
        
        addEventListener( Event.ADDED_TO_STAGE, init );
    }
    
    /**
     * Initializes this class and kicks off update routine.
     * @param e
     */
    private function init( e:Event ):Void
    {
        removeEventListener( Event.ADDED_TO_STAGE, init );
        
        addChild( m_animSrc );
        origin = { x:Left, y:Top };
        
        //MainLoop.init(); //TODO: assume this was called vs initing it here?
        onAddedToStage( e );
    }
	
	private function onAddedToStage( e:Event ):Void
	{
		removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ); 
		
        MainLoop.runUpdate( this, UpdatePhase.ANIMATION );
	}
	
	private function onRemovedFromStage( e:Event ):Void
	{
		removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		
		MainLoop.stopUpdate( this, UpdatePhase.ANIMATION );
	}
    
    /**
     * Setter for smoothing property. Needs to be overridden to set smoothing in implementation.
     * @param s
     * @return
     */
    private function set_smoothing( s:Bool ):Bool
    {
        smoothing = s;
        return s;
    }
    
    /**
     * Setter for origin. Will offset the asset relative to its size.
     * @param o     Origin, ie { x:Left, y:Top }
     * @return
     */
    private function set_origin( o:Origin ):Origin
    {
		DisplayTools.setOrigin( m_animSrc, o );
		originPos.x = -m_animSrc.x;
		originPos.y = -m_animSrc.y;
        return o;
    }
    
    /**
     * Sets the origin position to an absolute value.
     * @param x
     * @param y
     */
    public function setOrigin( x:Float, y:Float ):Void
    {
        originPos.x = x;
        originPos.y = y;
		DisplayTools.setOriginPos( m_animSrc, { x:originPos.x, y:originPos.y } );
    }
    
    /**
     * The update routine. Should also be overridden for each implementation.
     * @param context
     */
    public function update( context:UpdateContext ):Void
    {
        if ( !isPlaying ) return;
        
        if ( !isLooping )
        {
            if ( currentFrame == totalFrames - 1 )
            {
                dispatchEvent( new AnimEvent( AnimEvent.COMPLETE ) );
            }
            
            //TODO: do we need last_frame in addition to complete? or make var names clearer
            if ( currentFrame == framesLoaded - 1 )
            {
                dispatchEvent( new AnimEvent( AnimEvent.LAST_FRAME ) );
            }
        }
    }
    
    /**
     * Plays the animation.
     */
    public function play():Void 
    {
        isPlaying = true;
    }
    
    /**
     * Pauses the animation.
     */
    public function stop():Void 
    {
        isPlaying = false;
    }
    
    /**
     * Sets the frame and plays the animation. Warning: Using frame number not yet implemented. Use string instead.
     * @param frame     A frame index Int or frame label String.
     */
    public function gotoAndPlay( frame:Dynamic, ?loop:Bool ):Void 
    {
        gotoFrame( frame, loop );
        play();
    }
    
    /**
     * Sets the frame and pauses the animation. Warning: Using frame number not yet implemented. Use string instead.
     * @param frame     A frame index Int or frame label String.
     */
    public function gotoAndStop( frame:Dynamic ):Void 
    {
        gotoFrame( frame );
        stop();
    }
    
    /**
     * Increments the current frame of the animation.
     */
    //TODO: handle overflow loop or no progress
    public function nextFrame():Void 
    {
        gotoFrameIndex( currentFrame + 1 );
    }
    
    /**
     * Decrements the current frame of the animation.
     */
    //TODO: handle overflow loop or no progress
    public function prevFrame():Void 
    {
        gotoFrameIndex( currentFrame - 1 );
    }
    
    /**
     * Deterimes the type of the frame and calls the appropriate functions.
     * @param frame     A frame index Int or frame label String.
     */
    private function gotoFrame( frame:Dynamic, ?loop:Bool ):Void
    {
        if ( Std.is( frame, String ) )
        {
            gotoFrameLabel( cast frame, loop );
        }
        else if ( Std.is( frame, Int ) )
        {
            gotoFrameIndex( cast frame );
        }
        else if ( Std.is( frame, Float ) )
		{
			gotoFrameIndex( Std.int( cast frame ) );
		}
        else Debug.warn( "frame is invalid" );
    }
    
    /** Definition for going to a frame label. Override this! */
    private function gotoFrameLabel( frame:String, ?loop:Bool ):Void {}
    /** Definition for going to a frame index. Override this! */
    private function gotoFrameIndex( frame:Int ):Void {}
}