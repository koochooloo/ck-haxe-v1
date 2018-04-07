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

package game.question;
import com.firstplayable.hxlib.Debug;
import game.question.QuestionBank.QuestionCollection;
import haxe.ds.StringMap;

@:allow(game.question.QuestionBank)
class QuestionCollection
{
	/**
	 * The identifier for this collection
	 */
	private var m_key:String;
	
	/**
	 * Set of questions for this collection.
	 * Will be null on non-top level classes
	 */
	private var m_questions:Array<String>;
	
	/**
	 * Sub collection of this collection.
	 * Will be null on the leaf level of the structure.
	 */
	private var m_collection:StringMap<QuestionCollection>;
	
	/**
	 * Constructs the collection
	 * @param	keyName
	 */
	public function new(keyName:String)
	{
		m_key = keyName;
		
		m_questions = null;
		m_collection = null;
	}
	
	/**
	 * Sets the collection as a leaf node with no questions
	 */
	private function setAsLeafNode():Void
	{
		if (m_collection != null)
		{
			Debug.warn("this collection already has sub collections. Can't set as leaf node");
			return;
		}
		
		if (m_questions == null)
		{
			m_questions = [];
		}
	}
	
	/**
	 * Sets this collection as a leaf collection by giving it a new question.
	 * @param	question
	 */
	private function giveQuestion(question:String):Void
	{
		if (m_collection != null)
		{
			Debug.warn("this collection already has sub collections. Can't give questions");
			return;
		}
		
		if (m_questions == null)
		{
			m_questions = [];
		}
		
		m_questions.push(question);
	}
	
	/**
	 * Sets this collection as a node by giving it a sub collection.
	 * @param	collection
	 */
	private function giveCollection(collection:QuestionCollection):Void
	{		
		if (collection == null)
		{
			Debug.warn("Collection is null...");
			return;
		}
		
		if (m_questions != null)
		{
			Debug.warn("already have questions on this collection. Destroying...");
			m_questions = null;
		}
		
		if (m_collection == null)
		{
			m_collection = new StringMap<QuestionCollection>();
		}
		
		if (m_collection.exists(collection.m_key))
		{
			Debug.warn("already have key: " + collection.m_key);
			return;
		}
		
		m_collection.set(collection.m_key, collection);
	}
	
	/**
	 * Returns a subcollection from this collection
	 * @param	key
	 * @return
	 */
	private function getSubCollection(key:String):QuestionCollection
	{
		if (m_collection == null)
		{
			return null;
		}
		
		return m_collection.get(key);
	}
	
	/**
	 * Gets the key for this subcollection
	 * @return
	 */
	private function getKeys():Iterator<String>
	{
		if (isLeafNode())
		{
			Debug.warn("Is leaf node, has no keys!");
			return null;
		}
		
		return m_collection.keys();
	}
	
	/**
	 * Returns whether this collection is a leaf node.
	 * @return
	 */
	private function isLeafNode():Bool
	{
		return (m_collection == null);
	}
	
	/**
	 * Attempts to return the collection of questions for the provided args.
	 * @param	args
	 * @return
	 */
	private function getQuestions(args:Array<String>):Array<String>
	{
		if (args == null)
		{
			Debug.warn("at " + m_key + ": no args provided!");
			return null;
		}
		
		if (args.length == 0)
		{
			if (m_questions == null)
			{
				Debug.warn("at " + m_key + ": got to end of args, and have no questions!");
				return null;
			}
			
			return m_questions;
		}
		
		if (m_collection == null)
		{
			Debug.warn("at " + m_key + ": have more args: " + args + " but no sub collection!");
			return null;
		}
		
		var nextKey:String = args.shift();
		var subcollection:QuestionCollection = m_collection.get(nextKey);
		if (subcollection == null)
		{			
			Debug.log("at " + m_key + ": no subcollection with name: " + nextKey);
			return null;
		}
		
		//Recursive call with less args.
		return subcollection.getQuestions(args);
	}
	
	/**
	 * Returns a copy of this collection
	 * @return
	 */
	private function copy():QuestionCollection
	{
		var newCollection:QuestionCollection = new QuestionCollection(m_key);
		
		//If we're copying a leaf, copy all the questions.
		if (isLeafNode())
		{
			if (m_questions == null)
			{
				m_questions = [];
				newCollection.setAsLeafNode();
			}
			else
			{
				for (question in m_questions)
				{
					newCollection.giveQuestion(question);
				}
			}
			
			return newCollection;
		}
		
		//Otherwise, we need to go deeper...
		for (key in m_collection.keys())
		{
			var oldSubCollection:QuestionCollection = getSubCollection(key);
			var newSubCollection:QuestionCollection = oldSubCollection.copy();
			newCollection.giveCollection(newSubCollection);
		}
		
		return newCollection;
	}
	
