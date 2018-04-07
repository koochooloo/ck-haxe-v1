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

package game;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.anim.SpritesheetAnim;
import com.firstplayable.hxlib.events.AnimEvent;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;
import spritesheet.Spritesheet;

/**
 * Callback Ids that correspond to functions declared at bottom of file.
 * Are called when specified animation stages are completed.
 */
typedef StageCompleteCallback = StateAnimSprite -> Array<Dynamic> -> Void;

/**
 * Defintion of a state stage.
 * Every state is comprised of 1 or more stages which will be played
 * through in order as each animation completes.
 * animationName: Animation to play for this given state stage
 * soundName: optional sound to play when this stage is entered.
 * soundLoop: whether the sound should continue to play as long as we're in this stage.
 * onComplete: function to call when this stage is complete.
 * onCompleteArgs: args to pass to onComplete
 */
typedef StateStageDefinition = {animationName:String,
	soundName:String, soundLoop:Bool,
	onComplete:StageCompleteCallback, onCompleteArgs:Array<Dynamic>
};

typedef StateDefinition = Array<StateStageDefinition>;

typedef StateMap = Map<String, StateDefinition>;

/**
 * Owns a SpritesheetAnim, and lets you define States, with various stages,
 * and handle automatically playing the animation for each state-stage,
 * progressing through the states/stages, optionally playing SFX,
 * and optionally calling a callback when the final stage of a state
 * completes.
 */
class StateAnimSprite
{
	/**
	 * Static members for defining the state maps for various object types.
	 */
	private static var ms_stateMaps:Map<String, StateMap> = new Map<String, StateMap>();
	
	/**
	 * Adds a state map to ms_stateMaps with the given name.
	 * @param	name
	 */
	public static function declareStateMap(name:String):Void
	{
		Debug.warn_if(ms_stateMaps.exists(name), "Already have a state map called: " + name + ", overwriting");
		ms_stateMaps[name] = new StateMap();
	}
	
	/**
	 * Adds a state with the provided name to the requested state map.
	 * @param	mapName
	 * @param	stateName
	 */
	public static function declareState(mapName:String, stateName:String):Void
	{
		if (!ms_stateMaps.exists(mapName))
		{
			Debug.warn("No map exists with the given name: " + mapName);
			return;
		}
		
		var stateMap:StateMap = ms_stateMaps[mapName];
		
		Debug.warn_if(stateMap.exists(stateName), "Already have a state called: " + stateMap + ", overwriting");
		stateMap[stateName] = new StateDefinition();
	}
	
	/**
	 * Adds a new stage to the requested state within the specific state map name
	 * @param	mapName
	 * @param	stateName
	 * @param	animName	Animation to play on the managed sprite for this stage.
	 * @param	sName		SFX to play when set to this stage.
	 * @param	sLoops		Whether to loop the SFX as long as we're in this stage.
	 * @param	callback	Callback that triggers when this stage's animation completes.
	 * @param	args		Arguments to pass to callback.
	 */
	public static function addStage(mapName:String, stateName:String, 
		animName:String, ?sName:String, ?sLoops:Bool, 
		?callback:StageCompleteCallback, ?args:Array<Dynamic>)
	{
		if (!ms_stateMaps.exists(mapName))
		{
			Debug.warn("No map exists with the given name: " + mapName);
			return;
		}
		var stateMap:StateMap = ms_stateMaps[mapName];
		
		if(!stateMap.exists(stateName))
		{
			Debug.warn("No state exists with name: " + stateName);
			return;
		}
		var state:StateDefinition = stateMap[stateName];
		
		var sn:String = "";
		if (sName != null)
		{
			sn = sName;
		}
		
		var sl:Bool = false;
		if (sLoops != null)
		{
			sl = sLoops;
		}
		
		var newStage:StateStageDefinition = {animationName:animName,
		soundName:sn, soundLoop:sl, onComplete:callback, onCompleteArgs:args};
		
		state.push(newStage);
	}
	
