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

package game.controllers;

import com.firstplayable.hxlib.Debug;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import game.net.AccountManager;
import game.net.AccountManager.Student;
import game.ui.login.StudentButton;
import game.ui.login.StudentColor;
import game.ui.login.StudentIdConfirmation;
import game.ui.login.StudentIdConfirmationButtonIds;
import game.ui.login.StudentIdMenu;
import game.ui.login.StudentNumber;
import game.utils.AbstractEnumTools;
import game.utils.StudentUtils;
import haxe.ds.Option;

using Lambda;
using game.utils.OptionExtension;

class StudentIdController
{
	private var m_students:Array<Student>;
	private var m_studentUI:StudentIdMenu;
	private var m_confirmationUI:StudentIdConfirmation;
	

	public function new(students:Array<Student>)
	{
		m_studentUI = new StudentIdMenu();
		m_confirmationUI = new StudentIdConfirmation();
		
		m_students = students.copy();
		
		for (student in m_students)
		{
			var id:Int = student.getNumberFromId() - 1;
			
			var color:StudentColor = StudentUtils.getColorFromId(id);
			var number:StudentNumber = StudentUtils.getNumberFromId(id);
			
			var button = new StudentButton(color, number);
			
			m_studentUI.addStudentButton(button);
		}
	}
	
	public function start():Void
	{
		m_studentUI.show();
		
		SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onStudentButtonClicked);
	}
	
	public function stop():Void
	{
		m_studentUI.hide();
		m_confirmationUI.hide();
		m_studentUI = null;
		m_confirmationUI = null;
		
		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onStudentButtonClicked);
		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onConfirmationButtonClicked);
	}
	
	private function onStudentButtonClicked(event:GenericEvent<Int>):Void
	{
		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onStudentButtonClicked);
		
		function hasSameId(student:Student):Bool
		{
			var studentId:Int = student.getNumberFromId();
			return (studentId == (event.item + 1));
		}
		
		var student:Student = m_students.find(hasSameId);
		
		function showConfirmationUI():Void
		{
			var color:StudentColor = StudentUtils.getColorFromId(event.item);
			var number:StudentNumber = StudentUtils.getNumberFromId(event.item);
			m_confirmationUI.setColorAndNumber(color, number);
			m_confirmationUI.show();
			
			SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onConfirmationButtonClicked);
		}
		
		function onStudentLoaded(data:Student):Void
		{
			student.saveData = data.saveData;
			student.playerProfile = data.playerProfile;
			Debug.log( "On student loaded: " + data.playerProfile );
			showConfirmationUI();
			SpeckGlobals.student = Some(student);
		}
		
		function onFailedToLoadStudent(msg:String):Void
		{
			Debug.log('Error: $msg');
			showConfirmationUI();
			SpeckGlobals.student = None;
		}
		
		AccountManager.loadStudent(student.id, onStudentLoaded, onFailedToLoadStudent);
	}
	
	private function onConfirmationButtonClicked(event:GenericEvent<StudentIdConfirmationButtonIds>):Void
	{
		switch (event.item)
		{
			case StudentIdConfirmationButtonIds.NO:
				{
					m_confirmationUI.hide();
					
					SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onConfirmationButtonClicked);
					SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onStudentButtonClicked);
				}
			case StudentIdConfirmationButtonIds.YES:
				{
					StateManager.setState(GameState.ASSESSMENT_OR_GLOBE);
					SpeckGlobals.saveProfile.setStudentId();
				}
		}
	}
}