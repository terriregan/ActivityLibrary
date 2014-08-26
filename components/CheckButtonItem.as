package org.nflc.activities.components
{
	import spark.components.Button;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.ActivityConstants;
	
	public class CheckButtonItem extends Button
	{
		private var _itemState:String;
		
		public function get itemState():String
		{
			return _itemState;
		}
		
		public function set itemState( value:String ):void
		{
			_itemState = value;
			if( ConfigurationManager.getInstance().requireUserSelectionForFeedback )
				enabled = ( value == ActivityConstants.UNANSWERED ) ? false : true;
		}
		
		public function CheckButtonItem()
		{
			super();
			setStyle( "styleName", "button" );
			buttonMode = true;
		}

	}
}