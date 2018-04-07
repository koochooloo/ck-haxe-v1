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
import com.firstplayable.hxlib.Debug;
#if js
import js.html.Audio;
#end
using StringTools;

//TODO: expand class to handle longer strings than cap (break up into array and callback events to play sequence)
class GoogleTTS
{
    //google has size cap for requests
    private static inline var GOOGLE_SIZE_CAP:Int = 100;
    
    /**
     * Plugs into Google's TTS API to generate and playback an MP3.
     * @param text      Text to convert to audio.
     * @param lang      Language code, ie "en".
     */
    public static function say( text:String, lang:String = "en" ):Void
    {
        var request:String = generateRequest( text, lang );
        
        #if js
        var audio:Audio = new Audio();
        audio.src = request;
        audio.play();
        #else
        //TODO: add support for other platforms
        Debug.warn( "Only js is currently supported!" );
        #end
    }
    
    //TODO: verify this works, may want to get rid of .mp3
    public static function get( text:String, lang:String = "en" ):String
    {
        var request:String = generateRequest( text, lang ) + ".mp3";
        return request;
    }
    
    private static function generateRequest( text:String, lang:String ):String
    {
        if ( text.length > GOOGLE_SIZE_CAP )
        {
            Debug.warn( "Text must be less than " + GOOGLE_SIZE_CAP + " to play. Truncating..." );
            text.substr( 0, GOOGLE_SIZE_CAP );
        }
        
        //replace spaces with %20
        var formatted:String = ~/ /g.replace( text, "%20" );
        return "http://translate.google.com/translate_tts?ie=utf-8&tl=" + lang + "&q=" + formatted;
    }
}