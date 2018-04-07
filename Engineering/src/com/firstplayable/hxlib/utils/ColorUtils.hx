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

class ColorUtils
{
    /**
     * Converts a hex value to RGBA Object.
     * @param    hex    The hex value to convert
     * @return    RGBA value as Object
     */
    public static function hexToArgb( hex:Int ):Dynamic
    {
        return
        {
            a:hex >> 24 & 0xFF,
            r:hex >> 16 & 0xFF,
            g:hex >> 8 & 0xFF,
            b:hex & 0xFF
        };
    }
    
    /**
     * Converts an RGB (0-255) value to HEX.
     * @param    r    Red value
     * @param    g    Green value
     * @param    b    Blue value
     * @return    HEX value
     */
    public static function argbToHex( r:Int, g:Int, b:Int, ?a:Int ):Int
    {
        return ( a == null ) ?
        ( ( r << 16 ) + ( g << 8 ) + b )
        :( ( a << 24 ) + ( r << 16 ) + ( g << 8 ) + b );
    }
    
    /**
     * Converts 5-bit RGB values (0-31) used on the DS to HEX
     * @param    r    Red value
     * @param    g    Green value
     * @param    b    Blue value
     * @param    ?a    Alpha value
     * @return    hex value of the color
     */
    public static inline function dsToHex( r:Int, g:Int, b:Int, ?a:Int ):Int
    {
        return argbToHex( ( r << 3 ) | ( r >> 2 )
                        , ( g << 3 ) | ( g >> 2 )
                        , ( b << 3 ) | ( b >> 2 )
                        , ( a << 3 ) | ( a >> 2 )
                        );
    }
    
    /**
     * Colors a DisplayObject (tint).
     * @param    obj    The object to colorize
     * @param    color    The color to use as the base tint
     */
    public static function colorTransform( obj:DisplayObject, color:Int ):Void
    {
        /*var colorTransform:ColorTransform = obj.transform.colorTransform;
        colorTransform.color = color;
        obj.transform.colorTransform = colorTransform;*/
    }
    
    /**
     * Applies a tint to a DisplayObject.
     * @param    obj    The DisplayObject to tint
     * @param    color    The color hex to use for the tint
     * @param    intensity    The intensity of the tint, in the range 0-1
     */
    public static function colorTint( obj:DisplayObject, color:Int, intensity:Float ):Void
    {
        /*const colorComponent:Object = hexToRgb( color );
        
        const ctMultiplier:Number = 1 - intensity;
        const ctRedOff:Number = MathUtils.roundPos( intensity * colorComponent.r );
        const ctGreenOff:Number = MathUtils.roundPos( intensity * colorComponent.g );
        const ctBlueOff:Number = MathUtils.roundPos( intensity * colorComponent.b );
        
        ms_colorTransform.redMultiplier = ctMultiplier;
        ms_colorTransform.greenMultiplier = ctMultiplier;
        ms_colorTransform.blueMultiplier = ctMultiplier;
        ms_colorTransform.alphaMultiplier = 1;
        ms_colorTransform.redOffset = ctRedOff;
        ms_colorTransform.greenOffset = ctGreenOff;
        ms_colorTransform.blueOffset = ctBlueOff;
        ms_colorTransform.alphaOffset = 0;
        
        obj.transform.colorTransform = ms_colorTransform;*/
    }
}