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


package game.net;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import game.events.DataLoadedEvent;
import game.net.schema.CountriesDef;
import game.net.schema.CountryAudiosDef;
import game.net.schema.DietaryPreferencesDef;
import game.net.schema.GamesDef;
import game.net.schema.MusicsDef;
import game.net.schema.RecipesDef;
import haxe.EnumTools;
import haxe.Json;
import haxe.Timer;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

/**
 * List of tables we can access via the api
 */
enum DatabaseTables
{
	COUNTRIES;
	COUNTRY_AUDIOS;
	DIETARY_PREFERENCES;
	GAMES;
	RECIPES;
	MUSICS;
}

enum DatabaseTableStatus
{
	UNLOADED;
	LOADING;
	ERROR;
	LOADED;
}

typedef DatabaseApiParams =
{
	@:optional var updated_at:Null<Int>;
	@:optional var start:Null<Int>;
	@:optional var page_size:Null<Int>;
	@:optional var type:Null<String>;
}

/**
 * Interface for sending requests to the backend server,
 * and handling the responses.
 */
class DatabaseInterface
{
	//=============================================
	// API Definitions
	//=============================================
	private static inline var BASE_REQUEST_URL:String = "https://portal.chefkoochooloo.com/api/v2/";
	private static inline var LANG_ENGLISH:String = "lang=en";
	private static inline var REQUEST_ID:String = "access_token=82e26e8a38cfe1e252415e1ef023a750";
	
	/**
	 * List of the table tables according to the api
	 */
	private static var ms_tableNames:Map<DatabaseTables, String> = [
		COUNTRIES			=>	"countries",
		COUNTRY_AUDIOS		=>	"audios",
		DIETARY_PREFERENCES =>	"dietary_preferences",
		GAMES				=>	"games",
		RECIPES				=>	"recipes",
		MUSICS				=>	"musics"
	];
	
	//=============================================
	// Initialization
	//=============================================
	
	public static var ms_tableData:Map<DatabaseTables, Array<Dynamic>> = [
		COUNTRIES			=>	[],
		COUNTRY_AUDIOS		=>	[],
		DIETARY_PREFERENCES =>	[],
		GAMES				=>	[],
		RECIPES				=>	[],
		MUSICS				=>	[]
	];
	
	public static var ms_tableStatus:Map<DatabaseTables, DatabaseTableStatus> = [
		COUNTRIES			=>	UNLOADED,
		COUNTRY_AUDIOS		=>	UNLOADED,
		DIETARY_PREFERENCES =>	UNLOADED,
		GAMES				=>	UNLOADED,
		RECIPES				=>	UNLOADED,
		MUSICS				=>	UNLOADED
	];
	
	private static var ms_startInitTime:Float = 0;
	private static var ms_loadedTables:Int = 0;
	
	/**
	 * Sends a request for data from the provided table to the server.
	 * @param	tableID
	 */
	public static function loadTable(tableID:DatabaseTables):Void
	{
		if (Tunables.DEBUG_DATABASE)
		{
			Debug.log("Send Request to load: " + tableID);
		}
		
		ms_tableStatus[tableID] = LOADING;
		//Extra parameters will be ignored
		var params:DatabaseApiParams =
		{
			start:0,
			page_size:Tunables.DEFAULT_PAGE_SIZE
		}
		var initialRequest:String = createRequest(tableID, params);
		loadTableHelper(tableID, initialRequest);
	}
	
