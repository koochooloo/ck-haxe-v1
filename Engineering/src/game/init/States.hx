//
// Copyright (C) 2016, 1st Playable Productions, LLC. All rights reserved.
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

package game.init;

#if (debug || build_cheats)
import com.firstplayable.hxlib.debug.menuEdit.MenuEditState;
#end
import com.firstplayable.hxlib.state.StateManager;
import game.states.AllergiesConfirmState;
import game.states.AssessmentCompletedState;
import game.states.AssessmentState;
import game.states.DecisionState;
import game.states.FavoritesState;
import game.states.GlobeState;
import game.states.LoadQuestionAudioState;
import game.states.ParentalState;
import game.states.PassportState;
import game.states.QuestionState;
import game.states.RecipesState;
import game.states.SplashState;
import game.states.AllergiesState;
import game.states.StudentIdLoginState;
import game.states.TeacherIdLoginState;
import game.states.AboutState;
import game.states.RecipeServingState;
import game.states.RecipeIngredientsState;
import game.states.RecipeStepsState;
import game.states.DidYouKnowState;
import game.states.FlagGameState;
import game.states.IngredientInfoState;
import game.states.MathGameState;
import game.states.CountryIntroState;
import game.states.AdminState;
import game.states.CountryStoryState;
import game.utils.StateUtils;
import game.ui.states.ModeSelectState;
import game.states.SupportState;

import game.def.GameState;

class States
{
	public static function init():Void
	{
		StateManager.addState( new SplashState() );
		StateManager.addState( new RecipesState() );
		StateManager.addState( new FavoritesState() );
		StateManager.addState( new AllergiesState() );
		StateManager.addState( new AboutState() );
		StateManager.addState( new RecipeServingState() );
		StateManager.addState( new RecipeIngredientsState() );
		StateManager.addState( new RecipeStepsState() );
		StateManager.addState( new DidYouKnowState() );
		StateManager.addState( new FlagGameState() );
		StateManager.addState( new IngredientInfoState() );
		StateManager.addState( new MathGameState() );
		StateManager.addState( new CountryIntroState() );
		StateManager.addState( new AllergiesConfirmState() );
		StateManager.addState( new ParentalState() );
		StateManager.addState( new AdminState() );
		StateManager.addState( new QuestionState() );
		StateManager.addState( new PassportState() );
		StateManager.addState(new LoadQuestionAudioState());
		StateManager.addState(new TeacherIdLoginState());
		StateManager.addState(new StudentIdLoginState());
		StateManager.addState(new GlobeState());
		StateManager.addState(new AssessmentState());
		StateManager.addState(new AssessmentCompletedState());
		StateManager.addState(new DecisionState(GameState.ASSESSMENT_OR_GLOBE, StateUtils.assessmentOrGlobe));
		StateManager.addState( new CountryStoryState() );
		StateManager.addState( new ModeSelectState() );
		StateManager.addState( new SupportState() );
		
		#if (debug || build_cheats)
		StateManager.addState( new MenuEditState(MENU_TEST) );
		#end
	}
}