package org.nflc.activities.view
{
	import flash.events.MouseEvent;
	
	import org.nflc.activities.components.HotSpotItem;
	import org.nflc.activities.components.RadioButtonItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.skins.ActivitySkin;
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.getItemByKey;
	
	public class HotSpotActivity extends ClickableActivity
	{
	
		public function HotSpotActivity()
		{
			super();
			configuration = configManager.activities[ActivityConstants.HOTSPOT];
		}
		
		
		override protected function processChoiceChange( e:MouseEvent = null ):void 
		{
			saveUserResponse( e )
			answerState = ActivityConstants.ANSWERED;
		}
		
		override protected function saveUserResponse( response:* ):void
		{
			var hotSpotItem:HotSpotItem;
			var e:MouseEvent = MouseEvent( response );
			data.sessionData.isAnswered = true;
			for each( var choice:ChoiceVO in data.sessionData.savedChoices )
			{
				choice.isSelected = ( choice.itemIndex == e.target.index ) ? true : false;
				hotSpotItem = getItemByKey( items, "index", choice.itemIndex )
				if( choice.isSelected )
					hotSpotItem.selected = true;
				else
					hotSpotItem.selected = false;
			}
			recordCorrectStatus();
		}
		
		override protected function recordCorrectStatus():void 
		{
			var userChoice:HotSpotItem = getItemByKey( items, "selected", true );
			var correctChoice:HotSpotItem = getItemByKey( items, "isCorrect", true );
			
			data.sessionData.isResponseCorrect = ( userChoice == correctChoice ) ? true : false;
		}
		
		override protected function check( e:MouseEvent = null ):void 
		{
			recordCorrectStatus();
			data.sessionData.numberOfAttempts++;
			processFeedback();
		}

		override protected function displayCompleteState():void
		{	
			for each( var item:HotSpotItem in items )
			{
				if( item.selected )
				{
					item.correctState = ( item.isCorrect ) ? ActivityConstants.CORRECT : ActivityConstants.INCORRECT;	
				}
				else
				{
					item.correctState = ( item.isCorrect ) ? ActivityConstants.CORRECT : null;
				}
			}
		}
		
	}
}