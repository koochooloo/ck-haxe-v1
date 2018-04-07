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
package com.firstplayable.hxlib.psoc;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.io.GameSave;
import com.firstplayable.hxlib.utils.Delay;
import com.firstplayable.hxlib.utils.PropUtils;
import haxe.Json;
import js.Lib;

typedef ScormFinish =
{
	//did user complete the activity? yes/no
	complete:Bool,
	//was user successful? pass/fail
	success:Bool,
	//user score
	score:Float
}

class PSoCSaveMan
{
	public static var instance(get,null):PSoCSaveMan;
	
	private static function get_instance():PSoCSaveMan
	{
		if ( instance == null )
			instance = new PSoCSaveMan();
		
		return instance;
	}
	
	//how many tries we attempt before giving up on psoc connection
	private static inline var COM_TRIES:Int = 20;
	
	//context object containing player grade and unit info, etc
	public var context(default, null):Dynamic;
	
	//player finish object
	public var finish:ScormFinish;
	
	//reference to player profile
	private var m_profile:GameSave;
	//true if connected to psoc
	private var m_connectedToPsoc:Bool;
	private var m_bridgeComTries:Int = 0;
	
	/**
	 * Creates a new psoc save manager.
	 */
	public function new()
	{
		m_connectedToPsoc = false;
		context = null;
		m_profile = null;
		finish = { complete:true, success:true, score:1.0 };
	}
	
	/**
	 * Attempts connection with PSC.
	 * @param	onResult	Called when connection is determined. Will pass null if connection failed.
	 */
	public function connect( onResult:Dynamic->Void ):Void
	{
		updateSave = onResult;
		checkForNativeBridge();
	}
	
	/**
	 * Receives state context from PSoC.
	 * @param	o
	 */
	private function onFetchPsocContext( o:Dynamic ):Void
    {
        if ( o == null )
        {
            Debug.log( "Fetch received null context object." );
            return;
        }
        
        Debug.log( "Fetch received context:\n" + o );
        context = { };
        
		//validate context object
        if ( Reflect.hasField( o, "unit" ) && Reflect.hasField( o.unit, "number" ) )
        {
            context.unit = o.unit.number;
        }
        else
        {
            Debug.log( "No unit present - defaulting..." );
            context.unit = 1;
        }
        
        if ( Reflect.hasField( o, "course" ) && Reflect.hasField( o.course, "grade" ) )
        {
            context.grade = o.course.grade;
        }
        else
        {
            Debug.log( "No grade present - defaulting..." );
            context.grade = 1;
        }
    }
	
	/**
	 * Receives save state object.
	 * @param	oStr
	 */
	private function onFetchPsocSave( oStr:String ):Void
    {
        Debug.log( "Received save" );
        
        var saveObj:Dynamic;
        
        //first time trigger or random issues
		if ( oStr == null )
		{
			Debug.log( "Fetch received null save object." );
			saveObj = null;
		}
		else
		{
			try
			{
				saveObj = Json.parse( oStr );
				//we need to keep debugInfo empty so it doesn't stack in the console output
				saveObj.debugInfo = "";
			}
			catch ( e:Dynamic )
			{
				Debug.log( "Fetch failed to parse JSON: " + Std.string( e ) );
				Lib.alert( "No save data detected. Click GO to create a new profle..." );
				saveObj = null;
			}
		}
		
		updateSave( saveObj );
    }
	
	/**
	 * Set this function to your conversion function to turn Dynamic into specific save object type.
	 * @param	save
	 */
	private dynamic function updateSave( save:Dynamic ):Void
	{
		Debug.log( "called" );
	}
	
	/**
	 * Called by PSoC when it needs to save.
	 */
	private function onPsocSave():Void
    {
        if ( !m_connectedToPsoc ) return;
		
		var userState:Dynamic = { };
		PropUtils.copyProperties( m_profile, userState, false );
		//we don't want to save the stream to the actual profile object or we will get an overflow error whenever it traces
		//userState.debugInfo = Debug.stream();
		
        Debug.log( "SAVING..." );
		EventBroker.doSave( Json.stringify( userState ) );
    }
	
	/**
	 * Called by PSoC when app about to close.
	 */
	private function onPsocFinish():Void
    {
        if ( !m_connectedToPsoc ) return;
		
        Debug.log( "FINISHING..." );
        EventBroker.doFinish( finish.complete, finish.success, finish.score );
    }
	
	/**
	 * Called when test harness is not found.
	 */
	private function testHarnessNotFound():Void
    {
        Lib.alert( "\nThere was an issue gathering your profile. Please restart the interactive to try again. If you continue, you will start with a new profile and will not be able to save." );
		updateSave( null );
    }
	
	/**
	 * Determines if we are connected to psoc.
	 */
	private function checkForNativeBridge():Void
    {
        var med:Dynamic = EventBroker.mediator;
        
		//check to evaluate whether test harness is ready
        if ( med != null && Reflect.hasField( med, "_events" ) && Reflect.hasField( med._events, "#fetch" ) )
        {
			//everything is go
			m_connectedToPsoc = true;
			
			EventBroker.addSave( onPsocSave );
			EventBroker.addFinish( onPsocFinish );
			fetch();
			
			return;
        }
		
        if ( m_bridgeComTries > COM_TRIES )
        {
			m_connectedToPsoc = false;
            testHarnessNotFound();
        }
        else
        {
            //try again
            Delay.setTimeout( 100, checkForNativeBridge );
            ++m_bridgeComTries;
        }
    }
	
	/**
	 * Post game save.
	 */
	public function post( newProfile:GameSave ):Void
    {
		m_profile = newProfile;
		
		if ( !m_connectedToPsoc ) return;
		
		if ( m_profile == null )
		{
			Debug.log( "Tried to save null profile! Ignoring..." );
			// EARLY RETURN
			return;
		}
		
		m_profile.timestamp = Date.now().toString();
		Debug.log( "About to save... " + m_profile.profileName );
		
		onPsocSave();
    }
    
    /**
     * Fetches game save object from PSoC.
     */
    public function fetch():Void
    {
		if ( !m_connectedToPsoc ) return;
		
		EventBroker.getContext( onFetchPsocContext );
		EventBroker.getSave( onFetchPsocSave );
    }
}