//
// Copyright (C) 2018, 1st Playable Productions, LLC. All rights reserved.
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

package com.firstplayable.hxlib.display;
import com.firstplayable.hxlib.loader.ResMan;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

/**
 * Nine Patch Panel, that allows us to have a dynamically sizing panel
 * without having the deal with the side effect of scaling of the children as well.
 */
class NinePatchPanel extends DisplayObjectContainer
{
	/**
	 * The backing image of the panel.
	 */
	public var panelSprite(default, null):DisplayObjectContainer;

	/**
	 * Constructs a panel with the provided backing resource and size.
	 * If no resource was provided, an invisible box will be created
	 * and added to hold the size of the panel.
	 * @param	(optional) resourceName
	 * @param	initialWidth
	 * @param	initialHeight
	 */
	public function new(?resourceName:String, initialWidth:Float, initialHeight:Float) 
	{
		super();
		
		if (resourceName == null)
		{
			panelSprite = createReferenceZone(initialWidth, initialHeight);
		}
		else
		{
			panelSprite = ResMan.instance.getSprite( resourceName );
		}
		
		panelSprite.scaleX = initialWidth / panelSprite.width;
		panelSprite.scaleY = initialHeight / panelSprite.height;
		
		addChild( panelSprite ); 
	}
	
	/**
	 * Makes a display object shape for the specified dimmensions
	 * @param	boundingBoxData
	 * @return
	 */
	private function createReferenceZone(width:Float, height:Float):DisplayObjectContainer
	{	
		var boxObj:Sprite = new Sprite();
		
		boxObj.graphics.beginFill( 0xFF80C0, 0 );
		boxObj.graphics.drawRect( 0, 0, width, height );
		boxObj.graphics.endFill();
		
		boxObj.visible = false;
		
		return boxObj;
	}
	
	public function setPanelSize(width:Float, height:Float):Void
	{
		panelSprite.scaleX = 1.0;
		panelSprite.scaleY = 1.0;
		
		panelSprite.scaleX = width / panelSprite.width;
		panelSprite.scaleY = height / panelSprite.height;
	}
	
}