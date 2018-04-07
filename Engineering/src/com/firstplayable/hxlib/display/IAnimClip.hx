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
package com.firstplayable.hxlib.display;

/**
 *   The AnimClip interface is a subset of the interface of the AS3 MovieClip class.
 *   It is intended as a common interface for various sorts of animations, which may
 *   have widely varying implementations.
 */
interface IAnimClip
{
    var currentFrame(default,null): Int;
    
    var isPlaying(default, null): Bool;
    
    var totalFrames(get,null): Int;
 
    function gotoAndPlay( ?frameIndex: Int /*, ?frameLabel: String */ ) : Void;
    function gotoAndStop( ?frameIndex: Int /*, ?frameLabel: String */ ) : Void;
    function nextFrame(): Void;
    function play(): Void;
    function prevFrame(): Void;
    function stop() : Void;

    private function get_totalFrames(): Int;

    // Other MovieClip functions that we might want to eventually support:
    
    // @:require(flash10) var currentFrameLabel(default,null) : String;
    // var currentLabel(default,null) : String;
    // var currentLabels(default,null) : Array<FrameLabel>;
    // var enabled : Bool;
    // var framesLoaded(default,null) : Int;
    
    
}