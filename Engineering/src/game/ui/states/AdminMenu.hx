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

package game.ui.states;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import game.net.AccountManager;
import game.ui.SpeckMenu;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;

#if js
import com.firstplayable.hxlib.net.apis.AmazonWebServicesApi;
import js.Error;
#end

class AdminMenu extends SpeckMenu
{
	private var m_teacherId:TextField;
	private var m_teacherGrade:TextField;

	private var m_submitButton:GraphicButton;

	private static var DEFAULT_ID:String;
	private static var DEFAULT_GRADE:String;

	private static var TEACHER_MAX_CHARS = 32;
	private static var GRADE_MAX_CHARS = 1;

	public function new() 
	{
		super( "AdminMenu" );

		m_submitButton = cast getChildByName("btn_submit");
		m_submitButton.enabled = false;

		setTextInField("lbl_feedback", "", true);

		m_teacherId = cast getChildByName("lbl_teacher");
		m_teacherId.selectable = true;
		m_teacherId.type = TextFieldType.INPUT;
		m_teacherId.restrict = "a-z A-Z 0-9";
		m_teacherId.maxChars = TEACHER_MAX_CHARS;
		m_teacherId.addEventListener( Event.CHANGE, onTextUpdate );
		m_teacherId.addEventListener( FocusEvent.FOCUS_IN, onIdFocusIn );
		m_teacherId.addEventListener( FocusEvent.FOCUS_OUT, onIdFocusOut );

		m_teacherGrade = cast getChildByName("lbl_grade");
		m_teacherGrade.selectable = true;
		m_teacherGrade.type = TextFieldType.INPUT;
		m_teacherGrade.restrict = "Kk 0-9";
		m_teacherGrade.maxChars = GRADE_MAX_CHARS;
		m_teacherGrade.addEventListener( Event.CHANGE, onTextUpdate );
		m_teacherGrade.addEventListener( FocusEvent.FOCUS_IN, onGradeFocusIn );
		m_teacherGrade.addEventListener( FocusEvent.FOCUS_OUT, onGradeFocusOut );

		if (DEFAULT_ID == null)
		{
			DEFAULT_ID = m_teacherId.text;
		}

		if (DEFAULT_GRADE == null)
		{
			DEFAULT_GRADE = m_teacherGrade.text;
		}
		
		showMenu();
	}
	
	override public function onButtonHit( ?caller:GraphicButton ):Void
	{
		super.onButtonHit( caller );
		
		WebAudio.instance.play( "SFX/button_click" );
		
		switch (caller.name)
		{
			case "btn_submit":
				onSubmit();
		}
	}

	private function onSubmit():Void
	{
		m_submitButton.enabled = false;
		setTextInField("lbl_feedback", "ACCOUNT_CREATING");

		var id:String = m_teacherId.text;
		var idReg:EReg = ~/[^a-zA-Z0-9]/g;
		id = idReg.replace(id, "").substring(0, TEACHER_MAX_CHARS);

		var grade:String = m_teacherGrade.text;
		var gradeReg:EReg = ~/[^kK0-9]/g;
		grade = gradeReg.replace(grade, "").substring(0, GRADE_MAX_CHARS);

		var teacher = new Teacher();
		teacher.id = id;
		teacher.grade = grade;

		AccountManager.createTeacher(teacher, onResult);

	}

	private function onResult(result:AccountResult):Void
	{
		m_submitButton.enabled = true;
		m_teacherId.text = DEFAULT_ID;

		m_teacherGrade.restrict = "";
		m_teacherGrade.maxChars = TEACHER_MAX_CHARS;
		m_teacherGrade.text = DEFAULT_GRADE;

		switch (result)
		{
			case SUCCESS:
				setTextInField("lbl_feedback", "ACCOUNT_SUCCESS");
			case EXISTS:
				setTextInField("lbl_feedback", "ACCOUNT_EXISTS");
			case ERROR:
				setTextInField("lbl_feedback", "ACCOUNT_ERROR");
		}
	}

	private function onIdFocusIn(e:FocusEvent):Void
	{
		if ( m_teacherId.text == DEFAULT_ID )
		{
			m_teacherId.text = "";
		}
	}

	private function onIdFocusOut(e:FocusEvent):Void
	{
		if ( m_teacherId.text == "" )
		{
			m_teacherId.text = DEFAULT_ID;
		}
	}

	private function onGradeFocusIn(e:FocusEvent):Void
	{
		if ( m_teacherGrade.text == DEFAULT_GRADE )
		{
			m_teacherGrade.text = "";
			m_teacherGrade.restrict = "Kk 0-9";
			m_teacherGrade.maxChars = GRADE_MAX_CHARS;
		}
	}

	private function onGradeFocusOut(e:FocusEvent):Void
	{
		if ( m_teacherGrade.text == "" )
		{
			m_teacherGrade.restrict = "";
			m_teacherGrade.maxChars = TEACHER_MAX_CHARS;
			m_teacherGrade.text = DEFAULT_GRADE;
		}
	}

	private function onTextUpdate(e:Event):Void
	{
		if (m_teacherId.text != "" && m_teacherId.text != DEFAULT_ID
				&& m_teacherGrade.text != "" && m_teacherGrade.text != DEFAULT_GRADE)
		{
			m_submitButton.enabled = true;
		}
		else
		{
			m_submitButton.enabled = false;
		}

	}
}