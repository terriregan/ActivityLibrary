package org.nflc.activities.model
{
	[RemoteClass(alias="org.nflc.activities.model.DropDownChoiceVO")]
	public class DropDownChoiceVO extends ChoiceVO
	{
		public var correctIndex:int;				// index poisition of correct drop down choice
		public var selectedIndex:int = -1;			// index of user selection
		public var listItem:String					// index item of drop down choice
	}
}