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

package game.controllers;

import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.loader.ResMan;
import game.cms.Answer.CMSAnswer;
import game.cms.Curriculum;
import game.cms.Dataset;
import game.cms.Grade;
import game.cms.Question.CMSQuestion;
import game.cms.QuestionDatabase;
import game.cms.QuestionSheet;
import game.cms.QuestionType;
import game.events.GenericEvent;
import game.events.GenericMenuEvents;
import game.events.QuestionEvents;
import game.models.AnswerTracker;
import game.models.PlayerChoice;
import game.net.AccountManager;
import game.net.NetAssets;
import game.ui.HudMenu.HudMode;
import game.ui.question.Answer.UIAnswer;
import game.ui.question.AnswerPanel;
import game.ui.question.ImageAnswer;
import game.ui.question.ImageQuestion;
import game.ui.question.NumericAnswer;
import game.ui.question.QuestionBackground;
import game.ui.question.QuestionButtonIds;
import game.ui.question.QuestionDebugOverlay;
import game.ui.question.QuestionHeader;
import game.ui.question.SocialStudiesStory;
import game.ui.question.TextAnswer;
import game.ui.question.TextQuestion;
import game.ui.question.UIBundle;
import game.ui.question.UIBundleBuilder.UIBundlerBuilder;
import game.ui.question.UIElement;
import game.utils.AbstractEnumTools;
import game.utils.URLUtils;
import game.utils.audio.AudioQueue;
import game.utils.audio.AudioQueueBuilder;
import haxe.ds.ObjectMap;
import haxe.ds.Option;
import motion.Actuate;
import openfl.display.Bitmap;

using StringTools;

using Lambda;
using game.utils.OptionExtension;
using game.models.AnswerExtension;

class QuestionController
{
	private static inline var S3_ASSET_URL:String = "https://chefk-prod.s3.amazonaws.com/curriculum/images/";
	private static inline var S3_SOUND_URL:String = "https://chefk-prod.s3.amazonaws.com/curriculum/audio/";

	private static var s_numberRegex:EReg = ~/^\d+$/;

	private var m_hasAnsweredIncorrectly:Bool;
	private var m_hasAnsweredAdaptiveQuestion:Bool;
	
	private var m_sheets:Option<Dataset<QuestionSheet>>;
	private var m_grades:Option<Dataset<Grade>>;
	private var m_weeks:Option<Dataset<Int>>;
	private var m_data:Dataset<CMSQuestion>;

	private var m_answerUI:Array<UIAnswer>;
	private var m_uiBundle:Option<UIBundle>;
	private var m_debugUI:QuestionDebugOverlay;

	private var m_uiAnswerToCmsAnswer:ObjectMap<UIAnswer, CMSAnswer>;

	private var m_tracker:Option<AnswerTracker>;

	public function new(data:Dataset<CMSQuestion>)
	{
		m_hasAnsweredIncorrectly = false;
		m_hasAnsweredAdaptiveQuestion = false;

		m_data = data;

		m_answerUI = [];
		m_uiBundle = None;

		m_debugUI = new QuestionDebugOverlay();

		m_uiAnswerToCmsAnswer = new ObjectMap<UIAnswer, CMSAnswer>();

		// Attempt to instantiate the tracker from the student's existing JSON
		m_tracker = SpeckGlobals.student.flatMap(function(student)
		{
			var tracker = AnswerTracker.fromJson(student.saveData == null ? '[]' : student.saveData);
			return Some(tracker);
		});
	}

