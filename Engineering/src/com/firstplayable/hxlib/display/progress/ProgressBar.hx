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
package com.firstplayable.hxlib.display.progress;
import com.firstplayable.hxlib.display.progress.fill.LinearFill;
import com.firstplayable.hxlib.display.progress.fill.RadialFill;
import com.firstplayable.hxlib.display.progress.fill.ShapeFill;
import openfl.display.Sprite;

/**
 * Type of progress bars available via this class.
 */
enum ProgressBarType
{
    Linear;
    Radial;
}

/**
 * A progress bar display object for tracking progress!
 */
class ProgressBar extends Sprite
{
    /**
     * The progress, [0-100].
     */
    public var progress( default, set ):Int;
    /**
     * The length of the filled portion of the progress bar.
     */
    public var fillLength( get, null ):Float;
    /**
     * The length of the max possible filled portion of the progress bar.
     */
    public var fullLength( get, null ):Float;
    
    private var m_bar:ShapeFill;
    
    /**
     * Creates a new progress bar.
     * @param type      Type of progress bar to draw.
     * @param params    Options for the specified type of progress bar.
     *                  See fill options in display.progress.fill package.
     */
    public function new( type:ProgressBarType, params:Dynamic ) 
    {
        super();
        
        switch( type )
        {
            case Linear: m_bar = new LinearFill( params );
            case Radial: m_bar = new RadialFill( params );
        }
        
        addChild( m_bar );
        
        //Initialize progress to 0
        progress = 0;
    }
    
    //setter for progress
    private function set_progress( perc:Int ):Int
    {
        if ( perc < 0 ) perc = 0;
        else if ( perc > 100 ) perc = 100;
        
        m_bar.fill( perc / 100 );
        return progress = perc;
    }
    
    //getter for fill length
    private function get_fillLength():Float
    {
        return m_bar.fillLength;
    }
    
    //getter for length
    private function get_fullLength():Float
    {
        return m_bar.fullLength;
    }
}