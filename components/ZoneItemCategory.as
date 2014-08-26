package org.nflc.activities.components
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.states.State;
	
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.events.DraggableEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class ZoneItemCategory extends ZoneItem
	{
		private var _header:String;
		
		[Bindable]
		public function get header():String
		{
			return _header;
		}
		
		public function set header( value:String ):void
		{
			_header = value;
		}
		
		// add key display on focus for ADA access 
		override protected function addTabKey():void
		{
			super.addTabKey();
			_tabKey.x = 0;
			_tabKey.y = -30;
		}
		
		public function ZoneItemCategory( style:String = "zoneItemCategory" )
		{
			super();
			setStyle( "styleName", style );
			percentHeight = 100;
			minHeight = 230;
		}
		
	}
}