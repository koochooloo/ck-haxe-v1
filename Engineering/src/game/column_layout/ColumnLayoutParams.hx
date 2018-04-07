//
// Copyright (C) 2015, 1st Playable Productions, LLC. All rights reserved.
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

package game.column_layout;

import openfl.geom.Point;

typedef ColumnLayoutParams = 
{
	var items:Array<IArrangeable>;
	var align:ColumnAlignment;
	var start:Point;
	var mediumWidth:Float;
	var largeWidth:Float;
	var gutterWidth:Float;
	var height:Float;
};