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

package game;

enum StepTypes
{
	BIGCHEF;
	LITTLECHEF;
}

class Step
{
	public var order(default, null):Int; // Order in which step should be performed, relative to others in the recipe. 
	public var type(default, null):StepTypes; // Describes who should perform a given step.
	public var instruction(default, null):String; 
	
	public function new(order:Int, type:Null<Int>, instruction:String) 
	{
		this.order = order;
		if (type != null) 
		{
			this.type = Type.createEnumIndex(StepTypes, type);
		}
		else
		{
			this.type = BIGCHEF;
		}

		this.instruction = instruction;
	}
	
}