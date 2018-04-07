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
package com.firstplayable.hxlib.display;
import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.Debug.*;
import haxe.ds.StringMap;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.Lib;
using com.firstplayable.hxlib.StdX;
using Lambda;

class GameDisplay
{
    /**
     * [write-only] Set the background color of the stage.
     */
    public static var backgroundColor( null, set ):Int;
    
    /**
     * [write-only] Masks the stage area to prevent graphics from rendering outside.
     */
    public static var enableMasking( null, set ):Bool;
    
    //a hash containing all layers
    private static var ms_layers:StringMap<Sprite> = new StringMap();
    //a sprite to deal with background color fill
    private static var ms_bgFill:Sprite = new Sprite();
    
    /**
     * Sets the background color of the stage.
     * @param    color    The color to set as the background.
     */
    //TODO: do we want to account for resizing the app? -jm
    private static function set_backgroundColor( color:Int ):Int
    {
        //TODO: need to refactor this to add a sprite if stage is used -jm
        var stage:Stage = Lib.current.stage;
        stage.addChildAt( ms_bgFill, 0 );
        ms_bgFill.graphics.clear();
        ms_bgFill.graphics.beginFill( color );
        ms_bgFill.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
        ms_bgFill.graphics.endFill();
        return color;
    }
    
    /**
     * Masks the stage area to prevent graphics from rendering outside.
     * @param    enable    Whether to enable stage masking.
     * @return
     */
    //TODO: do we want to account for resizing the app? -jm
    private static function set_enableMasking( enable:Bool ):Bool
    {
        //TODO: need to refactor this to add a sprite if stage is used -jm
        warn( "enableMasking() is currently not implemented!" );
        return false;
        /*if ( Application.app.isNull() )
        {
            log( "Application required in order to add app mask." );
            return false;
        }
        
        var stage:Stage = Lib.current.stage;
        var stageMask:Sprite = null;
        
        if ( stage.mask.isValid() && stage.mask.parent.isValid() )
            stage.removeChild( stage.mask );
        if ( enable )
        {
            stageMask = new Sprite();
            stageMask.graphics.beginFill( 0x000000 );
            stageMask.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
            stageMask.graphics.endFill();
            
            stage.addChildAt( stageMask, 0 );
            stageMask.mouseEnabled = false;
            stageMask.mouseChildren = false;
        }
        
        stage.mask = stageMask;
        return enable;*/
    }
    
    /**
     * Creates a new layer and adds it to the display tree.
     * If Application.hx is used, attaches to that; otherwise attaches to main stage.
     * @param    layer   	An assigned name for the layer; either a String or EnumValue.
     * @param    layerObj   Optional sprite object to use as the layer.
     * @param    priority   Optional int to use as z-index for layering.
	 * @return	the layer (layerObj, or a newly created sprite if null was passed)
     */
    public static function addLayer( name:Dynamic, layerObj:Sprite = null, priority:Int = -1 ):Sprite
    {
		var layerName:String = name;
		
        var layer:Sprite = ( layerObj.isNull() ? new Sprite() : layerObj );
        
        //if Application was used, add layers to that (same as Main).
        if ( Application.app.isValid() )
        {
            if ( priority > -1 )
                Application.app.addChildAt( layer, priority );
            else
                Application.app.addChild( layer );
        }
        //otherwise, add layers to the main stage.
        else
        {
            if ( priority > -1 )
                Lib.current.stage.addChildAt( layer, priority );
            else
                Lib.current.stage.addChild( layer );
        }
        
        ms_layers.set( layerName, layer );
		return layer;
    }
    
    /**
     * Removes a layer from the display tree.
     * @param    layerName    The name of the layer to remove.
     */
    public static function removeLayer( layerName:String ):Void
    {
        if( !verifyLayer( layerName ) ) return;
        var layer:Sprite = ms_layers.get( layerName );
        layer.parent.removeChild( layer );
        ms_layers.remove( layerName );
    }
    
	/**
     * @param    layerName    The name of the layer to return.
	 * @return   The requested layer (or null, if no layer exists with the given name).
     */
	public static function getLayer( layerName:String ): Sprite
	{
		if( !verifyLayer( layerName ) ) return null;
		return( ms_layers.get( layerName ) );
	}

    /**
	 * NOTE: this resets all properties! 
	 * @see clearLayer if you just want to remove children
	 * 
     * Removes a layer and renews it, maintaining its current priority. This function makes a new layer.
     * @param    layerName    The name of the layer to reset. String or EnumValue.
     */
    public static function resetLayer( name:Dynamic ):Void
    {
		var layerName:String = name;
        var layerSpr:Sprite = ms_layers.get( layerName );
        
		var layerScale:Float = 1.0;
        var layerIndex:Int = -1;
		
        if ( layerSpr != null )
		{
			layerScale = layerSpr.scaleX; //< assume uniform scale
			if ( layerSpr.parent != null )
            {
				layerIndex = layerSpr.parent.getChildIndex( layerSpr );
			}
        }
		
        removeLayer( layerName );
        var newLayer:Sprite = addLayer( layerName, layerIndex );
		
		// warn on potential misuse of resetLayer()
		warn_if( (newLayer.scaleX != layerScale), "The scale for layer '" + name + "' has changed after resetLayer(); did you mean to use clearLayer() instead?" );
    }
	
