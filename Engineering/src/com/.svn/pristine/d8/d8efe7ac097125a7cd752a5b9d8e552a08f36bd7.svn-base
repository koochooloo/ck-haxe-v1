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
package com.firstplayable.hxlib.debug;
import haxe.ds.StringMap;
import Reflect;
import Type;
using Lambda;
using Std;
using StringTools;

class PropMan
{
    /**
     * Map containing registered objects.
     */
    private static var map:StringMap<Dynamic> = new StringMap();
    
    /*macro public static function getVarName( exp: Expr ):String
    {
        var expString:String = MacroUtils.exprPrinter.printExpr( exp );
        var textExpr: Expr = Context.makeExpr( expString, Context.currentPos() );
        return macro trace( $textExpr + " = " + $exp );
    }*/
    
    /**
     * Registers an object to allow runtime modification.
     * @param obj       The object to modify.
     * @param rename    A name to reference 'obj' by. TODO: If no name is provided, use 'obj' variable name. -jm
     */
    public static function register( obj:Dynamic, rename:String = null ):Void
    {
        //TODO: auto generate name based on obj's var name if no rename is passed -jm
        if ( rename == null ) rename = "unnamed";
        map.set( rename, obj );
    }
    
    /**
     * Parses a command and executes the results.
     * @param command   A command to execute; "myVar.x = 50" or "myFunc( 25, false, large elephant )". See full doc for list of rules:
     *                  * Strings should not be quoted (unless should contain quotes) or contain only whitespace.
     *                  * Function args should not use strings containing '=' or ','.
     * 
     * @param command   "myThing.x = 23", "myFunc( 25, 'sally' )"
     */
    public static function call( command:String ):Void
    {
        var isVar:Bool = command.indexOf( "=" ) != -1;
        isVar ? callVar( command ) : callFunc( command );
    }
    
    /**
     * Handles variable expression parsing.
     * @param command   "myVar.a = 7"
     * //TODO: add support for '+=', etc
     */
    private static function callVar( command:String ):Void
    {
        var valStr:String = command.substring( command.indexOf( "=" ) + 1 ).trim();
        var objPropStr:String = command.substring( 0, command.indexOf( "=" ) ).trim();
        var objStr:String = objPropStr.substring( 0, objPropStr.indexOf( "." ) ).trim();
        var propStr:String = objPropStr.substring( objPropStr.indexOf( "." ) + 1 ).trim();
        
        var obj:Dynamic = map.get( objStr );
        
        var hasField:Bool = false;
        var oClass:Class<Dynamic> = Type.getClass( obj );
        
        //check for Dynamic class type
        if ( oClass == null )
        {
            hasField = Reflect.hasField( obj, propStr );
            //trace( Reflect.fields( obj ) );
        }
        else
        {
            var instanceFields:Array<String> = Type.getInstanceFields( oClass );
            var staticFields:Array<String> = Type.getClassFields( oClass );
            hasField = 
            ( instanceFields.has( propStr ) || instanceFields.has( "__" + propStr ) ) ||
            ( staticFields.has( propStr ) || staticFields.has( "__" + propStr ) );
            //trace( instanceFields );
            //trace( staticFields );
        }
        
        if ( hasField )
        {
            Reflect.setProperty( obj, propStr, valStr );
        }
        else
        {
            Debug.log( "Failed to set field \'" + propStr + "\' on obj " + objStr + "; field does not exist.");
        }
    }
    
    /**
     * Handles function expression parsing.
     * @param command   "doSomething(23, true, staples forever)"
     */
    public static function callFunc( command:String ):Void
    {
        //function
        var funcStr:String = command.substring( 0, command.indexOf( "(" ) );
        //contents of (), trim whitespace
        var argStr:String = command.substring( command.indexOf( "(" ) + 1, command.lastIndexOf( ")" ) ).trim();
        
        //get func from map
        var func:Dynamic = map.get( funcStr );
        
        if ( func == null )
        {
            Debug.log( "Failed to call function \'" + funcStr + "\'; func does not exist.");
            return;
        }
        
        //function has args
        if ( argStr.length > 0 )
        {
            var args:Array<String> = argStr.split( "," );
            
            //trim whitespace
            for ( i in 0...args.length )
            {
                args[ i ] = args[ i ].trim();
            }
            
            Reflect.callMethod( null, func, args );
        }
        //function has no args
        else
        {
            Reflect.callMethod( null, func, [] );
        }
    }
}