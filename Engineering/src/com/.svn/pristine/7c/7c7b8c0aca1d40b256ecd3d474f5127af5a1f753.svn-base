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

package com.firstplayable.hxlib.display;

import com.firstplayable.hxlib.loader.SpriteDataManager;
import spritesheet.data.BehaviorData;
import spritesheet.Spritesheet;

/**
 * Maps frame names from a Spritesheet to the SpriteBoxData that defines the bounds (and ref point) for that image.
 */
class SpritesheetBounds
{
	private var m_frameBoxData:Map<String, SpriteBoxData> = null;
	
	public function new( sheet:Spritesheet, resPath:String ) 
	{
		m_frameBoxData = new Map();
		if ( sheet == null || resPath == null ) { Debug.warn( "Cannot construct spritesheet bounds" ); }
		else
		{
			setRpjData( sheet.behaviors, resPath );
		}
	}
	
	public function getBounds( currentFrameLabel:String ):SpriteBoxData
	{
		var bnds:SpriteBoxData = m_frameBoxData.get( currentFrameLabel );
		if ( bnds != null )
		{
			bnds = bnds.copy();
		}
		
		return bnds;
	}
	
	private function setRpjData( frames:Map<String, BehaviorData>, resPath:String ):Void
	{
		for ( frame in frames )
		{
			var frameImagePath:String = resPath + frame.name + ".png";
			var d:SpriteBoxData = SpriteDataManager.instance.get( frameImagePath );
			if ( d != null )
			{
				m_frameBoxData.set( frame.name, d );
			}
			else
			{
				Debug.log( "No sprite box data found for '" + frameImagePath + "'" );
			}
		}
		
	}
}