	private static var UNSET_STATE:String = "__unset";
	
	/**
	 * Definitions for specific instances of StateAnimSprite
	 */
	private var m_sprite:SpritesheetAnim;
	public var managedSprite(get, null):SpritesheetAnim;
	public function get_managedSprite():SpritesheetAnim
	{
		return m_sprite;
	}
	
	private var m_states:StateMap;
	
	private var m_curState:String;
	public var state(get, set):String;
	
	private var m_curStage:Int;
	
	private var m_completedStage:Bool;
	
	public static var numSprites:Int;

	public function new(sprite:SpritesheetAnim, stateMapName:String) 
	{
		++numSprites;
		
		Debug.warn_if(sprite == null, "Managed sprite being set to null!");
		m_sprite = sprite;
		
		if (ms_stateMaps.exists(stateMapName))
		{
			m_states = ms_stateMaps[stateMapName];
		}
		else
		{
			var currentStates:String = "Existing maps: ";
			for (map in ms_stateMaps.keys())
			{
				currentStates += ", " + map;
			}
			
			Debug.warn("No state map exists with name: " + stateMapName + "\n" + currentStates);
			m_states = null;
		}
	
		initInstanceVars();
	}
	
	private function initInstanceVars():Void
	{
		m_curState = UNSET_STATE;
		m_curStage = 0;
		m_completedStage = false;
	}
	
	/**
	 * Call to signal this to stop managing the provided sprite
	 */
	public function release():Void
	{
		if (m_sprite != null)
		{
			if (m_sprite.hasEventListener(AnimEvent.COMPLETE))
			{
				m_sprite.removeEventListener(AnimEvent.COMPLETE, onStageComplete);
			}
		}
		
		initInstanceVars();
		
		m_sprite = null;
	}
	
	/**
	 * Sets the managed sprite to the provided state
	 * @param	state	Name of state to set to.
	 */
	public function set_state(newState:String):String
	{
		if (m_sprite == null || m_states == null)
		{
			return m_curState;
		}
		
		if (!m_states.exists(newState))
		{
			Debug.warn("State doesn't exist with name: " + newState);
			return m_curState;
		}
		
		if (m_states[newState].length == 0)
		{
			Debug.warn("state " + newState + " has no stage definitions!");
			return m_curState;
		}
		
		//trace("Enter state: " + newState);
	
		if (m_curState != UNSET_STATE)
		{
			leaveStage();
		}
		
		m_curState = newState;
		m_curStage = 0;
		
		enterStage();
		
		return m_curState;
	}
	
	/**
	 * Gets the current state
	 * @return
	 */
	public function get_state():String
	{
		return m_curState;
	}
	
	/**
	 * Gets the stage definition for the current state + stage
	 * @return
	 */
	inline private function getCurStage():StateStageDefinition
	{
		if (m_curState != UNSET_STATE)
		{
			var curState:StateDefinition = m_states[m_curState];	
			return curState[m_curStage];
		}
		else
		{
			return null;
		}
	}
	
	/**
	 * Handles functionality for entering a stage
	 */
	private function enterStage():Void
	{
		m_completedStage = false;
		
		if (m_sprite != null)
		{
			m_sprite.addEventListener(AnimEvent.COMPLETE, onStageComplete);
			playAnim();
			playSfx();
		}
	}
	
	/**
	 * Handles functionality for leaving a stage
	 */
	private function leaveStage():Void
	{
		if (m_sprite != null)
		{
			//Clean up the listener for the previous state.
			if (m_sprite.hasEventListener(AnimEvent.COMPLETE))
			{
				m_sprite.removeEventListener(AnimEvent.COMPLETE, onStageComplete);
			}
		}
		
		//Stop SFX from the previous state
		var curStage:StateStageDefinition = getCurStage();
		if (curStage != null && WebAudio.instance.isSoundPlaying(getCurStage().soundName))
		{
			//TODO: need way to interrupt sfx.
		}
	}
	
