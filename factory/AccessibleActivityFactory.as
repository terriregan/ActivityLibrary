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
	
	public class AccessibleActivityFactory extends ActivityFactory
	{
		public function AccessibleActivityFactory()
		{
			super();
		}
		
		override public function createActivity( type:String ):Activity
		{
			activityType = type; 
			return new DropDownSelectActivity();
		}
		   
				   
	   override public function populateItemBank( xml:XML ):void 
		{
			var layout:String = xml..choices[0].@layout;
			var fixed:String = ( xml..choices[0].@fixed == "match" ) ? "match" : "item";
			if( ConfigurationManager.getInstance().displaySavedUserData )
			{
				if( activity.data.sessionData.savedChoices.length )
				{
					parseSavedChoices( activity.data.sessionData.savedChoices, layout );
				}
				else
				{
					parseChoiceXML( xml..choice, layout, fixed );
				}
			}
			else
			{
				parseChoiceXML( xml..choice, layout, fixed );
			}
		}
		
		private function parseSavedChoices( choices:Array, layout:String  ):void
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
				item.percentWidth = 60;
				items.push( item );
				index++;
			}   
					
			activity.items = [{stims: items, dropDown: activity.data.sessionData.savedMatches}];
		}
		
		private function parseChoiceXML(  xml:XMLList, layout:String, fixed:String  ):void
		{
			var item:IItem;
			var index:uint = 0;
			var choiceVO:DropDownChoiceVO;
			var items:Array = [];
			var dropDownList:Array = [];
			
			var fixedItem:XML;
			var matchItem:XML;
			
			for each( var choice:XML in xml )
			{
				if( fixed != "item" )
				{
					fixedItem = choice.match[0] as XML;
					matchItem = choice.item[0] as XML;
				}
				else
				{
					fixedItem = choice.item[0] as XML;
					matchItem = choice.match[0] as XML;
				}
				
				choiceVO = new DropDownChoiceVO();
				choiceVO.itemContent = {};
				choiceVO.correctIndex = index;
				
				item = fetchItem( fixedItem, index, choiceVO );
			
				dropDownList.push( XMLParseUtil.getContentNode( matchItem ) );
				item.percentWidth = 70;
				items.push( item );
				
				activity.data.sessionData.savedChoices.push( choiceVO );
				
				index++;
			}   
			
			activity.data.sessionData.savedMatches = dropDownList;
			
			if( ConfigurationManager.getInstance().randomizeActivityChoices ) 
				items = randomize( items );
			
			
			var vo:ChoiceVO;
			for( var i:uint; i < items.length; i++ )
			{
				item = items[i] as IItem;
				item.index = i;
				if( item is ImageItem )
					ImageItem(item).vo.itemIndex = i; 
				
				else if( item is MediaItem )
					MediaItem(item).vo.itemIndex = i; 
				
				else if( item is RichTextItem )
					RichTextItem(item).vo.itemIndex = i; 
				
				else if( item is TextItem )
					TextItem(item).vo.itemIndex = i; 
			}
			activity.items = [{stims: items, dropDown: dropDownList}];
		} 
		
		protected function fetchItem( xml:XML, index:int, choiceVO:DropDownChoiceVO ):IItem
		{
			var item:IItem;
			var isXML:Boolean = true;
			
			if( xml.@image.length() )
				choiceVO.itemContent.source =  XMLParseUtil.getContentNode( xml );
			
			else if( xml.@media.length() )
			{
				choiceVO.itemContent.source = "get icon data from xml"
				isXML = false;
			}
				
			else
				choiceVO.itemContent.source = XMLParseUtil.getContentNode( xml );
				
			if( isXML )
				item = itemFactory.createItem( ActivityConstants.TEXT_ITEM, 
												{ xml: choiceVO.itemContent.source,
												  correctIndex: index,
												  vo: choiceVO} );
			
			else
				item = itemFactory.createItem( ActivityConstants.TEXT_ITEM, 
												{ text: choiceVO.itemContent.source,
												  correctIndex: index,
												  vo: choiceVO} );
			
			return item;
		}
		
		
		/*private function fetchLayoutDimensions( layout:String ):int
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
				return 340; 
		}*/
		
	}
}