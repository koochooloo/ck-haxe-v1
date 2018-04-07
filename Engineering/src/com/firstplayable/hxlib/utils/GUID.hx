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
//Code snippet taken from: http://snipplr.com/view/45247/
//modified/documented by Jon
package com.firstplayable.hxlib.utils;
import com.firstplayable.hxlib.StdX;
import openfl.system.Capabilities;

class GUID implements Dynamic
{
    private static var m_counter:Int = 0;
    
    /**
     * Generates a globally unique identification string.
     * @return    guid string
     */
    public static function create():String
    {
        var dt:Date = Date.now();
        var id1:Float = dt.getTime();
        //TODO: should we change from Math.random() to Std.random()? Int vs Float concept here? -jm
        var id2:Int = Std.random( StdX.INT_MAX ); //Float.MAX_VALUE;
        var id3:String = 
            //TODO: Figure out what we want to do for android
            #if flash
                Capabilities.serverString;
            #else
                //sample string from Adobe docs
                "A=t&SA=t&SV=t&EV=t&MP3=t&AE=t&VE=t&ACC=f&PR=t&SP=t&SB=f&DEB=t&V=WIN%208%2C5%2C0%2C208&M=Adobe%20Windows&R=1600x1200&DP=72&COL=color&AR=1.0&OS=Windows%20XP&L=en&PT=External&AVD=f&LFD=f&WD=f";
            #end
        var rawID:String = calculate( id1 + id3 + id2 + ++m_counter ).toUpperCase();
        var finalString:String = rawID.substring( 0, 8 ) + "-" + rawID.substring( 8, 12 ) + "-" + 
            rawID.substring( 12, 16 ) + "-" + rawID.substring( 16, 20 ) + "-" + rawID.substring( 20, 32 );
        return finalString;
    }
    
    /**
     * 
     * @param    src
     * @return
     */
    private static function calculate( src:String ):String
    {
        return hex_sha1( src );
    }
    
    /**
     * 
     * @param    src
     * @return
     */
    private static function hex_sha1( src:String ):String
    {
        return binb2hex( core_sha1( str2binb( src ), src.length * 8 ) );
    }
    
    /**
     * 
     * @param    x
     * @param    len
     * @return
     */
    private static function core_sha1( x:Array<Int>, len:Int ):Array<Int>
    {
        x[len >> 5] |= 0x80 << (24 - len % 32);
        x[((len + 64 >> 9) << 4) + 15] = len;
        
        var w:Array<Int> = new Array();
        var a:Int = 1732584193;
        var b:Int = -271733879;
        var c:Int = -1732584194;
        var d:Int = 271733878;
        var e:Int = -1009589776;
        
        var wLen:Int = 80;
        for ( index in 0...x.length )
        {
            var i:Int = index * 16;
            
            var olda:Int = a;
            var oldb:Int = b;
            var oldc:Int = c;
            var oldd:Int = d;
            var olde:Int = e;
            
            for ( j in 0...wLen )
            {
                if (j < 16) w[j] = x[i + j];
                else w[j] = rol(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16], 1);
                var t:Int = safe_add(safe_add(rol(a, 5), sha1_ft(j, b, c, d)), safe_add(safe_add(e, w[j]), sha1_kt(j)));
                
                e = d;
                d = c;
                c = rol(b, 30);
                b = a;
                a = t;
            }
            
            a = safe_add(a, olda);
            b = safe_add(b, oldb);
            c = safe_add(c, oldc);
            d = safe_add(d, oldd);
            e = safe_add(e, olde);
        }
        
        return [a, b, c, d, e];
    }
    
    /**
     * 
     * @param    t
     * @param    b
     * @param    c
     * @param    d
     * @return
     */
    private static function sha1_ft( t:Int, b:Int, c:Int, d:Int ):Int
    {
        if (t < 20) return (b & c) | ((~b) & d);
        if (t < 40) return b ^ c ^ d;
        if (t < 60) return (b & c) | (b & d) | (c & d);
        return b ^ c ^ d;
    }
    
    /**
     * 
     * @param    t
     * @return
     */
    private static function sha1_kt( t:Int ):Int
    {
        return (t < 20) ? 1518500249 : (t < 40) ? 1859775393 : (t < 60) ? -1894007588 : -899497514;
    }
    
    /**
     * 
     * @param    x
     * @param    y
     * @return
     */
    private static function safe_add( x:Int, y:Int ):Int
    {
        var lsw:Int = (x & 0xFFFF) + (y & 0xFFFF);
        var msw:Int = (x >> 16) + (y >> 16) + (lsw >> 16);
        return (msw << 16) | (lsw & 0xFFFF);
    }
    
    /**
     * 
     * @param    num
     * @param    cnt
     * @return
     */
    private static function rol( num:Int, cnt:Int ):Int
    {
        return (num << cnt) | (num >>> (32 - cnt));
    }
    
    /**
     * 
     * @param    str
     * @return
     */
    private static function str2binb( str:String ):Array<Int>
    {
        var bin:Array<Int> = new Array();
        var mask:Int = (1 << 8) - 1;
        
        var len:Int = str.length * 8;
        for ( index in 0...len )
        {
            var i:Int = index * 8;
            bin[i >> 5] |= (str.charCodeAt(index) & mask) << (24 - i % 32);
        }
        
        return bin;
    }
    
    /**
     * 
     * @param    binarray
     * @return
     */
    private static function binb2hex( binarray:Array<Int> ):String
    {
        var str:String = new String("");
        var tab:String = new String("0123456789abcdef");
        
        var len:Int = binarray.length * 4;
        for ( i in 0...len )
        {
            str += tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8 + 4)) & 0xF) + 
                tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8)) & 0xF);
        }
        
        return str;
    }
}