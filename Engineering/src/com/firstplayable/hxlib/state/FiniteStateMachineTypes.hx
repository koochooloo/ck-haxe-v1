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

import haxe.EnumFlags;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;


typedef StateId = Int;
typedef MachineProperties = EnumFlags< MachinePropBitId >;

typedef StateList = Array< StateId >;
typedef StateMap = Map< StateId, StateList >;		//!< Maps current states to viable next states.
typedef TransitionMap = Map< StateId, StateId >;	//!< Maps states to default next state.
typedef StateOperationsMap = Map< StateId, StateOperationFunc >;
typedef StateTransDecisionMap = Map< StateId, StateTransDecisionFunc >;


class FiniteStateMachineTypes
{
	/**
	 * Comparison function that checks whether a value is equal to a given StateId. 
	 * This is needed because projects typically use an abstract StateId (eg abstract CoreGameState( StateId ))
	 * which cannot be directly compared to a value of type StateId. 
	 */
	public static function equals( stateID:StateId, id:Dynamic ):Bool
	{
		return stateID == cast( id );
	}
}

// -----------------------------
// ----- Function typedefs -----
// -----------------------------


//! @note:  StateMachine is expected to have N of these where N is the equivalent to the number of states.
typedef StateOperationFunc = Void -> StateStatusId;


//! @param StateId:  The target state which it's desired to transition to.
//!					Note: will only transition there if the user defined checks within the decision function evaluate to true
//! @return StateId: The state which it's been determined that the machine should go to given the 
//!					the results of the user defined checks within the decision function
//! @return INVALID_STATE_ID in the event of an irrecoverable error
typedef StateTransDecisionFunc = StateId -> StateId;


//! Handles any prep work for transition from the current state to the spec'd target StateId
//! @param StateId:  The target state which is the result of calling the StateTransDecisionFunc
//!                  that the machine is to transition to
//! @return TransResult:  Indicates how the transition went see TransResult Enumeration
typedef StateTransitionFunc = StateId -> TransResult;


// -----------------
// ----- Enums -----
// -----------------
// TODO: make these all abstract enums? that will allow for default values

enum StateStatusId
{
	SS_CONTINUE;			//!< Indicates the the current state is still in the midst of its process
	SS_LEAVE;				//!< Indicates that the current state is done, and it's time to go to the next in the tree
}

enum InterruptType
{
	INTERRUPTS_BLOCKED;		//!< The current state of the machine must finish its operation and exit to its default transition
	INTERRUPTS_ALLOWED;		//!< The current state of the machine can be re-directed or pre-empted to go its known transition point without completing its processing
}

enum ExitRequestType
{
	EXIT_IF_INTERRUPTIBLE;	//!< Exit only if state is in an amenable state or interruptible
	EXIT_FORCEABLY;			//!< Exit regardless of the status of the current state
}

enum TransResult
{
	TRANS_SUCCESSFUL;
	TRANS_TO_MACHINE_DEFAULT;
	TRANS_FAILED;
}

enum MachinePropBitId
{
	//! The current state of the machine can be re-directed or pre-empted to go to its known
	//! transition point without completing its processing
	//! @note: OFF BY DEFAULT
	STATE_INTERRUPTABLE;
}



// ------------------
// ----- MACROS -----
// ------------------


class FiniteStateMachineMacros
{
	/**
	 * Registers a valid state for this machine. Call this before the other macros.
	 * 
	 * @param	stateID (StateId) - the ID to register
	 * @param	stateMap  (StateMap) - the map to register it in
	 * 
	 * @see FiniteStateMachine class docs for usage example
	 */
	macro public static function REG_STATE( stateID:Expr, stateMap:Expr ):Expr
	{
		return macro
			{
				$stateMap[ cast( $stateID ) ] = [];
			}
	}
	
	/**
	 * Registers a valid exit point for a state. Must call REG_STATE first.
	 * 
	 * @param	exitFromStateId (StateId)
	 * @param	exitToStateId (StateId)
	 * @param	stateMap (StateMap)
	 * 
	 * @see FiniteStateMachine class docs for usage example
	 */
	macro public static function REG_STATE_EXIT_POINT( exitFromStateId:Expr, exitToStateId:Expr, stateMap:Expr ):Expr
	{
		return macro
			{
				$stateMap[ cast( $exitFromStateId ) ].push( cast( $exitToStateId ) );
			}
	}
	
	/**
	 * Registers a custom transition decision function.
	 * 
	 * @param	stateID (StateId)
	 * @param	customDecisionHandler (StateTransDecisionFunc)
	 * @param	decisionMap (StateTransDecisionMap)
	 * 
	 * @see StateTransDecisionFunc docs
	 * @see FiniteStateMachine class docs for usage example
	 */
	macro public static function REG_STATE_CUSTOM_TRANS_DECISION_FUNC( stateID:Expr, customDecisionHandler:Expr, decisionMap:Expr ):Expr
	{
		return macro
			{
				$decisionMap[ cast( $stateID ) ] = $customDecisionHandler;
			}
	}
	
	/**
	 * Registers the default exit point for a given state.
	 * 
	 * @param	exitFromStateId (StateId)
	 * @param	defaultExitToStateId (StateId)
	 * @param	transMap (TransitionMap)
	 * 
	 * @see FiniteStateMachine class docs for usage example
	 */
	macro public static function REG_STATE_DEFAULT_EXIT_AS( exitFromStateId:Expr, defaultExitToStateId:Expr, transMap:Expr ):Expr
	{
		return macro
			{
				$transMap[ cast( $exitFromStateId ) ] = cast( $defaultExitToStateId );
			}
	}
	
	/**
	 * Registers the function that is called each update() for this state.
	 * 
	 * @param	stateID (StateId)
	 * @param	stateOpFunction (StateOperationFunc)
	 * @param	opsMap (StateOperationsMap)
	 * 
	 * @see StateOperationFunc docs
	 * @see FiniteStateMachine class docs for usage example
	 */
	macro public static function REG_STATE_OP_FUNC_AS( stateID:Expr, stateOpFunction:Expr, opsMap:Expr ):Expr
	{
		return macro
			{
				$opsMap[ cast( $stateID ) ] = $stateOpFunction;
			}
	}
}
