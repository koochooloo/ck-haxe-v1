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

package game.ui;

import com.firstplayable.hxlib.app.Application;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.LayerName;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import openfl.display.Bitmap;

class SkyBackground
{
	private static var background(get, null):OPSprite;
	private static function get_background():OPSprite
	{
		if (background == null)
		{
			var bitmap:Bitmap = ResMan.instance.getImage("2d/BG/bg_skyBase");
			background = new OPSprite(bitmap);
			background.x = (Application.app.targetSize.x * 0.5);
			background.y = (Application.app.targetSize.y);
		}
		
		return background;
	}
	
	public static function showBackground():Void
	{
		GameDisplay.attach(LayerName.BACKGROUND, background);
	}
	
	public static function hideBackground():Void
	{
		GameDisplay.remove(LayerName.BACKGROUND, background);
	}
}