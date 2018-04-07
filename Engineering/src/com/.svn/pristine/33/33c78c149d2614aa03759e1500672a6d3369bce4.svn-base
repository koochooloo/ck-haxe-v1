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
import com.firstplayable.hxlib.utils.AssertUtil;
/**
 * A more managed way to work with time. Allows addition of time. And returns time in a more time - y way. Allows keeps track of the period and if the clock is a 24 hour clock
 * @author ...Rushabh
 */

 enum Period
 {
     AM;
     PM;
 }
class TimeSpan
{
    private var m_sec: Int;
    private var m_min: Int;
    private var m_hr: Int;
    private var m_period: Period;
	private var m_24hrClock : Bool;
    
    public function new( ?sec : Int, ?min: Int, ?hr: Int , ?is24HrClock: Bool ) 
    {
        if ( sec >= 60 || min >= 60 || hr >= 24 )        
        {
            AssertUtil.Assert ( false, "Make sure you are entering the right time." );
        }
        
        m_sec = sec;
        m_min = min;
        m_hr = hr;
		refreshTime();
		m_24hrClock = is24HrClock;
        
    }
    
    public inline function getPeriod ( ) : String
    {
		if ( m_hr < 12 ) 
			m_period = Period.AM;
		else
			m_period = Period.PM;
		
		//duh!
		if ( m_hr == 0 )
			m_period = Period.PM;
			
        return m_period.getName();
    }
    
    public inline function setPeriod ( period : Period ) : Void
    {
        m_period = period;
    }
    
    public inline function toString ( ) : String
    {
        return m_hr + " : " + m_min + " : " + m_sec;
    }
    
    public inline function getMinutes () : Int 
    {
        if ( m_min < 0 )
            return 0;
        return m_min;
    }
    
    public inline function getSeconds () : Int 
    {
        if ( m_sec < 0 ) 
            return 0;
        return m_sec;
    }
    
    public inline function getHours () : Int 
    {        
        if ( m_hr < 0 )
            return 0;
			
		if ( !m_24hrClock ) 
		{
			return m_hr % 12 == 0 ? 12 : m_hr % 12;
		}
        return m_hr;
    }
    
	public inline function getMinutesString () : String
	{
		var minStr:String = Std.string ( getMinutes() ) ;
		if ( minStr.length < 2 )
		{
			return "0" + minStr;
		}
		return minStr;
	}
	
	public inline function getHoursString () : String
	{
		var hrStr:String = Std.string ( getHours() ) ;
		if ( hrStr.length < 2 )
		{
			return "0" + hrStr;
		}
		return hrStr;
	}
	
	public inline function getSecondsString () : String
	{
		var secStr:String = Std.string ( getSeconds() ) ;
		if ( secStr.length < 2 )
		{
			return "0" + secStr;
		}
		return secStr;
	}
	
    public inline function setSeconds ( sec: Int ) : Void
    {
        AssertUtil.Assert (  sec < 60 ,  "Seconds cannot be greater than 59. Entered: " + Std.string ( sec ));
        m_sec = sec;
    }
    
    public inline function setMinutes ( min : Int ) : Void
    {
		AssertUtil.Assert (  min < 60 ,  "Minutes cannot be greater than 59. Entered: " + Std.string ( min ));
        m_min = min;
    }
    
    public  inline function setHours ( hr : Int ) : Void
    {
		AssertUtil.Assert ( hr < 24 , "Hours cannot be greater than 23. Entered: " + Std.string ( hr ) );
        m_hr = hr;
		//To accomodate AM -> PM vice verca
		refreshTime();
    }
    
    public inline function addTime ( time:TimeSpan ) : Void
    {
        AssertUtil.Assert ( time != null ) ;
        addSeconds ( time.getSeconds () );
        addMinutes ( time.getMinutes() );
        addHours ( time.getHours() );
        refreshTime();
    }
    
    public inline function addSeconds ( sec : Int ) : Void 
    {
        AssertUtil.Assert ( sec < 60 );
        m_sec += sec;
        if ( m_sec <= 0)
        {
            m_sec = 0;
        }
        refreshTime();
    }
    
    public inline function addMinutes ( min :Int ) : Void 
    {        
		m_min += min;
        refreshTime();
    }
    
    public inline function addHours ( hrs : Int ): Void 
    {
        m_hr += hrs;
        refreshTime();
    }    
    
    
    private inline function refreshTime () : Void 
    {        
        if ( m_sec >= 60 ) 
        {
            m_min ++;
            m_sec = m_sec % 60;
        }
        
        if ( m_min >= 60 )
        {
            m_hr ++;
            m_min = m_min % 60;
        } 
        
		getPeriod ();
		
		if ( m_hr >= 24 )
        {
            //We aren't keeping track of days. So just the mod.
            m_hr = m_hr % 24;		
		}
        
        if ( m_sec < 0)
        {
            m_sec = 59 ;
            if ( m_min >= 1 )
            {
                m_min --;
            }
            else
            {
                m_sec = 0;
            }
        }
        
        if ( m_min < 0)
        {
            m_min = 59;
            if (m_hr >= 1)
            {
                m_hr--;
            }
            else
            {
                m_min = 0;
            }
        }
        
        if ( m_hr < 0)
        {
			//yay!
            m_hr = 23;
        }        
        dumpTime();
    }
	
	private inline function dumpTime ()
	{
		Debug.log ( m_hr + " : " + m_min + " : " + m_sec + m_period.getName());
	}
	public inline function getTotalSeconds () : UInt
	{
		return m_sec + m_min * 60 + m_hr * 60 * 60;
	}
	
	public inline function getTotalMinutes () : Int 
	{
		return m_min + m_hr * 60;
	}


}