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

package com.firstplayable.hxlib.utils.json;
import com.firstplayable.hxlib.display.GraphicButton;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

enum ClientType 
{
    GENERIC_MENU;
    NUM_CLIENT_TYPES;
}

interface IJsonClient
{
    public function getType():ClientType;
    public function onButtonHit( ?caller:GraphicButton ):Void;
    public function onButtonDown( ?caller:GraphicButton ):Void;
    public function onButtonUp( ?caller:GraphicButton ):Void;
    public function onButtonOver( ?caller:GraphicButton ):Void;
    public function onButtonOut( ?caller:GraphicButton ):Void;
    public function addButton( btn:GraphicButton ):Void;
    
    public function addChild( child:DisplayObject ):DisplayObject;    // IJsonClient will be a Sprite; need to know that this method is available
}
