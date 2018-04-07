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
import com.firstplayable.hxlib.debug.tunables.Tunables;
import game.DataManager.ContentData;
import game.Step.StepTypes;
import game.def.RecipeTypes;
import game.def.GradeDefs;
import game.events.DataLoadedEvent;
import game.net.DatabaseInterface;
import game.net.NetAssets;
import game.net.schema.CountryAudioDef;
import game.net.schema.CountryDef;
import game.net.schema.DietaryPreferenceDef;
import game.net.schema.GameDef;
import game.net.schema.GameOptionDef;
import game.net.schema.IngredientDef;
import game.net.schema.MealTypeDef;
import game.net.schema.RecipeDef;
import game.net.schema.SocialIssueDef;
import game.net.schema.ToolDef;
import haxe.Json;
import openfl.utils.AssetType;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.utils.json.JsonObjectFactory;
import haxe.io.Path;
//import com.firstplayable.hxlib.loader.ResContext;

using StringTools;
/*
 * Handles game content supplied from the back-end. 
 * */

 // Type definitions for json parsing. Each table is represented as { rows: [ ... ] }
 typedef ContentData = { var rows : Array<Dynamic>; };
 
class DataManager
{
	public var allRecipes(default, null):Map<String, Recipe>; // Lists recipes, keyed by recipe name
	public var allCountries(default, null):Map<String, Country>; // Lists countries, keyed by country name
	public var allIngredients(default, null):Map<String, Ingredient>; // Lists ingredients, keyed by ingredient name
	public var allergens(default, null):Array<Ingredient>; // List of allergens currently flagged by user.
	public var favorites(default, null):Array<Recipe>; // List of recipes that have been marked "favorites", to appear in favorites menu.
	public var mathQuestions(default, null):Array< MultipleChoiceQuestion >;

	public static inline var BASE_SOUND_URL:String = "https://chefk-prod.s3.amazonaws.com/uploads/country_audio/file/";
	
	public function new()
	{
		this.allRecipes = new Map();
		this.allCountries = new Map();
		this.allIngredients = new Map();
		this.allergens = new Array();
		this.favorites = new Array();
		this.mathQuestions = new Array();
	}
	
	/**
	 * Inits the game logic data from data loaded from the database backend via DatabaseInterface
	 * @return
	 */
	public function init():EnumValue
	{
		// Parse data
		getAllIngredients();
		getAllRecipes();
		getAllCountries();
		getMathQuestions();
		
		if (Tunables.PRELOAD_ASSETS)
		{
			//Preload italy
			var italy:Country = getCountry("Italy");
			if (italy == null)
			{
				Debug.warn("no country called: " + "Italy");
			}
			else
			{
				NetAssets.instance.getImage(italy.coverImage);
			
				for (recipe in italy.recipes)
				{
					NetAssets.instance.getImage(recipe.images[0]);
				}
			}
		}
		
		// Load save using new data
		SpeckGlobals.saveProfile.get();
		
		// Let others know we've finished
		SpeckGlobals.event.dispatchEvent(new DataLoadedEvent());
		
		return null; // TODO - success/failure error enum
	}

	public function setDataFromSave( savedAllergens:Array< String >, savedFavorites:Array< String > ):Void
	{
		if ( savedAllergens != null )	
		{
			for ( ingredientName in savedAllergens )
			{
				trace( ingredientName );
				var i:Ingredient = allIngredients.get( ingredientName );
				allergens.push( i );
			}
		}
		if ( savedFavorites != null )	
		{
			for ( recipeName in savedFavorites )
			{
				trace( recipeName );
				var r:Recipe = allRecipes.get( recipeName );
				favorites.push( r );
			}
		}
	}
	
	// Returns true if item was successfully added (array length increases)
	public function addAllergen(i:Ingredient):Bool
	{
		var len:Int = this.allergens.length;
		var newlen:Int = this.allergens.push(i);
		var added:Bool = len < newlen;
		i.setAllergen( true );
		
		if ( added )
		{
			SpeckGlobals.saveProfile.setSavedAllergens( allergens );
		}
		
		return added;
	}
	
