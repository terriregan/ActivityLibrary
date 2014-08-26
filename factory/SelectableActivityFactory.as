package org.nflc.activities.factory
{
	import flash.events.MouseEvent;
	
	import org.nflc.activities.components.CheckBoxItem;
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
	import org.nflc.activities.view.BinaryChoiceActivity;
	import org.nflc.activities.view.MultipleChoiceActivity;
	import org.nflc.activities.view.SelectAllThatApplyActivity;
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.randomize;
	
	
	public class SelectableActivityFactory extends ActivityFactory
	{
	   public function SelectableActivityFactory()
		{
			super();
		}
		
		//  paramatized factory - binary, mulitple, select all that apply
		override public function createActivity( type:String ):Activity
		{
			activityType = type; 
		
			switch( activityType )
			{
				case ActivityConstants.BINARY_CHOICE:
					return new BinaryChoiceActivity();
					break;
				
				case ActivityConstants.MULTIPLE_CHOICE:
					return new MultipleChoiceActivity();
					break;
				
				case ActivityConstants.SELECT_ALL_THAT_APPLY:
					return new SelectAllThatApplyActivity();
					break;
			}
		
			return null;
		}
		
		override public function populateItemBank( xml:XML ):void 
		{
			if( ConfigurationManager.getInstance().displaySavedUserData )
			{
				if( activity.data.sessionData.savedChoices && activity.data.sessionData.savedChoices.length )
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
			var wrappedItem:IItem;
			var index:int = 0;
			for each( var choice:ChoiceVO in choices )
			{
				if( choice.itemType == ActivityConstants.IMAGE_ITEM )
				{
					wrappedItem = itemFactory.createItem( ActivityConstants.IMAGE_ITEM, 
						{source: choice.itemContent.source, alt: choice.itemContent.alt} );
				}
					
				else if( choice.itemType == ActivityConstants.MEDIA_ITEM )
				{
					wrappedItem = itemFactory.createItem( ActivityConstants.MEDIA_ITEM, 
						{source: choice.itemContent.source, 
						 mediaSource: choice.itemContent.mediaSource} );
				}
					
				else
				{
					wrappedItem = itemFactory.createItem( ActivityConstants.TEXT_ITEM, 
						{xml: choice.itemContent.source} );
				}
				// wrap item in radio button
				if( wrappedItem )
				{
					if( activityType == ActivityConstants.SELECT_ALL_THAT_APPLY )
					{
						item = new CheckBoxItem( wrappedItem, activity );
						CheckBoxItem(item).accessibilityName = wrappedItem.alt;
						CheckBoxItem( item ).selected = choice.isSelected;
						
					}
					else
					{
						item = new RadioButtonItem( wrappedItem, activity );
						RadioButtonItem(item).accessibilityName  = wrappedItem.alt;
						RadioButtonItem( item ).selected = choice.isSelected;
					}
					
					item.percentWidth = 100;
					item.isCorrect = choice.isCorrect;
					item.index = choice.itemIndex;
					activity.items.push( item );
				}
				else
				{
					// alert error
				}
			}
		}
		
		private function parseChoiceXML(  xml:XMLList ):void
		{
			var item:ISelectableItem;
			var wrappedItem:IItem;
			var index:int = 0;
			var choiceVO:ChoiceVO;
			var items:Array = [];
			
			for each( var choice:XML in xml )
			{
				items.push( choice );
			}
			
			if( ConfigurationManager.getInstance().randomizeActivityChoices && activityType != ActivityConstants.BINARY_CHOICE ) 
				items = randomize( items );
			
			for each( var xmlItem:XML in items )
			{
				choiceVO = new ChoiceVO();
				choiceVO.itemContent = {};
				
				if( xmlItem.@image.length() )
				{
					choiceVO.itemType = ActivityConstants.IMAGE_ITEM;
					choiceVO.itemContent.source = xmlItem.@image;
					choiceVO.itemContent.alt = xmlItem.@alt;
					wrappedItem = itemFactory.createItem( ActivityConstants.IMAGE_ITEM, 
														  {source: choiceVO.itemContent.source, alt: choiceVO.itemContent.alt} );
				}
					
				else if( xmlItem.@media.length() )
				{
					choiceVO.itemType = ActivityConstants.MEDIA_ITEM;
					choiceVO.itemContent.source = "get icon data from xml";
					choiceVO.itemContent.mediaSource = "get nmedia data from xml";
					wrappedItem = itemFactory.createItem( ActivityConstants.MEDIA_ITEM, 
														  {source: choiceVO.itemContent.source, 
														   mediaSource: choiceVO.itemContent.mediaSource} );
				}
					
				else
				{
					choiceVO.itemType = ActivityConstants.TEXT_ITEM;	
					choiceVO.itemContent.source = XMLParseUtil.getContentNode( xmlItem );
					wrappedItem = itemFactory.createItem( ActivityConstants.TEXT_ITEM, 
														  {xml: choiceVO.itemContent.source} );
				}
				
				// wrap item in radio button
				if( wrappedItem )
				{
					if( activityType == ActivityConstants.SELECT_ALL_THAT_APPLY )
					{
						item = new CheckBoxItem( wrappedItem, activity );
						CheckBoxItem(item).accessibilityName = wrappedItem.alt;
					}
					else
					{
						item = new RadioButtonItem( wrappedItem, activity );
						RadioButtonItem(item).accessibilityName = wrappedItem.alt;
					}
					
					item.percentWidth = 100;
					item.isCorrect = ( xmlItem.@isCorrect == "true" ) ? true : false;
					item.index = index++;
					
					choiceVO.isCorrect = item.isCorrect;
					choiceVO.itemIndex = item.index;
					choiceVO.isSelected = false;
					activity.data.sessionData.savedChoices.push( choiceVO );
					
					activity.items.push( item );
				}
				else
				{
					// alert error
				}
			}
		}
		
	}
}