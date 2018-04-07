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

class DateToolsX extends DateTools
{
    private static var m_monthNames:Array<String> =
    [
       "January",
       "February",
       "March",
       "April",
       "May",
       "June",
       "July",
       "August",
       "September",
       "October",
       "November",
       "December"
   ];
    
    private static var m_weekdayNames:Array<String> =
    [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday"
    ];
    
    /**
     * Get the name of a month.
     * @param month     The month to get, [0-11].
     * @return
     */
    public static function getMonthName( month:Int ):String
    {
        if ( month > 11 ) return "Month index out of bounds.";
        return m_monthNames[ month ];
    }
    
    /**
     * Get the name of a weekday.
     * @param day       The day to get, [0-6].
     * @return
     */
    public static function getWeekdayName( day:Int ):String
    {
        if ( day > 6 ) return "Day index out of bounds.";
        return m_weekdayNames[ day ];
    }
    
    /**
     * Gets the day of the year, [0-366].
     * @param    date    The date object to use.
     * @return   day of the year; accounts for leapyear.
     */
    public static function getYearDay( date:Date ):Int
    {
        var year:Int = date.getFullYear();
        var month:Int = date.getMonth();
        var dayOfYear:Int = date.getDate();
        
        for ( i in 0...month )
        {
            //we need to initialize a new date, but we only care about year + month
            dayOfYear += DateTools.getMonthDays( new Date( year, i, 1, 1, 1, 1 ) );
        }
        
        return dayOfYear;
    }
    
    /**
     * Determines if the date is a leapyear.
     * @param    date    The date object to check.
     * @return   true if leapyear, false if not.
     */
    public static function isLeapYear( date:Date ):Bool
    {
        return( date.getFullYear() % 4 == 0 );
    }
    
    /**
     * Gets the string of the date as "YYYY-MM-DD".
     * @param   date    The date object to use.
     * @return  date as a formatted string.
     */
    public static function toStringDate( date:Date ):String
    {
        return date.toString().split( " " )[ 0 ];
    }
    
    /**
     * Gets the string of the date as "HH:MM:SS".
     * @param   date    The date object to use.
     * @return  date's time as a formatted string.
     */
    public static function toStringTime( date:Date ):String
    {
        return date.toString().split( " " )[ 1 ];
    }
}