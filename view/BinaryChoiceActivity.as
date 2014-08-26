package org.nflc.activities.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.nflc.activities.components.RadioButtonItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.skins.ActivitySkin;
	import org.nflc.util.XMLParseUtil;
	
	import spark.components.RadioButtonGroup;
	
	import utils.array.getItemByKey;
	
	public class BinaryChoiceActivity extends SelectableActivity
	{
	
		public function BinaryChoiceActivity()
		{
			super();
			configuration = configManager.activities[ActivityConstants.BINARY_CHOICE];
		}
		
		override public function display():void
		{
			rbg = new RadioButtonGroup();
			rbg.addEventListener( Event.CHANGE, processSelectionChange );
			
			for each( var item:RadioButtonItem in items )
				item.group = rbg;
			
			super.display();
		}

		/* need to add additonal event to account for tabbing between radio buttons.
		 * The selection change due to tab and arrow keys did not dispatch a sam e event as an click
		 */
		protected function processSelectionChange( e:Event ):void
		{
			_saveUserResponse( RadioButtonItem(rbg.selection).index );
		}
		
		override protected function processChoiceChange( e:MouseEvent = null ):void 
		{
			saveUserResponse( e );
		}
		
		override protected function saveUserResponse( response:* ):void
		{
			var e:MouseEvent = MouseEvent( response );
			_saveUserResponse( e.target.index );
		}
		
		protected function _saveUserResponse( index:uint ):void
		{
			answerState = ActivityConstants.ANSWERED;
			
			data.sessionData.isAnswered = true;
			for each( var choice:ChoiceVO in data.sessionData.savedChoices )
			{
				choice.isSelected = ( choice.itemIndex == index ) ? true : false;
			}
			recordCorrectStatus();
		}
		
		override protected function recordCorrectStatus():void 
		{
			var userChoice:RadioButtonItem = getItemByKey( items, "selected", true );
			var correctChoice:RadioButtonItem = getItemByKey( items, "isCorrect", true );
			
			data.sessionData.isResponseCorrect = ( userChoice == correctChoice ) ? true : false;
		}
		
		override protected function check( e:MouseEvent = null ):void 
		{
			recordCorrectStatus();
			data.sessionData.numberOfAttempts++;
			processFeedback();
		}
		
		// only one attempt allowed
		override protected function processFeedback():void
		{	
			if( data.sessionData.isResponseCorrect )
			{
				displayFeedback( XMLParseUtil.getContentNode(data.content..feedback.(@type == "correct")[0]) );  
			}
			else
			{
				displayFeedback( XMLParseUtil.getContentNode(data.content..feedback.(@type == "incorrect2")[0]) ); 
			}
			
			displayCompleteState();
			markAsComplete();
		}
 
		// cannot move this to parent class as we need reference to "RadioButtonItem" slected
		override protected function displayCompleteState():void
		{	
			for each( var item:RadioButtonItem in items )
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
		
		override public function dispose():void
		{
			rbg.removeEventListener( Event.CHANGE, processSelectionChange );
			super.dispose();
		}
		
	}
}