package org.nflc.activities.factory
{
	import flash.events.MouseEvent;
	
	import org.nflc.activities.components.CheckBoxItem;
	import org.nflc.activities.components.HotSpotItem;
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.components.ISelectableItem;
	import org.nflc.activities.components.ImageItem;
	import org.nflc.activities.components.MediaItem;
	import org.nflc.activities.components.RadioButtonItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ActivityData;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.view.Activity;
	import org.nflc.activities.view.HotSpotActivity;
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.randomize;
	
	
	public class ClickableActivityFactory extends ActivityFactory
	{
	   public function ClickableActivityFactory()
		{
			super();
		}
		
		//  paramatized factory - hotspot
		override public function createActivity( type:String ):Activity
		{
			activityType = type; 
			switch( activityType )
			{
				case ActivityConstants.HOTSPOT:
					return new HotSpotActivity();
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
					parseSavedChoices( activity.data.sessionData.savedChoices );
				}
				else
				{
					parseChoiceXML( xml..choice );
				}
			}
			else
			{
				parseChoiceXML(  xml..choice );
			}
		}
		
		private function parseSavedChoices( choices:Array ):void
		{
			var item:ISelectableItem;
			var index:int = 0;
			for each( var choice:ChoiceVO in choices )
			{
				item = new HotSpotItem();
				item.width= choice.itemContent.width;
				item.height = choice.itemContent.height;
				item.x = choice.itemContent.x;
				item.y = choice.itemContent.y;
				HotSpotItem( item ).type = choice.itemContent.type;
				HotSpotItem( item ).selected = choice.isSelected;
				
				item.index = choice.itemIndex;
				item.isCorrect = choice.itemContent.isCorrect;
			
				activity.items.push( item );
			}
		}
		
		private function parseChoiceXML( xml:XMLList ):void
		{
			var item:ISelectableItem;
			var index:int = 0;
			var choiceVO:ChoiceVO;
			var items:Array = [];
			
			for each( var choice:XML in xml )
			{
				choiceVO = new ChoiceVO();
				choiceVO.isSelected = false;
				choiceVO.itemContent = {};
				choiceVO.itemContent.x = choice.@x;
				choiceVO.itemContent.y = choice.@y;
				choiceVO.itemContent.width = choice.@width;
				choiceVO.itemContent.height = choice.@height;
				choiceVO.itemContent.type = choice.@type;
				choiceVO.itemContent.isCorrect = ( choice.@isCorrect == "true" ) ? true : false;
				
				item = new HotSpotItem();
				item.width= choiceVO.itemContent.width;
				item.height = choiceVO.itemContent.height;
				item.x = choiceVO.itemContent.x;
				item.y = choiceVO.itemContent.y;
				HotSpotItem( item ).initializeGraphic( choiceVO.itemContent ); 
				
				choiceVO.itemIndex = item.index = index++;
				item.isCorrect = choiceVO.itemContent.isCorrect;
				
				activity.data.sessionData.savedChoices.push( choiceVO );
				activity.items.push( item );
				
			}
		}
		
		
	}
}