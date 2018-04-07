//
// Copyright (C) 2006-2016, 1st Playable Productions, LLC. All rights reserved.
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
package;

import massive.munit.Assert;
import com.firstplayable.hxlib.utils.ShuffleBag;

class ShuffleBagTest 
{
	static var SHUFFLE_MIN:Int = 3;
	static var SHUFFLE_MAX:Int = 8;
	static var SHUFFLE_LOOPS:Int = 3;
	
	@Test
	public function testIntBag():Void
	{
	   var testBag:ShuffleBag<Int> = new ShuffleBag<Int>();
	   for (i in SHUFFLE_MIN ... SHUFFLE_MAX)
	   {
	      testBag.add(i);
	   }

      var prev:Int = SHUFFLE_MAX;

      for (j in 0 ... SHUFFLE_LOOPS)
      {
         var usedBits:Array<Bool> = new Array<Bool>();
         for (i in SHUFFLE_MIN ... SHUFFLE_MAX)
         {
            usedBits[i] = false;
         }         
         
         for (i in SHUFFLE_MIN ... SHUFFLE_MAX)
         {
            var t:Int = testBag.next();
            Assert.isTrue(prev != t);
            Assert.isTrue(usedBits[t] == false);
            usedBits[t] = true;

            prev = t;
         }
      }
   }	
	
	@Test
	public function testStringBag():Void
	{
	   var strBag:ShuffleBag<String> = new ShuffleBag<String>();
      strBag.add("A");
      strBag.add("B");
      strBag.add("C");
      strBag.add("D");
      strBag.add("E");
      strBag.add("F");	
      
      var prev:String = "";
		for ( i in 0...10 )
		{
		   var t:String = strBag.next();
		   Assert.isTrue(t != prev);
		   prev = t;
		}
   }
	
}