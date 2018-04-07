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
import game.controllers.TeacherIdController;
import game.def.GameState;
import game.ui.load.SpeckLoader;
import haxe.ds.Option;

#if js
import js.html.Element;
import js.Browser;
#end

class TeacherIdLoginState extends SpeckBaseState
{
	private var m_controller:TeacherIdController;
	
	public function new() 
	{
		super(GameState.TEACHER_ID_LOGIN);
	}
	
	override public function enter(p:GameStateParams):Void 
	{
		m_assets = SpeckLoader.loginAssets;
		
		super.enter(p);
	}
	
	override public function initMenu()
	{
		m_controller = new TeacherIdController();
		var id:Option<String> = cast m_params.args[0];
		m_controller.start(id);
		
		#if js 
		var element:Element = Browser.window.document.getElementById('bg');
		if (element != null)
		{
			element.hidden = true;
		}
		#end
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
