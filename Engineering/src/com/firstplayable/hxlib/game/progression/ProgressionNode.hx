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
package com.firstplayable.hxlib.game.progression;
import com.firstplayable.hxlib.game.progression.ProgressionNode.NodeStatus;
import haxe.ds.EnumValueMap;
import haxe.ds.StringMap;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

enum NodeStatus
{
	LOCKED;
	NEW;
	PLAYED;
	COMPLETE;
}

enum StarStatus
{
	HIDDEN;
	NO_STARS;
	ONE_STAR;
	TWO_STARS;
	THREE_STARS;
}

class ProgressionNode extends Sprite
{
	private var m_curState:NodeStatus;
	private var m_nodeStates:EnumValueMap<NodeStatus,Bitmap>;
	private var m_nodeStars:Array<Array<Bitmap>>;
	public var worldY:Float;
	
	/**
	 * Constructs a progression node.
	 */
	public function new()
	{
		super();
		
		cacheAsBitmap = true;
	}
	
	/**
	 * Sets the node's visible state.
	 * @param	state	The state name to show. If no state is provided, the node will be hidden.
	 */
	public function setState( ?state:NodeStatus ):Void
	{
		for ( state in m_nodeStates )
		{
			state.visible = false;
		}
		
		if ( state == null ) return;
		var newState:DisplayObject = m_nodeStates.get( state );
		
		if ( newState == null )
		{
			Debug.log( "No state exists with name '" + state + "'." );
			return;
		}
		
		m_curState = state;
		newState.visible = true;
	}
	
	public function setStars( status:StarStatus ):Void
	{
		if ( m_nodeStars == null )
			return;
		
		//TODO: THIS LOGIC NEEDS CLEANIN' -jm
		m_nodeStars[ 0 ][ 0 ].visible = false;
		m_nodeStars[ 0 ][ 1 ].visible = false;
		m_nodeStars[ 1 ][ 0 ].visible = false;
		m_nodeStars[ 1 ][ 1 ].visible = false;
		m_nodeStars[ 2 ][ 0 ].visible = false;
		m_nodeStars[ 2 ][ 1 ].visible = false;
		
		if ( m_curState == LOCKED )
			return;
		
		switch( status )
		{
			case HIDDEN:	//do nothing
			case NO_STARS:
				m_nodeStars[ 0 ][ 1 ].visible = true;
				m_nodeStars[ 1 ][ 1 ].visible = true;
				m_nodeStars[ 2 ][ 1 ].visible = true;
			case ONE_STAR:
				m_nodeStars[ 0 ][ 0 ].visible = true;
				m_nodeStars[ 1 ][ 1 ].visible = true;
				m_nodeStars[ 2 ][ 1 ].visible = true;
			case TWO_STARS:
				m_nodeStars[ 0 ][ 0 ].visible = true;
				m_nodeStars[ 1 ][ 0 ].visible = true;
				m_nodeStars[ 2 ][ 1 ].visible = true;
			case THREE_STARS:
				m_nodeStars[ 0 ][ 0 ].visible = true;
				m_nodeStars[ 1 ][ 0 ].visible = true;
				m_nodeStars[ 2 ][ 0 ].visible = true;
		}
	}
	
	/**
	 * Adds the map states to the node.
	 * @param	stateMap
	 */
	public function attachStates( stateMap:EnumValueMap<NodeStatus,Bitmap> ):Void
	{
		m_nodeStates = stateMap;
		
		for ( state in m_nodeStates )
		{
			state.x = -state.width * 0.5;
			state.y = -state.height * 0.5;
			addChild( state );
		}
	}
	
	/**
	 * Adds the stars to the node.
	 * @param	stateMap	all star images needed by the node
	 */
	public function attachStars( stateMap:Array<Array<Bitmap>> ):Void
	{
		m_nodeStars = stateMap;
		
		for ( stars in m_nodeStars )
		{
			for ( star in stars )
			{
				star.x += -width * 0.5;
				star.y += -height * 0.5;
				addChild( star );
			}
		}
	}
}