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
package com.firstplayable.hxlib.text;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

class AutoField
{
    //TODO: make a copy function -jm
    
    /**
     * Creates a new field with some default properties.
     * @param t
     * @param s
     * @return
     */
    public static function create( t:TextField = null, s:Bool = false ):AutoField
    {
        return new AutoField( t, s );
    }
    
    /**
     * The text field modified by these functions.
     */
    public var field( default, null ):TextField;
    
    /**
     * 
     * @param t
     * @param s
     */
    public function new( t:TextField, s:Bool = false ):Void
    {
        if ( t == null ) t = new TextField();
        field = t;
        field.selectable = s;
    }
    
    /**
     * 
     * @param x     Sets x position.
     * @param y     Sets y position.
     * @param ?w    Sets width.
     * @param ?h    Sets height.
     * @return
     */
    public function area( x:Float, y:Float, ?w:Float = 0, ?h:Float = 0 ):AutoField
    {
        field.x = x;
        field.y = y;
        if( w > 0 )
            field.width = w;
        if( h > 0 )
            field.height = h;
        return this;
    }
    
    /**
     * 
     * @param word  Toggles wordWrapping
     * @param line  Toggles multiline
     * @return
     */
    public function wrapping( ?word:Bool = true, ?line:Bool = true ):AutoField
    {
        field.wordWrap = word;
        field.multiline = line;
        return this;
    }
    
    /**
     * 
     * @param font  Sets font family.
     * @param size  Sets font size.
     * @param color Sets font color.
     * @return
     */
    public function format( font:String, size:Int, color:Int ):AutoField
    {
        //TODO: incorporate font grabbing via ofl here?
        field.defaultTextFormat = new TextFormat( font, size, color );
        field.embedFonts = true;
        return this;
    }
    
    /**
     * 
     * @param a     Sets field alignment.
     * @return
     */
    public function align( ?a:TextFieldAutoSize = null ):AutoField
    {
        if ( a == null ) a = TextFieldAutoSize.LEFT;
        field.autoSize = a;
        return this;
    }
    
    /**
     * 
     * @param t     Sets the type of textfield.
     * @param pass  Sets whether the input field is a password field.
     * @return
     */
    public function type( ?t:TextFieldType = null, ?pass:Bool = false ):AutoField
    {
        if ( t == null ) t = TextFieldType.DYNAMIC;
        field.type = t;
        if ( field.type == TextFieldType.INPUT ) field.selectable = true;
        field.displayAsPassword = pass;
        return this;
    }
    
    //other props we may want to add
    /*t.antiAliasType
    t.interactionMode*/
}