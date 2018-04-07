﻿package fl.transitions
{
	import flash.events.Event;

	/**
	 * The TweenEvent class represents events that are broadcast by the fl.transitions.Tween class.
	 */
	public class TweenEvent extends Event
	{
		/**
		 * Indicates that the motion has started playing. 
		 */
		public static const MOTION_START : String = 'motionStart';
		/**
		 * Indicates that the Tween has been stopped
		 */
		public static const MOTION_STOP : String = 'motionStop';
		/**
		 * Indicates that the Tween has reached the end and finished. 
		 */
		public static const MOTION_FINISH : String = 'motionFinish';
		/**
		 * Indicates that the Tween has changed and the screen has been updated.
		 */
		public static const MOTION_CHANGE : String = 'motionChange';
		/**
		 * Indicates that the Tween has resumed playing after being paused.
		 */
		public static const MOTION_RESUME : String = 'motionResume';
		/**
		 * Indicates that the Tween has restarted playing from the beginning in looping mode.
		 */
		public static const MOTION_LOOP : String = 'motionLoop';
		/**
		 * The time of the Tween when the event occurred.
		 */
		public var time : Number;
		/**
		 * The value of the property controlled by the Tween, when the event occurred.
		 */
		public var position : Number;

		/**
		 *  Constructor function for a TweenEvent object.
		 */
		public function TweenEvent (type:String, time:Number, position:Number, bubbles:Boolean = false, cancelable:Boolean = false);
		/**
		 *  @private
		 */
		public function clone () : Event;
	}
}