﻿package fl.accessibility
{
	import flash.events.Event;
	import flash.accessibility.Accessibility;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.SelectableList;
	import fl.core.UIComponent;

	/**
	 *  The SelectableListAccImpl class, also called the SelectableList Accessibility Implementation class,
	 */
	public class SelectableListAccImpl extends AccImpl
	{
		/**
		 *  @private
		 */
		private static var accessibilityHooked : Boolean;
		/**
		 *  @private
		 */
		private static const ROLE_SYSTEM_LISTITEM : uint = 0x22;
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_FOCUSED : uint = 0x00000004;
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_INVISIBLE : uint = 0x00008000;
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_OFFSCREEN : uint = 0x00010000;
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_SELECTABLE : uint = 0x00200000;
		/**
		 *  @private
		 */
		private static const STATE_SYSTEM_SELECTED : uint = 0x00000002;
		/**
		 *  @private
		 */
		private static const EVENT_OBJECT_FOCUS : uint = 0x8005;
		/**
		 *  @private
		 */
		private static const EVENT_OBJECT_SELECTION : uint = 0x8006;

		/**
		 *  @private
		 */
		protected function get eventsToHandle () : Array;

		/**
		 *  @private
		 */
		private static function hookAccessibility () : Boolean;
		/**
		 *  @private
		 */
		public static function createAccessibilityImplementation (component:UIComponent) : void;
		/**
		 *  Enables accessibility for a SelectableList component.
		 */
		public static function enableAccessibility () : void;
		/**
		 * @private
		 */
		public function SelectableListAccImpl (master:UIComponent);
		/**
		 *  @private
		 */
		public function get_accRole (childID:uint) : uint;
		/**
		 *  @private
		 */
		public function get_accValue (childID:uint) : String;
		/**
		 *  @private
		 */
		public function get_accState (childID:uint) : uint;
		/**
		 *  @private
		 */
		public function get_accDefaultAction (childID:uint) : String;
		/**
		 *  @private
		 */
		public function accDoDefaultAction (childID:uint) : void;
		/**
		 *  @private
		 */
		public function getChildIDArray () : Array;
		/**
		 *  @private
		 */
		public function accLocation (childID:uint) : *;
		/**
		 *  @private
		 */
		public function get_accSelection () : Array;
		/**
		 *  @private
		 */
		public function get_accFocus () : uint;
		/**
		 *  @private
		 */
		public function accSelect (selFlag:uint, childID:uint) : void;
		/**
		 *  @private
		 */
		protected function getName (childID:uint) : String;
		/**
		 *  @private
		 */
		protected function eventHandler (event:Event) : void;
	}
}