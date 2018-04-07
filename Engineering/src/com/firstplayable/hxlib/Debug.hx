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
package com.firstplayable.hxlib;
import com.firstplayable.hxlib.StdX.isNull in isNull;
import com.firstplayable.hxlib.StdX.isValid in isValid;

#if macro
    import haxe.macro.Context;
    import haxe.macro.Expr;
    import haxe.PosInfos;
    import com.firstplayable.hxlib.utils.MacroUtils;
#else
    import haxe.CallStack;
    import haxe.Log;
    import haxe.PosInfos;
    #if js
    import js.Lib;
    import js.Browser;
    #end
#end

enum Severity
{
    Info;
    Warn;
    Error;
}

class Debug
{
    private static var m_outStream:StringBuf = new StringBuf();
    public static inline function stream():String { return m_outStream.toString(); }

    private static var hushes:Map<String, Severity> = new Map<String, Severity>();

    /**
     * Silences any subsequent Info level debug calls from the calling class
     * Can be called in the constructor, or for classes where that is awkward
     * (static classes or ones that are constructed may times) you can cheat with:
     *        private static var hush = Debug.hush();
     *
     * TODO: Make a macro for this?
     *
     * @param severity Highest level of message to hush.
     * @param codePos Magically created by haxe, contains call site info.
     */
    public static function hush( ?severity:Severity, ?codePos:PosInfos ):Bool
    {
        if ( severity == null )
        {
            severity = Info;
        }
        
        hushes.set(codePos.className, severity);

        return true;
    }
    
    public static inline function warn( msg:String, ?codePos:PosInfos ):Void
    {
        logHelper( msg, Severity.Warn, codePos );
    }

    public static inline function error( msg:String, ?codePos:PosInfos ):Void
    {
        logHelper( msg, Severity.Error, codePos );
    }
    
    public static inline function log_if( condition:Bool, msg:String, ?codePos:PosInfos ):Bool
    {
        if ( condition )
        {
            logHelper( msg, codePos );
        }
        
        return condition;
    }
    
    public static inline function warn_if( condition:Bool, msg:String, ?codePos:PosInfos ):Bool
    {
        if ( condition )
        {
            logHelper( msg, Severity.Warn, codePos );
        }
        
        return condition;
    }

    public static inline function error_if( condition:Bool, msg:String, ?codePos:PosInfos ):Bool
    {
        if ( condition )
        {
            logHelper( msg, Severity.Error, codePos );
        }
        
        return condition;
    }
    

    /**
     * Outputs a customized message to the debug console.
     * @param    severity    The message type.
     * @param    ?codePos    <automatically passed>
     */
    public static function log( msg:String, ?severity:Severity, ?codePos:PosInfos ):Void
    {
        logHelper( msg, severity, codePos );
    }

