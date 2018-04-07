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

package com.firstplayable.hxlib.utils.json;

import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.display.GenericMenu;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.utils.json.JsonUtils.*;
import haxe.Json;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.geom.Point;

using com.firstplayable.hxlib.StdX;
using Std;

/**
 * Used by JsonObjectFactory to populate a GenericMenu based on some JSON data created in Paist
 */
class JsonMenuPlugIn implements IJsonBasePlugIn
{
	public static var OBJECT_TYPES:Array<String> = [
		"spriteObject",
		"button",
		"label",
		"panel",
		"borderPanel",
		"ninePatchPanel"
	];
	
	private static inline var MAX_OPACITY:Int = 31;
	
    // contains the functions that construct the objects and set their type-specifc props
    private var m_makerDir:JsonMenuMakerDirectory;    
    
    private var m_jsonFileName:String;
    private var m_rMenu:GenericMenu;
    
    // Buckets to help us set the priority of objects;
    // objects are added to the menu in order of priority once all have been constructed
    private var m_buckets:ObjectMap<DisplayObjectContainer,Array<Array<DisplayObject>>>;
	
	private var m_objsToReposition:ObjectMap<DisplayObject,Dynamic>;

    public function new( jsonFileName:String, rMenu:GenericMenu ) 
    {
        m_makerDir = new JsonMenuMakerDirectory();
        m_jsonFileName = jsonFileName;
        m_rMenu = rMenu;
        m_buckets = new ObjectMap();
    }
    
    //-------------------------------------------------------------------------------------
    
    /**
     * Parse the JSON file and start creating objects, then add them to the menu
     * @return true, if successful (can't currently fail)
     */
    public function beginPopulation():Bool
    {
        var json:Dynamic = ResMan.instance.getJson( m_jsonFileName );
		
        var topMenuVal:Dynamic = Reflect.getProperty( json, "topMenu" );
        
        var menuAsDoc:DisplayObjectContainer = m_rMenu.as( DisplayObjectContainer );
        
		for (objectType in OBJECT_TYPES)
		{
			startProduction( topMenuVal, objectType, menuAsDoc );
		}
        
        addObjectsToMenu( menuAsDoc );
		
		finalizePositions();
        
        return true;
    }
    
    //-------------------------------------------------------------------------------------
    
    /**
     * Creates objects of the specified type
     * @param    menuData    - json data potentially containing an array of object descriptors
     * @param    objectType    - the type of object to create, eg "spriteObject"
     */
    private function startProduction( menuData:Dynamic, objectType:String, rOwner:DisplayObjectContainer ):Void
    {
        // Try to get the array of objects
        var items:Array<Dynamic> = Reflect.getProperty( menuData, objectType );
        
        if ( items == null )
        {
            // EARLY RETUN--no items to create
            return;
        }
        
        // Create each object of type specified in the JSON data
        for ( curMeta in items )
        {
			var platform:String = getValueRecursively( "platform", curMeta );
			
			// Only create elements needed by the current platform
			// "Common" elements will be included (since platform = null in that case)
			if ( platform != null && platform != LayoutMap.curLayout.getName() )
			{
				continue;
			}
			
			// Set the JSON file as the lib, so it can be retrieved from ResMan
			curMeta.lib = m_jsonFileName; //TODO: this line may no longer be needed 12/14/15 -jm
			
            var obj:DisplayObject = createOneOfType( curMeta, m_makerDir.getMakerFunc( objectType ), rOwner );
			
			// If we are making an object that can have children,
			// recurse to see if it has children
			if ( obj.is( DisplayObjectContainer ))
			{
				var doc:DisplayObjectContainer = obj.as( DisplayObjectContainer );
				
				for (objectType in OBJECT_TYPES)
				{
					startProduction( curMeta, objectType, doc );
				}
				
				addObjectsToMenu( doc );
			}
        }
    }
    
    //-------------------------------------------------------------------------------------
    
    /**
     * Creates a DisplayObject using the specified function and JSON data
     * @param    curMeta        - json data specifying object properties
     * @param    typeCreator    - function that will actually create the object
     * @param    rOwner    - not currently used; owner is currently always the GenericMenu
     */
    private function createOneOfType( curMeta:Dynamic, typeCreator:Dynamic -> DisplayObject, rOwner:DisplayObjectContainer ):DisplayObject
    {
        var curProduct:DisplayObject = typeCreator( curMeta );
        if ( curProduct == null )
        {
            // EARLY RETURN
            warn( "Failed to contruct object on menu" );
            return null;
        }
        
        finishProductAssembly( curMeta, curProduct, rOwner );
        return curProduct;
    }
    
