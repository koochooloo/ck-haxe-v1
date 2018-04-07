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

package game.save;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.io.GameSave;
import game.controllers.FlowController;
import game.def.DemoDefs;
import game.def.PassportDefs;
import game.def.PassportDefs.StampStatus;
import game.init.Display;
import game.net.AccountManager;
import game.net.AccountManager.Student;
import haxe.EnumTools;
import haxe.Json;
import haxe.ds.Option;
#if js
import js.Browser;
#else
import lime.system.System;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
#end
import lime.tools.helpers.GUID;

using Type;

/**
 * Class used during initialization to set up controllers and managers with saved data,
 * and used to safe off progression after every level.
 */
class PlayerProfile extends GameSave
{	
	private static inline var PRODUCT_NAME:String 				= "Speck";
	private static inline var PROFILE_NAME:String 				= "Speck-user";
	private static inline var VERSION_FIELD:String 				= "version";
	private static inline var TUTORIAL_FIELD:String				= "hasSeenTutorial";
	private static inline var ALLERGENS_FIELD:String 			= "savedAllergens";
	private static inline var FAVORITES_FIELD:String 			= "savedFavorites";
	private static inline var STAMPS_FIELD:String 				= "passportStamps";
	private static inline var GRADE_FIELD:String 				= "gradeLevel";
	private static inline var UUID_FIELD:String					= "uuid";
	private static inline var USER_ID:String 					= "userId";
	
	public static var state( get, null ):PlayerProfile;
	private static function get_state( ):PlayerProfile
	{
		//If we need a state, make one!
		if ( state == null )
		{
			state = new PlayerProfile();
		}
		return state;
	}
	
	// Data being saved: 
	public var hasSeenTutorial(default, null):Bool;
	public var savedAllergens(default, null):Array< String >; // List of ingredient names
	public var savedFavorites(default, null):Array< String >; // List of recipe names
	public var passportStamps(default, null):Map<String, StampStatus>; // Progress status of stamps.
	public var m_uuid(default, null):String; //uuid used for analytics, replaced with student login name
	public var userId(default, null):String; // User login - teacher + student ID (specific to grade level/teacher)
	
	private static var ALL_FIELDS:Array<String> = [
		VERSION_FIELD,
		TUTORIAL_FIELD,
		ALLERGENS_FIELD,
		FAVORITES_FIELD,
		STAMPS_FIELD,
		GRADE_FIELD,
		UUID_FIELD,
		USER_ID
	];
	
	/**
	 * PlayerProfile Constructor.
	 */
	public function new() 
	{
		super();
		
		productName = PRODUCT_NAME;
		profileName = PROFILE_NAME;
		
		clear();
	}
	
	/**
	 * Resets the profile to the initial state
	 */
	public function clear():Void
	{
		hasSeenTutorial = false;
		userId = "";
		savedAllergens = [];
		savedFavorites = [];
		passportStamps = new Map<String, StampStatus>();
		for (countryName in PassportDefs.COUNTRY_STAMP_MAP.keys())
		{
			passportStamps[countryName] = UNEARNED;
		}
		m_uuid = GUID.uuid();
	}
	
	/**
	 * Resets the save file to initial state and posts.
	 */
	public function eraseProfile():Void
	{
		clear();
		
		post();
	}
	
	/**
	 * Forces managers to update their data, and save the game.
	 */
	public function saveGame():Void
	{
		post();
	}
	
	/**
	 *  Save PlayerProfile data both locally and to AWS
	 */
	public function post():Void
	{
		postLocally();
		postAWS();
	}
	
	private function createSaveObject():SaveObject
	{
		var stampProgress:Array<StampData> = [];
		
		for (countryName in PassportDefs.COUNTRY_STAMP_MAP.keys())
		{
			var progress:StampStatus = passportStamps.get(countryName);
			var nextStamp:StampData = {country:countryName, status:progress.getIndex()};
			stampProgress.push(nextStamp);
		}
		
		return {
			version: SaveVersion.CURRENT,
			hasSeenTutorial: this.hasSeenTutorial,
			savedAllergens: this.savedAllergens,
			savedFavorites: this.savedFavorites,
			passportStamps: stampProgress,
			gradeLevel: this.gradeLevel,
			uuid: m_uuid,
			userId: this.userId
		};
	}
	
