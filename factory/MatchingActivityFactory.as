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
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.getItemByKey;
	import utils.array.randomize;
	
	
	public class MatchingActivityFactory extends ActivityFactory
	{
	  public function MatchingActivityFactory()
		{
			super();
		}
		
	    // paramatized factory - matching,  categorizing
		override public function createActivity( type:String ):Activity
		{
			activityType = type; 
			switch( activityType )
			{
				case ActivityConstants.MATCHING:
					return new MatchingActivity();
					break;
			}
			return null;
		}
		
		override public function populateItemBank( xml:XML ):void 
		{
			var layout:String = xml..choices[0].@layout;
			var offset:uint = (xml..choices[0].@offset.length() ) ? xml..choices[0].@offset : 0;
			if( ConfigurationManager.getInstance().displaySavedUserData )
			{
				if( activity.data.sessionData.savedChoices.length )
				{
					parseSavedChoices( activity.data.sessionData.savedMatches, layout );
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
			activity.layoutStyle = layout;
			activity.offset = offset;
		}
		
		
		private function parseSavedChoices( matches:Array, layout:String  ):void
		{
			var item:DraggableItem;
			var zoneItem:ZoneItem;
			var draggableWrappedItem:IItem;
			var staticWrappedItem:IItem;
			
			var index:int = 0;
			var items:Array = [];
			var zones:Array = [];
			var matchItems:Array = [];
			var bc:BorderContainerItem;
			
			var dim:Object = fetchLayoutDimensions( layout ); // need to handle dimensions for other item types
			
			var vo:DraggableChoiceVO;
			for each( var match:DraggableChoiceVO in matches )
			{
				vo = getItemByKey( activity.data.sessionData.savedChoices, "itemIndex", index );
			
				draggableWrappedItem = fetchSavedItem( vo );
				staticWrappedItem = fetchSavedItem( match );
				
				draggableWrappedItem.width = dim.drag;
				staticWrappedItem.width = dim.static;
				
				// wrap item in draggable container
				if( draggableWrappedItem )
				{
					item = new DraggableItem( draggableWrappedItem, activity );	
					item.correctZoneIndex = index;
					
					zoneItem = new ZoneItem();
					zoneItem.index = index;
					zoneItem.width = dim.drag + (ActivityConstants.DRAG_PADDING * 2); 
					
					item.vo = vo;
					item.correctZoneIndex = vo.correctZoneIndex;
						
					items.push( item );
					bc = new BorderContainerItem(staticWrappedItem);
					bc.tabChildren = false;
					matchItems.push( bc );
					zones.push( zoneItem );
				}
				else
				{
					// alert error
				}
				
				index++;
			}
			
			activity.items = [{stims: items, zones: zones, matches:matchItems}];
		}
		
		private function parseChoiceXML(  xml:XMLList, layout:String ):void
		{
			var item:DraggableItem;
			var zoneItem:ZoneItem;
			var draggableWrappedItem:IItem;
			var staticWrappedItem:IItem;
			
			var index:int = 0;
			var choiceVO:DraggableChoiceVO;
			var matchVO:DraggableChoiceVO; 
			var items:Array = [];
			var zones:Array = [];
			var matches:Array = [];
			var bc:BorderContainerItem;
			
			var dim:Object = fetchLayoutDimensions( layout ); // need to handle dimensions for other item types
			
			for each( var choice:XML in xml )
			{
				matchVO = new DraggableChoiceVO();
				matchVO.itemContent = {};
				
				choiceVO = new DraggableChoiceVO();
				choiceVO.itemContent = {};
				
				draggableWrappedItem = fetchItem( choice.item[0], choiceVO );
				staticWrappedItem = fetchItem( choice.match[0], matchVO );
								
				draggableWrappedItem.width = dim.drag;
				staticWrappedItem.width = dim.static;
				
				// wrap item in draggable container
				if( draggableWrappedItem )
				{
					item = new DraggableItem( draggableWrappedItem, activity );	
					item.correctZoneIndex = index;
					
					zoneItem = new ZoneItem();
					zoneItem.index = index;
					zoneItem.width = dim.drag + (ActivityConstants.DRAG_PADDING * 2); 
									
					choiceVO.correctZoneIndex = zoneItem.index;
					item.vo = choiceVO;
					
					matchVO.itemIndex = index;
					
					items.push( item );
					bc =  new BorderContainerItem(staticWrappedItem);
					bc.tabChildren = false;
					matches.push( bc );  // do not put in border container if image
					zones.push( zoneItem );
					
					activity.data.sessionData.savedChoices.push( choiceVO );
					activity.data.sessionData.savedMatches.push( matchVO );
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
			
			activity.items = [{stims: items, zones: zones, matches:matches}];
		}
		
		
		protected function fetchItem( xml:XML, vo:DraggableChoiceVO ):IItem
		{
			var wrappedItem:IItem;
			
			if( xml.@image.length() )
			{
				vo.itemType = ActivityConstants.IMAGE_ITEM;
				vo.itemContent.source = xml.@image;
				vo.itemContent.alt = XMLParseUtil.getContentNode( xml );
				wrappedItem = itemFactory.createItem( ActivityConstants.IMAGE_ITEM, 
					{source: vo.itemContent.source, alt: vo.itemContent.alt} );				
			}
				
			else if( xml.@media.length() )
			{
				vo.itemType = ActivityConstants.MEDIA_ITEM;
				vo.itemContent.source = "get icon data from xml";
				vo.itemContent.mediaSource = "get nmedia data from xml";
				wrappedItem = itemFactory.createItem( ActivityConstants.MEDIA_ITEM, 
													 {source: vo.itemContent.source, 
													  mediaSource: vo.itemContent.mediaSource} );
			}
				
			else
			{
				vo.itemType = ActivityConstants.TEXT_ITEM;	
				vo.itemContent.source = XMLParseUtil.getContentNode( xml );
				wrappedItem = itemFactory.createItem( ActivityConstants.TEXT_ITEM,  
					{xml: vo.itemContent.source} );
			}
			
			return wrappedItem;
		}
		
		protected function fetchSavedItem( vo:DraggableChoiceVO ):IItem
		{
			var wrappedItem:IItem;
			
			if( vo.itemType == ActivityConstants.IMAGE_ITEM )
			{
				wrappedItem = itemFactory.createItem( ActivityConstants.IMAGE_ITEM, 
					{source: vo.itemContent.source, alt: vo.itemContent.alt} );
			}
				
			else if( vo.itemType == ActivityConstants.MEDIA_ITEM )
			{
				wrappedItem = itemFactory.createItem( ActivityConstants.MEDIA_ITEM, 
					{source: vo.itemContent.source, 
						mediaSource: vo.itemContent.mediaSource} );
			}
				
			else
			{
				wrappedItem = itemFactory.createItem( ActivityConstants.TEXT_ITEM, 
					{xml: vo.itemContent.source} );
			}
			
			return wrappedItem;
		}
		
		
		private function fetchLayoutDimensions( layout:String ):Object
		{
			if( layout == ActivityConstants.RIGHT_DOMINANT )
				return {drag: 120, static: 400}; 
			
			else if( layout == ActivityConstants.RIGHT_DOMINANT_MID )
				return {drag: 170, static: 290}; 
			
			else if( layout == ActivityConstants.RIGHT_DOMINANT_SHORT )
				return {drag: 210, static: 200}; 
				
			else if( layout == ActivityConstants.LEFT_DOMINANT )
				return {drag: 400, static: 120}; 
			
			else if( layout == ActivityConstants.LEFT_DOMINANT_MID )
				return {drag: 290, static: 170}; 
			
			else if( layout == ActivityConstants.COLUMN )
				return {drag: 80, static: 175}; 
				
			else
				return {drag: 200, static: 200}; 
		}
		
	}
}