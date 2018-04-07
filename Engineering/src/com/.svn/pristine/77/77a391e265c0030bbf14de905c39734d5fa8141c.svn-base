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
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.utils.json.IJsonClient.ClientType;

using StringTools;

/**
 * Singleton that creates a json plug-in and uses it to populate a client (eg a GenericMenu) using some JSON data
 */
class JsonObjectFactory
{
    private static var m_instance:JsonObjectFactory;
    private var m_plugIn:IJsonBasePlugIn;
    
    private function new()
    {
        
    }
    
    /**
     * Creates the JsonObjectFactory instance (if it hasn't already been created) and returns it
     * @return the JsonObjectFactory instance
     */
    public static function getInstance():JsonObjectFactory
    {
        if ( m_instance == null )
        {
            m_instance = new JsonObjectFactory();
        }
        
        return m_instance;
    }
    
    //-------------------------------------------------------------------------------------
    
    /**
     * Kicks off the process that constructs and adds objects to the menu
     * @param    jsonFileName    - name of the json file that will populate the menu
     * @param    rClient            - the menu to be populated
     * @return    true if the menu was successfully populated; false otherwise
     */
    public function populate( jsonFileName:String, rClient:IJsonClient ):Bool
    {
        //Associate ourselves with the calling client.
        log( "JsonObjectFactory::populate --> Now creating JsonFile:  " + jsonFileName );
        var initedPlugIn:Bool = ascertainAppropriatePlugIn( jsonFileName, rClient );
		
        if ( !initedPlugIn )
        {
            warn( "ERROR:  Failed to init plug-in!!!" );
            deinit();
            return false;
        }
		
        if ( !ResMan.instance.isRegistered( jsonFileName ) )
        {
            warn( "ERROR:  Unable to load json file!!! " + jsonFileName );
            deinit();
            return false;
        }
        
        // TODO: hierarchy
        // Start actually populating the menu
        var initiatedPopulationProcess:Bool = m_plugIn.beginPopulation();
        if( !initiatedPopulationProcess )
        {
            deinit();
            return false;
        }
		
        deinit();
		
        return true;
    }
    
    //-------------------------------------------------------------------------------------
    
    /**
     * Chooses and creates the plug-in that will actually populate the client
     * @param    jsonFile    - the name of the JSON file used to populate the menu
     * @param    rClient        - the menu to be populated
     * @return    true if the plug-in was created; false otherwise
     */
    private function ascertainAppropriatePlugIn( jsonFile:String, rClient:IJsonClient ):Bool
    {
        if ( rClient == null )
        {
            warn( "ERROR:  Client is currently NULL!!" );
            return false;
        }

        if ( m_plugIn != null )
        {
            warn( "ERROR: Can't assign plug-in.  Plug-in is currently initialized!!" );
            return false;
        }

        switch ( rClient.getType() )
        {
            case ClientType.GENERIC_MENU:
            {
                m_plugIn = new JsonMenuPlugIn( jsonFile, cast rClient );
            }
            case ClientType.NUM_CLIENT_TYPES:
            {
                warn( "ERROR:  Called with an invalid client type!!" );
            }
        }

        return true;
    }
    
    //-------------------------------------------------------------------------------------
    
    private function deinit():Void
    {
        m_plugIn = null;
    }
    
}
