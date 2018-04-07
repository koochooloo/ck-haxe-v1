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
package com.firstplayable.hxlib.display.progress.fill;
import openfl.display.Sprite;

class ShapeFill extends Sprite
{
    public var fillLength( default, null ):Float;
    public var fullLength( default, null ):Float;
    
    public function new() 
    {
        super();
        fillLength = 0;
        fullLength = 0;
    }
    
    /**
     * Updates the fill area with a new percentage.
     * @param perc  The percentage to fill the circle, [0.0 - 1.0].
     */
    public function fill( perc:Float ):Void
    {
        if ( perc < 0 ) perc = 0;
        else if ( perc > 1 ) perc = 1;
        updateDraw( perc );
    }
    
    private function updateDraw( t:Float ):Void
    {
        //overridden
    }
}