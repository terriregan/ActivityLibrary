package org.nflc.activities.view
{
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import org.nflc.activities.components.AccessibleDropDownItemRenderer;
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.DropDownChoiceVO;
	import org.nflc.util.XMLParseUtil;
	
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	import utils.array.getItemByKey;
	import utils.array.removeDuplicates;
	
	public class DropDownSelectActivity extends Activity
	{
		public var stims:Array = [];
		public var dropDownListDP:ArrayCollection;
		
		public var itemsToReset:Array = [];
		public var ddLists:Array = [];
				
		public function DropDownSelectActivity()
		{
			super();
			configuration = configManager.activities[ActivityConstants.DROP_DOWN_SELECT];
		}
		
		override public function populateStandardInstructions():void 
		{
			standardInstructions.text = configuration.instructions;
		}
		
		override public function display():void
		{
			stims = items[0].stims;
			tabbedItems = [];
			
			var vo:DropDownChoiceVO
			var ddl:DropDownList;
			var hGroup:HGroup;
			var i:uint = 0;
			
			dropDownListDP = new ArrayCollection(); 
			populateDropDownDP();
			
			for each( var item:IItem in stims )
			{
				vo = getItemByKey( data.sessionData.savedChoices, "itemIndex", i );
				
				hGroup = new HGroup();
				hGroup.percentWidth = 100;
				hGroup.gap = 15;
				
				ddl = new DropDownList();
				ddl.addEventListener( DropDownEvent.CLOSE, onDropDownClose );
				ddl.addEventListener( FocusEvent.FOCUS_OUT, onDropDownFocusOut );
				
				if( data.interactionType != ActivityConstants.CATEGORIZING )
					ddl.addEventListener( IndexChangeEvent.CHANGE, onDropDownChange );
				//ddl.accessibilityName = "Wave Characterisitcs";
				// add label function
				// tool tip
				ddl.percentWidth = 40;
				ddl.selectedIndex = vo.selectedIndex;
				ddl.setStyle( "color", "#333333" );
				ddl.labelFunction = getDropDownLabel;
				ddl.id = "dd" + i;
				ddl.accessibilityName = "Select a choice for item " + (i+1) ;
				ddl.dataProvider = dropDownListDP;
				BindingUtils.bindProperty( ddl, "dataProvider", this, "dropDownListDP" );
				ddLists.push( ddl );
				
				hGroup.addElement( item );
				hGroup.addElement( ddl );
				itemBank.addElement( hGroup ); 
				
				tabbedItems.push( item );
				tabbedItems.push( ddl );
				
				i++;
			}
						
			super.display();
			super.updateTabIndices( "add" );
		}
		
		private function getDropDownLabel( value:Object ):String
		{
			return value.label;
		}
		
		private function refreshDDLists():void
		{
			var len:uint = ddLists.length;
			var ddl:DropDownList;
			for( var i:uint=0; i < len; i++ )
			{
				ddl = ddLists[i] as DropDownList;
				ddl.dataProvider = dropDownListDP;
			}
		}
		
		private function populateDropDownDP():void
		{
			var ddlArr:Array = items[0].dropDown;
			var vo:DropDownChoiceVO;
			var txt:String;
			for( var i:uint = 0; i <  ddlArr.length; i++ )
			{
				dropDownListDP.addItem({label: ddlArr[i]}); 
			}
			updateDropDownDP();
		}
		
		private function updateDropDownDP():void
		{
			var ddlArr:Array = items[0].dropDown;
			var vo:DropDownChoiceVO;
			var txt:String;
			var obj:Object;
			for( var i:uint = 0; i <  ddlArr.length; i++ )
			{
				obj = dropDownListDP.getItemAt(i);
				vo = getItemByKey( data.sessionData.savedChoices, "selectedIndex", i );			// is this index selected in another drop down?
				if( vo )
				{
					txt = ddlArr[i] + " (Item " + (vo.itemIndex+1) + " selection)";
					obj.label = txt;
				}
				else{
					obj.label = ddlArr[i];}
			}
		
		}

		override protected function check( e:MouseEvent = null ):void 
		{
			recordCorrectStatus();
			data.sessionData.numberOfAttempts++;
			processFeedback();
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
		
		private function resetIncorrectSelections():void
		{
			var ddl:DropDownList;
			for each( var vo:DropDownChoiceVO in itemsToReset )
			{
				vo.selectedIndex  = -1;
				ddl = getItemByKey( ddLists, "id", "dd" +  vo.itemIndex );
				ddl.selectedIndex = -1;
			}
			answerState = ActivityConstants.UNANSWERED;
		}
		
		protected function onDropDownChange( e:IndexChangeEvent ):void
		{
			var ddl:DropDownList;
			var len:uint = ddLists.length;
			var indexes:Array = [];
			var unique:Array;
			for( var i:uint=0; i < len; i++ )
			{
				ddl = ddLists[i] as DropDownList;
				if( ddl.selectedIndex != -1 )
					indexes.push(ddl.selectedIndex);
			}
			
			unique = removeDuplicates( indexes );
			answerState = ( unique.length == len ) ? ActivityConstants.ANSWERED : ActivityConstants.UNANSWERED;
		}
		
		protected function onDropDownClose( e:DropDownEvent ):void
		{
			updateSelection( DropDownList(e.target) );
		}
		
		protected function onDropDownFocusOut( e:FocusEvent ):void
		{
			updateSelection(  DropDownList(e.target) );
		}
		
		protected function updateSelection( ddl:DropDownList ):void
		{
			var itemIndex:uint = uint(ddl.id.charAt(2));
			var response:Object = { "itemIndex": itemIndex, "selectedIndex": ddl.selectedIndex }
			
			if( data.interactionType != ActivityConstants.CATEGORIZING )
				checkForDuplicateSelection( itemIndex, ddl.selectedIndex );
			
			saveUserResponse( response );
			answerState = ( data.sessionData.isAnswered ) ? ActivityConstants.ANSWERED : 
				ActivityConstants.UNANSWERED;
			
			updateDropDownDP();
		
		}
		
		private function checkForDuplicateSelection( itemIndex:uint, selectedIndex:uint ):void
		{
			var vo:DropDownChoiceVO;
			var ddl:DropDownList;
			var len:uint = ddLists.length;
			for( var i:uint=0; i < len; i++ )
			{
				if( i != itemIndex )
				{
					ddl = ddLists[i] as DropDownList;
					if( ddl.selectedIndex == selectedIndex )
					{
						vo = getItemByKey( data.sessionData.savedChoices, "selectedIndex", selectedIndex );
						ddl.selectedIndex = -1;
						if( vo )
							vo.selectedIndex = -1;
					}
				}
			}
		}
		
		override protected function saveUserResponse( response:* ):void
		{
			var choice:DropDownChoiceVO = getItemByKey( data.sessionData.savedChoices, "itemIndex", response.itemIndex );
			choice.selectedIndex = response.selectedIndex;
			
			var allAnswered:Boolean = true;
			for each( var vo:DropDownChoiceVO in data.sessionData.savedChoices )
			{
				if( vo.selectedIndex == -1 )
					allAnswered = false;
			}
			data.sessionData.isAnswered = allAnswered;
			recordCorrectStatus();
		}
		
		override protected function recordCorrectStatus():void 
		{
			itemsToReset = [];
			var isCorrect:Boolean = true;
			for each( var vo:DropDownChoiceVO in data.sessionData.savedChoices )
			{
				if( vo.selectedIndex != vo.correctIndex )
				{
					itemsToReset.push( vo );
					isCorrect = false;
				}
			}
			data.sessionData.isResponseCorrect = isCorrect;
		}
		
		override protected function displayCompleteState():void
		{	
			var vo:DropDownChoiceVO;
			var ddl:DropDownList;
			for each( vo in data.sessionData.savedChoices )
			{
				ddl = getItemByKey( ddLists, "id", "dd" +  vo.itemIndex );
				if( vo.selectedIndex == vo.correctIndex )
					trace("show correct");
				else
					trace("show incorrecrt");
				
				ddl.enabled = false;
			}
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			
			var len:uint = ddLists.length;
			var ddl:DropDownList;
			for( var i:uint=0; i < len; i++ )
			{
				ddl = ddLists[i] as DropDownList;
				ddl.removeEventListener( DropDownEvent.CLOSE, onDropDownClose );
				ddl.removeEventListener( FocusEvent.FOCUS_OUT, onDropDownFocusOut );
				if( data.interactionType != ActivityConstants.CATEGORIZING )
					ddl.removeEventListener( IndexChangeEvent.CHANGE, onDropDownChange );
			}
			ddLists = null;
			stims = null;
			dropDownListDP = null;
			itemsToReset = null;
		}
	
		
	}
}