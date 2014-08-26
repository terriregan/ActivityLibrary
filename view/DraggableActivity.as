package org.nflc.activities.view
{
	import flash.events.MouseEvent;
	
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	import mx.messaging.AbstractConsumer;
	
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.components.ZoneItem;
	import org.nflc.activities.events.DraggableEvent;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.DraggableChoiceVO;
	import org.nflc.util.XMLParseUtil;
	
	import spark.effects.Move;
	import spark.layouts.BasicLayout;
	
	import utils.array.getItemByKey;
	
	public class DraggableActivity extends Activity
	{
		public var stims:Array = [];
		public var zones:Array = [];
		public var matches:Array = [];
		public var itemsToReturn:Array = [];
		
		public function DraggableActivity()
		{
			super();
			addEventListener( DraggableEvent.DROP, dragDropHandler );
		}
		
		override public function populateStandardInstructions():void 
		{
			standardInstructions.text = configuration.instructions;
		}
		
		override protected function partAdded( partName:String,instance:Object ):void
		{
			super.partAdded( partName, instance ); 
			if( instance == itemBank )
			{
				instance.layout = new BasicLayout();  // overide default vertical layout
			}
		}
		
		protected function dragDropHandler( e:DraggableEvent ):void
		{
			var draggableItem:DraggableItem = e.draggable;
			var zone:ZoneItem;
			if( e.droppedOn is ZoneItem )	
			{
				zone = e.droppedOn;
				
				// return an item that currently occupies this zone
				if( zone.isOccupied )
				{
					var di:DraggableItem = getItemByKey( stims, "inZoneIndex", zone.index );
					if( di !== draggableItem )  // do not return the item if it is dropped in the same zone it is in currently
						returnToToStartPosition( di );
				}
			}
			else
			{
				var droppedOn:DraggableItem = e.droppedOn;
				zone = getItemByKey( zones, "index", droppedOn.inZoneIndex );
				if( draggableItem !== droppedOn ) // do not return the item if it is dropped on itself
					returnToToStartPosition( droppedOn );
			}
			
			// clear any zone that the item was previously in
			updateZoneProps( draggableItem );
			updateItemProps( draggableItem, zone );
			
			saveUserResponse( draggableItem );
		}
		
		protected function updateZoneProps( draggableItem:DraggableItem ):void
		{
			if( draggableItem.inZoneIndex != -1 )
			{
				var z:ZoneItem = getItemByKey( zones, "index", draggableItem.inZoneIndex );
				z.isOccupied = false;
			}
		}
		
		protected function updateItemProps( draggableItem:DraggableItem, zone:ZoneItem ):void
		{
			draggableItem.x = zone.x;
			draggableItem.y =  zone.y + (zone.height/2 - draggableItem.height/2);
			zone.isOccupied = true;
			draggableItem.inZoneIndex = draggableItem.vo.inZoneIndex = zone.index;
			draggableItem.enableDrop();
		}
				
		override protected function saveUserResponse( response:* ):void
		{
			//var zone:ZoneItem = getItemByKey( zones, "isOccupied", false );
			var draggbleItem:DraggableItem = getItemByKey( stims, "inZoneIndex", -1 );
			if( draggbleItem )
			{
				answerState = ActivityConstants.UNANSWERED;
				data.sessionData.isAnswered = false;
			}
			else
			{
				answerState = ActivityConstants.ANSWERED;
				data.sessionData.isAnswered = true;
			}
			recordCorrectStatus();
		}
		
		override protected function recordCorrectStatus():void 
		{
			if( data.sessionData.isAnswered )
			{	
				var isCorrect:Boolean = true;
				itemsToReturn = [];
				for each( var di:DraggableItem in stims )
				{
					if( di.inZoneIndex != di.correctZoneIndex )
					{
						isCorrect = false;
						itemsToReturn.push( di );
					}
				}
				data.sessionData.isResponseCorrect = isCorrect;
			}
			else
				data.sessionData.isResponseCorrect = false;
		}
		
		protected function returnToToStartPosition( item:DraggableItem ):void
		{
			item.inZoneIndex = item.vo.inZoneIndex = -1;
			item.disableDrop();
			
			var mover:Move = new Move();
			mover.duration = 200;
			mover.target = item;
			mover.xFrom = item.x;
			mover.xTo = 0;
			mover.yFrom = item.y;
			mover.yTo = item.startY;
			mover.play();
		}
		
		override protected function check( e:MouseEvent = null ):void 
		{
			recordCorrectStatus();
			data.sessionData.numberOfAttempts++;
			processFeedback();
		}
		
		// need to be able to handle unlimited number of attempts - put this in activity
		override protected function processFeedback():void
		{	
			if( data.sessionData.isResponseCorrect )
			{
				displayCompleteState();
				markAsComplete();
				displayFeedback( XMLParseUtil.getContentNode(data.content..feedback.(@type == "correct")[0]) ); 
			}
			else
			{
				if( data.sessionData.numberOfAttempts < configuration.numberAttemptsAllowed )
				{
					for each( var di:DraggableItem in itemsToReturn )
					{
						resetIncorrectAnswer( di );
					}
					displayFeedback( configuration.defaultFeedback );
				}
				else
				{
					displayCompleteState();
					markAsComplete();
					displayFeedback( XMLParseUtil.getContentNode(data.content..feedback.(@type == "incorrect2")[0]) ); 
				}
			}
		}
		
		private function resetIncorrectAnswer( di:DraggableItem ):void
		{
			var zone:ZoneItem = getItemByKey( zones, "index", di.inZoneIndex );
			zone.isOccupied = false;
			answerState = ActivityConstants.UNANSWERED;
			data.sessionData.isAnswered = false;
			
			returnToToStartPosition( di );
		}
		
		override protected function displayCompleteState():void
		{	
			for each( var item:DraggableItem in stims )
			{
				if( item.inZoneIndex == item.correctZoneIndex )
					item.correctState = ActivityConstants.CORRECT;
				else
					item.correctState = ActivityConstants.INCORRECT;
			}			
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
			var len:uint = stims.length;
			for( var i:uint=0; i < len; i++ )
			{
				if( stims[i] )
					IItem(stims[i]).dispose();
				if( zones[i] )
					IItem(zones[i]).dispose();
				stims[i] = null;
				zones[i] = null;
			}
			items = null;
			stims = null;
			zones = null;
			matches = null;
			itemsToReturn = null;
		}
	}
}