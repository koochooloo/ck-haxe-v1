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

package com.firstplayable.hxlib.state;

import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.utils.Utils;
import openfl.events.Event;
// TODO: it would be great to have a single import here
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.ExitRequestType;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.InterruptType;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.MachineProperties;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateId;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateList;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateMap;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateOperationsMap;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateStatusId;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateTransDecisionFunc;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateTransDecisionMap;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.StateTransitionFunc;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.TransitionMap;
import com.firstplayable.hxlib.state.FiniteStateMachineTypes.TransResult;


/**
 * Based on dslib's SimpleStateMachine.
 * 
 * Example usage:
 * 
		// Outside your class definition
 		@:enum
		abstract CoreGameState( StateId )
		{
			var IDLE_STATE					= 0;
			var CARD_ACTION_RESPONSE_STATE	= 1;
			// more states...
		}
		
		// In your class:
		private function transitionDecisionHandler( targetStateId:StateId ):StateId { //do stuff }
		private function executeTransition( targetStateId:StateId ):TransResult { //do stuff }
		
		// In some function in your class:
		var stateTree:StateMap = new StateMap(); 								// (aka: valid transition points)
		var placeholder:StateTransDecisionMap = new StateTransDecisionMap();	// We have no need for custom state decision funcs
		var transMap:TransitionMap = new TransitionMap();						// (aka: Custom default exit point for states)
		var stateOps:StateOperationsMap = new StateOperationsMap();				// (aka: Stores update functions for states)
		
		REG_STATE( IDLE_STATE, stateTree );
			REG_STATE_EXIT_POINT( IDLE_STATE, CARD_ACTION_RESPONSE_STATE, stateTree );
			REG_STATE_DEFAULT_EXIT_AS( IDLE_STATE, CARD_ACTION_RESPONSE_STATE, transMap );
			REG_STATE_OP_FUNC_AS( IDLE_STATE, handleIdleState, stateOps );
		
		REG_STATE( CARD_ACTION_RESPONSE_STATE, stateTree );
			REG_STATE_EXIT_POINT( CARD_ACTION_RESPONSE_STATE, FEEDBACK_STATE, stateTree );
			REG_STATE_EXIT_POINT( CARD_ACTION_RESPONSE_STATE, IDLE_STATE, stateTree );
			REG_STATE_DEFAULT_EXIT_AS( CARD_ACTION_RESPONSE_STATE, FEEDBACK_STATE, transMap );
			REG_STATE_OP_FUNC_AS( CARD_ACTION_RESPONSE_STATE, handleCardActionResponseState, stateOps );
			
		// more state setup macros
		
		m_state = new FiniteStateMachine( stateTree, stateOps, placeholder, transMap, transitionDecisionHandler, executeTransition, cast( IDLE_STATE ) );
		m_state.startMachine();
		m_state.setState( cast( IDLE_STATE ) );
 */
class FiniteStateMachine
{
	public static inline var INVALID_STATE_ID:Int = -1;
	
	public var curStateId( default, null ):StateId;
	public var prevStateId( default, null ):StateId;
	public var name:String = "Unnamed State Machine"; //< DEBUGGING SUPPORT: Used to identify this machine's prints from other machines which may be operating at the same time
	
	private var m_defaultStateId:StateId;
	private var m_props:MachineProperties;
	
	private var m_stateMap:StateMap;
	private var m_stateOpMap:StateOperationsMap;
	private var m_stateTransDecisionMap:StateTransDecisionMap;
	private var m_defaultTransMap:TransitionMap;
	private var m_defaultTransDecisionFunc:StateTransDecisionFunc;
	private var m_transHandlerFunc:StateTransitionFunc;
	
