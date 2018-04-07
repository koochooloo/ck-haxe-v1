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

package game.controllers;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.Debug.log;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.Country;
import game.Recipe;
import game.cms.Dataset;
import game.cms.Grade;
import game.cms.Question;
import game.cms.QuestionDatabase;
import game.cms.QuestionQuery;
import game.def.DemoDefs;
import game.def.GameState;
import game.cms.Curriculum;
import game.net.AccountManager;
import haxe.ds.Option;

using game.utils.OptionExtension;

/**
 * Flags which type of flow we use - pilot or consumer
 */
enum FlowMode
{
	PILOT;
	CONSUMER;
}

/**
 * Flags which flow subset we are using
 */
enum FlowPath
{
	PILOT;
	CONSUMER_COUNTRY;
	CONSUMER_RECIPE;
	CONSUMER_FAVORITES;
}

/**
 * Flags direction of linear flow progression (forwards or backwards)
 */
enum FlowDir
{
	NEXT;
	PREV;
}

/**
 * Wrapped in GameStateParams and referenced between state transitions
 */
typedef FlowData =
{
	selectedCountry:Country,
	selectedRecipe:Recipe,
	currentCurriculum:Curriculum
} // TODO - question data? (curriculum)

class FlowController
{
	// ======================================================
	// Definitions
	// ======================================================
	
	public static var flowPos(default, null) :Int = 0;
	public static var currentMode(default, null):FlowMode   = FlowMode.PILOT;
	public static var currentPath(default, null):FlowPath  = FlowPath.PILOT;
	public static var currentState(default, null):GameState = GameState.GLOBE;
	public static var data(default, null):FlowData = {
		selectedCountry:   null,
		selectedRecipe:    null,
		currentCurriculum: null
	};
	
	// Flow paths are initiated at respective HUD buttons, and return to the HUD at the end 
	// ---------------------------------
	// Pilot subpath
	// ---------------------------------
	/**
	 * Flow for pilot testing 
	 * See https://docs.google.com/presentation/d/1LYIOTC4L_NAxgwEFrVz1vcDmsxrt5Pbu2RdLqYk3A5o/edit#slide=id.g29aee94d7c_1_428
	 */ 
	private static var pilot_flow:Array< GameState > = [
		GameState.GLOBE,
		GameState.COUNTRYINTRO, // Paging country facts
		GameState.FLAGGAME, 
		GameState.COUNTRYSTORY, // Story description
		GameState.QUESTION, 
		GameState.RECIPEINGREDIENTS, 
		GameState.RECIPESTEPS, 
		GameState.QUESTION, 
		GameState.DIDYOUKNOW, 
		GameState.RECIPESERVING,
		GameState.PASSPORT,
		GameState.GLOBE
	]; // TODO: LOGIN, posttest
	
	// ---------------------------------
	// Consumer subpaths
	// ---------------------------------
	/**
	 *  Consumer flow accessed through the hud.
	 *  Used after selecting a recipe
	 */
	private static var consumer_recipe_flow:Array< GameState > = [
		GameState.GLOBE,
		GameState.RECIPES,
		GameState.RECIPEINGREDIENTS,
		GameState.RECIPESTEPS,
		GameState.RECIPESERVING,
		GameState.MATHGAME,
		GameState.FLAGGAME,
		GameState.DIDYOUKNOW,
		GameState.GLOBE
	];
	
	/**
	 *  Consumer flow accessed through the hud.
	 *  Used when selecting a country, up until selecting a country recipe
	 */
	private static var consumer_country_flow:Array< GameState > = [ 
		GameState.GLOBE,
		GameState.COUNTRYINTRO,
		GameState.RECIPES,
		GameState.RECIPEINGREDIENTS,
		GameState.RECIPESTEPS,
		GameState.RECIPESERVING,
		GameState.MATHGAME,
		GameState.FLAGGAME,
		GameState.DIDYOUKNOW,
		GameState.GLOBE
	];
	
	private static var consumer_favorites_flow:Array< GameState > = [ 
		GameState.GLOBE,
		GameState.FAVORITES,
		GameState.RECIPEINGREDIENTS,
		GameState.RECIPESTEPS,
		GameState.RECIPESERVING,
		GameState.MATHGAME,
		GameState.FLAGGAME,
		GameState.DIDYOUKNOW,
		GameState.GLOBE
	];
	
	private static var pathMap( default, null ):Map < FlowPath, Array<GameState> > = [
		PILOT => pilot_flow,
		CONSUMER_COUNTRY => consumer_country_flow,
		CONSUMER_RECIPE => consumer_recipe_flow,
		CONSUMER_FAVORITES => consumer_favorites_flow
	];
	
	
	// ======================================================
	// State transition functions
	// ======================================================
	
	public static function initPilot():Void
	{
		currentMode   = FlowMode.PILOT;
		currentPath   = FlowPath.PILOT;
		currentState  = GameState.GLOBE;
		
		flowPos = 0;
		
		data = {
		selectedCountry:   null,
		selectedRecipe:    null,
		currentCurriculum: null
		};
	}
	