	/**
	 * Prints this collection in a readable format
	 */
	private function toString():String
	{
		var returnString:String = "Root Collection " + m_key + ":";
		
		if (isLeafNode())
		{
			if (m_questions == null)
			{
				m_questions = [];
				returnString += "\n\tMISSING: ";
			}
			else
			{
				if (m_questions.length == 0)
				{
					returnString += "\n\tNo Questions";
				}
				else
				{
					for (question in m_questions)
					{
						returnString += "\n\t" + question;
					}
				}
			}
		}
		else
		{
			for (key in getKeys())
			{
				var subCollection:QuestionCollection = getSubCollection(key);
				if (subCollection == null)
				{
					returnString += "\n\tMISSING: " + key;
				}
				else
				{
					returnString += subCollection.toStringHelper(1);
				}
			}
		}
		
		return returnString;
	}
	
	/**
	 * Prints a sub collection with the proper depth level
	 * @param	depth
	 * @return
	 */
	private function toStringHelper(depth:Int):String
	{
		var returnString = "\n";
		
		var indentation:String = "";
		//Indent
		for (i in 0...depth)
		{
			indentation += "\t";
		}
		returnString += indentation;		
		if (isLeafNode())
		{
			indentation += "\t";
			returnString += "Leaf Node: " + m_key;
			if (m_questions == null)
			{
				m_questions = [];
				returnString += "\n" + indentation + "MISSING!";
			}
			else
			{
				if (m_questions.length == 0)
				{
					returnString += "\n" + indentation + "0 Questions";
				}
				else
				{
					for (question in m_questions)
					{
						returnString += "\n" + indentation + question;
					}
				}
			}
		}
		else
		{
			returnString += "Node: " + m_key;
			for (key in getKeys())
			{
				var subCollection:QuestionCollection = getSubCollection(key);
				if (subCollection == null)
				{
					returnString += "\n" + indentation + "MISSING: " + key;
				}
				returnString += subCollection.toStringHelper(depth + 1);
			}
		}
		
		return returnString;
	}
}

/**
 * Class that creates a usable question bank out of a values list
 * provided by the string exporter.
 */
class QuestionBank 
{
	/**
	 * Collection of all question ids. Mapped for type -> level.
	 */
	private var m_questionBankMaster:StringMap<QuestionCollection>;
	
	/**
	 * Collection of all unasked question ids. Mapped for type -> level.
	 * Refreshes from the master bank if no questions are left for a given type -> level
	 */
	private var m_questionBankCurrent:StringMap<QuestionCollection>;
	
	/**
	 * Name of the bank.
	 */
	private var name(default, null):String;
	
	/**
	 * Whether we should ask all questions before repeating.
	 */
	private var m_randomExhaustive:Bool;
	
	/**
	 * Construct the question bank
	 * @param	values			XML values string map from string exporter
	 * @param	sortArguments	Array of arguments in the lookup order of the bank.
	 * @param 	exhaustive		Whether we should ask all questions before repeating.
	 */
	public function new(nm:String, values:StringMap<Dynamic>, sortArguments:Array<String>, exhaustive:Bool = true) 
	{
		m_questionBankMaster = null;
		m_questionBankCurrent = null;
		
		if (values == null)
		{
			Debug.warn("values was null. Can't make question bank.");
			return;
		}
		if (sortArguments == null)
		{
			Debug.warn("sortArguments was null. Can't make question bank.");
			return;
		}
		if (sortArguments.length == 0)
		{
			Debug.warn("0 Sort arguments provided. Need at least 1 to make question bank.");
			return;
		}

		m_questionBankMaster = initBank(values, sortArguments);
		m_questionBankCurrent = copyBank(m_questionBankMaster);
		
		name = nm;
		m_randomExhaustive = exhaustive;
	}
	
	//==================================================================
	// Structure construction and maintenance
	//==================================================================
	
