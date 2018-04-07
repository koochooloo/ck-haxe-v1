//
// Copyright (C) 2017, 1st Playable Productions, LLC. All rights reserved.
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

package game.utils;

import haxe.ds.Option;

class OptionExtension
{
    public static function isSome<T>(opt:Option<T>):Bool
    {
        switch (opt)
        {
            case Some(_):
            {
                return true;
            }
            case None:
            {
                return false;
            }
        }
    }

    public static function isNone<T>(opt:Option<T>):Bool
    {
        switch (opt)
        {
            case Some(_):
            {
                return false;
            }
            case None:
            {
                return true;
            }
        }
    }

    public static function map<A, B>(opt:Option<A>, f:A->B):Option<B>
    {
        switch (opt)
        {
            case Some(value):
            {
                return Some(f(value));
            }
            case None:
            {
                return None;
            }
        }
    }

    public static function unit<T>(value:T):Option<T>
    {
        return Some(value);
    }

    public static function flatMap<A, B>(opt:Option<A>, f:A->Option<B>):Option<B>
    {
        switch (opt)
        {
            case Some(value):
            {
                return f(value);
            }
            case None:
            {
                return None;
            }
        }
    }

    public static function lift<A,B>(f:A->B):Option<A>->Option<B>
    {
        return function g(opt:Option<A>):Option<B>
        {
            return map(opt, f);
        }
    }

    public static function unwrap<T>(opt:Option<T>, defaultValue:T):T
    {
        switch (opt)
        {
            case Some(value):
            {
                return value;
            }
            case None:
            {
                return defaultValue;
            }
        }
    }
}