	public function start():Void
	{
		goToQuestion();

		SpeckGlobals.event.addEventListener(GenericMenuEvents.BUTTON_CLICKED, onButtonClicked);
		
		// Back button should only be accessible when entered via the PILOT flow
		var accessedViaFlow:Bool = (FlowController.data.currentCurriculum != null);
		if (accessedViaFlow)
		{
			SpeckGlobals.hud.enable(HudMode.SIMPLE);
		}
		
		// Debug UI should only be visible when accessed via the template button
		var accessedViaTemplate:Bool = (FlowController.data.currentCurriculum == null);
		var accessedViaAssessment:Bool = URLUtils.didProvideAssessment();
		#if debug
		if (accessedViaTemplate)
		{
			var sheets:Array<QuestionSheet> = AbstractEnumTools.getValues(QuestionSheet);
			var grades:Array<Grade> = AbstractEnumTools.getValues(Grade);
			var weeks:Array<Int> = [for (i in 1...11) i];
			
			Dataset.make(sheets).flatMap(function(sheetsDataset){
				m_sheets = Some(sheetsDataset);
				
				return Dataset.make(grades).flatMap(function(gradesDataset){
					m_grades = Some(gradesDataset);
					
					return Dataset.make(weeks).flatMap(function(weeksDataset){
						m_weeks = Some(weeksDataset);
						
						m_debugUI.currentCurriculum = sheetsDataset.item;
						m_debugUI.currentGrade = Std.string(gradesDataset.item);
						m_debugUI.currentWeek = Std.string(weeksDataset.item);
						m_debugUI.show();
						
						var questions:Array<CMSQuestion> = 
							QuestionDatabase.instance.query()
								.inSheet(sheetsDataset.item)
								.forGrade(gradesDataset.item)
								.forWeek(weeksDataset.item)
								.finish();
								
						return Dataset.make(questions).flatMap(function(questionsDataset){
							m_data = questionsDataset;
							goToQuestion();
							return Some(questionsDataset);
						});
					});
				});
			});
		}
		#end
	}

	public function stop():Void
	{
		m_debugUI.hide();

		SpeckGlobals.event.removeEventListener(GenericMenuEvents.BUTTON_CLICKED, onButtonClicked);
	}

	private function getNextQuestion():Void
	{
		if (m_data.onLastItem())
		{
			// Record the player's updated choices using the answer tracker
			SpeckGlobals.student.flatMap(function(student)
			{
				return m_tracker.flatMap(function(tracker)
				{
					student.saveData = tracker.toJson();
					AccountManager.saveStudent(student);

					return Some(tracker);
				});
			});

			var event = new GenericEvent(this, QuestionEvents.COMPLETE);
			SpeckGlobals.event.dispatchEvent(event);
		}
		else
		{
			m_data.goToNextItem();

			var isEasy:Bool = (m_data.item.questionType == QuestionType.ADAPTIVE_EASIER);
			var isHard:Bool = (m_data.item.questionType == QuestionType.ADAPTIVE_HARDER);
			var shouldSkip:Bool = (isHard && m_hasAnsweredIncorrectly) || (isEasy && !m_hasAnsweredIncorrectly) || m_hasAnsweredAdaptiveQuestion;
			if (shouldSkip)
			{
				getNextQuestion();
			}
			else
			{
				clearCurrentQuestion();
				setupForQuestion(m_data.item);
			}
		}
	}

	private function goToQuestion():Void
	{
		clearCurrentQuestion();
		setupForQuestion(m_data.item);
	}

	private function clearCurrentQuestion():Void
	{
		m_hasAnsweredIncorrectly = false;

		m_answerUI = [];

		m_uiBundle = m_uiBundle.flatMap(function(bundle)
		{
			function hide(element:UIElement):Option<UIElement>
			{
				element.hide();
				return Some(element);
			}

			bundle.questionBackground.flatMap(hide);
			bundle.imageQuestion.flatMap(hide);
			bundle.textQuestion.flatMap(hide);
			bundle.answerPanel.flatMap(hide);
			bundle.expandedStory.flatMap((hide));
			bundle.compactStory.flatMap((hide));
			bundle.questionHeader.flatMap(hide);

			return None;
		});

		m_uiAnswerToCmsAnswer = new ObjectMap<UIAnswer, CMSAnswer>();

		WebAudio.instance.stop();
	}