	/**
	 * Inits the master question bank based on the provided arguments
	 * @param	values
	 * @param	sortArguments
	 */
	private static function initBank(values:StringMap<Dynamic>, sortArguments:Array<String>):StringMap<QuestionCollection>
	{
		var bank:StringMap<QuestionCollection> = new StringMap<QuestionCollection>();
		
		for (questionKey in values.keys())
		{
			var question:Dynamic = values.get(questionKey);
			var argumentValues:Array<String> = getArgumentValues(question, sortArguments);
			if (argumentValues == null)
			{
				Debug.warn("failure constructing question. argument values null. skipping...");
				continue;
			}
			
			if (argumentValues.length == 0)
			{
				Debug.warn("failure constructing question. 0 argument values. skipping...");
				continue;
			}
			if (argumentValues.indexOf("") != -1)
			{
				Debug.log("invalid question: " + questionKey + ", has blank entry in one of its indexed columns");
			}
			
			//Get the root question collection
			var firstVal:String = argumentValues.shift();
			
			var rootCollection:QuestionCollection = bank.get(firstVal);
			if (rootCollection == null)
			{
				rootCollection = new QuestionCollection(firstVal);
				bank.set(firstVal, rootCollection);
			}
			
			//Go down the tree, building nodes as needed until we reach the end
			var curCollection:QuestionCollection = rootCollection;
			for(nextValue in argumentValues)
			{
				var subCollection:QuestionCollection = curCollection.getSubCollection(nextValue);
				if (subCollection == null)
				{
					subCollection = new QuestionCollection(nextValue);
					curCollection.giveCollection(subCollection);
				}
				
				curCollection = subCollection;
			}
			
			// Add this question to the leaf node.
			curCollection.giveQuestion(questionKey);
		}
		
		return bank;
	}
	
	/**
	 * Returns the values for each of the provided arguments in order, returning null on failure
	 * @param	question
	 * @param	sortArguments
	 * @return
	 */
	private static function getArgumentValues(question:Dynamic, sortArguments:Array<String>):Array<String>
	{
		var values:Array<String> = [];
		for (args in sortArguments)
		{
			if (!Reflect.hasField(question, args))
			{
				Debug.warn("question does not have field: " + args + ": " + Std.string(question));
				return null;
			}
			var val:String = Std.string(Reflect.field(question, args));
			values.push(val);
		}
		
		return values;
	}
	
	/**
	 * Provides a copy of the provided question bank, with a shallow copy of the leaf question array.
	 * @param	bank
	 * @return
	 */
	private static function copyBank(bank:StringMap<QuestionCollection>):StringMap<QuestionCollection>
	{
		if (bank == null)
		{
			return null;
		}
		
		var newBank:StringMap<QuestionCollection> = new StringMap<QuestionCollection>();
		
		for (key in bank.keys())
		{
			var oldRootCollection:QuestionCollection = bank.get(key);
			var newRootCollection:QuestionCollection = oldRootCollection.copy();
			newBank.set(key, newRootCollection);
		}
		
		return newBank;
	}
	
	/**
	 * Refreshes the current bank for the provided keys from the master bank.
	 * Returns null on failure
	 * @param	args
	 * @return 	the refreshed questions
	 */
	private function refreshQuestionBank(args:Array<String>):Array<String>
	{
		Debug.log("Refreshing bank: " + name);
		
		var refreshArgs:Array<String> = args.copy();
		
		//========================================
		// Find the master list of questions for provided arguments
		//========================================
		var initialKey:String = refreshArgs.shift();
		var masterArgs:Array<String> = refreshArgs.copy();
		var masterRootCollection:QuestionCollection = m_questionBankMaster.get(initialKey);
		if (masterRootCollection == null)
		{
			Debug.warn("No questions in master collection for key: " + initialKey);
			return null;
		}
		
		var masterQuestions:Array<String> = masterRootCollection.getQuestions(masterArgs);
		if (masterQuestions == null)
		{
			return null;
		}
		
		if (masterQuestions.length == 0)
		{
			Debug.warn("tried refresh for " + args + " but 0 questions found!");
			return null;
		}
		
		//========================================
		// Refresh the current bank.
		//========================================
		var currentRootCollection:QuestionCollection = m_questionBankCurrent.get(initialKey);
		if (currentRootCollection == null)
		{
			Debug.warn("No questions in current collection for key: " + initialKey);
			return null;
		}
		
		var currentArgs:Array<String> = refreshArgs.copy();
		var currentQuestions:Array<String> = currentRootCollection.getQuestions(currentArgs);
		if (currentQuestions == null)
		{
			return null;
		}
		if (currentQuestions.length != 0)
		{
			Debug.warn("tried refresh for " + args + " but still had questions!");
		}
		
		for (question in masterQuestions)
		{
			currentQuestions.push(question);
		}
		
		return currentQuestions;
	}
	