	/**
	 * Plays the animation for current State - Stage
	 */
	inline private function playAnim():Void
	{	
		var curStage:StateStageDefinition = getCurStage();
		if (curStage != null)
		{
			var animToPlay:String = curStage.animationName;
			m_sprite.gotoAndPlay(animToPlay);
		}
		else
		{
			Debug.warn("no stage for: " + m_curState + ", " + m_curStage);
		}
	}
	
	/**
	 * Plays the sfx for current State - Stage
	 */
	inline private function playSfx():Void
	{
		var curStage:StateStageDefinition = getCurStage();
		if (curStage != null )
		{
			var soundToPlay:String = curStage.soundName;
			if (soundToPlay != "")
			{
				var loopSound:Bool = curStage.soundLoop;
				if (loopSound)
				{
					WebAudio.instance.play(soundToPlay, onSFXFinish);
				}
				else
				{
					WebAudio.instance.play(soundToPlay);
				}
			}
		}
	}
	
	/**
	 * Callback for completion of SFX: plays the sfx again if set to loop
	 */
	private function onSFXFinish():Void
	{
		//If the animation has been stopped we don't want to keep playing the sfx.
		if (m_sprite!= null && m_sprite.isPlaying)
		{
			var curStage:StateStageDefinition = getCurStage();
			if (curStage != null)
			{
				if(curStage.soundLoop)
				{
					playSfx();
				}
			}
		}
	}
	
	/**
	 * Callback for completion of animation for a stage.
	 * Handles progression to next stage, and optional specified callback
	 * @param	e
	 */
	private function onStageComplete(e:AnimEvent):Void
	{
		if (!m_completedStage)
		{
			var curStage:StateStageDefinition = getCurStage();
			if (curStage != null)
			{
				var cb:StageCompleteCallback = curStage.onComplete;
			
				if (m_curStage < m_states[m_curState].length - 1)
				{
					leaveStage();
					++m_curStage;
					enterStage();
				}
				else
				{
					m_completedStage = true;
				}
				
				if (cb != null)
				{
					var args:Array<Dynamic> = curStage.onCompleteArgs;
					cb(this, args);
				}
			}
		}
	}
	
	//====================================================================
	// Common Callbacks
	//====================================================================
	
	/**
	 * Goes to the provided state.
	 * state	First element is the requested state.
	 */
	public static function goToState(sprite:StateAnimSprite, newState:Array<Dynamic>):Void
	{
		if (newState == null || newState.length == 0)
		{
			Debug.warn("Improper args, expects: [String]");
		}
		
		var nextState:String = newState[0];
		sprite.state = nextState;
	}
	
	/**
	 * Restarts from the first stage in the current state.
	 */
	public static function repeat(sprite:StateAnimSprite, unused:Array<Dynamic>):Void
	{
		sprite.leaveStage();
		sprite.m_curStage = 0;
		sprite.enterStage();
	}
	
	//====================================================================
	// Utility Functions
	//====================================================================
	
	public static function createSpritesheetAnim(resource:String):SpritesheetAnim
	{
		//trace("create spritesheet for: " + resource);
		var sheetName:String = The.resourceMap.getSheetPath( resource );
		if ( sheetName != The.resourceMap.INVALID )
		{
			var animName:String = resource;
			
			// don't return a cached version, or things may fail to appear // <-- lies!  only for paist
			var sheet:Spritesheet = ResMan.instance.getSpritesheet( sheetName, true ); // true to use cache and not reload spritesheet each time
			
			var anim:SpritesheetAnim = new SpritesheetAnim( sheet );
			
			anim.name = resource;
			
			// go to the animation
			anim.gotoAndPlay( animName );
			
			//trace("created spritesheet for: " + resource);
			//trace("========================");
			return anim;
		}
		return null;
	}
	
}