	// Returns true if item was removed (array length decreases)
	public function removeAllergen(i:Ingredient):Bool
	{
		var removed:Bool = false;
		
		for ( allergen in allergens )
		{
			if ( i.name == allergen.name )
			{
				removed = true;
				allergens.remove( allergen );
				break;
			}
		}
		
		if ( removed )
		{
			SpeckGlobals.saveProfile.setSavedAllergens( allergens );
		}
		
		return removed;
	}
	
	public function addFavorite( r:Recipe ):Bool
	{
		var len:Int = favorites.length;
		var newLen:Int = favorites.push( r );
		var added:Bool = len < newLen;
		
		if ( added )
		{
			SpeckGlobals.saveProfile.setSavedFavorites( favorites );
		}
		
		return added; 
	}
	
	public function removeFavorite( r:Recipe ):Bool
	{
		var removed:Bool = false;
		
		for ( fav in favorites )
		{
			if ( r.name == fav.name )
			{
				removed = true;
				favorites.remove( fav );
				break;
			}
		}
		
		if ( removed ) 
		{
			SpeckGlobals.saveProfile.setSavedFavorites( favorites );
		}
		
		return removed;
	}
	
	public function hasFavorite( r:Recipe ):Bool
	{
		for ( fav in favorites )
		{
			if ( r.name == fav.name )
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function hasAllergen( i:Ingredient ):Bool
	{
		for ( allergen in allergens )
		{
			if ( i.name == allergen.name )
			{
				return true;
			}
		}
		
		return false;
	}
	
	//===============================================================
	// Get game data
	//===============================================================
	
	public function getRecipe( name:String ):Recipe
	{
		var nameLower:String = name.toLowerCase();
		return allRecipes.get( nameLower );
	}
	
	public function getCountry( name:String ):Country
	{
		var nameLower:String = name.toLowerCase();
		return allCountries.get( nameLower );
	}
	
	//===============================================================
	// Load game data from the database backend
	//===============================================================
	
	/*
	 * Stitches together data from the database to create a map of the ingredients
	 * in a form used by the rest of the game.
	 * @return
	 */
	private function getAllIngredients():Map<String, Ingredient>
	{
		//TODO: this is a non-ideal way to do this.
		//When api is given support for returning ingredients directly
		//we can do this smarter.
		allIngredients = new Map<String, Ingredient>();
		
		var dbRecipes:Array<RecipeDef> = cast DatabaseInterface.ms_tableData[RECIPES];
		for (recipe in dbRecipes)
		{
			var dbIngredients:Array<IngredientDef> = recipe.ingredients;
			for (ingredient in dbIngredients)
			{
				var name:String = ingredient.name;
				var spotlight:String = ingredient.tip; // Is this the data we want?
				//we are not using units or amounts here since they are baked into the title.
				var newIngredient:Ingredient = new Ingredient(name, spotlight);
				allIngredients.set(newIngredient.name, newIngredient);
			}
		}
		
		return allIngredients;
	}
	
	/**
	 * Stitches together data from the database to create a map of the recipes
	 * in a form used by the rest of the game.
	 * @return
	 */
	private function getAllRecipes():Map<String, Recipe>
	{
		allRecipes = new Map<String, Recipe>();
		
		var countriesByID:Map<Int, CountryDef> = new Map<Int, CountryDef>();
		var dbCountries:Array<CountryDef> = cast DatabaseInterface.ms_tableData[COUNTRIES];
		for (country in dbCountries)
		{
			countriesByID[country.id] = country;
		}
		
		var dbRecipes:Array<RecipeDef> = cast DatabaseInterface.ms_tableData[RECIPES];
		for (recipe in dbRecipes)
		{
			var name:String = recipe.name.toLowerCase();
			if (name != null)
			{
				var id:Int = recipe.id;
				
				var presentation:String = recipe.presentation;
				var tools:Array<Tool> = getToolDataFromRecipe(recipe);
				
				var ingredients:Array<Ingredient> = getIngredientsFromRecipe(recipe);
				
				var types:Array<RecipeTypes> = getRecipeTypesFromRecipe(recipe);
				if (types == null)
				{
					Debug.log("unsupported recipe types in recipe #" + id + ": " + name);
					//don't include this recipe
					continue;
				}
				
				var steps:Array<Step> = getStepsFromRecipe(recipe);
				
				var dbImages:Array<String> = getImagesFromRecipe(recipe);
				var images:Array<String> = new Array();
				if (dbImages.length > 0)
				{
					for ( i in dbImages )
					{
						 images.push( dbImages[0] );//getSmallFileName( dbImages[0] ) );
					}
				}
				if (!countriesByID.exists(recipe.country_id))
				{
					Debug.log("no country with ID: " + recipe.country_id);
					continue;
				}
				var country:String = countriesByID[recipe.country_id].name.toLowerCase();
				
				var r = new Recipe(id, name, presentation, country, images, ingredients, tools, steps, types);
				allRecipes.set(name, r);
			}
			
		}
		
		return allRecipes;
	}
	
	/**
     * Gets the small file version of the provided file name
     * @param    originalFile
     * @return
     */
    private static function getSmallFileName(originalFile:String):String
    {
        if (originalFile == null)
        {
            return null;
        }
        
        var filenamePath:Path = new Path(originalFile);
        
        var smallImgURL:String = filenamePath.dir + "/" + filenamePath.file + "_small" + "." + filenamePath.ext;
        
        return smallImgURL;
    }
	
	/**
     * Gets the small file version of the provided file name
     * @param    originalFile
     * @return
     */
    private static function getSmallCountryFileName(originalFile:String):String
    {
        if (originalFile == null)
        {
            return null;
        }
        
        var filenamePath:Path = new Path(originalFile);
        
        var smallImgURL:String = filenamePath.dir + "/image" + filenamePath.file + "_small" + "." + filenamePath.ext;
        
        return smallImgURL;
    }
	
	/**
	 * Gets the game logic version of the recipe ingredients from the database
	 * PRE: assumes that allIngredients has been populated.
	 * @param	recipe
	 * @return
	 */
	private function getIngredientsFromRecipe(recipe:RecipeDef):Array<Ingredient>
	{
		var ingredients:Array<Ingredient> = [];
		for (ingredient in recipe.ingredients)
		{
			var nextIngredient:Ingredient = allIngredients.get(ingredient.name);
			if (nextIngredient == null)
			{
				Debug.warn("somehow ingredient didn't exist in allInredients: " + ingredient.name);
				continue;
			}
			
			ingredients.push(nextIngredient);
		}
		
		return ingredients;
	}
	
	/**
	 * Gets the game logic version of the recipe types from the database
	 * @param	recipe
	 * @return
	 */
	private function getRecipeTypesFromRecipe(recipe:RecipeDef):Array<RecipeTypes>
	{
		var types:Array<RecipeTypes> = [];
		
		//Gets types from dietary_preferences
		for (preference in recipe.dietary_preferences)
		{
			var nextType:RecipeTypes = translateRecipeTypeFromDietaryPreference(preference);
			if (nextType == null)
			{
				//Missing a dietary preference is not dangerous if it's on a recipe
				//since dietary preferences are always the absence of something
				//never the presence of something
				continue;
			}
			types.push(nextType);
		}
		
		//Gets types from meal_types
		for (mealType in recipe.meal_types)
		{
			var nextType:RecipeTypes = translateRecipeTypeFromMealType(mealType);
			if (nextType == null)
			{
				continue;
			}
			types.push(nextType);
		}
		
		return types;
	}
	
	/**
	 * Returns the game logic version of a recipe type from the database
	 * @param	type
	 * @return
	 */
	private function translateRecipeTypeFromMealType(type:MealTypeDef):RecipeTypes
	{
		var name:String = type.name;
		
		if (name == "Appetizer")
		{
			return APPETIZERS;
		}
		
		if (name == "Breakfast")
		{
			return BREAKFAST;
		}
		
		if (name == "Main Course")
		{
			return MAINCOURSE;
		}
		
		if (name == "Dessert")
		{
			return DESSERT;
		}
		
		Debug.log("unhandled meal type: " + name);
		return null;
	}
	
	/**
	 * Returns the game logic version of a recipe type from the database
	 * @param	type
	 * @return
	 */
	private function translateRecipeTypeFromDietaryPreference(type:DietaryPreferenceDef):RecipeTypes
	{
		var name:String = type.name;

		if (name == "Vegetarian")
		{
			return VEGETARIAN;
		}
		
		if (name == "Dairy Free")
		{
			return DAIRYFREE;
		}
		
		if (name == "Gluten Free")
		{
			return GLUTENFREE;
		}
		
		Debug.log("unhandled dietary preference: " + name);
		return null;
	}
	
	/**
	 * Gets game logic versions of the recipe steps from the database
	 * @param	recipe
	 * @return
	 */
	private function getStepsFromRecipe(recipe:RecipeDef):Array<Step>
	{
		var steps:Array<Step> = [];
		
		for (step in recipe.steps)
		{
			var stepNumber:Int = steps.length;
			var stepType:StepTypes = translateStepTypeFromDatabase(step.type);
			var instruction:String = step.text;
			var nextStep:Step = new Step(stepNumber, stepType.getIndex(), instruction);
			steps.push(nextStep);
		}
		
		return steps;
	}
	
	/**
	 * Returns the game logic version of a recipe step type from the database
	 * @param	type
	 * @return
	 */
	private function translateStepTypeFromDatabase(type:String):StepTypes
	{
		if (type == "Little chef")
		{
			return LITTLECHEF;
		}
		else
		{
			//Default to big chef if not little chef
			//Safer to make an adult to the step.
			return BIGCHEF;
		}
	}
	
	/**
	 * Gets game logic versions of the recipe images from the database
	 * @param	recipe
	 * @return
	 */
	private function getImagesFromRecipe(recipe:RecipeDef):Array<String>
	{
		var images:Array<String> = [];
		for (image in recipe.images)
		{
			var newImage:String = image.image;
			images.push(newImage);
		}
		
		return images;
	}
	
	/**
	 * Gets game logic versions of the tools used by a recipe
	 * @return
	 */
	private function getToolDataFromRecipe(recipe:RecipeDef):Array<Tool>
	{
		var tools:Array<Tool> = [];
		for (tool in recipe.tools)
		{
			var newTool:Tool = translateToolFromDatabase(tool);
			tools.push(newTool);
		}
		
		return tools;
	}
	/**
	 * Creates a game logic version of a social issue from a backend database version
	 * @param	issue
	 * @return
	 */
	private function translateToolFromDatabase(tool:ToolDef):Tool
	{
		var name:String = tool.name;
		var url:String = tool.url;
		return new Tool(name, url);
	}
		
	/**
	 * Stitches together data from the database to create a map of the countries
	 * in a form used by the rest of the game.
	 * @return
	 */
	private function getAllCountries():Map<String, Country>
	{
		allCountries = new Map<String, Country>();
		
		//===========================================================
		// Map of what audios each country has, which will be used to
		// generate game logic country objects.
		//===========================================================
		var audiosByCountryId:Map<Int, Array<CountryAudioDef>> = new Map < Int, Array<CountryAudioDef>>();
		var databaseAudios:Array<CountryAudioDef> = cast DatabaseInterface.ms_tableData[COUNTRY_AUDIOS];
		for (audio in databaseAudios)
		{
			if (!audiosByCountryId.exists(audio.country_id))
			{
				audiosByCountryId[audio.country_id] = [];
			}
			audiosByCountryId[audio.country_id].push(audio);
		}
		
		//===========================================================
		// Map of what recipes each country has, which will be used to
		// generate game logic country objects.
		//===========================================================
		var recipesByCountryId:Map<Int, Array<RecipeDef>> = new Map<Int, Array<RecipeDef>>();
		var databaseRecipes:Array<RecipeDef> = cast DatabaseInterface.ms_tableData[RECIPES];
		for (recipe in databaseRecipes)
		{
			recipe.name = recipe.name.toLowerCase();
			if (!recipesByCountryId.exists(recipe.country_id))
			{
				recipesByCountryId[recipe.country_id] = [];
			}
			recipesByCountryId[recipe.country_id].push(recipe);
		}
		
		//===========================================================
		// Generate game logic country objects.
		//===========================================================
		var databaseCountries:Array<CountryDef> = cast DatabaseInterface.ms_tableData[COUNTRIES]; 
		for (country in databaseCountries)
		{
			//========================================
			// Pull together general country data
			//========================================
			var id:Int = country.id;
			var name:String = country.name.toLowerCase();
			var population:Int = country.population;
			var capital:String = country.capital;
			var code:String = country.code;
			var cover:String = country.country_image;//getSmallCountryFileName( country.country_image );
			var flag:String = getSmallFileName( country.country_flag );
			var wish:String = country.salutation;
			
			var socialIssues:Array<SocialIssue> = getSocialIssuesFromCountry(country);
			var facts:Array<String> = getFactsFromCountry(country);
			
			var countryRecipes:Array<RecipeDef> = recipesByCountryId.get(id);
			var recipes:Array<Recipe> = [];
			
			//Not all countries will have recipes!
			if (countryRecipes != null)
			{
				for (dbRecipe in countryRecipes)
				{
					var newRecipe:Recipe = translateRecipeFromDatabase(dbRecipe);
					if (newRecipe == null)
					{
						//somehow this failed...
						//don't add the recipe
						continue;
					}
					recipes.push(newRecipe);
				}
			}
			
			//========================================
			// Pull together audio data
			//========================================
			var music:String = null;
			var greeting:String = null;
			var mealAudio:String = null;

			var baseUrl = BASE_SOUND_URL;
			
			var allAudio:Array<CountryAudioDef> = audiosByCountryId.get(id);
			if (allAudio != null)
			{
				//The audio schema is really weird.
				//From what I can determine, audio info for countries is held
				//separately in "country_audios" for some reason.
				
				//In the actual database, entries say which country they are the "greeting" audio for
				//and also which country they are the "bon apetite" audio for.
				//There seems to be no column for if they are "music" for a country.
				
				//There is another table called "musics" in the database.
				//this just seems to be a list of files, with no way to figure out what they'e supposed to be.
				//It is also empty.
				
				//Unfortunately, we can't even use all the country audio info, because the api only returns
				//which country a given element belongs to, not what type of audio it is.
				//For now we will just arbitrarily map the first sound as the music.
				
				//TODO: FIX THIS when it's possible.
				if (allAudio.length > 0)
				{
					music = allAudio[0].file;

					// The only place we ger a full URL for a sound file is with the country audio
					// that we get here.  The greeting and bonappetit audios only give us a filename
					// and id number.  So we cheat and grab the base url here (just in case it ever 
					// changes from the default) and stitch together base/id/filename below.
					var soundId:String = Std.string(allAudio[0].id);
					var i = music.lastIndexOf(soundId);

					if (i != -1)
					{
						baseUrl = music.substring(0, i);
					}
				}
			}

			if (country.greeting_audio != null)
			{
				var g = country.greeting_audio[0];
				if (g != null)
				{
					greeting = baseUrl + g.id + "/" + g.url;
				}
			}

			if (country.bonappetit_audio != null)
			{
				var ba = country.bonappetit_audio[0];
				if (ba != null)
				{
					mealAudio = baseUrl + ba.id + "/" + ba.url;
				}
			}

			//========================================
			// Create the Country object
			//========================================
			var c:Country = new Country(id, name, socialIssues, population, capital, code, cover, flag, wish, recipes, facts, 
				music, greeting, mealAudio);
			allCountries.set(name, c);
		}
		
		return allCountries;
	}
	
	/**
	 * Creates game logic versions of Social Issues from the backend database version
	 * @param	country
	 * @return
	 */
	private function getSocialIssuesFromCountry(country:CountryDef):Array<SocialIssue>
	{
		var issues:Array<SocialIssue> = [];
		for (issue in country.social_issues)
		{
			var newIssue:SocialIssue = translateSocialIssueFromDatabase(issue);
			issues.push(newIssue);
		}
		
		return issues;
	}
	
	/**
	 * Creates a game logic version of a social issue from a backend database version
	 * @param	issue
	 * @return
	 */
	private function translateSocialIssueFromDatabase(issue:SocialIssueDef):SocialIssue
	{
		var description:String = issue.issue;
		var url:String = issue.url;
		return new SocialIssue(description, url);
	}
	
	/**
	 * Creates game logic versions of Country Facts from the backend database version
	 * @param	country
	 * @return
	 */
	private function getFactsFromCountry(country:CountryDef):Array<String>
	{
		var facts:Array<String> = [];
		for (fact in country.fact)
		{
			var newFact:String = fact.name;
			facts.push(newFact);
		}
		
		return facts;
	}
	
	/**
	 * Creates game logic versions of a Recipe from the backend database version
	 * @param	country
	 * @return
	 */
	private function translateRecipeFromDatabase(recipe:RecipeDef):Recipe
	{
		var receipeName:String = recipe.name;
		var foundRecipe:Recipe = allRecipes.get(recipe.name);
		if (foundRecipe == null)
		{
			Debug.log("recipe not found in allRecipes: " + recipe.name);
		}
		
		return foundRecipe;
	}
	
	/**
	 * Stitches together data from the database to create a map of the math questions
	 * in a form used by the rest of the game.
	 * @return
	 */
	private function getMathQuestions():Array< MultipleChoiceQuestion >
	{
		mathQuestions = new Array<MultipleChoiceQuestion>();
		
		var dbQuestions:Array<GameDef> = cast DatabaseInterface.ms_tableData[GAMES];
		for (question in dbQuestions)
		{
			if (question.type != "math")
			{
				continue;
			}
			
			var nextQuestion:MultipleChoiceQuestion = getMultipleChoiceQuestionFromDatabase(question);
			mathQuestions.push(nextQuestion);
		}
		
		return mathQuestions;
	}
	
	/**
	 * Creates game logic versions of a MultipleChoiceQuestion from the backend database version
	 * @param	question
	 */
	private function getMultipleChoiceQuestionFromDatabase(question:GameDef):MultipleChoiceQuestion
	{
		var wordedProblem:String = question.worded_question;
		var mathProblem:String = question.question;
		
		var correctOption:String = translateMultipleChoiceOptionFromDatabase(question.correct_option);
		
		var wrongOptions:Array<String> = [];
		for (option in question.options)
		{
			//don't include the correct option
			if (option.id == question.correct_option.id)
			{
				continue;
			}
			
			var nextOption:String = translateMultipleChoiceOptionFromDatabase(option);
			wrongOptions.push(nextOption);
		}
		
		var question:MultipleChoiceQuestion = new MultipleChoiceQuestion(wordedProblem, mathProblem, wrongOptions, correctOption);
		return question;
	}
	
	/**
	 * Creates game logic versions of a multiple choice option from the backend database version
	 * @param	country
	 * @return
	 */
	private function translateMultipleChoiceOptionFromDatabase(option:GameOptionDef):String
	{
		return option.value;
	}
}