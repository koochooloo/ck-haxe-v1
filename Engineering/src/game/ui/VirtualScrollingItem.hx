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

package game.ui;
import away3d.library.assets.BitmapDataAsset;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import game.ui.VirtualScrollingMenu;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 *  A container for display object groups used in scrolling lists.
 *  Manages object positioning and creation. 
 */
class VirtualScrollingItem extends DisplayObjectContainer
{
	private var refGroup:DisplayObjectContainer;
	private var group:DisplayObjectContainer;
	public var  debugName:Int;
	public var isUpdated(default, null):Bool = false;
	
	// Display objects (update these for individual-list functionality. 
	//		See also: ScrollingData class in VirtualScrollingItem.hx
	private var m_image:OPSprite;
	private var m_buttons:Array< GraphicButton >; // List should be in display order, since it is populated from __children; reverse to hit front layered buttons first?
	private var m_label:TextField;

	
	// Button overstate scaling
	private static inline var BUTTON_OVERSTATE_SCALE:Float = 1.1; 
	private var m_baseScaleX:Float;
	private var m_baseScaleY:Float;
	
	public function new( displayGroup:DisplayObjectContainer, count:Int ):Void
	{
		super();
		
		// ---------------------------------------------------
		// Init member vars
		// ---------------------------------------------------
		m_buttons = new Array();
		refGroup = displayGroup;
		debugName = count;
		
		// ---------------------------------------------------
		// Create new display object group from ref
		// ---------------------------------------------------
		copyDisplayGroup( refGroup, count );
	}
	
	/**
	 * Instantiate a new group of display objects, copied from ref
	 * */
	private function copyDisplayGroup( ref:DisplayObjectContainer, count ):Void
	{
		group = createDOCFromRef( ref );
		if ( ref.__children.length < 1 )
		{
			return;
		}
		
		for ( child in ref.__children )
		{	
			if ( Std.is( child, GraphicButton ) )
			{
				createButtonFromRef( cast (child, GraphicButton) );
			}
			else if ( Std.is( child, TextField ) )
			{
				m_label = createTextFromRef( cast (child, TextField), count );			}
			else if ( Std.is( child, OPSprite ) )
			{
				m_image = createSpriteFromRef( cast (child, OPSprite) );
			}
		}
	}
	
	/**
	 * Add a sprite mask area so display objects are hidden when moved out of scroll bounds
	 * */
	public function addMask( maskArea:Sprite )
	{
		//Create a clone of the mouse field.
		var maskBounds:Rectangle = maskArea.getBounds(maskArea.parent);
		
		for (i in 0...group.numChildren)
		{
			var nextChild:DisplayObject = group.getChildAt(i);
			var scrollMask:Shape = new Shape();
			group.parent.addChild(scrollMask);
			scrollMask.graphics.beginFill(0xFF00FF, 1);
			scrollMask.graphics.drawRect( maskBounds.x, maskBounds.y, maskBounds.width, maskBounds.height);
			scrollMask.graphics.endFill();
			nextChild.mask = scrollMask;
		}
	}
	
	// ========================================
	// Data management
	// ========================================
	public function updateData( data:ScrollingData )
	{
		switch ( data.imgSrc )
		{
			case Some( bitmap ): setImage( bitmap );
			case None: //
		}
		switch ( data.label )
		{
			case Some( text ):setText( text, m_label );
			case None: //
		}
		switch ( data.primaryButtonSrc )
		{
			case Some( bitmap ): setButton( bitmap, m_buttons[0] );
			case None: //
		}
		switch ( data.secondaryButtonSrc )
		{
			case Some( bitmap ): setButton( bitmap, m_buttons[1] );
			case None: //
		}
		
		m_baseScaleX = group.scaleX;
		m_baseScaleY = group.scaleY;
		isUpdated = true;
	}
	
	/**
	 * Changes an image object in display list. 
	 * Assumes one image in display list
	 * Naiive - TODO database integration
	 */
	private function setImage( bitmap:Bitmap ):Void
	{
		m_image.changeImage( bitmap );
		m_image.visible = true;
	}
	
