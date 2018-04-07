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

package game.def;
import game.cms.Grade;
import game.def.GradeDefs;

#if (debug || build_cheats)
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.cheats.Cheats;
import com.firstplayable.hxlib.state.StateManager;
import game.def.PassportDefs.StampStatus;

class CheatDefs 
{
	/**
	 * Registers cheats.
	 */
	public static function initCheats():Void
	{
		//=================================================
		// General
		//=================================================
		var clearSave:CheatData = 
		{
			name:"Clear Save",
			tags: ["General"],
			func: function(){eraseSave();}
		};
		Cheats.registerCheat(clearSave);
		
		var earnStampCheat:CheatData = 
		{
			name:"Earn Next Stamp",
			tags: ["General"],
			func: function(){earnNextStamp();}
		};
		Cheats.registerCheat(earnStampCheat);
		
		/*
		var showLog:CheatData = 
		{
			name:"Show Log",
			tags: ["General"],
			func: function(){SpeckGlobals.eventLog.getCheatLog();}
		};
		Cheats.registerCheat(showLog);
		*/
	}
	
	//=======================================
	// General Cheats
	//=======================================
	private static function eraseSave():Void
	{
		SpeckGlobals.saveProfile.eraseProfile();
	}
	
	private static function earnNextStamp():Void
	{
		var countryList:Array<String> = GradeDefs.COUNTRIES_BY_GRADE.get(SpeckGlobals.saveProfile.gradeLevel);
		if (countryList == null)
		{
			Debug.warn("no countries for grade, defaulting to grade 1");
			countryList = GradeDefs.COUNTRIES_BY_GRADE[Grade.FIRST];
		}
		for (country in countryList)
		{
			if (SpeckGlobals.saveProfile.passportStamps[country] == UNEARNED)
			{
				SpeckGlobals.saveProfile.updateStampStatus(country, EARNED);
				break;
			}
		}
	}

}
#end
