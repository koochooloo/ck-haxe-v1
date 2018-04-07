//
// Copyright (C) 2015, 1st Playable Productions, LLC. All rights reserved.
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

package;

import assets.Gamestrings;
import com.firstplayable.hxlib.utils.Version;
import game.DataManager;
import game.net.AccountManager.Student;
import game.net.AccountManager.Teacher;
import game.save.PlayerProfile;
import game.ui.HudMenu;
import game.ui.states.CountryMenu;
import haxe.ds.Option;
import openfl.events.EventDispatcher;
import game.GameEventLog;

#if (debug || build_cheats)
import com.firstplayable.hxlib.debug.cheats.CheatsMenu;
import com.firstplayable.hxlib.debug.tunables.TunablesMenu;
#end

class SpeckGlobals
{
	//==========================================
	// Events
	//==========================================
	public static inline var AWS_REGION = "us-west-2";
	public static inline var AWS_IDENTITY_POOL_ID = "us-west-2:da5309fa-e5f6-424c-897c-7570e208c117";

	//==========================================
	// Events
	//==========================================
	public static var event( default, null ):EventDispatcher = new EventDispatcher();
	public static var databaseCMSLoaded:Bool = false;
	public static var databaseFlagsLoaded:Bool = false;
	
	//==========================================
	// Debug
	//==========================================	
	#if (debug || build_cheats)
	public static var debugMenu:TunablesMenu;
	public static var cheatsMenu:CheatsMenu;
	#end
	public static var eventLog:GameEventLog = new GameEventLog();
	
	//==========================================
	// Managers
	//==========================================
	public static var saveProfile:PlayerProfile;
	public static var dataManager:DataManager = new DataManager();
	public static var gameStrings:Gamestrings = new Gamestrings();
	public static var teacher:Option<Teacher> = None;
	public static var student(default, set):Option<Student> = None;
	
	//==========================================
	// UI
	//==========================================
	public static var hud:HudMenu;
	public static inline var FADE_TIME:Float = 1;
	
	//==========================================
	// Audio
	//==========================================
	
	public static var isGloballyMuted:Bool = false;
	public static var isBGMMuted:Bool = false;
	public static var BgmID:String = "";
	
	//==========================================
	// Initialization
	//==========================================
	
	private static var ms_initiedManagers:Bool = false;
	public static function initManagers():Void
	{
		if (ms_initiedManagers)
		{
			return;
		}
		
		saveProfile = new PlayerProfile();
		ms_initiedManagers = true;
	}
	
	public static function initDatabaseCMS():Void
	{
		dataManager.init();
	}
	
	private static var ms_initedUI:Bool = false;
	public static function initUI():Void
	{
		if (ms_initedUI)
		{
			return;
		}
		
		ms_initedUI = true;
	}
	
	/*
	 * Make sure we update the active playerProfile if we update the active student.
	 * */
	public static function set_student( studentOp:Option<Student> ):Option<Student>
	{
		student = studentOp; 
		
		switch ( studentOp )
		{
			case Some( s ):
			{
				saveProfile.setData( s.playerProfile );				
			}
			case None: //
		}
		
		return studentOp;
	}
	
}