    //-------------------------------------------------------------------------------------
    
    /**
     * Sets the generic properties, eg position, and type-specific properties that require a ref to the menu
     * @param    curMeta        - json data specifying object properties
     * @param    curProduct    - the DisplayObject whose properties are being set
     * @param    rOwner    - not currently used; owner is currently always the GenericMenu
     */
    private function finishProductAssembly( curMeta:Dynamic, curProduct:DisplayObject, rOwner:DisplayObjectContainer ):Void
    {
        // Set the object's name, if it has one
        var name:String = getValueRecursively( "name", curMeta );
        if ( name != null )
        {
            curProduct.name = name;
			
			// Save the object by its name, so that we can access regardless of place in display tree
			var record:Null<Bool> = getValueRecursively( "record", curMeta );
			if ( record != null && record )
			{
				m_rMenu.addObjectByName( curProduct, name );
			}
        }
		
		// Set position
		var adjustPosAfterParenting:Bool = setObjectInitalPosition( curMeta, curProduct );
		if ( adjustPosAfterParenting )
		{
			addObjectToRepositionList( curMeta, curProduct );
		}
        
        // If we have a button, have it use the menu's handler
        if ( curProduct.is( GraphicButton ) )
        {
            var btn:GraphicButton = curProduct.as( GraphicButton );
			btn.onHit = m_rMenu.onButtonHit;
			btn.onButtonDown = m_rMenu.onButtonDown;
			btn.onButtonUp = m_rMenu.onButtonUp;
			btn.onButtonOver = m_rMenu.onButtonOver;
			btn.onButtonOut = m_rMenu.onButtonOut;
            m_rMenu.addButton( btn );
        }
        
        // Add to a priority bucket
        var priority:Null<Int> = getValueRecursively( "priority", curMeta );
        if ( priority == null )
        {
            priority = 0;
        }
        addObjectToPriorityList( curProduct, priority, rOwner );
        
        // Set visibility
        var visible:Null<Bool> = getValueRecursively( "visible", curMeta );
		// Default true if not present.
		curProduct.visible = ( visible == null || visible );
		
		// Opacity
        var opacity:Null<Int> = getValueRecursively( "opacity", curMeta );
        if ( opacity != null )
        {
            curProduct.alpha = opacity / MAX_OPACITY;
        }
		
		// Scaling
		var scale:Array<Dynamic> = getValueRecursively( "scale", curMeta );
		if ( scale != null )
		{
			curProduct.scaleX = cast scale[ 0 ];
			curProduct.scaleY = cast scale[ 1 ];
		}
    }
    
    //-------------------------------------------------------------------------------------
	
	private function setObjectInitalPosition( curMeta:Dynamic, curProduct:DisplayObject ):Bool
	{
        var posVal:Array<Dynamic> = getValueRecursively( "position", curMeta );
		if ( posVal == null )
		{
			posVal = [ 0, 0 ];
		}
		
		curProduct.x = cast posVal[ 0 ];
		curProduct.y = cast posVal[ 1 ];
		
		// Returns true if position adjustments are needed after parenting
		var posRelVal:Null<Bool> = getValueRecursively( "positionRelative", curMeta );
		return ( posRelVal != null && !posRelVal );
	}
	
    //-------------------------------------------------------------------------------------
	
