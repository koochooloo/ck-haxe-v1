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

package game;
import com.firstplayable.hxlib.Debug;
import game.SocialIssue;

/**
 * Class that holds the data tied to specific countries that we need for game logic.
 */
class Country
{
	private static inline var DEFAULT_WEEK = -1;
	public var id(default, null):Int;
	public var name(default, null):String; 
	public var socialIssues(default, null):Array<SocialIssue>; // Description & charity for relevant social issues in the country/
	public var population(default, null):Int; 
	public var capital(default, null):String; 
	public var code(default, null):String; // Country code
	public var coverImage(default, null):String; // Image used in an informational color page (URL)
	public var flagImage(default, null):String; // Image used in flag game, country list (URL)
	public var wish(default, null):String; // Phrase said when serving a meal; "Enjoy your meal!" etc. Displayed in Recipe Serving page.
	public var recipes(default, null):Array<Recipe>; // List of recipes attributed to this country.
	public var facts(default, null):Array<String>;
	public var music(default, null):String; // Music to play in country page, country recipe pages. (URL)
	public var greetingAudio(default, null):String;  // URL of the "greeting" audio for this country
	public var mealAudio(default, null):String;  // URL of the "bon apetite" audio for this country
	public var pilotWeek:Int;
	
	/**
	 * Constructor for the game logic version of a Country.
	 * @param	id
	 * @param	name
	 * @param	socialIssues
	 * @param	population
	 * @param	capital
	 * @param	code
	 * @param	coverImage
	 * @param	flagImage
	 * @param	wish
	 * @param	recipes
	 * @param	facts
	 * @param	music
	 * @param	greetingAudio
	 * @param	mealAudio
	 */
	public function new(id:Int, 
		name:String, 
		socialIssues:Array<SocialIssue>, 
		population:Int, 
		capital:String, 
		code:String, 
		coverImage:String, 
		flagImage:String, 
		wish:String, 
		recipes:Array<Recipe>, 
		facts:Array<String>,
		music:String, 
		greetingAudio:String,
		mealAudio:String)
	{
		this.id = id;
		this.name = name;
		this.socialIssues = socialIssues;
		this.population = population;
		this.capital = capital;
		this.code = code;
		this.coverImage = coverImage;
		this.flagImage = flagImage;
		this.wish = wish;
		this.recipes = recipes;
		this.music = music;
		this.facts = facts;
		this.greetingAudio = greetingAudio;
		this.mealAudio = mealAudio;
		this.pilotWeek = DEFAULT_WEEK; // default
	}
	
	public static function sortAlpha( a:Country, b:Country ):Int
	{
		a.name.toLowerCase();
		b.name.toLowerCase();
		if ( a.name > b.name ) 		return 1;
		else if ( a.name < b.name ) return (-1)
		else 						return 0;
	}
	
	public static function sortWeek( a:Country, b:Country ):Int
	{
		if ( a.pilotWeek > DEFAULT_WEEK && b.pilotWeek > DEFAULT_WEEK )
		{
			if ( a.pilotWeek > b.pilotWeek ) 		return 1;
			else if ( a.pilotWeek < b.pilotWeek ) return (-1)
			else 						return 0;
		}
		else
		{
			Debug.log( "No pilot data for " + a.name + " and " + b.name );
			return 0;
		}

	}
	
}