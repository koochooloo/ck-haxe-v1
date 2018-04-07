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
import com.firstplayable.hxlib.debug.tunables.Tunables;
import openfl.geom.Point;

class ColumnLayout
{
	// Private to prevent instantation
	private function new()
	{
	}
	
	private static function leftAlign(params:ColumnLayoutParams):Void
	{
		// Current row and column in the layout.
		var row:Int = 0;
		var column:Int = 0;

		// Position to place the current tile at.
		var offset:Point = new Point(params.start.x, params.start.y);

		// Helper function to advance to the next row in the layout.
		function advanceRow():Void
		{
			row += 1;
			column = 0;
			offset.x = Math.round(params.start.x);
			offset.y = Math.round(offset.y + params.height);
		}

		// Iterate over every tile.
		for (item in params.items)
		{
			// Test what size of tile this is.
			var isMedium:Bool = (item.size == ColumnSize.MEDIUM);
			var isLarge:Bool = (item.size == ColumnSize.LARGE);

			// Check if this tile won't fit and we should advance.
			if (isMedium)
			{
				if (column > 2)
				{
					advanceRow();
				}
			}

			// Check if this tile won't fit and we should advance.
			if (isLarge)
			{
				if (column > 0)
				{
					advanceRow();
				}
			}

			// Position the tile.
			item.x = Math.round(offset.x);
			item.y = Math.round(offset.y);

			// Determine how many columns to advance.
			if (isMedium)
			{
				column += 1;
				offset.x = Math.round(offset.x + params.mediumWidth + params.gutterWidth);
			}
			else
			{
				column += 2;
				offset.x = Math.round(offset.x + params.largeWidth);
			}

			// If we've reached the end of the row, advance to a new one.
			if (column >= 2)
			{
				advanceRow();
			}
		}
	}
	
	private static function rightAlign(params:ColumnLayoutParams):Void
	{
		// Current row and column in the layout.
		var row:Int = 0;
		var column:Int = 0;
		
		params.start = new Point(params.start.x + params.largeWidth, params.start.y);

		// Position to place the current tile at.
		var offset:Point = new Point(params.start.x, params.start.y);

		// Helper function to advance to the next row in the layout.
		function advanceRow():Void
		{
			row += 1;
			column = 0;
			offset.x = Math.round(params.start.x);
			offset.y = Math.round(offset.y + params.height);
		}

		// Iterate over every tile.
		for (item in params.items)
		{
			// Test what size of tile this is.
			var isMedium:Bool = (item.size == ColumnSize.MEDIUM);
			var isLarge:Bool = (item.size == ColumnSize.LARGE);
			
			// Check if this tile won't fit and we should advance.
			if (isMedium)
			{
				if (column > 2)
				{
					advanceRow();
				}
			}

			// Check if this tile won't fit and we should advance.
			if (isLarge)
			{
				if (column > 0)
				{
					advanceRow();
				}
			}

			// Determine how many columns to advance.
			if (isMedium)
			{
				column += 1;
				offset.x = Math.round(offset.x - params.mediumWidth - params.gutterWidth);
			}
			else
			{
				column += 2;
				offset.x = Math.round(offset.x - params.largeWidth);
			}

			// Position the tile.
			item.x = Math.round(offset.x);
			item.y = Math.round(offset.y);
			
			// If we've reached the end of the row, advance to a new one.
			if (column >= 2)
			{
				advanceRow();
			}
		}
	}

	// Helper function that applies a 3-column layout to the ComparisonTiles.
	public static function apply(params:ColumnLayoutParams):Void
	{
		switch (params.align)
		{
			case ColumnAlignment.LEFT:
				{
					leftAlign(params);
				}
			case ColumnAlignment.RIGHT:
				{
					rightAlign(params);
				}
		}
	}
}
