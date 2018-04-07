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
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.loader.ResMan;
import game.layouts.ProgressionLayout;
import game.states.GameStates;
import motion.Actuate;
import motion.easing.Quad;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;

enum CameraMode
{
	PAGE;
	FOLLOW;
}

class ProgressionCam
{
	/**
	 * True if you are on the final page.
	 */
	public var isLastPage(default, null):Bool;
	
	/**
	 * True if you are on the first page.
	 */
	public var isFirstPage(default, null):Bool;
	
	/**
	 * Sets the behavior of the camera.
	 */
	public var mode:CameraMode;	//TODO: currently only paging is supported; support FOLLOW
	
	//the number of pages in the map
	private var m_totalPages:Int;
	//the height of one background image (assumed screen height)
	private var m_screenHeight:Int;
	//the current y-pos the camera is at
	private var m_curY:Int;
	//the current page the camera is at
	private var m_curPage:Int;
	//the sorted object list by page number
	private var m_objPages:Array<Array<DisplayObject>>;
	//temp array to hold initial set of objects prior to their positions being updated
	private var m_tempObjs:Array<DisplayObject>;
	
	/**
	 * Constructor for camera.
	 */
	public function new()
	{
		mode = PAGE;
		m_curPage = 1;
		m_curY = 0;
		m_tempObjs = [];
		m_objPages = [];
		
		doneMoving();
	}
	
	/**
	 * Sets the list of background images that this camera will manage.
	 * Background images are the basis for some property values in this class.
	 * This function will also invoke manage().
	 * @param	bgs
	 */
	public function manageBackgrounds( bgs:Array<Bitmap> ):Void
	{
		m_screenHeight = Std.int( bgs[ 0 ].height );
		m_totalPages = bgs.length;
		
		manage( cast bgs );
	}
	
	/**
	 * Sets the list of objects that this camera will manage.
	 * @param	objs	The list of objects to track.
	 */
	public function manage( objs:Array<DisplayObject> ):Void
	{
		for ( obj in objs )
		{
			m_tempObjs.push( obj );
		}
	}
	
	/**
	 * Updates the pages that all elements belong to based on their current y-coord.
	 */
	public function refreshPages():Void
	{
		m_objPages = [];
		
		for ( i in 0...m_totalPages )
		{
			m_objPages.push( [] );
		}
		
		//sort objects by page number
		for ( obj in m_tempObjs )
		{
			var page:Int = Std.int( obj.y / m_screenHeight );
			m_objPages[ page ].push( obj );
		}
	}
	
	/**
	 * Scrolls up one page.
	 */
	public function pageUp():Void
	{
		--m_curPage;
		
		if ( m_curPage < 1 )
		{
			m_curPage = 1;
			return;
		}
		
		move( m_screenHeight );
	}
	
	/**
	 * Scrolls down one page.
	 */
	public function pageDown():Void
	{
		++m_curPage;
		
		if ( m_curPage > m_totalPages )
		{
			m_curPage = m_totalPages;
			return;
		}
		
		move( -m_screenHeight );
	}
	
	//scrolls the camera to offset location
	private function move( dy:Int ):Void
	{
		showNextPage();
		m_curY += dy;
		
		for ( page in m_objPages )
		{
			for ( obj in page )
			{
				Actuate.tween( obj, 1.0, { y:obj.y + dy } )
					.ease( Quad.easeOut );
			}
		}
		
		Actuate.timer( 1.0 )
			.onComplete( doneMoving );
	}
	
	//snaps the camera to offset location
	private function moveInstant( dy:Int ):Void
	{
		m_curY += dy;
		
		for ( page in m_objPages )
		{
			for ( obj in page )
			{
				obj.y += dy;
			}
		}
		
		doneMoving();
	}
	
	/**
	 * Sets the camera to focus on the specified page.
	 * @param	page	1 is the bottom page.
	 * @param	scroll	Sets whether to scroll or snap.
	 */
	public function setPage( toPage:Int, scroll:Bool = false ):Void
	{
		//if not going anywhere, cancel
		if ( toPage == m_curPage )
		{
			doneMoving();
			return;
		}
		
		//set to toPage
		var deltaPage:Int = m_curPage - toPage;
		m_curPage = toPage;
		
		var dY:Int = deltaPage * m_screenHeight;
		
		if ( scroll )
			move( dY );
		else
			moveInstant( dY );
	}
	
	//triggers when move code is finished.
	private function doneMoving():Void
	{
		isLastPage = m_curPage == 1;
		isFirstPage = m_curPage == m_totalPages;
		
		hidePages();
	}
	
	//shows elements about to enter screen
	private function showNextPage():Void
	{
		var pageIndex:Int = m_curPage - 1;
		
		//make oncoming page visible before we scroll
		for ( obj in m_objPages[ pageIndex ] )
		{
			obj.visible = true;
		}
	}
	
	//hides elements not on current page
	private function hidePages():Void
	{
		var pageIndex:Int = m_curPage - 1;
		
		for ( i in 0...m_totalPages )
		{
			if ( i == pageIndex )
				continue;
			
			for ( obj in m_objPages[ i ] )
			{
				obj.visible = false;
			}
		}
	}
	
	/**
	 * Scrolls to the specified node.
	 * @param	node	The node to focus on.
	 */
	public function setFocus( node:ProgressionNode ):Void
	{
		var page:Int = Std.int( node.worldY / m_screenHeight ) + 1;
		setPage( page, true );
	}
}