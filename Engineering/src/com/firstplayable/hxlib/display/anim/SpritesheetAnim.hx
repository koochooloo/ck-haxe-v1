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
package com.firstplayable.hxlib.display.anim;
import com.firstplayable.hxlib.app.Updateable.UpdateContext;
import com.firstplayable.hxlib.display.DisplayTools.OriginX;
import com.firstplayable.hxlib.display.DisplayTools.OriginY;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.display.SpriteBoxData;
import com.firstplayable.hxlib.display.SpritesheetBounds;
import com.firstplayable.hxlib.display.ParamBoxData;
import com.firstplayable.hxlib.display.anim.importers.BehaviorDataWithParams;
import com.firstplayable.hxlib.loader.ResMan;
import lime.ui.MouseCursor;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import spritesheet.data.BehaviorData;
import spritesheet.Spritesheet;

#if !spritesheet
#error "Could not find haxelib 'spritesheet', does it need to be installed?"
#end
class SpritesheetAnim extends MovieAnim
{
    private static inline var timeline:String = "_timeline";
    
    private var m_spritesheet:Spritesheet = null;
    
    // State tracking from AnimatedSprite.
    private var loopTimeMS:Float = 0;
    private var timeElapsedMS:Float = 0;
    private var currentBehavior:BehaviorData = null;
    private var shouldLoop:Bool = false;
	
	//Properties
	
	/**
	 * Cursor to display when the mouse is hovering over this object.
	 * If null, will use parent defined behavior.
	 */
	public var cursor(default, default):MouseCursor;

    /**
     * 
     * @param sheet
     * @param info
     */
    public function new( s:Spritesheet, ?resPath:String ) 
    {
        super();
        
        m_spritesheet = s;
        m_animSrc = new OPSprite( new Bitmap() );
        framesLoaded = s.totalFrames;
        
        //add an animation with all frames for frame index support
        var allframes:Array<Int> = [];
        for ( i in 0...framesLoaded )
        {
            allframes.push( i );
        }
        
        define( timeline, allframes );
        gotoAndStop( timeline );
    }
    
    /**
     * Defines an animation frame sequence.
     * @param name
     * @param frames
     */
    public function define( name:String, frames:Array<Int>, loop:Bool = true, fps:Int = 60 ):Void
    {
        m_spritesheet.addBehavior( new BehaviorData( name, frames, loop, fps ) );
    }
    
    /**
     * Checks if the given frame label exists
     * @param frame
     */
    public function hasFrameLabel( frame:String ):Bool 
    {
        return m_spritesheet.behaviors.exists( frame );
    }
    
    public function getAnimLength( animName:String ):Int
    {
        var bd:BehaviorData = m_spritesheet.behaviors.get( animName );
        
        if ( bd == null )
        {
            return 0;
        }
        
        return bd.frames.length;
    }
    
    /**
     * Used in SpritesheetAnims that are maps, not animations
     */
    public function getFrameImg( frame:String ):Bitmap // TODO BitmapData
    {
        gotoAndStop( frame );
        var sprite:OPSprite = cast m_animSrc;
        return sprite.getBitmap();
    }

    /**
     * Navigates the play head to a frame label.
     * @param frame
     */
    override function gotoFrameLabel( frame:String, ?loop:Bool ):Void 
    {
        super.gotoFrameLabel( frame, loop );
        
        var sprite:OPSprite = cast m_animSrc;
		frame = ResMan.instance.verifyPath( frame );
        var behavior:BehaviorData = m_spritesheet.behaviors.get( frame );
        if ( behavior != null )
        {
            currentBehavior = behavior;
            timeElapsedMS = 0;
            loopTimeMS = (behavior.frames.length / behavior.frameRate) * 1000;

            advanceAnim( 0, true );

            if ( loop != null )
            {
                shouldLoop = loop;
            }
            else
            {
                var defaultLoop:Bool = false;
                shouldLoop = Params.getWithDefault( defaultLoop, behavior, Params.getParamValueBool, Params.LOOPING );
            }
        }
        else
        {
            // Ignore.
            //Debug.warn( "Unknown behavior: " + str( frame ) );
        }
        
        updateFrames();
    }
    
	/** Get the current frame index based on timeElapsedMS / loopTimeMS.
	 * Clamps to valid range, but may return 0 on empty/missing anim.
	 */
    private function getCurrentFrameIndex():Int
	{
        var ratio:Float = timeElapsedMS / loopTimeMS;
		
		var lastFrameIdx:Int = 0;
		if ( ( currentBehavior != null ) && ( currentBehavior.frames != null ) )
		{
			// May be -1 for empty anim.
			lastFrameIdx = currentBehavior.frames.length - 1;
		}
		
        var frameIdx:Int = Math.round( ratio * lastFrameIdx );
		if ( frameIdx > lastFrameIdx )
		{
			// Never return > lastFrameIdx, unless this is an empty anim (see below).
			frameIdx = lastFrameIdx;
		}
		if ( frameIdx < 0 )
		{
			// Never return negative (even for empty anim).
			frameIdx = 0;
		}
		
		return frameIdx;
    }
    
