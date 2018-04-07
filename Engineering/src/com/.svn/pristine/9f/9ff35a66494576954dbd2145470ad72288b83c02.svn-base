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
package com.firstplayable.hxlib.app;
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.utils.MacroUtils;
import haxe.Timer;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.Lib;
import openfl.system.System;
using com.firstplayable.hxlib.Debug;

enum ScaleMode
{
	NONE;
	FIT;
	CROP;
}

/**
 * A standard application wireframe.
 * Last updated with FD 4.6.1, OFL 2.0, HX 3.1.3 in mind.
 */
class Application extends Sprite
{
    //static members
    /**
     * A global instance of the Application object.
     */
    public static var app( default, null ):Application;    //static reference to this
    
    /**
     * Version information as a string, if provided with "bin/version.txt".
     */
    public static var buildInfo( default, null ):String = "BUILD INFO:\n-not available";    //version info
    
    //---- Pool of dimension consts
    /**
     * The initial dimensions of the stage from the start of the application runtime.
     * This is equal to the stageWidth/stageHeight properties of stage at startup.
     */
    public var initSize( default, null ):Point;
    
    /**
     * The current dimensions bounding the application content (objects attached to stage).
     * This is equal to the width/height properties of stage.
     */
    public var contentSize( get, null ):Point;
    private function get_contentSize():Point
    {
        return new Point( stage.width, stage.height );
    }
    
    // TODO: Do we want to cache these values as an optimization (per the Flash version?)
    /**
     * The current application (stage) dimensions.
     * This is equal to the stageWidth/stageHeight properties of stage.
     */
    public var appSize( get, null ):Point;
    private function get_appSize():Point
    {
        return new Point( stage.stageWidth, stage.stageHeight );
    }
	
	/**
     * When using custom scaling, defines the size at which assets were created
	 * (eg, the size of the background images)
     */
    public var targetSize( get, null ):Point = null;
    private function get_targetSize():Point
    {
        return ( targetSize != null ) ? targetSize : appSize;
    }
	
	/**
	 * The scale needed to make targetSize fit appSize, using the specified scaleMode
	 */
	public var scale( default, null ):Float;
	/**
	 * Setting scaleMode will re-calculate scale.
	 * If using custom scaling (ie using with targetSize)
	 * then targetSize must be set first. 
	 */
	public var scaleMode( default, set ):ScaleMode;
	private function set_scaleMode( mode:ScaleMode ):ScaleMode
	{
		if ( mode == ScaleMode.NONE )
		{
			scale = 1.0;
		}
		else
		{
			scale = calculateScale( mode );
		}
		
		return ( scaleMode = mode );
	}
	
	
    /**
     * The dimensions of the active display monitor (full screen).
     * This is equal to the fullscreenWidth/fullscreenHeight properties of stage.
     */
    public var screenSize( get, null ):Point;
    private function get_screenSize():Point
    {
        #if flash
            return new Point( stage.fullScreenWidth, stage.fullScreenHeight );
        #else
            error( "Property screenSize is not implemented for this target." );
            return new Point();
        #end
    }
    
    /**
     * The current center position of the application (stage).
     * This is equal to half the stageWidth/stageHeight properties of stage.
     */
    public var center( get, null ):Point;
    private function get_center():Point
    {
        return new Point( appSize.x * 0.5, appSize.y * 0.5 );
    }
    
    private var m_inited:Bool;
    
    /**
     * Creates a new application.
     */
    public function new() 
    {
        super();
        
        //set global reference
        app = this;
        Lib.current.stage.addChild( app );
        
        //confirm stage exists
        if ( stage.exists() ) init();
        else addEventListener( Event.ADDED_TO_STAGE, init );
    }
    
    /**
     * Handles initialization of this class after it is added to the stage.
     * Override to perform additional custom actions.
     * @param    e    Event (optional)
     */
    private function init( e:Event = null ):Void
    {
        if ( m_inited ) return;
        
        m_inited = true;
        removeEventListener( Event.ADDED_TO_STAGE, init );
        
        //set init dimensions
        initSize = new Point( stage.stageWidth, stage.stageHeight );
		setSizeForManualScaling();
        
        stage.addEventListener( Event.DEACTIVATE, deactivate );
        stage.addEventListener( Event.RESIZE, onResize );
		
		#if debug
			stage.color = 0x232323; //off-black
		#end
		
        setDefaults();
        updateBuildInfo();
        
        //done
        //log( "application ready!" ); // hush; redundant with build info print
        
		initLayers();
        onInitialized();
    }
	
	private function setSizeForManualScaling():Void
	{
		// override in Main if this functionality is desired
	}
	
	private function initLayers():Void
	{
		//visual layers setup
		GameDisplay.addLayer( LayerName.BACKGROUND	);
		GameDisplay.addLayer( LayerName.PRIMARY		);
		GameDisplay.addLayer( LayerName.FOREGROUND	);
		GameDisplay.addLayer( LayerName.HUD 		);
		GameDisplay.addLayer( LayerName.DEBUG		);
		GameDisplay.addLayer( LayerName.BUILDSTAMP	);
	}
    
