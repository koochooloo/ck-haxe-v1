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

import assets.Gamestrings;
import com.firstplayable.hxlib.state.StateManager;
import com.firstplayable.hxlib.utils.json.GlobalTable.The;
import game.def.GameState;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import game.events.TextFieldEvents;
import game.net.AccountManager;
import game.net.AccountManager.Teacher;
import game.ui.login.TeacherIdConfirmation;
import game.ui.login.TeacherIdConfirmationButtonIds;
import game.ui.login.TeacherIdMenu;
import game.ui.login.TeacherIdMenuButtonIds;
import haxe.ds.Option;

using game.utils.OptionExtension;

class TeacherIdController
{
	private static inline var TF_TEXTID:String = "LOGIN_TEACHERID";
	
	private var m_loginUI:TeacherIdMenu;
	private var m_confirmationUI:TeacherIdConfirmation;

	public function new()
	{
		m_loginUI = new TeacherIdMenu();
		m_confirmationUI = new TeacherIdConfirmation();
	}

	public function start(id:Option<String>):Void
	{
		m_loginUI.disableLoginButton();
		m_loginUI.start();
		m_loginUI.show();

		switch (id)
		{
			case Some(teacherId):
				{
					m_loginUI.inputText = teacherId;
					performLogin();
				}
			case None:
				{
					SpeckGlobals.event.addEventListener(TextFieldEvents.TEXT_CHANGED, onLoginTextChanged);
					SpeckGlobals.event.addEventListener(TextFieldEvents.FOCUS_GAINED, onLoginFocusGained);
					SpeckGlobals.event.addEventListener(TextFieldEvents.FOCUS_LOST, onLoginFocusLost);
					SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onLoginButtonClicked);
				}
		}
	}

	public function stop():Void
	{
		m_loginUI.hide();
		m_loginUI.stop();
		m_loginUI = null;

		m_confirmationUI.hide();
		m_confirmationUI = null;

		SpeckGlobals.event.removeEventListener(TextFieldEvents.TEXT_CHANGED, onLoginTextChanged);
		SpeckGlobals.event.removeEventListener(TextFieldEvents.FOCUS_GAINED, onLoginFocusGained);
		SpeckGlobals.event.removeEventListener(TextFieldEvents.FOCUS_LOST, onLoginFocusLost);
		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onLoginButtonClicked);
		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onConfirmationButtonClicked);
	}

	private function onLoginTextChanged(event:GenericEvent<TeacherIdMenu>):Void
	{
		var isEmpty:Bool = (m_loginUI.inputText.length <= 0);
		if (isEmpty)
		{
			m_loginUI.disableLoginButton();
		}
		else
		{
			m_loginUI.enableLoginButton();
		}
	}
	
	private function onLoginFocusGained(event:GenericEvent<TeacherIdMenu>):Void
	{
		var isDefaultText:Bool = (m_loginUI.inputText == The.gamestrings.get(TF_TEXTID));
		if (isDefaultText)
		{
			m_loginUI.inputText = "";
		}
	}
	
	private function onLoginFocusLost(event:GenericEvent<TeacherIdMenu>):Void
	{
		var isEmpty:Bool = (m_loginUI.inputText.length <= 0);
		if (isEmpty)
		{
			m_loginUI.inputText = The.gamestrings.get(TF_TEXTID);
		}
	}
	
	private function performLogin():Void
	{
		m_loginUI.disableLoginButton();
		AccountManager.loadTeacher(m_loginUI.inputText, onLoginSuccess, onLoginFailure);
	}
	
	private function onLoginSuccess(teacher:Teacher):Void
	{
		SpeckGlobals.teacher = Some(teacher);
		
		var strings:Gamestrings = cast The.gamestrings;
		strings.setToken("TOKEN__TEACHER_ID", teacher.id);
		m_confirmationUI.message = strings.get("TEACHER_ID_CONFIRMATION");
		
		m_confirmationUI.show();

		SpeckGlobals.event.removeEventListener(TextFieldEvents.TEXT_CHANGED, onLoginTextChanged);
		SpeckGlobals.event.removeEventListener(TextFieldEvents.FOCUS_GAINED, onLoginFocusGained);
		SpeckGlobals.event.removeEventListener(TextFieldEvents.FOCUS_LOST, onLoginFocusLost);
		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onLoginButtonClicked);
		SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onConfirmationButtonClicked);
	}
	
	private function onLoginFailure(message:String):Void
	{
		m_loginUI.inputText = The.gamestrings.get(TF_TEXTID);
		m_loginUI.disableLoginButton();
		m_loginUI.showErrorMessage(message);
		
		m_confirmationUI.hide();
		
		SpeckGlobals.event.addEventListener(TextFieldEvents.TEXT_CHANGED, onLoginTextChanged);
		SpeckGlobals.event.addEventListener(TextFieldEvents.FOCUS_GAINED, onLoginFocusGained);
		SpeckGlobals.event.addEventListener(TextFieldEvents.FOCUS_LOST, onLoginFocusLost);
		SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onLoginButtonClicked);
		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onConfirmationButtonClicked);
	}

	private function onLoginButtonClicked(event:GenericEvent<TeacherIdMenuButtonIds>):Void
	{
		switch (event.item)
		{
			case TeacherIdMenuButtonIds.LOGIN:
				{
					performLogin();
				}
		}
	}

	private function onConfirmationButtonClicked(event:GenericEvent<TeacherIdConfirmationButtonIds>):Void
	{
		switch (event.item)
		{
			case TeacherIdConfirmationButtonIds.NO:
				{
					m_loginUI.inputText = The.gamestrings.get(TF_TEXTID);
					m_loginUI.disableLoginButton();

					m_confirmationUI.hide();

					SpeckGlobals.event.addEventListener(TextFieldEvents.TEXT_CHANGED, onLoginTextChanged);
					SpeckGlobals.event.addEventListener(TextFieldEvents.FOCUS_GAINED, onLoginFocusGained);
					SpeckGlobals.event.addEventListener(TextFieldEvents.FOCUS_LOST, onLoginFocusLost);
					SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onLoginButtonClicked);
					SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onConfirmationButtonClicked);
				}
			case TeacherIdConfirmationButtonIds.YES:
				{
					SpeckGlobals.teacher.flatMap(function(teacher){
						StateManager.setState(GameState.STUDENT_ID_LOGIN, {args: [teacher]});
						return Some(teacher);
					});
				}
		}
	}
}