	/**
	 *  Save user interaction data to local storage
	 */
	private function postLocally()
	{
		var stampProgress:Array<StampData> = [];
		
		for (countryName in PassportDefs.COUNTRY_STAMP_MAP.keys())
		{
			var progress:StampStatus = passportStamps.get(countryName);
			var nextStamp:StampData = {country:countryName, status:progress.getIndex()};
			stampProgress.push(nextStamp);
		}
		
		var saveObj:SaveObject = createSaveObject();
		
		var json:String = Json.stringify(saveObj);
		#if js
		Browser.window.localStorage.setItem(productName, json);
		#else
		var saveFilePath:String = System.applicationStorageDirectory + productName + userId;
		File.saveContent(saveFilePath , json);
		#end
		
		if ( Tunables.DEBUG_SAVE_PROFILE )
		{
			Debug.log("===============================");
			Debug.log("===============================");
			Debug.log("===============================");
			Debug.log("=========Save Profile==========");
			Debug.log("Save Object:");
			Debug.log(Std.string(saveObj));
			Debug.log("Json:");
			Debug.log(json);
			debugPrint();
			Debug.log("===============================");
			Debug.log("===============================");
			Debug.log("===============================");
		}
	}
	
	/**
	 * Save user interaction data to Dynamo bucket 
	 */
	private function postAWS()
	{
		var currentStudent:Student = switch( SpeckGlobals.student )
		{
			case Some( student ): student;
			case None: null;
		}
		
		if ( currentStudent != null )
		{
			var saveObj:SaveObject = createSaveObject();
			if ( saveObj != null )
			{
				var saveJson:String = Json.stringify(saveObj);
				currentStudent.playerProfile = saveJson;
				AccountManager.saveStudent(currentStudent);	
			}
		}
	}
	
	override public function saveGameStateEntry(menuName:String):Void 
	{
		super.saveGameStateEntry(menuName);
		Display.updateStateStamp();
		post();
	}
	
	/**
	 * Retrieves data from local save and writes values to PlayerProfile.
	 */
	public function get():Bool
	{
		// Try to pull online save data
		if ( getAWS() )
		{
			return true;
		}
		// If no data is available online, try local storage
		else if ( getLocal() )
		{
			return true;
		}
		// No save profile for this user
		else
		{
			return false;
		}
	}
	
	private function getAWS():Bool
	{	
		var currentStudent:Student = switch( SpeckGlobals.student )
		{
			case Some( student ): student;
			case None: null;
		}
				
		if ( currentStudent != null )
		{
			var saveStr:String = currentStudent.playerProfile;
			var foundSave:Bool = (saveStr != null) && (saveStr != "" );
			if (foundSave)
			{
				var saveObj:Dynamic = Json.parse(saveStr);
				parseSaveData( saveObj );
				return true;
			}
			
		}
		
		return false;
	}
	
	private function getLocal():Bool
	{
		#if js
		var saveStr:String = Browser.window.localStorage.getItem(productName);
		#else
		var saveStr:String = "{}";
		var saveFilePath = System.applicationStorageDirectory + productName;
		if (FileSystem.exists(saveFilePath))
		{
			saveStr = File.getContent(saveFilePath);
		}
		#end
			
		var foundSave:Bool = (saveStr != null);
		if (foundSave)
		{
			var saveObj:Dynamic = Json.parse(saveStr);

			for (field in ALL_FIELDS)
			{
				if (!Reflect.hasField(saveObj, field))
				{
					if (Tunables.DEBUG_SAVE_PROFILE)
					{
						Debug.log("===============================");
						Debug.log("===============================");
						Debug.log("===============================");
						Debug.log("=========Save Profile==========");
						Debug.log("was missing field: " + field);
						Debug.log(saveStr);
						debugPrint();
						Debug.log("===============================");
						Debug.log("===============================");
						Debug.log("===============================");
					}
					
					return false;
				}
			}
			
			parseSaveData( saveObj );
		}
		
		if (Tunables.DEBUG_SAVE_PROFILE)
		{
			Debug.log("===============================");
			Debug.log("===============================");
			Debug.log("===============================");
			Debug.log("=========Save Profile==========");
			Debug.log(saveStr);
			debugPrint();
			Debug.log("===============================");
			Debug.log("===============================");
			Debug.log("===============================");
		}
		
		return foundSave;
	}
	
