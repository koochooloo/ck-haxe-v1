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

package game.cms;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.loader.ResMan;
import game.utils.AbstractEnumTools;
import haxe.DynamicAccess;
import haxe.Json;
import haxe.ds.Option;
import haxe.ds.StringMap;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

using game.utils.OptionExtension;

class QuestionDatabase
{
	public static inline var CA_TEXT:String = "CA_TEXT";
	public static inline var CA_IMAGE:String = "CA_IMAGE";
	public static inline var CA_VO:String = "CA_VO";
	
	public static inline var COUNTRY:String = "COUNTRY";
	
	public static inline var COUNTRY_FACT:String = "COUNTRY_FACT";
	public static inline var COUNTRY_FACT_VO:String = "COUNTRY_FACT_VO";
	public static inline var COUNTRY_IMAGE:String = "COUNTRY_IMAGE";
	
	public static inline var CURRICULUM:String = "CURRICULUM";
	
	public static inline var GRADE:String = "GRADE";
	
	public static inline var ID:String = "ID";
	
	public static inline var INCLUDE:String = "INCLUDE";
	
	public static inline var QUESTION:String = "QUESTION";
	public static inline var QUESTION_IMAGE:String = "QUESTION_IMAGE";
	public static inline var QUESTION_TYPE:String = "QUESTION_TYPE";
	public static inline var QUESTION_VO:String = "QUESTION_VO";
	
	public static inline var RECIPE:String = "RECIPE";
	
	public static inline var WA_ONE_TEXT:String = "WA_1_TEXT";
	public static inline var WA_ONE_IMAGE:String = "WA_1_IMAGE";
	public static inline var WA_ONE_VO:String = "WA_1_VO";
	
	public static inline var WA_TWO_TEXT:String = "WA_2_TEXT";
	public static inline var WA_TWO_IMAGE:String = "WA_2_IMAGE";
	public static inline var WA_TWO_VO:String = "WA_2_VO";
	
	public static inline var WEEK:String = "WEEK";
	
	public static inline var LEARNING_STANDARD:String = "LEARNING_STANDARD";
	
	public static inline var QUESTION_DATABASE_LIBRARY:String = "QuestionDatabase";

	private static inline var S3_CMS_URL:String = "https://chefk-prod.s3.amazonaws.com/curriculum/";
	
	public static var instance(get, null):QuestionDatabase;
	private static function get_instance():QuestionDatabase
	{
		if (instance == null)
		{
			instance = new QuestionDatabase();
		}
		
		return instance;
	}
	
	private var m_questions:Array<Question>;
	private var m_callback:Null<Void->Void>;
	private var m_sheetsToLoad:Int;
	
	private function new()
	{
		m_questions = [];
		m_callback = null;
	}
	
	// Initiate a QuestionQuery that is initially populated with every Question in the QuestionDatabase
	@:access(game.cms.QuestionQuery)
	public function query():QuestionQuery
	{
		return new QuestionQuery(m_questions);
	}
	
	// Responsible for adding the associated JSON resources to ResMan
	// NOTE:  Don't need this if we're loading the data from the S3 bucket
	public function init():Void
	{
		var sheets:Array<QuestionSheet> = AbstractEnumTools.getValues(QuestionSheet);
		for (sheet in sheets)
		{
			ResMan.instance.addRes(QUESTION_DATABASE_LIBRARY, {src: sheet});
		}
	}

