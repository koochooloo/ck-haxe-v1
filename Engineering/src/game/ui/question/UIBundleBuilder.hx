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

import game.ui.question.UIBundleBuilder.UIBundlerBuilder;
import haxe.ds.Option;

class UIBundlerBuilder
{
	private var m_params:UIBundleParams;

	private function new()
	{
		m_params =
		{
			textQuestion: None,
			imageQuestion: None,
			answerPanel: None,
			compactStory: None,
			expandedStory: None,
			questionBackground: None,
			questionHeader: None
		};
	}
	
	public function textQuestion(value:TextQuestion):UIBundlerBuilder
	{
		m_params.textQuestion = Some(value);
		return this;
	}
	
	public function imageQuestion(value:ImageQuestion):UIBundlerBuilder
	{
		m_params.imageQuestion = Some(value);
		
		return this;
	}
	
	public function answerPanel(value:AnswerPanel):UIBundlerBuilder
	{
		m_params.answerPanel = Some(value);
		
		return this;
	}
	
	public function compactStory(value:SocialStudiesStory):UIBundlerBuilder
	{
		m_params.compactStory = Some(value);
		
		return this;
	}
	
	public function expandedStory(value:SocialStudiesStory):UIBundlerBuilder
	{
		m_params.expandedStory = Some(value);
		
		return this;
	}
	
	public function questionBackground(value:QuestionBackground):UIBundlerBuilder
	{
		m_params.questionBackground = Some(value);
		
		return this;
	}
	
	public function questionHeader(value:QuestionHeader):UIBundlerBuilder
	{
		m_params.questionHeader = Some(value);
		
		return this;
	}
	
	@:access(game.ui.question.UIBundle)
	public function finish():UIBundle
	{
		return new UIBundle(m_params);
	}
	
	public static function make():UIBundlerBuilder
	{
		return new UIBundlerBuilder();
	}
}