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

package game.ui.login;

import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.debug.tunables.Tunables;
import com.firstplayable.hxlib.display.GameDisplay;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.LayerName;
import game.cms.Grade;
import game.column_layout.ColumnLayout;
import game.column_layout.ColumnLayoutParams;
import game.column_layout.ColumnLayoutParamsBuilder;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import game.net.AccountManager.Teacher;
import openfl.display.DisplayObject;
import openfl.geom.Point;
import openfl.text.TextField;
import haxe.ds.Option;

class StudentIdMenu extends SpeckMenu
{
	public static inline var LAYOUT:String = "StudentSelectMenu";

	private static inline var HEADER_TEXT:String = "headerText_class";
	private static inline var INSTRUCTIONS_TEXT:String = "lbl_instructions";
	private static inline var GRADE_TEXT:String = "lbl_grade";

	private static var REFERENCE:Map<StudentColor, String> =
		[
			StudentColor.RED => "btn_red",
			StudentColor.YELLOW => "btn_yellow",
			StudentColor.GREEN => "btn_green",
			StudentColor.BLUE => "btn_blue"
		];

	public var header(get, set):String;
	public var instructions(get, set):String;

	private var m_headerLabel:TextField;
	private var m_instructionsLabel:TextField;
	private var m_gradeLabel:TextField;
	private var m_buttons:Map<StudentColor, Array<StudentButton>>;

	public function new()
	{
		super(LAYOUT);

		m_headerLabel = getChildAs(HEADER_TEXT, TextField);
		m_instructionsLabel = getChildAs(INSTRUCTIONS_TEXT, TextField);
		m_gradeLabel = getChildAs(GRADE_TEXT, TextField );
		m_buttons =
			[
				StudentColor.RED => [],
				StudentColor.YELLOW => [],
				StudentColor.GREEN => [],
				StudentColor.BLUE => []
			];
	}

	public function show():Void
	{
		set_gradeLabel();
		
		GameDisplay.attach(LayerName.PRIMARY, this);

		var event = new GenericEvent(this, GenericMenuEvents.SHOWN);
		SpeckGlobals.event.dispatchEvent(event);
	}

	public function hide():Void
	{
		GameDisplay.remove(LayerName.PRIMARY, this);

		var event = new GenericEvent(this, GenericMenuEvents.HIDDEN);
		SpeckGlobals.event.dispatchEvent(event);
	}

	override public function onButtonHit(?caller:GraphicButton):Void
	{
		super.onButtonHit(caller);

		WebAudio.instance.play( "SFX/button_click" );
		
		var event = new GenericEvent(caller.id, GenericMenuEvents.BUTTON_CLICKED);
		SpeckGlobals.event.dispatchEvent(event);
	}
	
	public function addStudentButton(button:StudentButton):Void
	{
		// Parent to this menu
		addChild(button);
		
		// Update the onHit callback
		button.onHit = onButtonHit;
		
		// Add to the internal array
		var buttons:Array<StudentButton> = m_buttons.get(button.color);
		buttons.push(button);
		
		// Retrieve the button to use as reference
		var child:String = REFERENCE.get(button.color);
		var ref:DisplayObject = getChildByName(child);
		
		// Layout the buttons
		for (i in 0...buttons.length)
		{
			var btn:StudentButton = buttons[i];
			btn.scaleX = ref.scaleX;
			btn.scaleY = ref.scaleY;
			btn.x = ref.x + (i * ref.width) + Tunables.PADDING_BETWEEN_ROWS;
			btn.y = ref.y;
		}
	}
	
	private function get_header():String
	{
		return m_headerLabel.text;
	}

	private function set_header(value:String):String
	{
		m_headerLabel.text = value;

		return m_headerLabel.text;
	}

	private function get_instructions():String
	{
		return m_instructionsLabel.text;
	}

	private function set_instructions(value:String):String
	{
		m_instructionsLabel.text = value;

		return m_instructionsLabel.text;
	}
	
	private function set_gradeLabel():Void
	{
		// Get current selected grade
		var teacher:Teacher = switch (SpeckGlobals.teacher)
		{
			case Some(teacher): teacher;
			case None: null;
		}
		
		if ( teacher != null )
		{
			// Display grade label
			var grade:Grade = teacher.grade;
			var gradeString:String = "";
			switch ( grade )
			{
				case KINDERGARTEN: gradeString += " Kindergarten ";
				case FIRST: gradeString += " First Grade ";
				case SECOND: gradeString += " Second Grade ";
			}
			gradeString += " Class ";
			
			var name:String = teacher.id;
			m_gradeLabel.text = name + "'s " + gradeString;
		}

	}
}