	public function new( stateMap:StateMap, 
						stateOpMap:StateOperationsMap, 
						stateTransDecisionMap:StateTransDecisionMap,
						defaultTransMap:TransitionMap,
						defaultTransDecisionFunc:StateTransDecisionFunc,
						transHandlerFunc:StateTransitionFunc,
						defaultStateId:StateId ) 
	{
		Debug.error_if( ( defaultTransDecisionFunc == null ), "No Default Transition Decision Function was specified!" );
		// TODO: do more of these need validation?
		
		curStateId = INVALID_STATE_ID;
		prevStateId = INVALID_STATE_ID;
		
		m_stateMap = stateMap;
		m_stateOpMap = stateOpMap;
		m_stateTransDecisionMap = stateTransDecisionMap;
		m_defaultTransMap = defaultTransMap;
		
		m_defaultTransDecisionFunc = defaultTransDecisionFunc;
		m_transHandlerFunc = transHandlerFunc;
		
		m_defaultStateId = defaultStateId;
		
		setInterruptType( INTERRUPTS_BLOCKED );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	public function startMachine():Void
	{
		Debug.log( name + " (startMachine) Starting machine." );
		Utils.safeAddListener( Application.app.stage, Event.ENTER_FRAME, onEnterFrame );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	public function stopMachine():Void
	{
		Debug.log( name + " (stopMachine) Stopping machine." );
		Utils.safeRemoveListener( Application.app.stage, Event.ENTER_FRAME, onEnterFrame );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	public function setState( stateID:StateId, ?curStateExitType:ExitRequestType = null ):Bool
	{
		if ( curStateExitType == null ) { curStateExitType == EXIT_IF_INTERRUPTIBLE; }
		
		Debug.log( name + " (setState) Request for: " + curStateId + " to exit to " + stateID );
		
		// Lots of validation
		var isValid:Bool = validateStateToSet( stateID, curStateExitType );
		if ( !isValid )
		{
			// EARLY RETURN
			return false;
		}
		
		// Try to go to the specified state
		var transTargetState:StateId = runStateDecisionFunction( stateID );
		var transitionResult:TransResult = m_transHandlerFunc( transTargetState );
		if ( Debug.warn_if( transitionResult == TRANS_FAILED, "( " + name + " ) " + "Error occurred during transition from " + curStateId + " to " + transTargetState + " w/ Specified TargetState: " + stateID ) )
		{
			//--EARLY EXIT--
			return false;
		}
		
		// Update state ids
		prevStateId = curStateId;
		curStateId = transTargetState;
		Debug.log( name + "(setState) Transitioned from: " + prevStateId + " to " + curStateId );
		
		return (curStateId == stateID);
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	public function isCurStateValid():Bool
	{
		return ( curStateId != INVALID_STATE_ID );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	// TODO: rename so as not to confuse with isCurStateValid ("valid" means two different things in these two functions)
	public function isStateValid( stateID:StateId ):Bool
	{
		return m_stateMap.exists( stateID );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	public function setInterruptType( type:InterruptType ):Void
	{
		if ( type == INTERRUPTS_ALLOWED )
		{
			m_props.set( STATE_INTERRUPTABLE );
		}
		else
		{
			m_props.unset( STATE_INTERRUPTABLE );
		}
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	public function isInterruptible():Bool
	{
		return m_props.has( STATE_INTERRUPTABLE );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	public function exitCurState( ?curStateExitType:ExitRequestType = null ):Bool
	{
		if ( curStateExitType == null )
		{
			curStateExitType = EXIT_IF_INTERRUPTIBLE;
		}
		
		if ( isInterruptible() || (curStateExitType == EXIT_FORCEABLY) )
		{
			var result:TransResult = exitState();
			return ( result == TRANS_SUCCESSFUL );
		}
		
		return false;
	}
	
	
	
	// ===== Private functions =========================================================================================
	
	private function update():Void
	{
		if ( !isCurStateValid() )
		{
			//--EARLY EXIT--
			return;
		}
		
		var curStatusId:StateStatusId = m_stateOpMap[ curStateId ]();
		if ( curStatusId == SS_LEAVE )
		{
			exitState();
		}
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	/**
	 * Indicates if the spec'd state has the required StateOpFunc associated with it.
	 */
	private function isStateOpVerified( stateId:StateId ):Bool
	{
		if ( !isStateValid( stateId ) )
		{
			return false;
		}
		
		return m_stateOpMap.exists( stateId );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	private function runStateDecisionFunction( targetState:StateId ):StateId
	{
		var decisionState:StateId = curStateId;
		if ( !isCurStateValid() ) { decisionState = targetState; }
		
		var transDecisionFunc:StateTransDecisionFunc = ( m_stateTransDecisionMap.exists( decisionState ) )
										? m_stateTransDecisionMap.get( decisionState )
										: m_defaultTransDecisionFunc;
		
		return transDecisionFunc( targetState );
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	private function exitState():TransResult
	{
		if ( Debug.warn_if( !isCurStateValid(), "( " + name + " ) " + " Can't exit a state because CurState hasn't been set." ) )
		{
			//--EARLY EXIT--
			return TRANS_FAILED;
		}
		
		var result:TransResult = TRANS_SUCCESSFUL;
		
		// Fallback to global default state if the target doesn't have one defined.
		var targetDefaultExitStateId:StateId = m_defaultTransMap.exists( curStateId ) ? m_defaultTransMap.get( curStateId ) : m_defaultStateId;
		var isTargetStateVerified:Bool = isStateOpVerified( targetDefaultExitStateId );
		if ( !isTargetStateVerified )
		{
			result = TRANS_TO_MACHINE_DEFAULT;
			targetDefaultExitStateId = m_defaultStateId;
		}
		
		var nextStateId:StateId = runStateDecisionFunction( targetDefaultExitStateId );
		var isNextStateVerified:Bool = ( (nextStateId == targetDefaultExitStateId) || isStateOpVerified( nextStateId ) );
		if ( !isNextStateVerified )
		{
			result = TRANS_TO_MACHINE_DEFAULT;
			nextStateId = m_defaultStateId;
		}
		
		var transitionStatus:TransResult = m_transHandlerFunc( nextStateId );
		
		//If we go to the original targeted state or we fail going to the next state
		//note that as the return value; otherwise, preserve the fact that the machine's
		//default was summoned to be used.
		if ( result != TRANS_TO_MACHINE_DEFAULT || transitionStatus == TRANS_FAILED )
		{
			result = transitionStatus;
		}
		
		prevStateId = curStateId;
		curStateId = nextStateId;
		
		Debug.log( name+  "(exitState) Exiting State: " + prevStateId + " Transitioning from: " + prevStateId + " to " + curStateId);
		
		return result;
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	/**
	 * Helper for setState()
	 */
	private function validateStateToSet( stateID:StateId, curStateExitType:ExitRequestType ):Bool
	{
		if ( Debug.warn_if( !isStateValid( stateID ), "( " + name + " ) " + stateID + " isn't known check StateMachine set up." )
			|| Debug.warn_if( !isStateOpVerified( stateID ), "( " + name + " ) " + "No StateOpFunc is defined for State: " + stateID + "!" ) )
		{
			//--EARLY EXIT--
			return false;
		}
		
		if ( isCurStateValid() )
		{
			// If we're not explicitly forcing a change, then only allow when in an interruptible state.
			if ( (curStateExitType == EXIT_IF_INTERRUPTIBLE) && !isInterruptible() )
			{
				//--EARLY EXIT--
				return false;
			}
			
			// Paranoia? I don't think it's possible to trigger this error conditoin.
			if ( Debug.warn_if( !m_stateMap.exists( curStateId ), "( " + name + " ) " + "Specified State: " + stateID + " isn't a known state." ) )
			{
				//--EARLY EXIT--
				return false;
			}
			
			// Enforce the policy that we ONLY allow transitioning to predefined states.
			var viableStates:StateList = m_stateMap.get( curStateId );
			if ( Debug.warn_if( (viableStates.indexOf( stateID ) == -1), "( " + name + " ) " + stateID + " isn't a valid destination state of CurState: " + curStateId ) )
			{
				//--EARLY EXIT--
				return false;
			}
		}
		
		return true;
	}
	
	//-------------------------------------------------------------------------------------------------------------------
	
	private function onEnterFrame( e:Event ):Void
	{
		update();
	}
}