	/**
	 * Check if saveobj is for the correct student and save version, then 
	 * 		pulls attr into the playerprofile.
	 */
	private function parseSaveData( saveObj:SaveObject ):Bool
	{
		var isCurrentVersion:Bool = (saveObj.version == SaveVersion.CURRENT);
		var isRelevantSave:Bool = isCurrentVersion && isStudentSave( saveObj.userId );
		if ( isRelevantSave )
		{
			// Set profile vars from the save data
			hasSeenTutorial = saveObj.hasSeenTutorial;
			savedAllergens = saveObj.savedAllergens;
			savedFavorites = saveObj.savedFavorites;
			
			var stampProgress:Map<String, StampStatus> = new Map<String, StampStatus>();
			var savedStampProgress:Array<StampData> = cast saveObj.passportStamps;
			
			for (stamp in savedStampProgress)
			{
				var progress:StampStatus = EnumTools.createByIndex(StampStatus, stamp.status);					
				stampProgress[stamp.country] = progress;
			}
			
			this.passportStamps = stampProgress;
			
			this.gradeLevel = saveObj.gradeLevel;
			
			this.m_uuid = saveObj.uuid;
			
			this.userId = saveObj.userId;
			
			SpeckGlobals.dataManager.setDataFromSave( savedAllergens, savedFavorites );
		}
		else 
		{
			Debug.log( "No local save data found for " + this.userId );
		}
		
		return isRelevantSave;
	}
	
	/**
	 * Prints the members of this object
	 */
	public function debugPrint():Void
	{
		Debug.log("Player Profiile:");
		for (field in Type.getInstanceFields(this.getClass()))
		{
			var fieldval:Dynamic = Reflect.field(this, field);
			if (!Reflect.isFunction(fieldval))
			{
				Debug.log(field + ": " + fieldval);
			}
		}
	}
	
	public function getCurrentStateString():String
	{
		if ( m_savedStates == null || m_savedStates.length == 0 )
		{
			// ERROR RETURN
			return "unknown game state";
		}
		
		var curState:SavedState = m_savedStates[ m_savedStates.length - 1 ];
		return curState.gameStateName + "::" + curState.gameMenuName;
	}
	
	public function setSavedAllergens( allergens:Array< Ingredient > ):Array< String >
	{	
		savedAllergens = [];
		
		if ( allergens != null )
		{
			for ( ingredient in allergens )
			{
				savedAllergens.push( ingredient.name );
			}
		}
		else 
		{
			savedAllergens = [];
		}

		return savedAllergens;
	}
	
	public function setSavedFavorites( favorites:Array< Recipe > ):Array< String >
	{
		savedFavorites = [];
		
		if ( favorites != null )
		{
			for ( fav in favorites )
			{
				savedFavorites.push( fav.name );
			}
		}
		else
		{
			savedFavorites = [];
		}

		return savedFavorites;
	}
	
	public function setHasSeenTutorial( b:Bool ):Bool
	{
		hasSeenTutorial = b;
		saveGame();
		return hasSeenTutorial;
	}
	
	/**
	 * Returns whether the passport button has been unlocked
	 * @return
	 */
	public function hasUnlockedPassport():Bool
	{
		for (status in passportStamps)
		{
			if (status != UNEARNED)
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Updates the stamp status for the provided country
	 * @param	country
	 * @param	status
	 */
	public function updateStampStatus(country:String, status:StampStatus):Void
	{
		passportStamps[country] = status;
		saveGame();
	}
	
	/**
	 * Returns whether any stamps are Earned but not yet Claimed.
	 * @return
	 */
	public function haveStampsToClaim():Bool
	{
		for (stamp in passportStamps)
		{
			if (stamp == EARNED)
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Unwraps student and sets ID
	 */
	public function setStudentId():String
	{
		switch ( SpeckGlobals.student )
		{
			case Some( student ):
			{
				this.userId = student.id;
                		saveGame();
				return this.userId;
			}
			case None:
			{
				Debug.log( "No student ID available for this session. Flow: " + FlowController.currentMode );
			}
		}
		
		this.userId = "";
		return "";
	}
	
	/*
	 * Parse data into memory
	 * */
	public function setData( data:String )
	{
		if ( data == null || data == "" )
		{
			clear();
		}
		else 
		{
			var saveObj:Dynamic = Json.parse( data );
			parseSaveData( saveObj );			
		}
	}
	 
	/**
	 *  Checks if current student ID matches save student ID
	 */
	private function isStudentSave( id:String ):Bool
	{
		switch ( SpeckGlobals.student )
		{
			case Some( student ):
			{
				var studentId:String = student.id;
				return studentId == id;
			}
			case None:
			{
				Debug.log( "No student ID available for this session. Flow: " + FlowController.currentMode );
			}
		}
		
		return false;
	}
}
