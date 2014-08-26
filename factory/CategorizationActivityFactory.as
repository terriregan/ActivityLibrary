package org.nflc.activities.factory
{
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.components.DraggableItemCategory;
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.components.ZoneItemCategory;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.DraggableChoiceVO;
	import org.nflc.activities.view.Activity;
	import org.nflc.activities.view.CategorizationActivity;
	
	import utils.array.randomize;
	import utils.array.getItemByKey;
	
	
	public class CategorizationActivityFactory extends MatchingActivityFactory
	{
	  public function CategorizationActivityFactory()
		{
			super();
		}
		
	    // paramatized factory - matching,  categorizing
		override public function createActivity( type:String ):Activity
		{
			activityType = type; 
			switch( activityType )
			{
				case ActivityConstants.CATEGORIZING:
					return new CategorizationActivity();
					break;
			}
			return null;
		}
		
		override public function populateItemBank( xml:XML ):void 
		{
			if( ConfigurationManager.getInstance().displaySavedUserData )
			{
				if( activity.data.sessionData.savedChoices.length )
				{
					parseSavedChoices( activity.data.sessionData.savedChoices, xml );
				}
				else
				{
					parseChoiceXML( xml );
				}
			}
			else
			{
				parseChoiceXML( xml );
			}
		}
		
		
		private function parseSavedChoices( choices:Array, xml:XML  ):void
		{
			var item:DraggableItemCategory;
			var zoneItem:ZoneItemCategory;
			var draggableWrappedItem:IItem;
			var zoneWidth:Number;
			
			var index:int = 0;
			var choiceVO:DraggableChoiceVO;
			
			var items:Array = [];
			var zones:Array = [];
			
			var numCategories:int = xml..category.length();
			zoneWidth = ActivityConstants.ITEM_BANK_WIDTH/numCategories - ((numCategories-1) * ActivityConstants.GUTTER);			
			for each( var category:XML in xml..category )
			{
				zoneItem = new ZoneItemCategory();
				zoneItem.index = category.@id;
				zoneItem.header = category;
				zoneItem.accessibilityName = "Category " + category;
				zoneItem.width = zoneWidth;
				zones.push( zoneItem );
			}
			
			var vo:DraggableChoiceVO;
			for each( var choice:DraggableChoiceVO in choices )
			{
				vo = getItemByKey( activity.data.sessionData.savedChoices, "itemIndex", index );
				
				draggableWrappedItem = fetchSavedItem( vo );				
				draggableWrappedItem.width = zoneWidth - 14;
				
				// wrap item in draggable container
				if( draggableWrappedItem )
				{
					item = new DraggableItemCategory( draggableWrappedItem, activity );	
					item.vo = vo;
					item.correctZoneIndex = vo.correctZoneIndex;
					
					items.push( item );
				}
				else
				{
					// alert error
				}
				
				index++;
			}
			
			activity.items = [{stims: items, zones: zones}];
		}
		
		private function parseChoiceXML(  xml:XML ):void
		{
			var item:DraggableItemCategory;
			var zoneItem:ZoneItemCategory;
			var draggableWrappedItem:IItem;
			var zoneWidth:Number;
			
			var index:int = 0;
			var choiceVO:DraggableChoiceVO;
			
			var items:Array = [];
			var zones:Array = [];
			
			var numCategories:int = xml..category.length();
			zoneWidth = ActivityConstants.ITEM_BANK_WIDTH/numCategories - ((numCategories-1) * ActivityConstants.GUTTER);
			for each( var category:XML in xml..category )
			{
				zoneItem = new ZoneItemCategory();
				zoneItem.index = category.@id;
				zoneItem.header = category;
				zoneItem.accessibilityName = "Category " + category;
				zoneItem.width = zoneWidth;
				zones.push( zoneItem );
			}
			
			for each( var choice:XML in xml..choice )
			{
				choiceVO = new DraggableChoiceVO();
				choiceVO.itemContent = {};
				
				draggableWrappedItem = fetchItem( choice.item[0], choiceVO );
				draggableWrappedItem.width = zoneWidth - 14;
				
				// wrap item in draggable container
				if( draggableWrappedItem )
				{
					item = new DraggableItemCategory( draggableWrappedItem, activity );	
					item.correctZoneIndex = choiceVO.correctZoneIndex = choice.item[0].@categoryId;
					
					item.x = choiceVO.startX = Math.floor( Math.random()*(1 + ( ActivityConstants.ITEM_BANK_WIDTH - zoneWidth - 20)) );
					item.y = choiceVO.startY = Math.floor( Math.random()*16 )+ 245;
					item.rotation = choiceVO.startRotation = Math.floor( Math.random()*6 ) - 3;
					
					item.vo = choiceVO;
					items.push( item );
					
					activity.data.sessionData.savedChoices.push( choiceVO );
				
				}
				else
				{
					// alert error
				}
				
				index++;
			}
			
			items = randomize( items ); // need to get its position
			var di:DraggableItemCategory;
			for( var i:uint; i < items.length; i++ )
			{
				di = items[i] as DraggableItemCategory;
				di.index = di.vo.itemIndex = i;  // set display index
			}
			activity.items = [{stims: items, zones: zones}];
		}
		
	}
}