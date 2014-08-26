package org.nflc.activities.components
{
	import mx.core.IVisualElement;
		
	public interface IItem extends IVisualElement 
	{
		function get alt():String;
		function set alt( value:String ):void;
		
		function get index():int;
		function set index( value:int ):void
			
		
		function dispose():void
	}
	
}