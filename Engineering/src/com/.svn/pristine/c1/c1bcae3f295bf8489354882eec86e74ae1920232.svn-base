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
package com.firstplayable.hxlib.psoc;

@:native( "Broker" )
extern class EventBroker
{
    public static var mediator:Dynamic;
    /**
     * Subscribe to save call.
     * @param cb    callback to handle saving.
     */
    public static function addSave( cb:Void->Void ):Void;
    /**
     * Publish save data.
     * @param save  object to save.
     */
    public static function doSave( save:Dynamic ):Void;
    /**
     * Subscribe to finish call.
     * @param cb    callback to handle finish.
     */
    public static function addFinish( cb:Void->Void ):Void;
    /**
     * Publishes finish event.
     * @param complete  Whether the student progressed in the activity.
     * @param success   Whether the student was succesful passing the activity.
     * @param score     The score given to the student.
     */
    public static function doFinish( complete:Bool, success:Bool, score:Float ):Void;
    /**
     * Publishes fetch event to get save data.
     * @param cb    callback to receive save object from.
     */
    public static function getSave( cb:String->Void ):Void;
    /**
     * Publishes fetch event to get context data.
     * @param cb    callback to receive context object from.
     */
    public static function getContext( cb:Dynamic->Void ):Void;
}