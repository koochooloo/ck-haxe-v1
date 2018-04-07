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
package com.firstplayable.hxlib.net;
#if js
import js.html.XMLHttpRequest;

class AjaxRequest
{
    private static var m_request:XMLHttpRequest;
    private static var m_url:String;
    private static var m_user:String;
    private static var m_pass:String;
    private static var m_callback:String->Void;
    private static var m_inited:Bool;
    
    public static inline var TYPE_POST:String = "POST";
    public static inline var TYPE_GET :String = "GET";
    private static inline var STATUS_OK:Int = 200;
    
    public static inline var FORMAT_NORM:String = null;
    public static inline var FORMAT_FORM:String = "Content-Type application/x-www-form-urlencoded;charset=UTF-8";
    
    /**
     * Initialize a connection.
     * @param    url        Ajax URL.
     * @param    user    optional user name
     * @param    pass    optional password
     */
    public static function init( url:String, ?user:String, ?pass:String ):Void
    {
        m_request = new XMLHttpRequest();
        m_url = url;
        m_user = user;
        m_pass = pass;
        m_inited = true;
    }
    
    /**
     * Sends a formatted request to the server's Ajax.
     * @param    type    TYPE_POST or TYPE_GET
     * @param    request web-formatted string to be sent
     * @param    header    Header info for post request only
     * @param    async    async or wait
     * @param    cb        callback to receive the resulting string
     */
    public static function request( type:String, request:String, ?header:String, ?async:Bool = true, ?cb:String->Void ):Void
    {
        if ( !m_inited )
        {
            Debug.warn( "Must call init() first!" );
            return;
        }
        
        m_callback = cb;
        m_request.onreadystatechange = onReady;
        m_request.open( type, m_url, async, m_user, m_pass );
        
        if ( type == TYPE_POST && header != null )
        {
            var headerInfo:Array<String> = header.split( ' ' );
            m_request.setRequestHeader( headerInfo[ 0 ], headerInfo[ 1 ] );
        }
        
        //TODO: handle & and = as data values -jm
        var requestStr:String = "";
        var props:Array<String> = request.split( "&" );
        
        for ( i in 0...props.length )
        {
            if ( i > 0 ) requestStr += "&";
            var propPair:Array<String> = props[ i ].split( "=" );
            requestStr += ( StringTools.urlEncode( propPair[ 0 ] ) + "=" + StringTools.urlEncode( propPair[ 1 ] ) );
        }
        
        m_request.send( requestStr );
    }
    
    /**
     * Checks whether the request has finished processing and forwards the data to the callback function.
     * @param    e
     */
    private static function onReady( e:Dynamic ):Void
    {
        if ( m_request.readyState == XMLHttpRequest.DONE && m_request.status == STATUS_OK )
        {
            Debug.log( "Request complete." );
            
            if ( m_callback != null )
            {
                m_callback( m_request.responseText );
            }
        }
    }
}
#end