	/**
	 * Clears all children and graphics on a layer, but doesn't effect the actual layer object.
	 * @param	name	The name of the layer to clear. String or EnumValue.
	 */
	public static function clearLayer( name:Dynamic ):Void
	{
		var layerName:String = name;
		var layerSpr:Sprite = ms_layers.get( layerName );
		
		if ( layerSpr != null )
		{
			layerSpr.graphics.clear();
			layerSpr.removeChildren();
		}
	}
	
    /**
     * Adds a display object child to a layer.
     * @param    layerName   The name of the layer to use as a parent. String or EnumValue.
     * @param    dObj        The display object to add.
     * @param    push        Whether to add the child to the front (true) or back (false) of the parent's children.
     */
    public static function attach( layerName:Dynamic, dObj:DisplayObject, push:Bool = true ):Void
    {
		var name:String = layerName;
		
        if( !verifyLayer( name ) ) return;
        var layer:Sprite = ms_layers.get( name );
        
        if ( push )
        {
            layer.addChild( dObj );
        }
        else
        {
            layer.addChildAt( dObj, 0 );
        }
    }
    
    /**
     * Removes a display object from a layer.
     * @param    layerName   The name of the layer the display object is a part of. String or EnumValue.
     * @param    dObj        The display object to remove.
     */
    public static function remove( layerName:Dynamic, dObj:DisplayObject ):Void
    {
		var name:String = layerName;
		
        if( !verifyLayer( name ) ) return;
        var layer:Sprite = ms_layers.get( name );
        
        if ( dObj != null && dObj.parent == layer )
        {
            layer.removeChild( dObj );
        }
        else
        {
            log( "Child does not exist! \"" + dObj + "\"" );
        }
    }
    
    /**
     * Enables or disables a layer's visibility. Can optionally override the toggle to set visible.
     * @param    layerName        The name of the layer to toggle.
     * @param    ?visibility      Overrides toggle behavior to set the visibility, only if provided.
     */
    public static function showLayer( name:Dynamic, ?visibility:Bool ):Void
    {
		var layerName:String = name;
        if( !verifyLayer( layerName ) ) return;
        var layer:Sprite = ms_layers.get( layerName );
        layer.visible = ( visibility.isNull() ? !layer.visible : visibility );
    }
    
    /**
     * Enables or disables a layer's input. Can optionally override the toggle to set enabled.
     * @param    layerName       The name of the layer to toggle.
     * @param    ?enabled        Overrides toggle behavior to set enabled, only if provided.
     */
    public static function enableLayer( layerName:String, ?enabled:Bool ):Void
    {
        if( !verifyLayer( layerName ) ) return;
        var layer:Sprite = ms_layers.get( layerName );
        layer.mouseEnabled = ( enabled.isNull() ? !layer.mouseEnabled : enabled );
        layer.mouseChildren = ( enabled.isNull() ? !layer.mouseChildren : enabled );
    }
    
    /**
     * Applies a mask to a layer.
     * @param    layerName    The name of the layer to mask.
     * @param    layerMask    The object to use as the mask. Use null to remove the mask.
     */
    public static function setLayerMask( layerName:String, layerMask:Sprite ):Void
    {
        if( !verifyLayer( layerName ) ) return;
        var layer:Sprite = ms_layers.get( layerName );
        
        //TODO: evaluate if adding mask to display is still needed in openfl, across flash + js targets -jm
        //remove previous mask from display, if it exists
        if ( layer.mask.isValid() && layer.mask.parent.isValid() )
        {
            layer.mask.parent.removeChild( layer.mask );
        }
        
        if ( layerMask.isValid() )
        {
            //TODO: see above todo about mask
            layer.addChild( layerMask );
            layerMask.mouseEnabled = false;
            layerMask.mouseChildren = false;
        }
        
        //TODO: cache depending on transparency -jm
        layer.cacheAsBitmap = false;
        layer.mask = layerMask;
    }
    
    /**
     * Traces a message noting a layer could not be found.
     * @param    layerName    The layer's name.
     */
    private static inline function verifyLayer( layerName:String ):Bool
    {
        if ( !ms_layers.exists( layerName ) )
        {
            warn( "Layer does not exist! \"" + layerName + "\"" );
            return false;
        }
        else return true;
    }
}