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

package game.states;

import game.states.SpeckBaseState;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import game.controllers.StudentIdController;
import game.def.GameState;
import game.net.AccountManager.Student;
import game.net.AccountManager.Teacher;
import game.ui.load.SpeckLoader;

class StudentIdLoginState extends SpeckBaseState
{
	private var m_controller:StudentIdController;
	
	public function new() 
	{
		super(GameState.STUDENT_ID_LOGIN);
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		m_assets = SpeckLoader.loginAssets;
		
		super.enter(p);
		
		var teacher:Teacher = cast p.args[0];
		
		m_controller = new StudentIdController(teacher.students);
		m_controller.start();
	}
	
	override public function exit():Void 
	{
		super.exit();
		
		if (m_controller != null)
		{
			m_controller.stop();
			m_controller = null;	
		}
	}
}
