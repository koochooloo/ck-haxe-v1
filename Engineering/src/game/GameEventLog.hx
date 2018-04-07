//
// Copyright (C) 2016, 1st Playable Productions, LLC. All rights reserved.
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

package game;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.utils.Version;
import game.events.LoggingEvent;
//import src.SpeckGlobals;

#if (js && html5)
import js.Browser;
import js.Error;
import js.html.AnchorElement;
#else
import lime.system.System;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
#end

/**
 * Class that listens for all LoggingEvents in the game, and maintains
 * a history of the last X events to occur. 
 * Adopted from Sheba revision 597.
 * Currently written for browser. TODO: cross-platform functionality.
 */

class GameEventLog
{
	var maxLogSize:Int;
	var log:List<LoggingEvent>;

	public function new(maxLogSize:Int = 100) 
	{
		this.maxLogSize = maxLogSize;
		log = new List<LoggingEvent>();
		
		SpeckGlobals.event.addEventListener(LoggingEvent.LOGGING_EVENT, onLoggingEvent);
		
		#if (js && html5)
		Browser.window.addEventListener('error', onBrowserError);
		#end
	}
	
	#if (js && html5)
	/**
	 * If we get a crash, dump out the event history, state history, and the details of the error that got thrown. 
	 * @param	e
	 */
	private function onBrowserError(e:Error):Void
	{
		bugReport(e);
	}
	#end
	
	/**
	 * Adds the event to the log, bumping off oldest events.
	 * @param	e
	 */
	private function onLoggingEvent(e:LoggingEvent):Void
	{
		while (log.length >= maxLogSize)
		{
			log.pop();
		}
		
		log.add(e);
	}
	
	#if (js && html5)
	/**
	 * Dumps data for log.
	 */
	public function dumpLog(e:Error):Void
	{
		Debug.log("==============================");
		Debug.log("==============================");
		Debug.log("Dumping Event Log");
		Debug.log("==============================");
		Debug.log("==============================");
		
		// Grab & display log of collected events
		Debug.log(getLog(e));
		
		Debug.log("==============================");
		Debug.log("==============================");
	}
	
	/**
	 * Gets a string for the log file.
	 * @return
	 */
	private function getLog(e:Error):String
	{
		var version = new Version();
		
		var logText:String = "Game Event Log";
		logText += "\nVersion: " + version.text;
		logText += "\nID: " + SpeckGlobals.saveProfile.guid;
		
		// Display error message
		logText += "\n===============================";
		logText += "\nError: ";
		logText += e.message;
		logText += "\n-------------------------------";

		// Display information collected in the event log
		logText += "\nLogging Events: ";
		for (ev in log)
		{
			var eventType:String = Std.string(ev.loggingType);
			var data:String = ev.details;
 
			logText += "\n-------------------------------";
			logText += "\nEvent: ";
			logText += eventType;
			logText += "\n Details: ";
			logText += data;
		}
		
		// Display state information
		logText += "\n-------------------------------";
		logText += "\nPlayer state info: ";
		logText += SpeckGlobals.saveProfile.getCurrentStateString();
		logText += "\n===============================";

		
		return logText;
	}
	
	/**
	 * Saves a bug report
	 */
	public function bugReport(e:Error):Void
	{
		dumpLog(e);
		
		var logData:String = getLog(e);
		
		var timeComponent = DateTools.format(Date.now(), "%Y_%m_%d_%H_%M_%S");
		var logName:String = SpeckGlobals.saveProfile.productName + "_" + timeComponent + ".log";
		
		#if js
		var dataStr:String = "data:text/txt;charset=utf-8," + StringTools.urlEncode(logData);
		var tempAnchor:AnchorElement = cast Browser.document.createAnchorElement();
		
		tempAnchor.download = logName;
		tempAnchor.href = dataStr;
		
		Browser.document.body.appendChild(tempAnchor);
		tempAnchor.click();
		#else
		var saveFilePath:String = System.applicationStorageDirectory + logName;
		trace("Attempting to save to file: " + saveFilePath);
		File.saveContent(saveFilePath, logData);
		#end
	}
	#end // #if (js && html5)

	
}