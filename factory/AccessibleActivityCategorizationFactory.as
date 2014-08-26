package org.nflc.activities.factory
{
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.components.ImageItem;
	import org.nflc.activities.components.MediaItem;
	import org.nflc.activities.components.RichTextItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.DropDownChoiceVO;
	import org.nflc.activities.view.Activity;
	import org.nflc.activities.view.DropDownSelectActivity;
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.randomize;
	import utils.array.getItemByKey;
	
	public class AccessibleActivityCategorizationFactory extends AccessibleActivityFactory
	{
		public function AccessibleActivityCategorizationFactory()
		{
			super();
		}
		
		override public function populateItemBank( xml:XML ):void 
		{
			if( ConfigurationManager.getInstance().displaySavedUserData )
			{
				if( activity.data.sessionData.savedChoices.length )
				{
					parseSavedChoices( activity.data.sessionData.savedChoices );
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
		
		private function parseSavedChoices( choices:Array ):void
		{
			var item:IItem;
			var index:uint = 0;
			var choiceVO:DropDownChoiceVO;
			var items:Array = [];
			
			for each( var choice:ChoiceVO in choices )
			{
				choiceVO = getItemByKey( choices, "itemIndex", index );
				
				item = itemFactory.createItem( ActivityConstants.TEXT_ITEM, 
					{ text: choiceVO.itemContent.source,
						correctIndex: choiceVO.correctIndex,
						vo: choiceVO} );
				item.percentWidth = 70;
				items.push( item );
				index++;
			}   
			
			activity.items = [{stims: items, dropDown: activity.data.sessionData.savedMatches}];
		}
		
		private function parseChoiceXML(  xml:XML  ):void
		{
			var item:IItem;
			var choiceVO:DropDownChoiceVO;
			var choices:Array = [];
			var items:Array = [];
			var dropDownList:Array = [];
			var index:int = 0;
			
			var fixedItem:XML;
			var choice:XML;
			
			for each( choice in xml..choice )
			{
				choices.push( choice );
			}
			
			if( ConfigurationManager.getInstance().randomizeActivityChoices ) 
				choices = randomize( choices );
			
			for each( choice in choices )
			{
				fixedItem = choice.item[0] as XML;
				
				choiceVO = new DropDownChoiceVO();
				choiceVO.itemContent = {};
				choiceVO.itemIndex = index;
				choiceVO.correctIndex = fixedItem.@categoryId;
				
				item = fetchItem( fixedItem, choiceVO.correctIndex, choiceVO );
				item.percentWidth = 70;
				items.push( item );
							
				activity.data.sessionData.savedChoices.push( choiceVO );
				
				index++;
			}   
		
			for each( var category:XML in xml..category )
			{
				dropDownList.push( category );
			}
			
			activity.data.sessionData.savedMatches = dropDownList;
			activity.items = [{stims: items, dropDown: dropDownList}];
		} 
	}
}