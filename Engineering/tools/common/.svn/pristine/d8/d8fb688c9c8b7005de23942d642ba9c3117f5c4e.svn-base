package;

import flash.display.DisplayObject;
import flash.events.Event;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author ...
 */
class Main extends Sprite 
{
	var o:DisplayObject;
	var test01aCallCount = 0;
	private function test01a (e:Event):Void {
		++test01aCallCount;
		if ( test01aCallCount == 1 ) {
			o.dispatchEvent( new Event("Test01Event") );
		}
	}
	
	var test02aShouldNeverExecuteOk = true;
	private function test02aShouldNeverExecute (e:Event):Void {
		test02aShouldNeverExecuteOk = false;
	}
	var test02aCallCount = 0;
	var test02Sequence:String = "";
	private function test02a (e:Event):Void {
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
	public function new() 
	{
		super();

		o = new DisplayObject();
		
		// Test 01: Use of not-yet populated entry in __newEventMap.
		// The first `if (list == null) return false; return` in 
		// `__dispatchEvent` is problematic: if you dispatch FooEvent,
		// don't add or remove listeners, and dispatch it again within 
		// a listener (taking care not to infinitely recurse using a 
		// bool or somesuch), you'll get a null __newEventMap.
		// Then you won't dispatch any future events.
		//
		// #1101 fixes this at
		// https://github.com/ImaginationSydney/openfl/blob/issue1100_EventDispatcher_nested/openfl/events/EventDispatcher.hx#L203
		// by always populating __newEventMap on the way into 
		// __dispatchEvent, if needed.
		//
		// #1105 fixes this in getList():
		// https://github.com/Leander1P/openfl/blob/eventdispatcher-nested-fixes/openfl/events/EventDispatcher.hx#L26
		// by not returning newListeners (nee __newEventMap entry) if it doesn't exist yet in ReadCopy mode;
		// it's acceptable to return the original listeners (nee __eventMap entry) if we're only reading.
		o.addEventListener( "Test01Event", test01a );
		o.dispatchEvent( new Event( "Test01Event" ) );
		trace ( (test01aCallCount == 2 ? "ok" : "NOT OK") + ": Expected call count of 2 for test01a, got " + test01aCallCount );

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
		trace ( (test02Sequence == "a(abc)bc" ? "ok" : "NOT OK") + ": adds or removes should not mutate a list we're currently traversing; wanted a(abc)bc and got: " + test02Sequence );
	}
}
