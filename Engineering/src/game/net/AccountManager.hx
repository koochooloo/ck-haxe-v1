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

package game.net;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;
import game.net.AccountManager.Student;
import game.net.AccountManager.Teacher;
import game.utils.StudentUtils;
import haxe.ds.Option;


#if js
import com.firstplayable.hxlib.net.apis.AmazonWebServicesApi;
import js.Error;
#end

class Teacher
{
	public var id(default, set):String;
	public var grade(default, set):String;
	public var students:Array<Student>;

	public function new()
	{
		students = [];
	}

	private function set_id(s:String)
	{
		return id = s.toUpperCase();
	}

	private function set_grade(g:String)
	{
		return grade = g.toUpperCase();
	}

	public function toString():String
	{
		return '$id\n$grade\n$students';
	}
}

class Student
{
	public var id(default, set):String;
	public var teacherId:String;
	public var saveData:String;
	public var playerProfile:String;

	public function new()
	{
	}
	
	public function getNumberFromId():Int
	{
		var textToStrip:String = '${teacherId}_';
		var idString:String = StringTools.replace(id, textToStrip, "");
		return Std.parseInt(idString);
	}

	private function set_id(s:String)
	{
		return id = s.toUpperCase();
	}

	public function toString():String
	{
		return '$id\n$teacherId\n$saveData\n$playerProfile';
	}
}

enum AccountResult
{
	SUCCESS;
	EXISTS;
	ERROR;
}

class AccountManager
{
	public static inline var STUDENTS_PER_TEACHER:Int = 32;

	private static var m_teacher:Teacher;
	private static var m_nextStudent:Int;
	private static var m_accountCallback:AccountResult->Void;
	
	private static var m_onSuccessfullyLoadedStudent:Null<Student->Void>;
	private static var m_onFailedToLoadStudent:Null<String->Void>;
	
	private static var m_teacherCallback:Teacher->Void;
	private static var m_errorCallback:String->Void;
	
	public static function connect()
	{
#if js
		AWS.connect(SpeckGlobals.AWS_REGION, SpeckGlobals.AWS_IDENTITY_POOL_ID);
#elseif ios
		AmazonWebServices.connect();
#end
	}
	
	public static function createTeacher(teacher:Teacher, callback:AccountResult->Void):Void
	{
#if js
		m_teacher = teacher;
		m_nextStudent = 0;
		m_accountCallback = callback;

		var db = new DynamoDB();

		var params:Dynamic = {
			TableName: "Teachers",
			Item: {
				"TeacherId": { S: teacher.id },
				"GradeLevel": { S: teacher.grade },
				"Students": { N: Std.string(STUDENTS_PER_TEACHER) },
				"Created": { S: Date.now().toString() }
			},
			ConditionExpression: "attribute_not_exists(TeacherId)"
		};

		//TODO: Make sure save doesn't exist (AWS will happily overwrite).
		db.putItem(params, onCreateTeacher);
#end
	}

	public static function createStudents():Void
	{
#if js
		var db = new DynamoDB();

		var params:Dynamic = {
			RequestItems: {
				Students: []
			}
		};

		var requestItems:Array<Dynamic> = [];
		while (m_nextStudent < STUDENTS_PER_TEACHER)
		{
			// Increment at top of loop so student ids are 1-indexed.
			m_nextStudent++;

			var s = new Student();
			s.id = '${m_teacher.id}_$m_nextStudent';
			s.teacherId = m_teacher.id;
			s.saveData = '[]';
			s.playerProfile = "";
			m_teacher.students.push(s);

			var request:Dynamic = {
				PutRequest: {
					Item:
					{
						StudentId: { S: s.id },
						TeacherId: { S: s.teacherId }
					}
				}
			};

			requestItems.push(request);

			// AWS limits batch size to 25
			if (requestItems.length >= 24)
			{
				break;
			}
		}

		params.RequestItems.Students = requestItems;

		db.batchWriteItem(params, onCreateStudents);
#end
	}

	public static function saveStudent(student:Student):Void
	{
#if js
		var db = new DynamoDB();

		var color:String = StudentUtils.getColorFromId(student.getNumberFromId());
		var number:String = StudentUtils.getNumberFromId(student.getNumberFromId());
		var icon:String = color + number;

		var params:Dynamic = {
			TableName: "Students",
			Item: {
				"StudentId": { S: student.id },
				"TeacherId": { S: student.teacherId },
				"Icon": { S: icon },
				"LastPlayed": { S: Date.now().toString() },
				"SaveData": { S: student.saveData },
				"Profile": { S: student.playerProfile }
			},
			ConditionExpression: "attribute_exists(StudentId)"
		};

		// trace(params);

		db.putItem(params, onSaveStudent);
#elseif ios
		AmazonWebServices.saveStudent(student.id, student.teacherId, student.saveData, student.playerProfile);
#end
	}

	public static function loadStudent(id:String, successCB:Student->Void, errorCB:String->Void):Void
	{
		m_onSuccessfullyLoadedStudent = successCB;
		m_onFailedToLoadStudent = errorCB;
		m_errorCallback = errorCB;

#if js
		var db = new DynamoDB();

		var params:Dynamic = {
			TableName: "Students",
			Key: {
				"StudentId": { S: id }
			}
		}

		// trace(params);

		db.getItem(params, onLoadStudent);
#elseif ios
		AmazonWebServices.loadStudent(id, onLoadStudent, onLoadError);
#end
	}

