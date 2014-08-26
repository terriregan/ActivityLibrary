package org.nflc.activities.factory
{
	import flash.events.MouseEvent;
	
	import org.nflc.activities.components.BorderContainerItem;
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.components.ImageItem;
	import org.nflc.activities.components.MediaItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.components.ZoneItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ActivityData;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.DraggableChoiceVO;
	import org.nflc.activities.view.Activity;
	import org.nflc.activities.view.MatchingActivity;
	import org.nflc.activities.view.OrderingActivity;
	import org.nflc.activities.view.DragToImageActivity;
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.getItemByKey;
	import utils.array.randomize;
	
	public class OrderingActivityFactory extends MatchingActivityFactory
	{
	  public function OrderingActivityFactory()
		{
			super();
		}
		
	    // paramatized factory - ordering
		override public function createActivity( type:String ):Activity
		{
			activityType = type; 
			switch( activityType )
			{
				case ActivityConstants.ORDERING:
					return new OrderingActivity();
					break;
				
				case ActivityConstants.DRAG_TO_IMAGE:
					return new DragToImageActivity();
					break;
			}
			return null;
		}
		
		override public function populateItemBank( xml:XML ):void 
		{
			
			var layout:String = xml..choices[0].@layout;
			if( ConfigurationManager.getInstance().displaySavedUserData )
			{
				if( activity.data.sessionData.savedChoices.length )
				{
					parseSavedChoices( activity.data.sessionData.savedChoices, layout );
				}
				else
				{
					parseChoiceXML( xml..choice, layout );
				}
			}
			else
			{
				parseChoiceXML( xml..choice, layout );
			}
		}
		
		
		private function parseSavedChoices( choices:Array, layout:String  ):void
		{
			var item:DraggableItem;
			var zoneItem:ZoneItem;
			var draggableWrappedItem:IItem;
			
			var index:int = 0;
			var items:Array = [];
			var zones:Array = [];
			
			var vo:DraggableChoiceVO;
			for each( var choice:DraggableChoiceVO in choices )
			{
				vo = getItemByKey( activity.data.sessionData.savedChoices, "itemIndex", index );
			
				draggableWrappedItem = fetchSavedItem( vo );				
				draggableWrappedItem.width = fetchLayoutDimensions( layout );
				
				// wrap item in draggable container
				if( draggableWrappedItem )
				{
					item = new DraggableItem( draggableWrappedItem, activity );	
					
					zoneItem = new ZoneItem();
					//zoneItem.index = index; 
					zoneItem.index = ( activityType == ActivityConstants.ORDERING ) ? index : vo.correctZoneIndex; // changed this, verify did not break main ordering
					zoneItem.width = draggableWrappedItem.width + (ActivityConstants.DRAG_PADDING * 2); 
					if( vo.targetX )
						zoneItem.xPos = vo.targetX;
						
					if( vo.targetY )
						zoneItem.yPos = vo.targetY;
					
					item.vo = vo;
					item.correctZoneIndex = vo.correctZoneIndex;
						
					items.push( item );
					zones.push( zoneItem );
				}
				else
				{
					// alert error
				}
				
				index++;
			}
			
			activity.items = [{stims: items, zones: zones}];
		}
		
		private function parseChoiceXML( xml:XMLList, layout:String ):void
		{
			var item:DraggableItem;
			var zoneItem:ZoneItem;
			var draggableWrappedItem:IItem;
			
			var index:int = 0;
			var choiceVO:DraggableChoiceVO;
			var items:Array = [];
			var zones:Array = [];
						
			for each( var choice:XML in xml )
			{
				choiceVO = new DraggableChoiceVO();
				choiceVO.itemContent = {};
				
				draggableWrappedItem = fetchItem( choice[0].item[0], choiceVO );
				draggableWrappedItem.width = fetchLayoutDimensions( layout );
			
				// wrap item in draggable container
				if( draggableWrappedItem )
				{
					item = new DraggableItem( draggableWrappedItem, activity );	
					item.correctZoneIndex = index;
					
					zoneItem = new ZoneItem();
					zoneItem.index = index;
				
					zoneItem.width = draggableWrappedItem.width + (ActivityConstants.DRAG_PADDING * 2); 
					if( choice.@x.length() )
						zoneItem.xPos = choiceVO.targetX = choice.@x;
					
					if( choice.@y.length() )
						zoneItem.yPos = choiceVO.targetY = choice.@y;
													
					choiceVO.correctZoneIndex = zoneItem.index;
					item.vo = choiceVO;
										
					items.push( item );
					zones.push( zoneItem );
					
					activity.data.sessionData.savedChoices.push( choiceVO );
				}
				else
				{
					// alert error
				}
				
				index++;
			}
			
			items = randomize( items ); // need to get its position
			var di:DraggableItem;
			for( var i:uint; i < items.length; i++ )
			{
				di = items[i] as DraggableItem;
				di.index = di.vo.itemIndex = i;  // set display index
			}
			activity.items = [{stims: items, zones: zones}];
		}
		
		private function fetchLayoutDimensions( layout:String ):int
		{
			if( layout == ActivityConstants.SHORT )
				return 60; 
			
			else if( layout == ActivityConstants.SHORT_MID )
				return 110; 
			
			else if( layout == ActivityConstants.SHORT_LONG )
				return 160; 
			
			else if( layout == ActivityConstants.MEDIUM )
				return 230; 
			
			else
				return 325; 
		}
		
	}
}