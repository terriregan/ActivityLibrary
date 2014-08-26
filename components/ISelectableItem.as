package org.nflc.activities.components
{
	public interface ISelectableItem extends IItem
	{
		function get isCorrect():Boolean;
		function set isCorrect( value:Boolean ):void
	}
}