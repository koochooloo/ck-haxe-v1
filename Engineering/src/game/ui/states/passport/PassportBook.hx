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

package game.ui.states.passport;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.display.OPSprite;
import game.cms.Grade;
import game.def.GradeDefs;
import game.net.AccountManager.Teacher;
import game.ui.SpeckMenu;
import haxe.ds.Option;

/**
 * The book on the passport menu that holds the stamps.
 */
class PassportBook extends SpeckMenu
{
	public static inline var MENU_NAME:String = "PassportBook";
	
	private var m_stamps:Array<PassportStamp>;
	
	public function new() 
	{
		super(MENU_NAME);
		
		m_stamps = [];
		var teacher:Teacher = switch( SpeckGlobals.teacher )
		{
			case Some( teacher ): teacher;
			case None: null;
		}
		
		if ( teacher != null )
		{
			var countryList:Array<String> = GradeDefs.COUNTRIES_BY_GRADE.get(teacher.grade);
			if (countryList == null)
			{
				Debug.warn("no stamps for grade...");
				return;
			}			
		
			//Create and initialize all the stamps
			for(i in 0...countryList.length)
			{
				var nextStamp:PassportStamp = new PassportStamp();
				var nextCountry:String = countryList[i];
				nextStamp.setup(i, nextCountry);
				
				var referenceStampName:String = "ref_stamp_" + i;
				var referenceStamp:OPSprite = getChildAs(referenceStampName, OPSprite);
				nextStamp.x = referenceStamp.x;
				nextStamp.y = referenceStamp.y;
				
				addChild(nextStamp);
				
				referenceStamp.visible = false;
				
				m_stamps.push(nextStamp);
			}
		}
	}
	
	public function release():Void
	{
		for (stamp in m_stamps)
		{
			stamp.release();
			removeChild(stamp);
		}
		m_stamps = null;
	}
}