	private function setupForQuestion(data:CMSQuestion):Void
	{
		// trace('setupForQuestion: $data');
		m_debugUI.currentQuestion = data.id;

		var isText:Bool = false;
		var isImage:Bool = false;
		var isNumber:Bool = false;

		var isSocialStudies:Bool = (data.curriculum == Curriculum.SOCIAL_STUDIES);
		var isMathScience:Bool = (data.curriculum == Curriculum.MATH_AND_SCIENCE);
		
		var isAssessment:Bool =
		(data.questionSheet == QuestionSheet.ZERO_WEEK_ASSESSMENT)
		|| 	(data.questionSheet == QuestionSheet.FIVE_WEEK_ASSESSMENT)
		|| 	(data.questionSheet == QuestionSheet.TEN_WEEK_ASSESSMENT);

		var isSocialStudiesAssessment:Bool = (isSocialStudies && isAssessment);
		var isMathScienceAssessment:Bool = ( isMathScience && isAssessment );

		var builder = UIBundlerBuilder.make();

		// Create the background
		{
			var background = new QuestionBackground();

			background.hideNextQuestionButton();

			builder.questionBackground(background);
		}

		// Create the header
		{
			if ( !isSocialStudies && !isMathScience )
			{
				var header = new QuestionHeader();

				header.header = data.curriculum;

				builder.questionHeader(header);
			}
		}

		// Create the question
		{
			var hasVO:Bool = data.questionVO.isSome();
			var hasImage:Bool = data.questionImage.isSome();

			if (isSocialStudiesAssessment || !hasImage)
			{
				var question = isSocialStudiesAssessment ? TextQuestion.makeSocialStudies() : TextQuestion.makeDefault();

				question.text = data.questionText;

				if (hasVO)
				{
					question.showVOButton();
				}
				else
				{
					question.hideVOButton();
				}

				builder.textQuestion(question);
			}
			else
			{
				var question = new ImageQuestion();

				question.text = data.questionText;

				data.questionImage.flatMap(function(imagePath)
				{
					var imgUrl = S3_ASSET_URL + imagePath + ".png";

					if (!NetAssets.instance.isAssetLoaded(imgUrl))
					{
						//TODO:  Loading image?
					}

					function onImgLoaded(img:Bitmap):Void
					{
						if (img != null)
						{
							question.image = img;
						}
					}

					NetAssets.instance.getImage(imgUrl, onImgLoaded);

					return Some(imagePath);
				});

				if (hasVO)
				{
					data.questionVO.flatMap(function(sndName)
						{
							var sndUrl = S3_SOUND_URL + sndName;
							var sndId = 'Questions/${sndName}';

							WebAudio.instance.multiRegister([sndUrl, sndUrl.replace(".ogg", ".mp3")], sndId);
							WebAudio.instance.load([sndId]);

							return Some(sndName);
						});

					// TODO: Show this after the load completes?
					question.showVOButton();
				}
				else
				{
					question.hideVOButton();
				}

				builder.imageQuestion(question);
			}
		}

		// Create the answers
		{
			for (answer in data.answers)
			{
				answer.text.flatMap(function(text)
				{
					isNumber = s_numberRegex.match(text);
					isText = !isNumber;
					return Some(text);
				});

				answer.image.flatMap(function(assetPath)
				{
					isImage = true;

					return Some(assetPath);
				});

				if (isImage)
				{
					var answerUI = new ImageAnswer();

					answer.image.flatMap(function(assetPath)
					{
						var imgUrl = S3_ASSET_URL + assetPath + ".png";

						if (!NetAssets.instance.isAssetLoaded(imgUrl))
						{
							//TODO:  Loading image?
						}

						function onImgLoaded(img:Bitmap):Void
						{
							if (img != null)
							{
								answerUI.image = img;
							}
						}

						NetAssets.instance.getImage(imgUrl, onImgLoaded);

						return Some(assetPath);
					});

					m_answerUI.push(answerUI);
					m_uiAnswerToCmsAnswer.set(answerUI, answer);
				}
				else if (isNumber)
				{
					var answerUI = new NumericAnswer();

					answer.text.flatMap(function(text)
					{
						answerUI.answer = text;
						return Some(text);
					});

					m_answerUI.push(answerUI);
					m_uiAnswerToCmsAnswer.set(answerUI, answer);
				}
				else if (isSocialStudiesAssessment)
				{
					var answerUI = TextAnswer.makeSmall();

					answer.text.flatMap(function(text)
					{
						answerUI.answer = text;
						return Some(text);
					});

					m_answerUI.push(answerUI);
					m_uiAnswerToCmsAnswer.set(answerUI, answer);
				}
				else
				{
					var answerUI = TextAnswer.makeLarge();

					answer.text.flatMap(function(text)
					{
						answerUI.answer = text;
						return Some(text);
					});

					m_answerUI.push(answerUI);
					m_uiAnswerToCmsAnswer.set(answerUI, answer);
				}
			}
		}

		// Create the answer panel
		{
			var panel:AnswerPanel =
			if (isSocialStudiesAssessment)
			{
				if (isText)
				{
					AnswerPanel.makeSmallText();
				}
				else
				{
					AnswerPanel.makeSocialStudes();
				}
			}
			else
			{
				if (isText)
				{
					AnswerPanel.makeLargeText();
				}
				else
				{
					AnswerPanel.makeDefault();
				}
			}

			// Helper function to determine if VO is present
			function hasVO(answer:CMSAnswer):Bool
			{
				return answer.vo.isSome();
			}

			// Helper function to load/register answer vo
			function loadVO(answer:CMSAnswer):Bool
			{
				answer.vo.flatMap(function(vo)
					{
						var sndUrl = S3_SOUND_URL + vo;
						var sndId = 'Questions/$vo';

						WebAudio.instance.multiRegister([sndUrl, sndUrl.replace(".ogg", ".mp3")], sndId);
						WebAudio.instance.load([sndId]);

						return Some(vo);
					});

				return true;
			}

			// Show the answer VO button if we have all necessary VO
			var hasAllAnswerVO:Bool = data.answers.foreach(hasVO);
			if (hasAllAnswerVO)
			{
				data.answers.foreach(loadVO);
				panel.showVOButton();
			}
			else
			{
				panel.hideVOButton();
			}

			panel.answers = Random.shuffle(m_answerUI);

			builder.answerPanel(panel);
		}

		// Create the story panel
		{
			if (isSocialStudiesAssessment)
			{
				var expanded = SocialStudiesStory.makeExpanded();
				var compact = SocialStudiesStory.makeCompact();

				data.countryFact.flatMap(function(countryFact)
				{
					expanded.text = countryFact;
					compact.text = countryFact;

					if (compact.isTextClipped())
					{
						compact.shortenText();
						compact.showButtonWithId(QuestionButtonIds.EXPAND_STORY);
					}
					else
					{
						compact.hideButtonWithId(QuestionButtonIds.EXPAND_STORY);
					}

					return Some(countryFact);
				});

				var hasVO:Bool = data.countryFactVO.isSome();
				if (hasVO)
				{
					expanded.showVOButton();
					compact.showVOButton();
				}
				else
				{
					expanded.hideVOButton();
					compact.hideVOButton();
				}

				builder.expandedStory(expanded)
				.compactStory(compact);
			}
		}

		var bundle:UIBundle = builder.finish();

		function show(element:UIElement):Option<UIElement>
		{
			element.show();
			return Some(element);
		}

		bundle.questionBackground.flatMap(show);
		bundle.imageQuestion.flatMap(show);
		bundle.textQuestion.flatMap(show);
		bundle.answerPanel.flatMap(show);
		bundle.compactStory.flatMap(show);
		bundle.questionHeader.flatMap(show);

		m_uiBundle = Some(bundle);
	}

