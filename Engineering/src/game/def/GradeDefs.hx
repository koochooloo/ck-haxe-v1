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

package game.def;
import game.cms.Grade;

class GradeDefs
{
	public static var GRADE_K_COUNTRIES:Array<String> = [
		"germany",
		"ireland",
		"russia",
		"turkey",
		"greece",
		"kenya",
		"el salvador",
		"sri lanka",
		"cambodia",
		"ethiopia"
	];
	/**
	 * Countries in the order they're unlocked for this grade
	 */
	public static var GRADE_1_COUNTRIES:Array< String > = [
		"italy", 
		"france",
		"south korea",
		"iran", 
		"india",
		"thailand",
		"japan", 
		"nigeria",
		"mexico", 
		"united states"
	];
	
	/**
	 * Countries in the order they're unlocked for this grade
	 */
	public static var GRADE_2_COUNTRIES:Array< String > = [
		"spain", 
		"united kingdom",
		"phillippines",
		"egypt", 
		"china",
		"israel",
		"vietnam", 
		"angola",
		"peru", 
		"costa rica"
	];
	
	/**
	 * Which country data is used for which grades
	 */
	public static var COUNTRIES_BY_GRADE:Map<Grade, Array<String>> = [
		Grade.KINDERGARTEN => GRADE_K_COUNTRIES,
		Grade.FIRST => GRADE_1_COUNTRIES,
		Grade.SECOND => GRADE_2_COUNTRIES
	];
	
	/**
	 * Determines if the provided country is part of the provided grade level curriculum.
	 * @param	countryName
	 * @param	grade
	 * @return
	 */
	public static function isCountryForThisGrade(countryName:String, grade:Grade):Bool
	{
		var countryList:Array<String> = COUNTRIES_BY_GRADE.get(grade);
		if (countryList == null)
		{
			return false;
		}
		
		return (countryList.indexOf(countryName) != -1);
	}
}