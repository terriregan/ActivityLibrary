package org.nflc.activities.components
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.view.Activity;
	
	import spark.components.Group;
	import spark.components.CheckBox;
	
	public class CheckBoxItem extends CheckBox implements ISelectableItem
	{
		[SkinPart(required="true")] 
		public var contentGroup:Group;
		
		[Bindable]
		public var correctState:String;
								
		private var _item:IItem;
		private var _isCorrect:Boolean;
		private var _index:int;
		private var _stateWatcher:ChangeWatcher;
		private var _alt:String;
		
		public function get alt():String
		{
			return _alt;
		}
		
		public function set alt( value:String ):void
		{
			_alt = value;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function set index(value:int):void
		{
			_index = value;
		}
		
		public function get isCorrect():Boolean
		{
			return _isCorrect;
		}
		
		public function set isCorrect( value:Boolean ):void
		{
			_isCorrect = value;
		}
		
		public function CheckBoxItem( item:IItem, activity:Activity ) 
		{
			_item = item;
			_stateWatcher = BindingUtils.bindSetter( setEnabledState, activity, "completeState" );
			setStyle( "styleName", "checkBoxItem" );
		}
		
		override protected function partAdded( partName:String, instance:Object ):void 
		{ 
			super.partAdded( partName, instance ); 
			if( instance == contentGroup )
			{
				instance.addElement( _item );
			}
		}
		
		public function dispose():void
		{
			_item.dispose();
			_stateWatcher.unwatch();
			_stateWatcher = null;
		}
		
		// watch for activity complete state
		private function setEnabledState( value:String ):void
		{
			if( ConfigurationManager.getInstance().lockUserResponseAfterAnswerGiven )
			{
				if( value == ActivityConstants.COMPLETE )
				{
					this.enabled = false;  // TODO: test to see if we need to disable wrapped item 
				}
			}
		}
		
	}
}