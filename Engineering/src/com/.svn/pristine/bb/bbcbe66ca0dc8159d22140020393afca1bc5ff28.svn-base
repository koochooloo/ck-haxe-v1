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
package com.firstplayable.hxlib.app;

import com.firstplayable.hxlib.app.UpdatePhase;


typedef UpdateContext =
{
    var phase: UpdatePhase;
}

/** An Updateable object implements an "update" function, which is callable by the
 *  game's MainLoop. */
interface Updateable
{
    /** The update function takes an "UpdateContext", which can be expanded to contain whatever
     *  games may require in the future.  For now, it contains a reference to the UpdatePhase
     *  in which the update is performed, which contains various information the update function
     *  may find useful (such as the time for which the update is being executed). 
     *  Many update functions probably will not need to make use of the UpdateContext, and it can be an
     *  unused parameter.  */
    function update( context: UpdateContext ): Void;
}