	public static function loadTeacher(id:String, successCB:Teacher->Void, errorCB:String->Void):Void
	{
		m_teacherCallback = successCB;
		m_errorCallback = errorCB;

#if js
		var db = new DynamoDB();

		var params:Dynamic = {
			TableName: "Teachers",
			Key: {
				"TeacherId": { S: id.toUpperCase() }
			}
		}

		db.getItem(params, onLoadTeacher);
#elseif ios
		AmazonWebServices.loadTeacher(id.toUpperCase(), onLoadTeacher, onLoadError);
#end
	}

#if ios
	private static function onLoadTeacher(t:Dynamic):Void
	{
		var teacher = new Teacher();
		teacher.id = t.id;
		teacher.grade = t.grade;

		var nStudents:Int = t.nStudents;
		for (i in 1...nStudents + 1)
		{
			var s = new Student();
			s.id = '${teacher.id}_$i';
			s.teacherId = teacher.id;
			teacher.students.push(s);
		}

		// Debug.log('onLoadTeacher: $teacher');

		if (m_teacherCallback != null)
		{
			m_teacherCallback(teacher);
		}
	}

	private static function onLoadStudent(s:Dynamic):Void
	{
		var student = new Student();
		student.id = s.id;
		student.teacherId = s.teacherId;
		student.saveData = s.saveData;
        student.playerProfile = s.profile;
		Debug.log('onLoadStudent: $student');

		if (m_onSuccessfullyLoadedStudent != null)
		{
			m_onSuccessfullyLoadedStudent(student);
		}
	}

	private static function onLoadError(msg:String):Void
	{
		if (msg == "ACCOUNT_DOESNOTEXIST")
		{
			msg = The.gamestrings.get("ACCOUNT_DOESNOTEXIST");
		}

		if (m_errorCallback != null)
		{
			m_errorCallback('$msg');
		}
	}
#end

#if js
	private static function onCreateTeacher(err:Error, data:Dynamic):Void
	{
		if (err != null)
		{
			if (err.name == "ConditionalCheckFailedException")
			{
				m_accountCallback(AccountResult.EXISTS);
			}
			else
			{
				Debug.warn('Error creating teacher: $err');
				m_accountCallback(AccountResult.ERROR);
			}
			return;
		}

		// Debug.log("Created teacher!!!!");
		// trace(data);

		createStudents();
	}

	private static function onCreateStudents( err:Error, data:Dynamic ):Void
	{
		if (err != null)
		{
			//TODO: Go back and delete the teacher account if student creation fails?
			Debug.warn('Error creating students: $err');
			m_accountCallback(AccountResult.ERROR);
			return;
		}

		if (Reflect.fields(data.UnprocessedItems).length > 0)
		{
			// In theory, AWS can fail on a subset of the items, which can then be resubmitted.
			// Our data is so tiny that this is extremely unlikely and has not been fully tested.
			Debug.log("Unprocesses batch item, retrying...");
			trace(data);

			//TODO:  Delay for a couple seconds....
			var db = new DynamoDB();
			db.batchWriteItem(data.UnprocessedItems, onCreateStudents);
			return;
		}

		// trace(data);
		// Debug.log('Created students up to $m_nextStudent');

		// AWS has a limit on batch size, so we may need to create more students...
		if (m_nextStudent < STUDENTS_PER_TEACHER)
		{
			createStudents();
			return;
		}

		// Debug.log("All students created!");

		if (m_accountCallback != null)
		{
			m_accountCallback(AccountResult.SUCCESS);
		}
	}

	private static function onSaveStudent(err:Error, data:Dynamic):Void
	{
		if (err != null)
		{
			Debug.warn('Error saving student data: $err');
			return;
		}

		// trace(data);
	}

	private static function onLoadStudent(err:Error, data:Dynamic):Void
	{
		if (err != null)
		{
			Debug.warn('Error downloading student data: $err');
			
			var msg:String = '$err';
			
			if (m_onFailedToLoadStudent != null)
			{
				m_onFailedToLoadStudent(msg);
			}
		}
		else if (data.Item == null)
		{
			var msg:String = "Failed to load student with the provided id!";
			
			if (m_onFailedToLoadStudent != null)
			{
				m_onFailedToLoadStudent(msg);
			}
		}
		else 
		{
			var s = data.Item;
			Debug.log( "Student data retrived: " + data );
			var student = new Student();
			student.id = s.StudentId.S;
			student.teacherId = s.TeacherId.S;
			student.saveData = (s.SaveData == null) ? '[]' : s.SaveData.S;
			student.playerProfile = (s.Profile == null) ? "" : s.Profile.S;

			if (m_onSuccessfullyLoadedStudent != null)
			{
				m_onSuccessfullyLoadedStudent(student);
			}
		}
	}

	private static function onLoadTeacher(err:Error, data:Dynamic):Void
	{
		if (err != null)
		{
			Debug.warn('Error downloading teacher data: $err');

			var msg:String = '$err';

			if (err.name == "NetworkingError")
			{
				msg = The.gamestrings.get("ACCOUNT_NETWORKERROR");
			}

			if (m_errorCallback != null)
			{
				m_errorCallback(msg);
			}

			return;
		}

		if (data.Item == null)
		{
			Debug.log("Teacher account does not exist");

			if (m_errorCallback != null)
			{
				m_errorCallback(The.gamestrings.get("ACCOUNT_DOESNOTEXIST"));
			}

			return;
		}

		var t = data.Item;
		var teacher = new Teacher();
		teacher.id = t.TeacherId.S;
		teacher.grade = t.GradeLevel.S;

		var nStudents:Int = Std.parseInt(t.Students.N);
		for (i in 1...nStudents + 1)
		{
			
			var s = new Student();
			s.id = '${teacher.id}_$i';
			s.teacherId = teacher.id;
			s.saveData = '[]';
			s.playerProfile = "";
			teacher.students.push(s);
		}

		if (m_teacherCallback != null)
		{
			m_teacherCallback(teacher);
		}
	}
#end
}
