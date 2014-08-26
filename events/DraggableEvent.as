package org.nflc.activities.events
{
	import flash.events.Event;
	
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.components.ZoneItem;
	
	public class DraggableEvent extends Event
	{
		public static const DROP:String = "drop";
		
		public var droppedOn:*;
		public var draggable:DraggableItem;
		public var isDroppedOnZone:Boolean;
		
		public function DraggableEvent(type:String, 
									   droppedOn:*, 
									   draggable:DraggableItem, 
									   isDroppedOnZone:Boolean = true,
									   bubbles:Boolean=true, 
									   cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.droppedOn = droppedOn;
			this.draggable = draggable;
			this.isDroppedOnZone = isDroppedOnZone;
		}
	}
}