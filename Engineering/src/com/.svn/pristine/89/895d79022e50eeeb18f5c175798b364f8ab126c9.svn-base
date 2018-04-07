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

import openfl.events.Event;
import openfl.events.EventDispatcher;

class EventDispatcherTest
{
   var test01aCallCount = 0;
   var o:EventDispatcher = null;
   var test02aCallCount = 0;
   var test02Sequence:String = "";

   private function test01a (e:Event):Void {
      ++test01aCallCount;
      if ( test01aCallCount == 1 ) { // avoid infinite recursion, but we still should get a second call
         o.dispatchEvent( new Event("Test01Event") );
      }
   }
   
   @Test
   public function testDispatch1() 
   {
      test01aCallCount = 0;
      o = new EventDispatcher();

      o.addEventListener( "Test01Event", test01a );
      o.dispatchEvent( new Event( "Test01Event" ) );

      Assert.areEqual(2, test01aCallCount);
   }

   public function test02a (e:Event):Void {
      test02Sequence += "a";
      ++test02aCallCount;
      if ( test02aCallCount == 1 ) {
         test02Sequence += "(";
         o.dispatchEvent( new Event( "Test02Event" ) );
         test02Sequence += ")";

         // dispatching should still be true here, so this shouldn't modify the list we're traversing over
         // ...but it does...
         o.removeEventListener( "Test02Event", test02a );
         o.removeEventListener( "Test02Event", test02b );
         o.addEventListener( "Test02Event", test02a, false, 4 );
         o.addEventListener( "Test02Event", test02b, false, 5 );
      }
   }
   private function test02b (e:Event):Void {
      test02Sequence += "b";
   }
   private function test02c (e:Event):Void {
      test02Sequence += "c";
   }    
    
   @Test
   public function testDispatch2() 
   {
      test02aCallCount = 0;
      test02Sequence = "";
      
      o = new EventDispatcher();
      // Test 02: Dispatching goes false too soon.
      // The reset of dispatching at the tail of __dispatchEvent,
      // namely the __dispatching.set (event.type, false); line, 
      // is unconditional. Clearly we want to keep dispatching true 
      // if we're nested, so we should only unset that if we're the
      // "outermost" dispatcher.
      o.addEventListener( "Test02Event", test02a, false, 3 );
      o.addEventListener( "Test02Event", test02b, false, 2 );
      o.addEventListener( "Test02Event", test02c, false, 1 );
      o.dispatchEvent( new Event( "Test02Event" ) );
      
      Assert.areEqual("a(abc)bc", test02Sequence);
   }
   
}