	/**
	 * Helper function for sending partial table request
	 * @param	request
	 */
	private static function loadTableHelper(table:DatabaseTables, request:String):Void
	{
		if (Tunables.DEBUG_DATABASE)
		{
			Debug.log("sending " + table + " request: " + request);
		}
		
		var urlLoader:URLLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, function(_){
			
			if (Tunables.DEBUG_DATABASE)
			{
				Debug.log("Request for " + table + " response received...");
			}
			
			//========================================
			// Parse the response
			//========================================
			var response:Dynamic = Json.parse(urlLoader.data);
			if (Tunables.DEBUG_DATABASE)
			{
				Debug.log(Std.string(response));
			}
			
			//========================================
			// Store the received table elements
			//========================================
			var fieldName:String = ms_tableNames[table];
			var responseElements:Array<Dynamic> = Reflect.field(response, fieldName);
			for (element in responseElements)
			{
				if (element.is_deleted)
				{
					continue;
				}
				
				ms_tableData[table].push(element);
			}
			
			//========================================
			// Determine if we've finished loading this table.
			//========================================
			if ((table == RECIPES) && (Tunables.USE_PARTIAL_RECIPE_LIST))
			{
				updateInitProgress(table);
			}
			else
			{
				if (response.next_page == null)
				{
					updateInitProgress(table);
				}
				else
				{
					onProgress();
					loadTableHelper(table, response.next_page);
				}
			}
		});
		
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(_){
			handleRequestError(table);
		});
		
		urlLoader.load(new URLRequest(request));
		
		if (Tunables.DEBUG_DATABASE)
		{
			Debug.log("Request for " + table + " Sent");
		}
	}
	
	/**
	 * Creates and returns a request to the specified table with the requested parameters
	 * @param	table
	 * @param	params
	 * @return
	 */
	private static function createRequest(table:DatabaseTables, params:DatabaseApiParams):String
	{
		var requestUrl:String = BASE_REQUEST_URL;
		requestUrl += ms_tableNames[table];
		requestUrl += "/?";
		
		var fields:Array<String> = Reflect.fields(params);
		for (field in fields)
		{
			var val:Dynamic = Reflect.field(params, field);
			if (val != null)
			{
				requestUrl += field + "=" + val + "&";
			} 
		}
		
		requestUrl += LANG_ENGLISH;
		requestUrl += "&";
		requestUrl += REQUEST_ID;
		
		return requestUrl;
	}
	
	/**
	 * Request all table data from the backend.
	 * Store it in locally accessible statics.
	 * TODO: this is gross, but it's what the original game did,
	 * and so we will follow...
	 */
	public static function initFromBackend():Void
	{
		if (Tunables.DEBUG_DATABASE)
		{
			Debug.log("==========================================");
			Debug.log("Begin DatabaseInterface initialization...");
			Debug.log("==========================================");
		}
		
		ms_startInitTime = Timer.stamp();
		
		ms_loadedTables = 0;
		for (key in ms_tableStatus.keys())
		{
			ms_tableStatus[key] = UNLOADED;
		}
		
		var tables:Array<DatabaseTables> = EnumTools.createAll(DatabaseTables);
		for (table in tables)
		{
			loadTable(table);
		}
	}
	
	/**
	 * Callback for when each database completes being loaded.
	 */
	private static function updateInitProgress(table:DatabaseTables)
	{
		if (Tunables.DEBUG_DATABASE)
		{
			Debug.log("Request for " + table + " Complete!");
			Debug.log("elements received: " + ms_tableData[table].length);
		}
		
		ms_tableStatus[table] = LOADED;
		++ms_loadedTables;
		
		handleInitComplete();
	}
	
	/**
	 * Callback for when there is an error loading a database.
	 * @param	e
	 */
	private static function handleRequestError(table:DatabaseTables):Void
	{
		ms_tableStatus[table] = ERROR;
		++ms_loadedTables;
		
		handleInitComplete();
	}
	
	private static function handleInitComplete():Void
	{
		var tables:Array<DatabaseTables> = EnumTools.createAll(DatabaseTables);
		if (ms_loadedTables >= tables.length)
		{
			SpeckGlobals.databaseCMSLoaded = true;
			var endTime:Float = Timer.stamp();
			var duration:Float = (endTime - ms_startInitTime) / 1000;
			
			if (Tunables.DEBUG_DATABASE)
			{
				Debug.log("==========================================");
				Debug.log("DatabaseInterface initialization complete!");
				Debug.log("took (" + duration + ") seconds.");
				Debug.log("loading results: ");
			}
			
			var errorFound:Bool = false;
			for (key in ms_tableStatus.keys())
			{
				Debug.log(Std.string(key) + ": " + ms_tableStatus[key]);
				if (ms_tableStatus[key] != LOADED)
				{
					errorFound = true;
				}
			}
			
			if (!errorFound)
			{
				if (Tunables.DEBUG_DATABASE)
				{
					Debug.log("SUCCESS!");
				}
				SpeckGlobals.event.dispatchEvent(new DataLoadedEvent(DataLoadedEvent.DATABASE_DATA_LOADED));
			}
			else
			{
				if (Tunables.DEBUG_DATABASE)
				{
					Debug.log("ERROR couldn't load all tables");
				}
				SpeckGlobals.event.dispatchEvent(new DataLoadedEvent(DataLoadedEvent.DATABASE_DATA_ERROR));
			}
			
			if (Tunables.DEBUG_DATABASE)
			{
				Debug.log("==========================================");
			}	
		}
		else
		{
			onProgress();
		}
	}
	
	private static function onProgress():Void
	{
		if (Tunables.DEBUG_DATABASE)
		{
			Debug.log("PROGRESS!");
		}
		SpeckGlobals.event.dispatchEvent(new DataLoadedEvent(DataLoadedEvent.DATABASE_DATA_PROGRESS));
	}
	
}