    /**
     * Additional initialization code, called by init().
     * Override to perform additional custom actions.
     */
    private function setDefaults():Void
    {
        stage.quality = StageQuality.BEST;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
    }
    
    /**
     * Called when application has finished initializing.
     */
    private dynamic function onInitialized():Void
    {
        warn( "Function onInitialized not set! Please use 'onInitialized = aFunc;' before calling super()." );
    }
    
    public function onResize( e:Event = null ):Void
    {
        //to be overridden with resize/orientation change behavior
    }
    
    /**
     * Event handler when the application loses focus.
     * Override to perform custom actions (ie, pause game or close app).
     * @param    e    Event
     */
    public function deactivate( e:Event = null ):Void
    {
        log( "Deactivating..." );
        stage.addEventListener( Event.ACTIVATE, activate );
    }
    
    /**
     * Event handler when the application regains focus.
     * Override to perform custom actions (ie, resume game).
     * @param    e    Event
     */
    public function activate( e:Event = null ):Void
    {
        log( "Activating..." );
        
        if ( stage.exists() )
        {
            stage.removeEventListener( Event.ACTIVATE, activate );
        }
    }
    
    /**
     * Exits the application, if playing in stand alone flash player or web browser.
     * @param    code    The exit code, usually 0 if exiting normally.
     */
    public function exit( code:Int = 0 ):Void
    {
        log( "Exiting... code " + code );
        #if flash
			openfl.Lib.fscommand( "quit", "" );
        #elseif js
            js.Browser.window.close();
        #end
        //TODO: use Lib.exit();
    }
    
    /**
     * Pauses execution of the program, with the exception of socket event delivery.
     * Works with AIR -debug apps (ADL) and in FlashDevelop IDE only.
     */
    public function pause():Void
    {
        #if air
            log( "Pausing ADL thread..." );
            System.pause();
        #else
            log("The current implentation of Application.pause() only works in AIR!");
        #end
    }
    
    /**
     * Resumes execution of the program, after calling pause().
     * Works with AIR -debug apps (ADL) and in FlashDevelop IDE only.
     */
    public function resume():Void
    {
        #if air
            log( "Resuming ADL thread..." );
            System.resume();
        #else
            log("The current implentation of Application.pause() only works in AIR!");
        #end
    }
    
	
	/**
	 * Calculates the scale needed to make targetSize fit appSize, using the specified scaleMode.
	 */
	public function calculateScale( mode:ScaleMode ):Float
	{
		var widthRatio:Float = appSize.x / targetSize.x;
		var heightRatio:Float = appSize.y / targetSize.y;
		
		return ( mode == ScaleMode.FIT ) 
				? Math.min( widthRatio, heightRatio )	// FIT
				: Math.max( widthRatio, heightRatio );	// CROP
	}
	
	
    /*
     * TODO: Looks like we will want to switch to use 'stage.allowsFullScreenInteractive = true' (which
     *       can only be triggered inside user input callback in flash 11.3+). -jm
     */
    /**
	 * THIS FUNCTION CURRENTLY DOES NOTHING. 
	 * DO NOT USE.
	 * 
     * See TODO comment above.
     * Sets the application to full screen mode, if full screen mode is available.
     * @param    fullscreen        true to set full screen, false to set windowed.
     */
    public function setFullscreenMode( fullscreen:Bool ):Void
    {
        var fsMsg:String = ( fullscreen ? "Enabling full screen mode..." : "Disabling full screen mode..." );
        log( fsMsg );
        
        #if flash
			warn("Setting full-screen mode is currently broken on Flash targets.");
			// TODO: there isn't actually a FSCommand class in the system package...
            //openfl.system.FSCommand._fscommand( "fullscreen", Std.string( fullscreen ) );
        #else
            log("Setting full-screen mode only works for Flash targets.");
        #end
    }
    
    /**
	 * THIS FUNCTION CURRENTLY DOES NOTHING. 
	 * DO NOT USE.
	 
     * Controls the flash context menu, if it exists.
     * @param    enabled        true to enable menu, false to disable menu.
     */
    public function enableMenu( enabled:Bool ):Void
    {
        var eMsg:String = ( enabled ? "Enabling menu context..." : "Disabling menu context..." );
        log( eMsg );
        
        #if flash
			warn("The Flash context menu cis currently broken on Flash targets!");
			// TODO: there isn't actually a FSCommand class in the system package...
            //openfl.system.FSCommand._fscommand( "showmenu", Std.string( enabled ) );
        #else
            log("The Flash context menu can only be enabled for Flash targets!");
        #end
    }
    
    /**
     * Sets the build info.
     */
    private function updateBuildInfo():Void
    {
        Application.buildInfo = MacroUtils.getBuildDate();
        log( "Build Date: " + Application.buildInfo );
    }
}