    private function advanceAnim( deltaTimeMS:Float, forceUpdate = false ):Void {
        
		var oldRatio = timeElapsedMS / loopTimeMS;
        var behaviorComplete:Bool = ! shouldLoop && ( oldRatio >= 1 );
        
        if (!behaviorComplete || forceUpdate) {
            
            timeElapsedMS += deltaTimeMS;
            
            var ratio = timeElapsedMS / loopTimeMS;
            
            if (ratio >= 1) {
                
                if ( shouldLoop ) {
                    
                    timeElapsedMS = timeElapsedMS % loopTimeMS;
                    
                } else {
                    
                    behaviorComplete = true;
					timeElapsedMS = loopTimeMS;
                    
                }
                
            }
            
            var currentFrameIndex:Int = getCurrentFrameIndex();
			if ( (currentBehavior != null) && (currentBehavior.frames != null) && (currentBehavior.frames.length > currentFrameIndex) )
			{
				var frameData = BehaviorDataWithParams.getCacheData( currentBehavior, m_spritesheet, currentFrameIndex );
				
				var sprite:OPSprite = cast m_animSrc;
				sprite.bitmapData = frameData;
				sprite.smoothing = smoothing;
				// See OPSprite for SpritesheetFrame offset accounting (baked into "offset" param).  Behavior origin is ignored.
				//DISABLED//sprite.x = frame.offsetX - currentBehavior.originX;
				//DISABLED//sprite.y = frame.offsetY - currentBehavior.originY;
			}
			else
			{
				Debug.log( 'advanceAnim: frame index out of bounds; behavior $currentBehavior currentFrameIndex $currentFrameIndex' );
			}
			
            
            if (behaviorComplete) {
                
                if (hasEventListener (Event.COMPLETE)) {
                    
                    dispatchEvent (new Event (Event.COMPLETE));
                    
                }       
                
            }
            
        }
        
    }
    
    /**
     * Navigates the play head to a frame index.
     * @param frame
     */
    override function gotoFrameIndex( frame:Int ):Void 
    {
        super.gotoFrameIndex( frame );
        
        if ( (currentBehavior != null) && (currentBehavior.frames != null) && (currentBehavior.frames.length > 0) )
        {
            timeElapsedMS = Math.ceil( ( frame * loopTimeMS ) / ( currentBehavior.frames.length - 1 ) );
        }
        else
        {
            timeElapsedMS = 0;
        }
        
        advanceAnim( 0, true );
        updateFrames();
    }
    
    /**
     * Updates animation properties.
     */
    private function updateFrames():Void
    {
        var sprite:OPSprite = cast m_animSrc;
        currentFrame = getCurrentFrameIndex();
        
        if ( currentBehavior != null )
        {
            currentFrameLabel = currentBehavior.name;
            totalFrames = (currentBehavior.frames != null) ? currentBehavior.frames.length : 0;
        }
        else
        {
            //TODO: add logic to mimic the same behavior as if we came in via frame label
            currentFrameLabel = null;
            totalFrames = framesLoaded;
        }
        
        updateBounds();
    }
    
    private function updateBounds():Void
    {
		// Automatic with OPSprite.
		// We ignore frame.offset* and currentBehavior.origin* for now, see above.
    }
    
    /**
     * Updates the animation.
     * @param context
     */
    override public function update( context:UpdateContext ):Void 
    {
        super.update( context );
        if ( !isPlaying ) return;
        
        advanceAnim( context.phase.period );
        
        updateFrames();
    }
    
    /**
     * Sets smoothing behavior.
     * @param s
     * @return
     */
    override function set_smoothing( s:Bool ):Bool 
    {
        var sprite:OPSprite = cast m_animSrc;
        sprite.smoothing = s;
        
        return super.set_smoothing( s );
    }
        
    /**
     * Returns a copy of this object's SpritesheetBounds 
     */
    public function getBoundsData():SpriteBoxData
    {
        if ( m_animSrc != null )
        {
            var sprite:OPSprite = cast m_animSrc;
            return sprite.getBoundsData(); //< returned as a copy
        }
        return null;
    }
	
	 /**
     * Returns an array of this object's param boxes of a requested type
	 * @return returns an empty or populated array of ParamBoxData (never null)
     */
	public function getParamBoxes(type:ParamBoxType):Array<ParamBoxData>
	{
		var boxes:Array<ParamBoxData> = [];
		if ( m_animSrc != null )
        {
            var sprite:OPSprite = cast m_animSrc;
            boxes = sprite.getParamBoxes(type); //< returned as a copy
        }
        return boxes;
	}
	
	/**
	 * Override of Sprite's function, gets cursor to display when mouse is hovering over this object.
	 * If null, will use parent defined behavior.
	 */
	private override function __getCursor ():MouseCursor {
		if (cursor == null)
		{
			return super.__getCursor();
		}
		
		return cursor;
	}
}