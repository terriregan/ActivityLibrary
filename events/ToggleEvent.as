package org.nflc.activities.events
{
	import flash.events.Event;
	
	
	public class ToggleEvent extends Event
	{
		public static const ON:String = "on";
		public static const OFF:String = "off";
		
		public function ToggleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}