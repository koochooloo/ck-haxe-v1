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
import com.firstplayable.hxlib.Debug.*;
import com.firstplayable.hxlib.audio.WebAudio;
import com.firstplayable.hxlib.display.GraphicButton;
import com.firstplayable.hxlib.display.OPSprite;
import com.firstplayable.hxlib.loader.ResMan;
import com.firstplayable.hxlib.state.IGameState.GameStateParams;
import com.firstplayable.hxlib.state.StateManager;
import game.Country;
import game.Recipe;
import game.Step.StepTypes;
import game.controllers.FlowController;
import game.def.GameState;
import game.ui.ScrollingManager;
import game.ui.SpeckMenu;
import game.ui.states.RecipeStepsMenu.StepGroup;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

#if (js && html5)
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.Element;
import js.Browser;
#end

typedef StepGroup =
{
	panel:DisplayObjectContainer,
	menuPane:OPSprite,
	stepIcon:OPSprite,
	chef:OPSprite,
	label:TextField,
	stepNumber:TextField
}

class RecipeStepsMenu extends SpeckMenu
{
	// ------ Static tunable vars:
	// TODO - callback to pull from paist bounding box
	private static inline var DISPLAYNUM:Int = 2;
	private static inline var PANEL_PADDING:Float = 20; // px
	
	private var m_scrollMenu:ScrollingManager;

	public function new(p:GameStateParams) 
	{
		super( "RecipeStepsMenu" );
	
		// Change menu title
		var title:TextField = cast getChildByName( "headerText_recipe" );
		title.text = capitalize( FlowController.data.selectedRecipe.name ); 
		
		// Create scrolling menu
		var scrollBounds:DisplayObjectContainer = cast getChildByName( "scroll_bounds" );
		m_scrollMenu = new ScrollingManager( scrollBounds.x, scrollBounds.y, scrollBounds.width, scrollBounds.height, this, "vertical", DISPLAYNUM );
		
		// Create steps and add them to the scrolling menu
		initSteps();

		// Initialize the scrolling menu
		m_scrollMenu.init();
		this.addChild( m_scrollMenu );
	}
	
	/**
	 *  Populate a scrolling list of steps using paist menu assets
	 */
	private function initSteps():Void
	{
		// Get sample step assets from the paist menu - three possible sizes [ small, med, large ]
		var paistGroups:Array< StepGroup > = getPaistGroups();
		
		// Create steps from recipe steps and paist reference. Pass them to the scroll manager.
		var ref:StepGroup = paistGroups[0];
		var offset:Float = 0;
		var increment:Float = 0;
		for ( step in FlowController.data.selectedRecipe.steps )
		{	
			// Panel for object parenting/relative positioning
			var panel:DisplayObjectContainer = new DisplayObjectContainer();
			panel.x = ref.panel.x;
			panel.y = ref.panel.y + offset;
			this.addChild( panel );
			
			// Display panel for step text 
			var menu:OPSprite = new OPSprite( ResMan.instance.getImage( "2d/UI/9patch/9patch-DefaultPanel" ) );
			menu.x = ref.menuPane.x;
			menu.y = ref.menuPane.y;
			menu.width = ref.menuPane.width;
			menu.height = ref.menuPane.height;
			panel.addChild( menu );
			
			// Green bubble icon behind the step number 
			var icon:OPSprite = new OPSprite( ResMan.instance.getImage( "2d/UI/stepNumber" ) );
			icon.x = ref.stepIcon.x;
			icon.y = ref.stepIcon.y;
			panel.addChild( icon );
			
			// Label with step instructions
			var label:TextField = new TextField();
			label.text = step.instruction;
			label.x = ref.label.x;
			label.y = ref.label.y;
			label.setTextFormat( ref.label.getTextFormat() );
			label.height = ref.label.height;
			label.width = ref.label.width;
			label.wordWrap = true;
			label.autoSize = TextFieldAutoSize.LEFT;
			panel.addChild( label );
			
			// Resize display panel based on text height
			menu.height = ( label.height > ref.menuPane.height ) ? label.height : ref.menuPane.height ;
			
			// Set offset increment based on menu panel size
			increment = menu.height;
			
			// Label with step number
			var number:TextField = new TextField();
			number.text = Std.string( step.order + 1 ); // Step order is zero-indexed
			number.autoSize = TextFieldAutoSize.CENTER;
			number.setTextFormat( ref.stepNumber.getTextFormat() );
			number.x = ref.stepNumber.x;
			number.y = ref.stepNumber.y;
			panel.addChild( number );
			
			// Big/little chef icon, depending on step type
			var chef:OPSprite; 
			switch ( step.type )
			{
				case StepTypes.BIGCHEF: 		
				{
					chef = new OPSprite( ResMan.instance.getImage( "2d/UI/chefBig" ) );
					chef.x = ref.chef.x;
					chef.y = ref.chef.y;
				}
				case StepTypes.LITTLECHEF: 
				{
					chef = new OPSprite( ResMan.instance.getImage( "2d/UI/chefLittle" ) );
					chef.x = ref.chef.x;
					chef.y = ref.chef.y;
				}
			}
			panel.addChild( chef );
			
			// Dummy button, menu size
			var button:GraphicButton = new GraphicButton( menu.getBitmap() );
			button.name = Std.string( step.order );
			
			// Add item to scroll menu
			m_scrollMenu.addItem( panel, button );
			
			// Increment offset
			offset += increment + PANEL_PADDING;
		}
		
		showMasks();
	}
	
	private function getPaistGroups():Array< StepGroup >
	{
		var paistGroups:Array< StepGroup > = new Array();
		for (i in 0...3)
		{
			var size:String = null;
			switch(i)
			{
				case 0: size = "small";
				case 1: size = "medium";
				case 2: size = "large";
			}
			
			var panel:DisplayObjectContainer = cast getChildByName("group_step_" + size);
			var pane:OPSprite = cast panel.getChildByName("panelStep_" + size);
			var stepIcon:OPSprite = cast panel.getChildByName("stepIcon_" + size);
			var big:OPSprite = cast panel.getChildByName("chefBig_" + size);
			var label:TextField = cast panel.getChildByName("lbl_step_" + size);
			var stepNumber:TextField = cast panel.getChildByName("lbl_stepNumber_" + size);
			panel.visible = false;
			
			var group:StepGroup = { 
				panel: panel, 
				menuPane: pane, 
				stepIcon: stepIcon, 
				chef: big, 
				label: label, 
				stepNumber: stepNumber
			};
			paistGroups.push(group);
		}
		
		return paistGroups;
	}
	
	private function showMasks():Void
	{
		// Reparent menu sprites on top of newly added sprites
		m_scrollMenu.reparent();
		
	}
}