	/**
	 * For objects with PositionRelative/UseParentCoordSpace set to false in Paist, we need to adjust the position
	 * (parenting may have caused the object to go to the wrong position, since openfl DisplayObjects are always
	 *  positioned relative to their parent).
	 * Also adjust to account for an Origin/AnchorPoint.
	 */
	private function setObjectFinalPosition( curMeta:Dynamic, curProduct:DisplayObject ):Void
	{
		var position:Point = new Point( curProduct.x, curProduct.y );
		
		var posRelVal:Null<Bool> = getValueRecursively( "positionRelative", curMeta );
		if ( posRelVal != null && !posRelVal )
		{
			// Need to reset the pos and scale to get correct G2L value -- cache scale so we can set it back after
			curProduct.x = 0;
			curProduct.y = 0;
			var scaleX:Float = curProduct.scaleX;
			var scaleY:Float = curProduct.scaleY;
			curProduct.scaleX = 1;
			curProduct.scaleY = 1;
			
			// Adjust position to account for PositionRelative = false
			position = curProduct.globalToLocal( position );
			
			// Account for the Origin/AnchorPoint offest
			var originVal:String = getValueRecursively( "origin", curMeta );
			if ( originVal != null )
			{
				var offsetX:Int = getAnchorOffsetX( originVal );
				var offsetY:Int = getAnchorOffsetY( originVal );
				position.x += offsetX;
				position.y += offsetY;
			}
			
			// Set the scale back 
			curProduct.scaleX = scaleX;
			curProduct.scaleY = scaleY;
		}
		
		// Set the final pos
		curProduct.x = position.x;
		curProduct.y = position.y;
	}
	
    //-------------------------------------------------------------------------------------
	
	private function getAnchorOffsetX( originVal:String ):Int
	{
		var anchorPoint:String = originVal.toLowerCase();
		if ( anchorPoint.indexOf( "center" ) != -1 )
		{
			return Std.int( Application.app.targetSize.x / 2 );
		}
		else if ( anchorPoint.indexOf( "right" ) != -1 )
		{
			return Std.int( Application.app.targetSize.x );
		}
		//else left, offset is 0
		return 0;
	}
	
    //-------------------------------------------------------------------------------------
	
	private function getAnchorOffsetY( originVal:String ):Int
	{
		var anchorPoint:String = originVal.toLowerCase();
		if ( anchorPoint.indexOf( "middle" ) != -1 )
		{
			return Std.int( Application.app.targetSize.y / 2 );
		}
		else if ( anchorPoint.indexOf( "bottom" ) != -1 )
		{
			return Std.int( Application.app.targetSize.y );
		}
		//else left, offset is 0
		return 0;
	}
	
    //-------------------------------------------------------------------------------------
	
	private function addObjectToRepositionList( curMeta:Dynamic, curProduct:DisplayObject ):Void
	{
		if ( m_objsToReposition == null )
		{
			m_objsToReposition = new ObjectMap();
		}
		
		m_objsToReposition.set( curProduct, curMeta );
	}
	
    //-------------------------------------------------------------------------------------
	
	private function finalizePositions():Void
	{
		if ( m_objsToReposition != null )
		{
			for ( key in m_objsToReposition.keys() )
			{
				setObjectFinalPosition( m_objsToReposition.get( key ), key );
			}
		}
	}
	
    //-------------------------------------------------------------------------------------
    
    /**
     * Adds ab object to a priority bucket
     * @param    obj            - the object
     * @param    priority    - its priority
     */
    private function addObjectToPriorityList( obj:DisplayObject, priority:Int, owner:DisplayObjectContainer ):Void
    {
        // Paranoia
        if ( obj == null || owner == null )
        {
            // EARLY RETURN
            return;
        }
        
        var priorities:Array<Array<DisplayObject>> = m_buckets.get( owner );
        if ( priorities == null )
        {
            priorities = new Array();
            m_buckets.set( owner, priorities );
        }
        
        var objs:Array<DisplayObject> = priorities[ priority ];
        if ( objs == null )
        {
            objs = new Array();
            priorities[ priority ] = objs;
        }
        objs.push( obj );
    }
    
    //-------------------------------------------------------------------------------------
    
    /**
     * Add all objects to the menu in order of priority
     */
    private function addObjectsToMenu( owner:DisplayObjectContainer ):Void
    {
        // Paranoia
        if ( owner == null )
        {
            // EARLY RETURN
            return;
        }
        
        var priorities:Array<Array<DisplayObject>> = m_buckets.get( owner );
        if ( priorities == null )
        {
            // EARLY RETURN -- no children to add
            return;
        }
        
        for ( arr in priorities )
        {
            // Since we're using an array instead of eg an IntMap, need to ensure we actually have objects at this priority
            // We can probably optimize this quite a bit by switching to something other than an Array here
            if ( arr == null )
            {
                continue;
            }
            
            for ( obj in arr )
            {
                owner.addChild( obj );
                obj = null;
            }
            arr = null;
        }
    }
}