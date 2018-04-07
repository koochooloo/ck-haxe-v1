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
import com.firstplayable.hxlib.display.anim.ActuateChain;
import com.firstplayable.hxlib.game.progression.ProgressionNode.NodeStatus;
import haxe.ds.EnumValueMap;
import haxe.ds.StringMap;
import motion.Actuate;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

//TODO: add critical path vs optional nodes
//TODO: update progression cam to figure out num nodes per page
//TODO: update progression cam to allow for FOCUS mode
//TODO: add notion of all nodes complete
//TODO: add node scoring and better unlocking protocol
class ProgressionMap extends Sprite
{
	private var m_backgrounds:Array<Bitmap>;
	private var m_nodes:Array<ProgressionNode>;
	private var m_progCam:ProgressionCam;
	
	private var m_curNode:Int;		//last level selected
	private var m_highestNode:Int;	//highest node reached
	private var m_lastNode:Int;		//last node in map
	
	/**
	 * Constructor
	 */
	public function new()
	{
		super();
		
		m_nodes = [];
		m_backgrounds = [];
		m_curNode = 0;
		m_lastNode = 0;
		m_highestNode = -1;
		
		m_progCam = new ProgressionCam();
	}
	
	/**
	 * Sets the number of nodes available for use.
	 * @param	numNodes
	 */
	public function setSize( numNodes:Int ):Void
	{
		m_lastNode = numNodes - 1;
		
		if ( m_nodes.length < m_lastNode )
		{
			for ( i in m_nodes.length...numNodes )
			{
				var newNode:ProgressionNode = new ProgressionNode();
				newNode.addEventListener( MouseEvent.MOUSE_DOWN, onNodeSelect );
				addChild( newNode );
				m_nodes.push( newNode );
			}
		}
		else if ( m_nodes.length > m_lastNode )
		{
			for ( i in m_lastNode...m_nodes.length )
			{
				removeChild( m_nodes.pop() );
			}
		}
		
		m_progCam.manage( cast m_nodes );
	}
	
	/**
	 * Unlocks the desired number of nodes.
	 * @param	numUnlocks	number of nodes to unlock.
	 */
	public function unlockNodes( numUnlocks:Int ):Void
	{
		m_highestNode = numUnlocks - 1;
		
		for ( i in 0...numUnlocks )
		{
			m_nodes[ i ].setState( PLAYED );
			m_nodes[ i ].mouseEnabled = true;
		}
		
		for ( i in numUnlocks...m_nodes.length )
		{
			m_nodes[ i ].setState( LOCKED );
			m_nodes[ i ].mouseEnabled = false;
		}
	}
	
	/**
	 * Unlocks the next node in the chain.
	 */
	public function unlockNew():Void
	{
		++m_highestNode;
		
		if ( m_highestNode > m_lastNode )
		{
			m_highestNode = m_lastNode;
			return;
		}
		
		//unlock node at m_highestNode
		var nextNode:ProgressionNode = m_nodes[ m_highestNode ];
		nextNode.mouseEnabled = false;
		
		m_progCam.setFocus( nextNode );
		unlockEffect( nextNode );
	}
	
	/**
	 * The effect to carry out for a new node when it is unlocked. Can be overridden and customized.
	 * @param	nextNode	The node that is about to unlock.
	 */
	private function unlockEffect( nextNode:ProgressionNode ):Void
	{
		ActuateChain.create.tween( [ 
			{ target:nextNode, duration:1.0, properties:{ scaleX:0 }, onComplete:function() { nextNode.setState( NEW ); } },
			{ target:nextNode, duration:1.0, properties:{ scaleX:1.0 } } ],
			function() { nextNode.mouseEnabled = true; } );
	}
	
	/**
	 * Callback for clicking on a node
	 * @param	e
	 */
	private function onNodeSelect( e:MouseEvent ):Void
	{
		var selected:ProgressionNode = cast e.currentTarget;
		m_curNode = m_nodes.indexOf( selected );
		Debug.log( "selected node " + m_curNode );
	}
}