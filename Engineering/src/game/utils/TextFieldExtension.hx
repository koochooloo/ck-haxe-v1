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


package game.utils;

import openfl.text.TextField;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl._internal.text.TextEngine;
import openfl._internal.text.TextLayoutGroup;

using StringTools;

// Reaching into TextField internals to determine when text will be terminated.
@:access(openfl.text.TextField)
@:access(openfl._internal.text.TextEngine)
@:access(openfl._internal.text.TextLayoutGroup)
class TextFieldExtension
{
	private static inline var ELLIPSIS:String = "...";
	
	// A helper function that returns true if the provided text will be cut short.
	public static function willTextBeClipped(tf:TextField):Bool
	{
		// Force an update() in case the text has been updated but the layout groups have not
		var engine:TextEngine = tf.__textEngine;
		engine.update();
		
		// Iterate through the TextLayoutGroups generated by the TextEngine
		// Look for the last group using a check pulled from CanvasTextField.render()
		for (group in engine.layoutGroups)
		{
			// Stop at the last visible group.
			var isLastLine:Bool = (group.lineIndex > tf.scrollV + engine.bottomScrollV - 2);
			if (isLastLine)
			{
				return true;
			}
		}
		
		return false;
	}
	
	// A helper function that trims text that will be clipped and appends an ellipsis at the end
	public static function shortenTextToFit(tf:TextField):Void
	{
		// Force an update() in case the text has been updated but the layout groups have not
		var engine:TextEngine = tf.__textEngine;
		engine.update();
		
		// Iterate through the TextLayoutGroups generated by the TextEngine
		// Look for the last group using a check pulled from CanvasTextField.render()
		var isTooBig:Bool = false;
		var lastVisibleGroup:TextLayoutGroup = null;
		for (group in engine.layoutGroups)
		{
			lastVisibleGroup = group;
			
			// Stop at the last visible group.
			var isLastLine:Bool = (group.lineIndex > tf.scrollV + engine.bottomScrollV - 2);
			if (isLastLine)
			{
				isTooBig = true;
				break;
			}
		}
		
		if (isTooBig)
		{
			// Work backwards from the last visible character and ensure that we aren't terminating in the middle of a word.
			var endIndex:Int = lastVisibleGroup.startIndex - ELLIPSIS.length;
			while (endIndex > 0)
			{
				// If we encounter a space character, then we are assuming we aren't in the middle of a word.
				if (tf.text.isSpace(endIndex))
				{
					break;
				}
				
				--endIndex;
			}
			
			// Chop off the end of the string and append the ellipsis
			var str:String = tf.text.substring(0, endIndex);
			str += ELLIPSIS;
			
			// Update the stored string
			tf.text = str;
		}
	}
}