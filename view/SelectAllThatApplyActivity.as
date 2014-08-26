package org.nflc.activities.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.nflc.activities.components.CheckBoxItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.skins.ActivitySkin;
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.getItemByKey;
	
	public class SelectAllThatApplyActivity extends SelectableActivity
	{
		public var itemsToReset:Array = [];
		
		public function SelectAllThatApplyActivity()
		{
			super();
			configuration = configManager.activities[ActivityConstants.SELECT_ALL_THAT_APPLY];	
		}
		
		override protected function processChoiceChange( e:MouseEvent = null ):void 
		{
			saveUserResponse( e );
			answerState = ( data.sessionData.isAnswered ) ? ActivityConstants.ANSWERED : 
															ActivityConstants.UNANSWERED;
		}
		
		override protected function saveUserResponse( response:* ):void
		{
			var e:MouseEvent = MouseEvent( response );
			var choice:ChoiceVO = getItemByKey( data.sessionData.savedChoices, "itemIndex", e.target.index );
			choice.isSelected = e.target.selected;
			
			data.sessionData.isAnswered = false;
			for each( var vo:ChoiceVO in data.sessionData.savedChoices )
			{
				if( vo.isSelected )
					data.sessionData.isAnswered = true;
			}
			recordCorrectStatus();
		}
		
		override protected function recordCorrectStatus():void 
		{
			itemsToReset = [];
			var isCorrect:Boolean = true;
			for each( var vo:ChoiceVO in data.sessionData.savedChoices )
			{
				if( vo.isSelected && !vo.isCorrect )
				{
					itemsToReset.push( vo );
					isCorrect = false;
				}
				else if( !vo.isSelected  && vo.isCorrect )
					isCorrect = false;
			}
			data.sessionData.isResponseCorrect = isCorrect;
		}
		
		override protected function check( e:MouseEvent = null ):void 
		{
			recordCorrectStatus();
			data.sessionData.numberOfAttempts++;
			processFeedback();
		}
		
		private function resetIncorrectSelections():void
		{
			for each( var vo:ChoiceVO in itemsToReset )
			{
				var item:CheckBoxItem = getItemByKey( items, "index", vo.itemIndex );
				item.selected = vo.isSelected = false;
			}
		}
		
		override protected function processFeedback():void
		{	
			if(  data.sessionData.isResponseCorrect )
			{
				displayFeedback( XMLParseUtil.getContentNode(data.content..feedback.(@type == "correct")[0]) );  
				displayCompleteState();
				markAsComplete();
			}
			else
			{
				if( data.sessionData.numberOfAttempts < configuration.numberAttemptsAllowed )
				{
					displayFeedback( configuration.defaultFeedback );
					resetIncorrectSelections();
				}
				else
				{
					displayFeedback( XMLParseUtil.getContentNode(data.content..feedback.(@type == "incorrect2")[0]) );  
					displayCompleteState();
					markAsComplete();
				}
			}
		}
		
		// cannot move this to parent class as we need reference to "CheckBoxItem" slected
		override protected function displayCompleteState():void
		{	
			for each( var item:CheckBoxItem in items )
			{
				if( item.selected )
				{
					item.correctState = ( item.isCorrect ) ? ActivityConstants.CORRECT : 
															 ActivityConstants.INCORRECT;	
				}
				else
				{
					item.correctState = ( item.isCorrect ) ? ActivityConstants.CORRECT : null;
				}
			}
		}
		
	}
}