	//==================================================================
	// Public Usage
	//==================================================================
	
	/**
	 * Gets a question for the provided args.
	 * Refreshes the collection if we're out of available questions.
	 * returns null on failure.
	 * @param	args
	 * @return
	 */
	public function getQuestion(args:Array<String>):String
	{
		if (m_questionBankCurrent == null)
		{
			Debug.warn("question bank has not been inited yet!");
			return null;
		}
		
		if (args == null)
		{
			Debug.warn("args are null, can't get any questions...");
			return null;
		}
		
		if (args.length == 0)
		{
			Debug.warn("no args provided, can't get questions...");
			return null;
		}
		
		var currentArgs:Array<String> = args.copy();
		var initialKey:String = currentArgs.shift();
		var currentRootCollection:QuestionCollection = m_questionBankCurrent.get(initialKey);
		if (currentRootCollection == null)
		{
			Debug.warn("No questions in current collection for key: " + initialKey);
			Debug.log("available keys:");
			for (key in m_questionBankCurrent.keys())
			{
				Debug.log(key);
			}
			printCurrentBank();
			return null;
		}
		
		var currentQuestions:Array<String> = currentRootCollection.getQuestions(currentArgs);
		if (currentQuestions == null)
		{
			Debug.log("Null questions retrieved for: " + currentArgs);
			return null;
		}
		
		if (currentQuestions.length == 0)
		{
			if (m_randomExhaustive)
			{
				currentQuestions = refreshQuestionBank(args);
				if (currentQuestions == null)
				{
					return null;
				}
				//If question length is still 0 after a refresh, something is wrong.
				if (currentQuestions.length == 0)
				{
					Debug.warn("Successful refresh for: " + name + " failed for args: " + args);
					return null;
				}
				
				Debug.log("Refreshed questions:");
				Debug.log(Std.string(currentQuestions));
			}
			else
			{
				//If we're not exhaustive, then not having questions is an error.
				Debug.warn("no questions available for: " + args);
				return null;
			}

		}

		var question:String = Random.fromArray(currentQuestions);
		if (m_randomExhaustive)
		{
			currentQuestions.remove(question);
		}
		
		return question;
	}
	
	/**
	 * Returns whether any questions exist for the specified args.
	 * @param	args
	 * @return
	 */
	public function haveQuestions(args:Array<String>):Bool
	{
		if (args == null)
		{
			Debug.warn("args are null, can't get any questions...");
			return false;
		}
		
		if (args.length == 0)
		{
			Debug.warn("no args provided, can't get questions...");
			return false;
		}
		
		var masterArgs:Array<String> = args.copy();
		var initialKey:String = masterArgs.shift();
		var masterRootCollection:QuestionCollection = m_questionBankMaster.get(initialKey);
		if (masterRootCollection == null)
		{
			Debug.log("No questions in master collection for key: " + initialKey);
			return false;
		}
		
		var questions:Array<String> = masterRootCollection.getQuestions(masterArgs);
		if (questions == null)
		{
			return false;
		}
		if (questions.length == 0)
		{
			return false;
		}
		
		return true;
	}
	
	//==================================================================
	// Debugging
	//==================================================================
	
	/**
	 * Outputs the provided question bank in a readable format
	 */
	private static function printBank(bank:StringMap<QuestionCollection>):Void
	{
		for (collection in bank)
		{
			Debug.log(collection.toString());
		}
	}
	
	/**
	 * Debug function for printing the master bank
	 */
	public function printMasterBank():Void
	{
		Debug.log("================" + name + "================");
		Debug.log( "=============== Master Bank =====================" );
		printBank(m_questionBankMaster);
		Debug.log( "=================================================" );
	}
	
	/**
	 * Debug function for printing the current bank
	 */
	public function printCurrentBank():Void
	{
		Debug.log("================" + name + "================");
		Debug.log( "=============== Current Bank =====================" );
		printBank(m_questionBankCurrent);
		Debug.log( "==================================================" );
	}
	
	/**
	 * Debug function for printing the current bank
	 */
	public function printBanks():Void
	{
		Debug.log("================" + name + "================");
		Debug.log( "=============== All Banks =====================" );
		printMasterBank();
		printBank(m_questionBankCurrent);
		Debug.log( "===============================================" );
	}
	
}
