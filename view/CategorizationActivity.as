package org.nflc.activities.view
{
	import flash.utils.Dictionary;
	import mx.core.UIComponent;
	
	import org.nflc.activities.components.BorderContainerItem;
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.components.DraggableItemCategory;
	import org.nflc.activities.components.FeedbackCategoryItem;
	import org.nflc.activities.components.ZoneItem;
	import org.nflc.activities.components.ZoneItemCategory;
	import org.nflc.activities.events.DraggableEvent;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.common.WindowManager;
	
	import spark.components.Group;
	import spark.effects.Move;
	
	import utils.array.getItemByKey;
	import utils.array.removeItem;
	
	public class CategorizationActivity extends DraggableActivity
	{
		public static const XGAP:uint = 20;	
		public static const YGAP:uint = 5;	
		
		private var categories:Array = [];
		
		public function CategorizationActivity()
		{
			super();
			configuration = configManager.activities[ActivityConstants.CATEGORIZING];
		}
		
		override public function display():void
		{
			var len:uint;	
			var i:uint;
			var stim:DraggableItem;
			var zone:ZoneItemCategory;
			var xPos:Number = 0;
			
			stims = items[0].stims;
			zones = items[0].zones;
			
			tabbedItems = [];
			
			var group:Group = new Group();
			
			len = zones.length;
			for( i = 0; i < len; i++ )
			{
				zone = zones[i]
				zone.x = xPos;
				group.addElement( zone );
			
				categories[zone.index] = new Array();
				xPos = xPos + zone.width + ActivityConstants.GUTTER;
			}
			
			itemBank.addElement( group );
			
			len = stims.length;
			for( i = 0; i < len; i++ )
			{
				itemBank.addElement( stims[i] );
				tabbedItems.push( DraggableItem(stims[i]).item );
			}
			
			restore();
			super.updateTabIndices( "add" );
		}
		
		private function restore():void
		{
			var zone:ZoneItemCategory;
			for each( var stim:DraggableItem in stims )
			{
				if( stim.vo.inZoneIndex != -1 )
				{
					zone = getItemByKey( zones, "index", stim.vo.inZoneIndex );
					stim.inZoneIndex = stim.vo.inZoneIndex;
					//stim.depth = 100;
					stim.depth = itemBank.numElements + 1;
					stim.x = zone.x + 2;
					stim.y = stim.vo.endY;
				
					stim.rotation = 0;
					stim.enableDrop();
					
					categories[zone.index].push( stim );
				}
				else
				{
					stim.x = stim.vo.startX;
					stim.y = stim.vo.startY;
					stim.rotation = stim.vo.startRotation;
				}
			}
			
			super.display();  // in the event complete state needs to be shown, call this here
		}
		
		override protected function returnToToStartPosition( item:DraggableItem ):void
		{
			updateZoneProps( item );
			item.inZoneIndex = item.vo.inZoneIndex = -1;
			item.rotation = item.vo.startRotation;
			item.disableDrop();
			
			var mover:Move = new Move();
			mover.duration = 200;
			mover.target = item;
			mover.xFrom = item.x;
			mover.xTo = item.vo.startX;
			mover.yFrom = item.y;
			mover.yTo = item.vo.startY;
			mover.play();
		}
		
		override protected function dragDropHandler( e:DraggableEvent ):void
		{
			// check to see if it is same zone
			var draggableItem:DraggableItem = e.draggable;
			var zone:ZoneItem;
			
			if( e.droppedOn is ZoneItem )
			{
				zone = e.droppedOn;
			}
			else
			{
				zone = getItemByKey( zones, "index", e.droppedOn.inZoneIndex );
			}
			
			// clear any zone that the item was previously in
			updateZoneProps( draggableItem );
			updateItemProps( draggableItem, zone );
			
			saveUserResponse( draggableItem );
		}
		
		override protected function updateZoneProps( draggableItem:DraggableItem ):void
		{
			if( draggableItem.inZoneIndex != -1 )
			{
				var zone:ZoneItem = getItemByKey( zones, "index", draggableItem.inZoneIndex );
				var items:Array = categories[draggableItem.inZoneIndex];
				var y:Number = draggableItem.y;
				var h:Number = 30;
				removeItem( items, draggableItem );
				for each( var di:DraggableItem in items )
				{
					h += di.height;
					if( di.y > y )
						di.y = di.vo.endY = di.y - draggableItem.height;
				}
				updateZoneHeight( zone, items );
			}
		}
		
		private function updateZoneHeight( zone:ZoneItem, draggables:Array ):void
		{
			var h:Number = 30;
			for each( var di:DraggableItem in draggables )
			{
				h += di.height;
			}
			zone.height = ( h < 230 ) ? 230 : h + 3;
		}
		
		
		override protected function updateItemProps( draggableItem:DraggableItem, zone:ZoneItem ):void
		{
			var items:Array = categories[zone.index];
			var y:Number = 30;
			for each( var di:DraggableItem in items )
			{
				y = y + di.height;
			}
			
			draggableItem.x = zone.x + 2;
			draggableItem.y = draggableItem.vo.endY = y;
			draggableItem.rotation = 0;
			draggableItem.inZoneIndex = draggableItem.vo.inZoneIndex = zone.index;
			draggableItem.enableDrop();
			items.push( draggableItem );
			
			updateZoneHeight( zone, items );
		}
		
		override protected function displayCompleteState():void
		{	
			super.displayCompleteState();
						
			var itemsToReturn:Array  = [];
			
			for each( var di:DraggableItem in stims )
			{
				if( di.inZoneIndex != di.correctZoneIndex )
					itemsToReturn.push( di );
			}
		
			var zone:ZoneItemCategory;
			var correctItem:DraggableItem;
			var bc:BorderContainerItem;
			for each( var ri:DraggableItem in itemsToReturn )
			{
				zone = getItemByKey( zones, "index", ri.inZoneIndex );
				correctItem = getItemByKey( stims, "correctZoneIndex", ri.inZoneIndex );
				
				bc = new BorderContainerItem( itemFactory.createItem(ActivityConstants.TEXT_ITEM, {text: correctItem.vo.itemContent.source }) );
				bc.enabled = false;
				bc.setStyle( "styleName", "draggableItem" );
				bc.width = correctItem.width;
				bc.height = correctItem.height;
				bc.x = 0;
				bc.y = zone.y + (zone.height/2 - correctItem.height/2) 
				
				/* use the code below when we have other item type
				var bd:BitmapData = new BitmapData( correctItem.width, correctItem.height );
				bd.draw( correctItem );
				var bm:Bitmap = new Bitmap( bd );
				bm.x = 0;
				bm.y = zone.y + (zone.height/2 - correctItem.height/2) 
				
				var uiComp:UIComponent = new UIComponent();
				uiComp.addChild( bm );
				itemBank.addElement( uiComp ); */
					
				//itemBank.addElement( bc );
			}
		}
		
		// commenting out as SANet cycle 2 has text feedback - need to incorporate both at some point
		/*override protected function displayFeedback( content:* ):void
		{
			if( completeState == ActivityConstants.COMPLETE )
			{
				var feedbackCategoryItem:FeedbackCategoryItem = new FeedbackCategoryItem();
				feedbackCategoryItem.display( data.content );
				WindowManager.getInstance().createPopUp( UIComponent(feedbackCategoryItem), 
					ActivityConstants.FEEDBACK_WIN, 400, 0 );  
			}
			else
				super.displayFeedback( content );
		}*/
		
	}
}