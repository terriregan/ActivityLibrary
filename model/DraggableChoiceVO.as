package org.nflc.activities.model
{
	[RemoteClass(alias="org.nflc.activities.model.DraggableChoiceVO")]
	public class DraggableChoiceVO extends ChoiceVO
	{
		public var inZoneIndex:int = -1;				// index of zone item is placed in
		public var correctZoneIndex:int;				// index of correct zone
		
		public var startY:Number;						// extend this class
		public var startX:Number;
		public var endY:Number;
		public var startRotation:Number;
		public var targetX:Number;
		public var targetY:Number;
	}
}