	public static function initConsumer():Void
	{
		currentMode   = FlowMode.CONSUMER;
		currentPath   = null;
		currentState  = GameState.GLOBE;
		
		flowPos = 0;
		
		data = {
		selectedCountry:   null,
		selectedRecipe:    null,
		currentCurriculum: null
		};
	}
	
	/**
	 *  Set current flow mode; distinguishes between pilot and consumer flow subsets
	 */
	public static function setMode( mode:FlowMode ):Void
	{
		currentMode = mode;
		
		// Init pilot path; consumer flows have different subpaths that are handled where they are instantiated in the HUD
		if ( mode == FlowMode.PILOT )
		{
			setPath( FlowPath.PILOT );
		}
	}
	
	/**
	 *  Set current flow path; sets game on a particular subset of states based on mode
	 */
	public static function setPath( path:FlowPath ):Void
	{
		flowPos = 0;
		currentPath = path;
	}
	
	private static function getParamsForState(state:GameState):GameStateParams
	{
		var args:Array<Dynamic> = [];
		
		if (state == GameState.QUESTION)
		{
			var query:QuestionQuery = QuestionDatabase.instance.query();
			
			query.withCurriculum(FlowController.data.currentCurriculum);
			
			switch (FlowController.data.currentCurriculum)
			{
				case Curriculum.MATH_AND_SCIENCE:
					{
						query.aboutRecipe(FlowController.data.selectedRecipe.name);
					}
				case Curriculum.SOCIAL_STUDIES:
					{
						query.aboutCountry(FlowController.data.selectedCountry.name);
					}
			}
			
			var questions:Array<CMSQuestion> = query.finish();
			
			Dataset.make(questions).flatMap(function(dataset){
				args.push(dataset);
				return Some(dataset);
			});
		}
		
		return {args: args};
	}
	
	/**
	 *  Set state to the next in the defined game flow, relative to the current state.
	 */
	public static function goToNext():GameState
	{
		var state:GameState = getState( FlowDir.NEXT );
		
		var params:GameStateParams = getParamsForState(state);
		
		StateManager.setState(state, params);
		
		currentState = state;
		
		if ( currentMode == FlowMode.PILOT )
		{
			// Switch curriculum if necessary
			updateCurriculum( state );
		
			// Update curriculum recipe if necessary
			updateRecipe( state );
			
			// Unlock 
			unlockStamp( state );
		}
		
		return state;
	}
	
	/**
	 *  Set state to the previous in the defined game flow, relative to the current state.
	 */
	public static function goToPrev():GameState
	{
		var state:GameState = getState( FlowDir.PREV );
		
		var params:GameStateParams = getParamsForState(state);
		
		StateManager.setState(state, params);
		
		currentState = state;
		
		return state;
	}
	
	// ---------------------------------
	// State transition helper functions 
	// ---------------------------------
	
	/**
	 *  Returns the immediate next or previous state in the game flow, relative to the current state.
	 */
	private static function getState( dir:FlowDir ):GameState
	{
		// Edit flow pos accordingly
		switch ( dir )
		{
			case NEXT: 	flowPos++;
			case PREV:  flowPos--;
		}
		
		if ( flowPos < 0 || flowPos > pathMap.get( currentPath ).length )
		{
			resetData();
		}

		// Return state at that pos given the current flow
		var state:GameState = pathMap.get( currentPath )[ flowPos ];
		return state;
	}
	
	// ======================================================
	// Data mgmt functions
	// ======================================================
	
	public static function resetData():Int
	{
		flowPos = 0;
		data = {
			selectedCountry:   null,
			selectedRecipe:    null,
			currentCurriculum: null	
		}
		
		return flowPos;
	}
	
	private static function updateCurriculum( state:GameState ):Void
	{
		if ( state == GameState.FLAGGAME )
		{
			trace( "setting flag game curriculum" );
			data.currentCurriculum = Curriculum.SOCIAL_STUDIES;
		}
		if ( state == GameState.RECIPESTEPS )
		{
			data.selectedRecipe = DemoDefs.getRecipeForCountry( data.selectedCountry.name );
			//DemoDefs.DEMOCOUNTRYRECIPES.get( data.selectedCountry.name );
			data.currentCurriculum = Curriculum.MATH_AND_SCIENCE;
		}
	}
	
	private static function updateRecipe( state:GameState ):Void
	{
		if ( state == GameState.FLAGGAME )
		{
			data.selectedRecipe = DemoDefs.getRecipeForCountry( data.selectedCountry.name ); 
		}
	}
	
	// ======================================================
	// Passport mgmt functions
	// ======================================================
	
	private static function unlockStamp( state:GameState ):Void
	{
		if ( currentMode == FlowMode.PILOT )
		{
			if ( state == getStampState() )
			{
				SpeckGlobals.saveProfile.updateStampStatus( data.selectedCountry.name, EARNED);
			}
		}
	}
	
	private static function getStampState():GameState
	{
		var path:Array< GameState > = pathMap.get( currentPath );
		var passportPos:Int = path.lastIndexOf( GameState.PASSPORT );
		return path[ passportPos - 1 ]; // state just before passport in the flow
	}
}