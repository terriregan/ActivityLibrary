package org.nflc.activities.model
{
	import org.nflc.activities.model.SessionData;
	
	public class ActivityData
	{
		public var id:String;
		public var loId:String;							// LO activity is associated with
		public var interactionType:String;
		public var content:XML;
		public var sessionData:SessionData;
	}
}