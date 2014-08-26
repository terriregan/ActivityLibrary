package org.nflc.activities.model
{
	[RemoteClass(alias="org.nflc.activities.model.SessionData")]
	public class SessionData
	{
		public var activityId:String;						// activityData obj it is associated with
		public var savedChoices:Array = []; 				// array of ItemVOs as originally displayed
		public var savedMatches:Array = []; 
		public var numberOfAttempts:int = 0;				// number of user attempts made
		public var isResponseCorrect:Boolean = false;		// is user response correct?
		public var isAnswered:Boolean = false;				// has user made a selection
		public var isComplete:Boolean = false;				// has user exhausted all attempts and received feedback
		
		public function SessionData( activityId:String )
		{
			this.activityId = activityId;
		}
	}
}