	/**
	 * Changes a text object in the display list.
	 * Assumes one image in display list
	 * Naiive - TODO database integration
	 */
	private function setText( text:String, label:TextField ):Void
	{
		var refWidth = label.width;
		var refHeight = label.height;
		
		label.text = text;
		
		if ( label.autoSize == TextFieldAutoSize.NONE )
		{
			label.width = refWidth;
			label.height = refHeight;
		}
		
	}
	
	private function setButton( bitmap:Bitmap, button:GraphicButton ):Void
	{
		var refWidth:Float= button.width;
		var refHeight:Float = button.height;
		button.changeImage( bitmap );
		button.width = refWidth;
		button.height = refHeight;
		
		// Reset base scale in case it adjusted with the new image
		m_baseScaleX = button.scaleX;
		m_baseScaleY = button.scaleY;
		
		// Set button's name to label, if applicable. 
		// 		Some menus use button name to determine selected recipes, ingredients, and countries
		var buttonName:String = m_label.text.split( "-" )[0]; // Removes country "coming soon" tag - TEMP
		button.name = m_label.text;
	}
	
	// ========================================
	// Scrolling functionality
	// ========================================
	
	/**
	 * Addtive - Move object group incrementally some distance in some direction
	 * */
	public function incrementPosition( distance:Float, orientation:Orientation ):Void
	{
		switch( orientation )
		{
			case Orientation.HORIZONTAL:	group.x += distance;
			case Orientation.VERTICAL:		group.y += distance;
		}
	}
	
	/**
	 * Set - Object group jumps some distance in some direction
	 * */
	public function setPosition( pos:Float, orientation:Orientation ):Void
	{
		switch( orientation )
		{
			case Orientation.HORIZONTAL:	group.x = pos;
			case Orientation.VERTICAL:		group.y = pos;
		}
	}
	
	public function setCoordinates( posX:Float, posY:Float )
	{
		group.x = posX;
		group.y = posY;		
	}
	