	private function onButtonClicked(event:GenericEvent<QuestionButtonIds>):Void
	{
		WebAudio.instance.play("SFX/button_click");

		var id:QuestionButtonIds = event.item;
		switch (id)
		{
			case QuestionButtonIds.ANSWER_ONE | QuestionButtonIds.ANSWER_TWO | QuestionButtonIds.ANSWER_THREE:
				{
					// Register the player's choice
					m_uiBundle.flatMap(function(bundle)
					{
						var uiAnswer:UIAnswer = m_answerUI[id];
						var cmsAnswer:CMSAnswer = m_uiAnswerToCmsAnswer.get(uiAnswer);

						if (!cmsAnswer.isCorrect)
						{
							m_hasAnsweredIncorrectly = true;
						}
						else
						{
							var isAdaptive:Bool = (m_data.item.questionType == QuestionType.ADAPTIVE_EASIER
												   || m_data.item.questionType == QuestionType.ADAPTIVE_HARDER );
							if ( isAdaptive )
							{
								m_hasAnsweredAdaptiveQuestion = true;
							}
						}

						// Record the player's choice using the answer tracker
						m_tracker.flatMap(function(tracker)
						{
							return m_data.item.week.flatMap(function(week)
							{
								var choice:PlayerChoice =
								{
									questionId: m_data.item.id,
									week: Std.string(week),
									grade: Std.string(m_data.item.grade),
									type: Std.string(m_data.item.questionType),
									sheet: m_data.item.questionSheet,
									curriculum: m_data.item.curriculum,
									answer: cmsAnswer.fromCmsAnswer(),
									learningStandard: m_data.item.learningStandard,
									timestamp: Date.now().toString()
								};

								tracker.recordChoice(choice);

								return Some(week);
							});
						});

						var feedbackController:IFeedbackController = FeedbackControllerFactory.make(m_data.item.questionSheet);

						var params:FeedbackParams =
						{
							id: id,
							bundle: bundle,
							cmsAnswer: cmsAnswer
						};

						if (feedbackController.evaluate(params))
						{
							m_uiBundle.flatMap(function(bundle)
							{
								var options:Array<Option<UIElement>> = cast [bundle.answerPanel, bundle.compactStory, bundle.expandedStory, bundle.imageQuestion, bundle.questionHeader, bundle.textQuestion];
								for (opt in options)
								{
									opt.flatMap(function(element)
									{
										element.fadeOut();
										return Some(element);
									});
								}

								Actuate.timer(UIElement.FADE_DURATION)
								.onComplete(getNextQuestion);

								return Some(bundle);
							});
						}

						return Some(bundle);
					});
				}
			case QuestionButtonIds.DEBUG_NEXT_QUESTION:
				{
					m_data.goToNextItem();
					goToQuestion();
				}
			case QuestionButtonIds.DEBUG_PREVIOUS_QUESTION:
				{
					m_data.goToPreviousItem();
					goToQuestion();
				}
			case QuestionButtonIds.DEBUG_NEXT_TAB:
				{
					m_sheets.flatMap(function(sheetsDataset){
						return m_grades.flatMap(function(gradesDataset){
							return m_weeks.flatMap(function(weeksDataset){
								sheetsDataset.goToNextItem();
								
								m_debugUI.currentCurriculum = sheetsDataset.item;
								m_debugUI.currentGrade = Std.string(gradesDataset.item);
								m_debugUI.currentWeek = Std.string(weeksDataset.item);
								
								var questions:Array<CMSQuestion> = 
									QuestionDatabase.instance.query()
										.inSheet(sheetsDataset.item)
										.forGrade(gradesDataset.item)
										.forWeek(weeksDataset.item)
										.finish();
										
								return Dataset.make(questions).flatMap(function(questionsDataset){
									m_data = questionsDataset;
									goToQuestion();
									return Some(questionsDataset);
								});
							});
						});
					});
				}
			case QuestionButtonIds.DEBUG_PREVIOUS_TAB:
				{
					m_sheets.flatMap(function(sheetsDataset){
						return m_grades.flatMap(function(gradesDataset){
							return m_weeks.flatMap(function(weeksDataset){
								sheetsDataset.goToPreviousItem();
								
								m_debugUI.currentCurriculum = sheetsDataset.item;
								m_debugUI.currentGrade = Std.string(gradesDataset.item);
								m_debugUI.currentWeek = Std.string(weeksDataset.item);
								
								var questions:Array<CMSQuestion> = 
									QuestionDatabase.instance.query()
										.inSheet(sheetsDataset.item)
										.forGrade(gradesDataset.item)
										.forWeek(weeksDataset.item)
										.finish();
										
								return Dataset.make(questions).flatMap(function(questionsDataset){
									m_data = questionsDataset;
									goToQuestion();
									return Some(questionsDataset);
								});
							});
						});
					});
				}
			case QuestionButtonIds.DEBUG_NEXT_WEEK:
				{
					m_sheets.flatMap(function(sheetsDataset){
						return m_grades.flatMap(function(gradesDataset){
							return m_weeks.flatMap(function(weeksDataset){
								weeksDataset.goToNextItem();
								
								m_debugUI.currentCurriculum = sheetsDataset.item;
								m_debugUI.currentGrade = Std.string(gradesDataset.item);
								m_debugUI.currentWeek = Std.string(weeksDataset.item);
								
								var questions:Array<CMSQuestion> = 
									QuestionDatabase.instance.query()
										.inSheet(sheetsDataset.item)
										.forGrade(gradesDataset.item)
										.forWeek(weeksDataset.item)
										.finish();
										
								return Dataset.make(questions).flatMap(function(questionsDataset){
									m_data = questionsDataset;
									goToQuestion();
									return Some(questionsDataset);
								});
							});
						});
					});
				}
			case QuestionButtonIds.DEBUG_PREVIOUS_WEEK:
				{
					m_sheets.flatMap(function(sheetsDataset){
						return m_grades.flatMap(function(gradesDataset){
							return m_weeks.flatMap(function(weeksDataset){
								weeksDataset.goToPreviousItem();
								
								m_debugUI.currentCurriculum = sheetsDataset.item;
								m_debugUI.currentGrade = Std.string(gradesDataset.item);
								m_debugUI.currentWeek = Std.string(weeksDataset.item);
								
								var questions:Array<CMSQuestion> = 
									QuestionDatabase.instance.query()
										.inSheet(sheetsDataset.item)
										.forGrade(gradesDataset.item)
										.forWeek(weeksDataset.item)
										.finish();
										
								return Dataset.make(questions).flatMap(function(questionsDataset){
									m_data = questionsDataset;
									goToQuestion();
									return Some(questionsDataset);
								});
							});
						});
					});
				}
			case QuestionButtonIds.DEBUG_NEXT_GRADE:
				{
					m_sheets.flatMap(function(sheetsDataset){
						return m_grades.flatMap(function(gradesDataset){
							return m_weeks.flatMap(function(weeksDataset){
								gradesDataset.goToNextItem();
								
								m_debugUI.currentCurriculum = sheetsDataset.item;
								m_debugUI.currentGrade = Std.string(gradesDataset.item);
								m_debugUI.currentWeek = Std.string(weeksDataset.item);
								
								var questions:Array<CMSQuestion> = 
									QuestionDatabase.instance.query()
										.inSheet(sheetsDataset.item)
										.forGrade(gradesDataset.item)
										.forWeek(weeksDataset.item)
										.finish();
										
								return Dataset.make(questions).flatMap(function(questionsDataset){
									m_data = questionsDataset;
									goToQuestion();
									return Some(questionsDataset);
								});
							});
						});
					});
				}
			case QuestionButtonIds.DEBUG_PREVIOUS_GRADE:
				{
					m_sheets.flatMap(function(sheetsDataset){
						return m_grades.flatMap(function(gradesDataset){
							return m_weeks.flatMap(function(weeksDataset){
								gradesDataset.goToPreviousItem();
								
								m_debugUI.currentCurriculum = sheetsDataset.item;
								m_debugUI.currentGrade = Std.string(gradesDataset.item);
								m_debugUI.currentWeek = Std.string(weeksDataset.item);
								
								var questions:Array<CMSQuestion> = 
									QuestionDatabase.instance.query()
										.inSheet(sheetsDataset.item)
										.forGrade(gradesDataset.item)
										.forWeek(weeksDataset.item)
										.finish();
										
								return Dataset.make(questions).flatMap(function(questionsDataset){
									m_data = questionsDataset;
									goToQuestion();
									return Some(questionsDataset);
								});
							});
						});
					});
				}
			case QuestionButtonIds.NEXT_QUESTION:
				{
					m_uiBundle.flatMap(function(bundle)
					{
						var options:Array<Option<UIElement>> = cast [bundle.answerPanel, bundle.compactStory, bundle.expandedStory, bundle.imageQuestion, bundle.questionHeader, bundle.textQuestion];
						for (opt in options)
						{
							opt.flatMap(function(element)
							{
								element.fadeOut();
								return Some(element);
							});
						}

						Actuate.timer(UIElement.FADE_DURATION)
						.onComplete(getNextQuestion);

						return Some(bundle);
					});
				}
			case QuestionButtonIds.EXPAND_STORY:
				{
					m_uiBundle.flatMap(function(bundle)
					{
						return bundle.compactStory.flatMap(function(compactStory)
						{
							return bundle.expandedStory.flatMap(function(expandedStory)
							{
								compactStory.hide();
								expandedStory.show();
								return Some(expandedStory);
							});
						});
					});
				}
			case QuestionButtonIds.CLOSE_STORY:
				{
					m_uiBundle.flatMap(function(bundle)
					{
						return bundle.compactStory.flatMap(function(compactStory)
						{
							return bundle.expandedStory.flatMap(function(expandedStory)
							{
								compactStory.show();
								expandedStory.hide();
								return Some(expandedStory);
							});
						});
					});
				}
			case QuestionButtonIds.ANSWER_VO:
				{
					WebAudio.instance.stopAllSounds();

					var builder = AudioQueueBuilder.make();

					for (uiAnswer in m_answerUI)
					{
						var cmsAnswer:CMSAnswer = m_uiAnswerToCmsAnswer.get(uiAnswer);
						cmsAnswer.vo.flatMap(function(vo)
						{
							var id:String = 'Questions/${vo}';
							builder.enqueue(id);

							return Some(vo);
						});
					}

					builder.onComplete(onVoComplete);

					var queue:AudioQueue = builder.finish();
					queue.trigger();

					m_uiBundle.flatMap(function(bundle)
					{
						bundle.compactStory.flatMap(function(compactStory)
						{
							compactStory.enableButtonById(QuestionButtonIds.STORY_VO);
							return Some(compactStory);
						});

						bundle.expandedStory.flatMap(function(expandedStory)
						{
							expandedStory.enableButtonById(QuestionButtonIds.STORY_VO);
							return Some(expandedStory);
						});

						bundle.answerPanel.flatMap(function(answerPanel)
						{
							answerPanel.disableButtonById(QuestionButtonIds.ANSWER_VO);
							return Some(answerPanel);
						});

						bundle.textQuestion.flatMap(function(textQuestion)
						{
							textQuestion.enableButtonById(QuestionButtonIds.QUESTION_VO);
							return Some(textQuestion);
						});

						bundle.imageQuestion.flatMap(function(imageQuestion)
						{
							imageQuestion.enableButtonById(QuestionButtonIds.QUESTION_VO);
							return Some(imageQuestion);
						});

						return Some(bundle);
					});
				}
			case QuestionButtonIds.QUESTION_VO:
				{
					m_data.item.questionVO.flatMap(function(vo)
					{
						WebAudio.instance.stopAllSounds();

						var id:String = 'Questions/${vo}';
						WebAudio.instance.playVO(id, onVoComplete);

						return m_uiBundle.flatMap(function(bundle)
						{
							bundle.compactStory.flatMap(function(compactStory)
							{
								compactStory.enableButtonById(QuestionButtonIds.STORY_VO);
								return Some(compactStory);
							});

							bundle.expandedStory.flatMap(function(expandedStory)
							{
								expandedStory.enableButtonById(QuestionButtonIds.STORY_VO);
								return Some(expandedStory);
							});

							bundle.answerPanel.flatMap(function(answerPanel)
							{
								answerPanel.enableButtonById(QuestionButtonIds.ANSWER_VO);
								return Some(answerPanel);
							});

							bundle.textQuestion.flatMap(function(textQuestion)
							{
								textQuestion.disableButtonById(QuestionButtonIds.QUESTION_VO);
								return Some(textQuestion);
							});

							bundle.imageQuestion.flatMap(function(imageQuestion)
							{
								imageQuestion.disableButtonById(QuestionButtonIds.QUESTION_VO);
								return Some(imageQuestion);
							});

							return Some(bundle);
						});
					});
				}
			case QuestionButtonIds.STORY_VO:
				{
					m_data.item.countryFactVO.flatMap(function(vo)
					{
						WebAudio.instance.stopAllSounds();

						var id:String = 'Questions/${vo}';
						WebAudio.instance.playVO(id, onVoComplete);

						return m_uiBundle.flatMap(function(bundle)
						{
							bundle.compactStory.flatMap(function(compactStory)
							{
								compactStory.enableButtonById(QuestionButtonIds.STORY_VO);
								return Some(compactStory);
							});

							bundle.expandedStory.flatMap(function(expandedStory)
							{
								expandedStory.enableButtonById(QuestionButtonIds.STORY_VO);
								return Some(expandedStory);
							});

							bundle.answerPanel.flatMap(function(answerPanel)
							{
								answerPanel.enableButtonById(QuestionButtonIds.ANSWER_VO);
								return Some(answerPanel);
							});

							bundle.textQuestion.flatMap(function(textQuestion)
							{
								textQuestion.disableButtonById(QuestionButtonIds.QUESTION_VO);
								return Some(textQuestion);
							});

							bundle.imageQuestion.flatMap(function(imageQuestion)
							{
								imageQuestion.disableButtonById(QuestionButtonIds.QUESTION_VO);
								return Some(imageQuestion);
							});

							return Some(bundle);
						});
					});
				}
		}
	}

	private function onVoComplete():Void
	{
		m_uiBundle.flatMap(function(bundle)
		{
			bundle.compactStory.flatMap(function(compactStory)
			{
				compactStory.enableButtonById(QuestionButtonIds.STORY_VO);
				return Some(compactStory);
			});

			bundle.expandedStory.flatMap(function(expandedStory)
			{
				expandedStory.enableButtonById(QuestionButtonIds.STORY_VO);
				return Some(expandedStory);
			});

			bundle.answerPanel.flatMap(function(answerPanel)
			{
				answerPanel.enableButtonById(QuestionButtonIds.ANSWER_VO);
				return Some(answerPanel);
			});

			bundle.textQuestion.flatMap(function(textQuestion)
			{
				textQuestion.enableButtonById(QuestionButtonIds.QUESTION_VO);
				return Some(textQuestion);
			});

			bundle.imageQuestion.flatMap(function(imageQuestion)
			{
				imageQuestion.enableButtonById(QuestionButtonIds.QUESTION_VO);
				return Some(imageQuestion);
			});

			return Some(bundle);
		});
	}
}