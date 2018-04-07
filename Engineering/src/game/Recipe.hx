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
import game.def.RecipeTypes;

class Recipe
{
	public var id(default, null):Int; //database id of recipe
	public var name(default, null):String; // Name of recipe
	public var presentation(default, null):String; // Serving instructions for the dish
	public var country(default, null):String; // Country of origin
	public var images(default, null):Array<String>; // Image of the finished dish (URL)
	public var ingredients(default, null):Array<Ingredient>; // List of ingredients required to make the dish
	public var tools(default, null):Array<Tool>; // List of tools required to make the dish
	public var steps(default, null):Array<Step>; // List of step-by-step preparation instructions
	public var types(default, null):Array<RecipeTypes>; // Type/s of dish for menu and search filtering (see def.RecipeTypes)
	
	public function new(id:Int, name:String, presentation:String, country:String, images:Array<String>, ingredients:Array<Ingredient>, tools:Array<Tool>, steps:Array<Step>, types:Array<RecipeTypes>) 
	{
		this.name = name;
		this.id = id;
		this.presentation = presentation;
		this.country = country;
		this.images = images;
		this.ingredients = ingredients;
		this.tools = tools;
		this.steps = steps;
		this.types = types;
	}
	
	/** 
	 * To be used for debug
	 * */
	public function setName( name:String )
	{
		this.name = name;
	}
	
	// Returns true if the parameter ingredient is incorporated in the recipe. 
	public function hasIngredient(ingredient:Ingredient):Bool
	{
		for (i in this.ingredients)
		{
			if (i.equals(ingredient))
			{
				return true;
			}
		}
		
		return false;
	}
	
	// Returns true if recipe has no allergens, and has the given recipe type/s.
	public function isViable(types:Array<RecipeTypes>):Bool
	{
		var allergens:Array<Ingredient> = SpeckGlobals.dataManager.allergens;
		var a:Bool = true; 
		var t:Bool = true;
		
		if (allergens.length > 0)
		{
			a = !hasAllergen(allergens);
		}
		if (types.length > 0)
		{
			t = hasType(types);
		}
	
		return a && t;
	}
	
	// Returns true if recipe contains an allergen ingredient.
	public function hasAllergen(allergens:Array<Ingredient>):Bool
	{
		for (i in allergens)
		{
			if (hasIngredient(i))
			{
				return true;
			}
		}
		
		return false;
	}
	
	// Returns true if the recipe has all types in the provided filter list
	public function hasType(recipeTypes:Array<RecipeTypes>):Bool
	{
		var b:Bool = true;
		
		for (t in recipeTypes)
		{
			if (this.types.indexOf(t) < 0) // Returns -1 when t is not in the array
			{
				b = false;
			}
		}
		
		return b;
	}
	
	
}