    private static function logHelper( msg:String, ?severity:Severity, ?codePos:PosInfos, ?logPos:Bool = null ):Void
    {
        if ( msg == null )
        {
            msg = "null";
        }

        if ( severity == null )
        {
            severity = Info;
        }
        
        if ( ( codePos != null ) && ( hushes.exists(codePos.className) ) )
        {
            if (hushes[codePos.className].getIndex() >= severity.getIndex())
            {
                return;
            }
        }

        var warnType:String = "";
        var logColor:Int = 0x000000; //black
        
        if ( severity == Severity.Error )
        {
            logColor = 0xD70000; //red
            warnType = "!!! ERROR: ";
            if ( logPos == null ) logPos = true;
        }
        else if ( severity == Severity.Warn )
        {
            logColor = 0xF0B70B; //orange
            warnType = "??? WARNING: ";
            if ( logPos == null ) logPos = true;
        }
        
        var methodPrefix:String = "";
        var fileLinePrefix:String = "";
        
        if ( logPos && ( codePos != null ) )
        {
            // Strip leading path from file name...
            var fileNameRaw:String = Std.string(codePos.fileName);
            var fileNameLastSlash:Int = fileNameRaw.lastIndexOf( "/" );
            if ( fileNameLastSlash >= 0 ) ++fileNameLastSlash;
            var fileName:String = fileNameRaw.substring( fileNameLastSlash );
            
            // ...or with backslashes...
            fileNameLastSlash = fileName.lastIndexOf( "\\" );
            if ( fileNameLastSlash >= 0 ) ++fileNameLastSlash;
            fileName = fileName.substring( fileNameLastSlash );
            
            // "file:line: "
            fileLinePrefix = fileName + ":" + Std.string(codePos.lineNumber) + ": ";

            // Strip leading classpath...
            var classNameRaw:String = Std.string(codePos.className);
            var classNameLastDot:Int = classNameRaw.lastIndexOf( "." );
            if ( classNameLastDot >= 0 ) ++classNameLastDot;
            var className:String = classNameRaw.substring( classNameLastDot );
            
            // "class.method: "
            methodPrefix = className + "." + Std.string(codePos.methodName) + ": ";
        }
        
        var stringMsg:String = Std.string(msg);
        var logMsg:String = warnType
                          + methodPrefix
                          + stringMsg;
        var alertBoxMsg:String = warnType 
                               + fileLinePrefix
                               + methodPrefix
                               + stringMsg;
        
    //only trace if debug
    #if debug
        
        #if flash
            Log.setColor( logColor );
            m_outStream.add( '\n' + logMsg );
            Log.trace( logMsg, codePos );
            Log.setColor( 0x000000 ); //back to black
            
            if ( severity == Severity.Error )
            {
                var report:String = "\n\n#Stack:\n" + CallStack.callStack().join("\n") + "\n#end\n";
                m_outStream.add( '\n' + report );
                Log.trace( report, codePos );
                //TODO CRASH GAME HERE
            }
        #elseif js
            if ( severity == Error )
            {
                //TODO ERROR TRACE HERE
                var report:String = alertBoxMsg + "\n\n#Stack:\n" + Std.string( CallStack.callStack().join("\n") + "\n#end\n" );
                m_outStream.add( '\n' + report );
                Log.trace( report, codePos );
            #if (openfl < "3.3.3")
                Lib.alert( report );
            #else
                Browser.alert( report );
            #end
                //TODO CRASH GAME HERE
            }
            else if ( severity == Warn )
            {
                //TODO WARN TRACE HERE
                m_outStream.add( '\n' + logMsg );
                Log.trace( logMsg, codePos );
            #if (openfl < "3.3.3")
                Lib.alert( alertBoxMsg );
            #else
                Browser.alert( alertBoxMsg );
            #end
            }
            else
            {
                m_outStream.add( '\n' + logMsg );
                Log.trace( logMsg, codePos );
            }
        #else
            m_outStream.add( '\n' + logMsg );
            trace( logMsg );
        #end
        
    //end if debug
    #end
    }
    
    public static inline function trin( ?codePos:PosInfos ):Void
    {
        logHelper("==>", Severity.Info, codePos );
    }
    
    public static inline function trout( ?codePos:PosInfos ):Void
    {
        logHelper("<==", Severity.Info, codePos );
    }
    
    public static inline function trhere( ?codePos:PosInfos ):Void
    {
        logHelper("<@>", Severity.Info, codePos, true );
    }

    /**
     * Performs a null check and warns the user depending on severity level.
     * @param    val          The value to check.
     * @param    ?severity    The type of warning to generate.
     * @param    ?varname     Variable name to accompany output.
     * @param    ?codePos     <automaticalled passed>
     * @return                true if the object is not null.
     */
    public static inline function exists( val:Dynamic, ?severity:Severity, ?varname:String = "variable", ?codePos:PosInfos ):Bool
    {
        if ( isNull( severity ) )
            severity = Severity.Warn;
        
        if ( isValid( val ) )
            return true;
        else
        {
            logHelper( varname + " is null!", severity, codePos );
            return false;
        }
    }
    
    /**
     *  This macro dumps the literal text of any expression it is given, and the expression's value.
     */
    macro public static function dump( exp: Expr ): Expr
    {
        var expString:String = MacroUtils.exprPrinter.printExpr( exp );
        var textExpr: Expr = Context.makeExpr( expString, Context.currentPos() );
        return macro trace( $textExpr + " = " + $exp );
    }
    
    /*
     * *
     *  This macro dumps the literal text of any expression it is given, and the expression's value.
    -- WIP --
    macro public static function better_dump( exp: Expr, ?codePosition: PosInfos ): Expr
    {
        var expString:String = Macros.exprPrinter.printExpr( exp );
        var textExpr: Expr = Context.makeExpr( expString, Context.currentPos() );
        return macro trace( $textExpr + " = " + $exp, codePosition );
    }
    */
}
