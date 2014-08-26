package org.nflc.activities.model
{
	[RemoteClass(alias="org.nflc.activities.model.ChoiceVO")]
	public class ChoiceVO
	{
		public var itemIndex:int;					// which display item is it associated with
		public var itemContent:Object;
		public var itemType:String;
		public var isSelected:Boolean;				// saved state
		public var isCorrect:Boolean;
	}
}