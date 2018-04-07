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

class Ingredient
{
	public var name(default, null):String; // Name of the ingredient
	public var spotlight(default, null):String; // Bonus information about the ingredient in science or culture. Optional in dataset - may be NULL.
	public var amount(default, null):Float; // (Optional) Associated with a specific recipe. 
	public var unit(default, null):String; // (Optional) Associated with a specific recipe.
	public var isAllergen(default, null):Bool; // Flipped by user, flags whether or not the ingredient should be excluded from country/recipe search. 
	
	public function new(name:String, ?spotlight:String, ?amount:Float, ?unit:String) 
	{
		this.name = name;
		this.spotlight = spotlight;
		this.amount = amount;
		this.unit = unit;
		this.isAllergen = false; // All recipes displayed by default
	}
	
	// Allows ingredient allergen status to be flipped in the Allergens Menu/Data Manager.
	public function setAllergen( b:Bool ):Void
	{
		isAllergen = b;
	}
	
	// Returns true if ingredients match. (Names are unique.) 
	public function equals(i:Ingredient):Bool
	{
		if (i.name == this.name)
		{
			return true;
		}
		
		return false;
	}
}