	// Load sheets from S3 bucket, rather than using ResMan
	public function loadFromS3(?callback:Void->Void):Void
	{
		m_callback = callback;
		m_sheetsToLoad = 0;

		var sheets:Array<QuestionSheet> = AbstractEnumTools.getValues(QuestionSheet);
		for (sheet in sheets)
		{
			m_sheetsToLoad++;

			var url:String = S3_CMS_URL + sheet;
			var urlLoader = new URLLoader();

			urlLoader.addEventListener(Event.COMPLETE, function(_){
				onS3JSONLoaded(urlLoader, sheet);
			});

			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(_){
				onS3Error(sheet);
			});

			urlLoader.load(new URLRequest(url));
		}
	}

	private function onS3JSONLoaded(urlLoader:URLLoader, sheet:QuestionSheet):Void
	{
		var json:String = cast urlLoader.data;
		loadSheetFromJSON(sheet, json);

		m_sheetsToLoad--;

		if (m_sheetsToLoad == 0 && m_callback != null)
		{
			m_callback();
			m_callback = null;
		}
	}

	//TODO:  This is probably game-breaking, so we should do something useful here...
	private function onS3Error(sheet:QuestionSheet):Void
	{
		Debug.warn('Error loading CMS sheet: $sheet');

		m_sheetsToLoad--;

		if (m_sheetsToLoad == 0 && m_callback != null)
		{
			m_callback();
			m_callback = null;
		}
	}
	
	// Responsible for loading the assoicated JSON resources using ResMan
	// The provided callback will be invoked on completion
	public function load(?callback:Void->Void):Void
	{
		m_callback = callback;
		
		ResMan.instance.load(QUESTION_DATABASE_LIBRARY, onJSONLoaded);
	}
	
	// Responsible for parsing the loaded JSON and invoking the provided callback
	private function onJSONLoaded():Void
	{
		var sheets:Array<QuestionSheet> = AbstractEnumTools.getValues(QuestionSheet);
		for (sheet in sheets)
		{
			var jsonString:String = ResMan.instance.getText(sheet);
			loadSheetFromJSON(sheet, jsonString);
		}
		
		if (m_callback != null)
		{
			m_callback();
		}
	}
	
	// Responsible for parsing the provided JSON and building Question instances from it
	private function loadSheetFromJSON(sheet:QuestionSheet, jsonString:String):Void
	{
		try
		{
			var entries:Array<DynamicAccess<Dynamic>> = Json.parse(jsonString);
			for (entry in entries)
			{
				var shouldSkip:Bool = (entry[INCLUDE] == Include.NO);
				if (shouldSkip)
				{
					continue;
				}
				
				var id:String = entry[ID];
				
				var week:Option<Int> = validateField(entry, WEEK).flatMap(validateInt);
				
				var questionType:QuestionType = entry[QUESTION_TYPE];
				
				var countryFact:Option<String> = validateField(entry, COUNTRY_FACT).flatMap(validateLength);
				var countryFactVO:Option<String> = validateField(entry, COUNTRY_FACT_VO).flatMap(validateLength);
				var countryImage:Option<String> = validateField(entry, COUNTRY_IMAGE).flatMap(validateLength);
				
				var grade:Grade = entry[GRADE];
				
				var curriculum:Curriculum = entry[CURRICULUM];
				
				var recipe:Option<String> = validateField(entry, RECIPE).flatMap(validateLength);
				
				var country:Option<String> = validateField(entry, COUNTRY).flatMap(validateLength);
				
				var questionText:String = entry[QUESTION];
				var questionImage:Option<String> = validateField(entry, QUESTION_IMAGE).flatMap(validateLength);
				var questionVO:Option<String> = validateField(entry, QUESTION_VO).flatMap(validateLength);
					
				var answers:Array<Answer> = [];
				
				{
					var caText:Option<String> = validateField(entry, CA_TEXT).flatMap(validateLength);
					var caImage:Option<String> = validateField(entry, CA_IMAGE).flatMap(validateLength);
					var caVO:Option<String> = validateField(entry, CA_VO).flatMap(validateLength);
					
					if (caText.isSome() || caImage.isSome())
					{
						var answer = new Answer(caText, caImage, caVO, true);
					
						answers.push(answer);
					}
				}
				
				{
					var waOneText:Option<String> = validateField(entry, WA_ONE_TEXT).flatMap(validateLength);
					var waOneImage:Option<String> = validateField(entry, WA_ONE_IMAGE).flatMap(validateLength);
					var waOneVO:Option<String> = validateField(entry, WA_ONE_VO).flatMap(validateLength);
					
					if (waOneText.isSome() || waOneImage.isSome())
					{
						var answer = new Answer(waOneText, waOneImage, waOneVO, false);
					
						answers.push(answer);
					}
				}
				
				{
					var waTwoText:Option<String> = validateField(entry, WA_TWO_TEXT).flatMap(validateLength);
					var waTwoImage:Option<String> = validateField(entry, WA_TWO_IMAGE).flatMap(validateLength);
					var waTwoVO:Option<String> = validateField(entry, WA_TWO_VO).flatMap(validateLength);
					
					if (waTwoText.isSome() || waTwoImage.isSome())
					{
						var answer = new Answer(waTwoText, waTwoImage, waTwoVO, false);
					
						answers.push(answer);
					}
				}
				
				var learningStandard:String = entry[LEARNING_STANDARD];
					
				var question = new Question(id, week, questionType, countryFact, countryFactVO, countryImage, grade, curriculum, sheet, questionText, questionImage, questionVO, answers, recipe, country, learningStandard);
				
				m_questions.push(question);
			}
		}
		catch (err:Dynamic)
		{
			Debug.error(err);
			trace(err);
		}
	}
	
	private function validateField(entry:DynamicAccess<Dynamic>, key:String):Option<String>
	{
		if (entry.exists(key))
		{
			var value:String = entry.get(key);
			return Some(value);
		}
		else
		{
			return None;
		}
	}
	
	private function validateInt(str:String):Option<Int>
	{
		return Some(Std.parseInt(str));
	}
	
	private function validateLength(str:String):Option<String>
	{
		if (str.length > 0)
		{
			return Some(str);
		}
		else
		{
			return None;
		}
	}
}