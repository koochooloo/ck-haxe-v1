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

package game.ui.question;

import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import game.cms.QuestionSheet;
import game.net.AccountManager.Student;
import game.ui.question.AssessmentButtonIds;
import com.firstplayable.hxlib.state.StateManager;
import game.def.GameState;
import game.utils.URLUtils;

using StringTools;

class Assessment extends UIElement
{
	public static inline var LAYOUT:String = "Assessment";
	
	public function new()
	{
		super(LAYOUT);
		
		// Hide nav button if accessed in "assessment only" mode
		if ( URLUtils.didProvideAssessment() )
		{
			toggleObjectVisibility( "btn_back", false );
		}
	}
	
	public override function show()
	{
		super.show();
		
		// ------------------------------
		// Conditionally display "completed" overlay for each assessment section
		// ------------------------------
		
		var student:Student = switch( SpeckGlobals.student )
		{
			case Some( s ): s;
			case None: null;
		}
		
		if ( student != null )
		{
			var hasCompletedPre:Bool = student.saveData.indexOf( QuestionSheet.ZERO_WEEK_ASSESSMENT ) > 0;
			var hasCompletedMid:Bool = student.saveData.indexOf( QuestionSheet.FIVE_WEEK_ASSESSMENT ) > 0;
			var hasCompletedPost:Bool = student.saveData.indexOf( QuestionSheet.TEN_WEEK_ASSESSMENT ) > 0;
			
			if ( hasCompletedPre )
			{
				disableButtonById( cast ( AssessmentButtonIds.BEFORE, Int ) );
				var before:OPSprite = cast getChildByName( "spr_completed_before" );
				before.visible = true;
			}
			
			if ( hasCompletedMid )
			{
				disableButtonById( cast ( AssessmentButtonIds.MIDDLE, Int ) );
				var middle:OPSprite = cast getChildByName( "spr_completed_middle" );
				middle.visible = true;
			}
					
			if ( hasCompletedPost )
			{
				disableButtonById( cast ( AssessmentButtonIds.END, Int ) );
				var after:OPSprite = cast getChildByName( "spr_completed_end" );
				after.visible = true;
			}
		}
	}
	
	override public function onButtonHit(?caller:GraphicButton):Void
	{
		super.onButtonHit(caller);
		
		if ( caller.name == "btn_back" )
		{
			StateManager.setState( GameState.GLOBE );
		}
	}
}