package org.nflc.activities.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.nflc.activities.components.ISelectableItem;
	import org.nflc.activities.components.ImageItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.skins.ActivitySkin;
	import org.nflc.util.XMLParseUtil;
	import spark.layouts.BasicLayout;
	
	import utils.array.getItemByKey;
	
	public class ClickableActivity extends Activity
	{
		public function ClickableActivity()
		{
			super();
		}
		
		override protected function partAdded( partName:String,instance:Object ):void
		{
			super.partAdded( partName, instance ); 
			if( instance == itemBank )
			{
				instance.layout = new BasicLayout();  // overide default vertical layout
			}
		}
		
		override public function populateStandardInstructions():void 
		{
			standardInstructions.text = configuration.instructions;
		}
		
		override public function display():void
		{
			itemBank.width = 650;
		
			if( promptComponents.length )
			{
				promptComponent.y = 140;
				var len:uint = promptComponents.length;
				for( var i:uint = 0; i < len; i++ )
					promptComponent.addElement( promptComponents[i] );
				
			}
			
			for each( var item:ISelectableItem in items )
			{
				item.addEventListener( MouseEvent.CLICK, processChoiceChange, false, 0, true );
				itemBank.addElement( item );  
			}
			
			super.display();
			super.updateTabIndices( "add" );
		}
		
		
		// need to be able to handle unlimited number of attempts
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
				}
				else
				{
					displayFeedback( XMLParseUtil.getContentNode(data.content..feedback.(@type == "incorrect2")[0]) );  
					displayCompleteState();
					markAsComplete();
				}
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			for each( var item:ISelectableItem in items )
			{
				item.removeEventListener( MouseEvent.CLICK, processChoiceChange );
				item.dispose();
				item = null;
			}
			items = null;
		}
		
	}
}