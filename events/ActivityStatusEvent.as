package org.nflc.activities.events
{
	import flash.events.Event;
	
	public class ActivityStatusEvent extends Event
	{
		public static const ANSWER_STATE_CHANGE:String = "answerStateChange";
		public static const COMPLETE:String = "activityComplete";
		
		public var status:String;
		
		public function ActivityStatusEvent( type:String, 
										     status:String = null, 
										     bubbles:Boolean = true, 
										     cancelable:Boolean = true )
		{
			super( type, bubbles, cancelable );
			this.status = status;
		}
		
		override public function clone():Event
		{
			return new ActivityStatusEvent( type, status, bubbles, cancelable );
		}
	}
}