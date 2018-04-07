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

import game.cms.Curriculum;
import game.cms.Grade;
import game.cms.Question;
import game.cms.QuestionDatabase;
import game.cms.QuestionQuery;

/**
 * Collection of constants and values useful for the demo version of game.
 */
class DemoDefs
{	
	private static inline var NUM_WEEKS:Int = 10;
	
	public static function getRecipeForCountry( countryName:String ):Recipe
	{
		var recipe:Recipe = null;
		
		// Get a question with the given country in it 
		var socialSet:Array< Question > = QuestionDatabase.instance.query().aboutCountry( countryName ).finish();
		var data:Question = socialSet[0];
		
		if ( data != null )
		{
			// Pull the grade/week from that country
			var grade:Grade = data.grade;
			
			var week:Int = switch( data.week )
			{
				case Some( w ): w;
				case None: 1;  // Arbitrary default?
			}
			
			// Grab a recipe with that data
			recipe = SpeckGlobals.dataManager.getRecipe( getRecipe( grade, week ) );
		}
		
		// Test recipe against dataset
		if ( recipe == null )
		{
			recipe = SpeckGlobals.dataManager.getRecipe( "Spring Rolls" ); // Arbitrary default
			recipe.setName( "DEFAULT RECIPE, INSUFFICIENT DATA" );
			trace( "Warning! No recipe data for " + countryName + ". Using default." );
		}
		
		return recipe;
	}
	
	public static function getRecipe( grade:Grade, week:Int ):String
	{
		var questionSet:Array< Question > = QuestionDatabase.instance.query().forWeek( week )
																   .forGrade( grade )
																   .withCurriculum( Curriculum.MATH_AND_SCIENCE )
																   .finish();
		
		// Loop to try and find a recipe name in the dataset
		var recipeName:String = null; 
		for ( question in questionSet )
		{
			switch question.recipe
			{
				case Some( name ): 
				{
					recipeName = name;
				}
				
				case None: // continue 
			}
			
			// WORKAROUND FOR CURRENT HAXE->JS IMPLEMENTATION
			// Break outside of the switch statement to avoid throwing an exception
			if ( recipeName != null )
			{
				break;
			}
		}
		
		// Set to default if we couldn't find anything
		if (recipeName == null) recipeName = "Spring Rolls";

		return recipeName;
	}
	
	// Old DEMO dataset
	

	 public static var DEMOCOUNTRIES:Array< String > = [ 
		"France", 
		"India", 
		"Iran", 
		"Israel", 
		"Italy", 
		"Mexico", 
		"Nigeria", 
		"Philippines", 
		"United States", 
		"Vietnam" 
	];

	 public static var DEMOCOUNTRYRECIPES:Map< String, String > = [
		"France" => "Whole Wheat Crepes", 
		"India" => "Green Gram Sprouts Salad", 
		"Iran" => "Persian Meat Balls", 
		"Israel" => "Potato pancake", 
		"Italy" => "Tomato and Olive Penne", 
		"Mexico" => "Tuna Sandwiches", 
		"Nigeria" => "Coconut Rice", 
		"Philippines" => "Filipino Noodles", 
		"United States" => "American Potato Salad", 
		"Vietnam" => "Spring Rolls"
	];
}