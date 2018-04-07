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

class ArrayTools
{
	public static function exists<T>( ar:Array<T>, x:T ):Bool
	{
		return ar.indexOf(x) != -1;
	}

    /**
     * Shuffles the array using the Fisher-Yates algorithm.
     *
     * See https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
     */
    public static function shuffle<T>( ar:Array<T> ):Void
    {
        var n:Int = ar.length;

        for ( i in 0...n - 1 )
        {
            var j:Int = Std.random( n - i ) + i;  // i <= j < n
            swap(ar, i, j);
        }
    }

    public static function swap<T>( ar:Array<T>, a:Int, b:Int ):Void
	{
		var tmp = ar[a];
		ar[a] = ar[b];
		ar[b] = tmp;
	}
	
	/**
	 * Binary search for lower end of range using a provided comparison function.
	 * Reference: http://en.cppreference.com/w/cpp/algorithm/lower_bound
	 * @param	toFind  value to compare against (second arg to comparisonFunction)
	 * @param	findIn  container to search
	 * @param	lessFn  returns true if first arg is "less" than second arg
	 * @return  index of first element not less than toFind, or findIn.length if not found
	 */
	public static function lowerBound<T>(toFind:T, findIn:Array<T>
	   , lessFn:T->T->Bool):Int
	{
		var idx:Int = 0;
		var count:Int = findIn.length;
		
		var first:Int = 0;
		
		while ( count > 0 )
		{
			idx = first;
			var step:Int = Std.int( count / 2 );
			idx += step;
			if ( lessFn( findIn[idx], toFind ) )
			{
				first = ++idx;
				count -= ( step + 1 );
			}
			else
			{
				count = step;
			}
		}
		
		return first;
	}
		
	/**
	 * Binary search for upper end of range using a provided comparison function.
	 * Reference: http://en.cppreference.com/w/cpp/algorithm/upper_bound
	 * @param	toFind  value to compare against (second arg to comparisonFunction)
	 * @param	findIn  container to search
	 * @param	lessFn  returns true if first arg is "less" than second arg
	 * @return  index of first element that is greater than toFind, or findIn.length if not found
	 */
	public static function upperBound<T>(toFind:T, findIn:Array<T>
	   , lessFn:T->T->Bool):Int
	{
		// This could be implemented in terms of lowerBound:
		// return lowerBound( toFind, findIn, function(a,b) return ! lessFn(b,a) )
		// ...but probably avoiding any possible lambda overhead and repeating here.
		
		var idx:Int = 0;
		var count:Int = findIn.length;
		
		var first:Int = 0;
		
		while ( count > 0 )
		{
			idx = first;
			var step:Int = Std.int( count / 2 );
			idx += step;
			if ( ! lessFn( toFind, findIn[idx] ) ) // only difference vs lowerBound (not and swap args)
			{
				first = ++idx;
				count -= ( step + 1 );
			}
			else
			{
				count = step;
			}
		}
		
		return first;
	}
}