	/**
	 *  Loop through to find if param x/y pos is contained within any button sprites.
	 *  Call button's onHit if so, and return true.
	 */
	public function tap( posX:Float, posY:Float  ):Bool
	{
		for ( button in m_buttons )
		{
			if ( pointInObject( posX, posY, button ) )
			{
				button.onHit( button );
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Tests if given coordinates are located within the object's bounds.
	 * Assumes top-left corner anchoring.
	 */
	private function pointInObject( posX:Float, posY:Float, obj:DisplayObject ):Bool
	{
		var objMinX:Float = group.x;
		var objMinY:Float = group.y;
		var objMaxX:Float = objMinX + obj.width;
		var objMaxY:Float = objMinY + obj.height;
		
		if ( (objMinX <= posX) && (objMaxX >= posX) && (posY >= objMinY ) && ( posY <= objMaxY ) )
		{
			return true;
		}
		
		return false;
	}
	
	/**
	 * Simulate overstate during MOUSE_OVER by scaling up by BUTTON_OVERSTATE_SCALE, and 
	 *  back to scale 1 otherwise.
	 */
	public function handleButtonOverState( posX:Float, posY:Float ):Void
	{
		
		for ( button in m_buttons )
		{
			var scaledUp:Bool = ( group.scaleX > m_baseScaleX && group.scaleY > m_baseScaleY );
			var scaledDown:Bool = ( group.scaleX <= m_baseScaleX && group.scaleY <= m_baseScaleY );
			
			if ( !pointInObject( posX, posY, button ) && scaledUp ) 
			{
				group.scaleX /= BUTTON_OVERSTATE_SCALE;
				group.scaleY /= BUTTON_OVERSTATE_SCALE;	
			}
			else if ( pointInObject( posX, posY, button ) && scaledDown )
			{
				group.scaleX *= BUTTON_OVERSTATE_SCALE;
				group.scaleY *= BUTTON_OVERSTATE_SCALE;
			}
		}
	}
	
	/**
	 *  Returns x or y pos of the group depending on orientation
	 */
	public function pos( orientation:Orientation ):Float
	{
		switch( orientation )
		{
			case Orientation.HORIZONTAL:	return group.x;
			case Orientation.VERTICAL:		return group.y;
		}
	}
	
	public function posX():Float
	{
		return group.x;
	}
	
	public function posY():Float
	{
		return group.y; 
	}
	
	public function clear():Void
	{
		m_buttons = [];
		m_image = null;
		m_label = null;
		isUpdated = false;
		
		if ( group.parent != null ) // If called on non-updated items, may be parentless
		{
			group.parent.removeChild( group );
		}
	}
	
	// ========================================
	// Object creation
	// ========================================
	
	/**
	 * Sets pos, scale, dimensions, visibility, state sprites, cursor, rotation
	 */
	private function createButtonFromRef( ref:GraphicButton ):GraphicButton
	{	
		var newBtn:GraphicButton = new GraphicButton( ref.upState, ref.downState, ref.overState,
													  ref.disabledState, ref.label, ref.onHit );
		newBtn.x = ref.x;
		newBtn.y = ref.y;
		newBtn.scaleX = ref.scaleX;
		newBtn.scaleY = ref.scaleY;
		newBtn.width = ref.width;
		newBtn.height = ref.height;
		newBtn.visible = ref.visible;
		newBtn.alpha = ref.alpha;
		newBtn.cursor = ref.cursor;
		newBtn.rotation = ref.rotation;
		newBtn.name = ref.name;

		m_buttons.push( newBtn );
		group.addChild( newBtn );
	
		return newBtn;
	}
	
	/**
	 * Sets text, textformat, wordwrap, visibility, rotation, position, autosize, width/height
	 */
	private function createTextFromRef( ref:TextField, count:Int ):TextField
	{
		var newTxt:TextField = new TextField();
		newTxt.text = ref.text;
		newTxt.setTextFormat( ref.getTextFormat() );
		newTxt.wordWrap = ref.wordWrap;
		newTxt.alpha = ref.alpha;
		newTxt.visible = ref.visible;
		newTxt.rotation = ref.rotation;
		newTxt.name = ref.name;
		newTxt.x = ref.x;
		newTxt.y = ref.y;
		newTxt.autoSize = ref.autoSize;
		newTxt.width = ref.width;
		newTxt.height = ref.height;
		m_label = newTxt;
		group.addChild( newTxt );
		
		return newTxt;
	}
	
	/**
	 * Sets bitmap, bounds, position, visibility, rotation
	 */
	private function createSpriteFromRef( ref:OPSprite ):OPSprite
	{
		var newSprite:OPSprite = new OPSprite();
		newSprite.bitmapData = ref.getBitmapData();

		newSprite.width = ref.width;
		newSprite.height = ref.height;
		newSprite.x = ref.x;
		newSprite.y = ref.y;
		newSprite.visible = ref.visible;
		newSprite.alpha = ref.alpha;
		newSprite.rotation = ref.rotation;
		newSprite.name = ref.name + debugName;
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
		group.addChildAt( newSprite, group.numChildren );
		
		return newSprite;
	}
	
	private function createDOCFromRef( ref:DisplayObjectContainer ):DisplayObjectContainer
	{
	   var newDOC:DisplayObjectContainer = new DisplayObjectContainer();
	   
	   newDOC.x = ref.x;
	   newDOC.y = ref.y;
	   
	   ref.parent.addChild( newDOC );
	 
	   return newDOC;
	}
	
	public function print():Void
	{
		trace( "Group: " + debugName );
		trace( "Position: (" + group.x + ", " + group.y + ")" );
		trace( "Dimensions: " + group.width + " " + group.height );
		trace( "visible: " + group.visible );
		trace( "alpha: " + group.alpha );
		trace( "group parent: " + group.parent );
		trace( "mask: " + group.mask );
		for ( child in group.__children )
		{
			trace( "\t" + child );
			trace( "\t\t Position: (" + child.x + ", " + child.y + ")" );
			trace( "\t\t Dimensions: " + child.width + " " + child.height );
			trace( "\t\t visible: " + child.visible );
			trace( "\t\t alpha: " + child.alpha );
			
			if ( Std.is( child, OPSprite ) && !Std.is( child, GraphicButton ) )
			{
				var img:OPSprite = cast child;
				trace( "\t\t bitmap:" + img.bitmapData );
				trace( "\t\t bitmap:" + img.getBitmap().name );
				trace( "\t\t sprite mask: " + img.mask );
				
			}
		}
	}
	
	
}