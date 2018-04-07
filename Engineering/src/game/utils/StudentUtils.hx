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

import game.ui.login.StudentColor;
import game.ui.login.StudentNumber;

class StudentUtils
{
	public static function getIdFromColorAndNumber(color:StudentColor, number:StudentNumber):Int
	{
		var colors:Array<StudentColor> = AbstractEnumTools.getValues(StudentColor);
		var numbers:Array<StudentNumber> = AbstractEnumTools.getValues(StudentNumber);
		
		var colorIndex:Int = colors.indexOf(color);
		var numberIndex:Int = numbers.indexOf(number);
		
		return (colorIndex * numbers.length) + numberIndex;
	}
	
	public static function getColorFromId(id:Int):StudentColor
	{
		var colors:Array<StudentColor> = AbstractEnumTools.getValues(StudentColor);
		var numbers:Array<StudentNumber> = AbstractEnumTools.getValues(StudentNumber);
		var index:Int = Std.int(id / numbers.length);
		return colors[index];
	}
	
	public static function getNumberFromId(id:Int):StudentNumber
	{
		var numbers:Array<StudentNumber> = AbstractEnumTools.getValues(StudentNumber);
		var index:Int = (id % numbers.length);
		return numbers[index];
	}
}