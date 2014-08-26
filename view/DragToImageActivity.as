package org.nflc.activities.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import org.nflc.activities.components.BorderContainerItem;
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.components.ImageItem;
	import org.nflc.activities.components.RadioButtonItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.components.ZoneItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.skins.ActivitySkin;
	import org.nflc.util.XMLParseUtil;
	
	import utils.array.getItemByKey;
	
	public class DragToImageActivity extends DraggableActivity
	{
		
		public static const XGAP:uint = 50;	
		public static const YGAP:uint = 5;	
		
		public function DragToImageActivity()
		{
			super();
			configuration = configManager.activities[ActivityConstants.DRAG_TO_IMAGE];
		}
		
		override public function display():void
		{
			var len:uint;
			var i:uint;
			
			stims = items[0].stims;
			zones = items[0].zones;
			
			tabbedItems = [];
			
			if( promptComponents.length )
			{
				len = promptComponents.length;
				for( i = 0; i < len; i++ )
				{
					if( promptComponents[i] is ImageItem )
					{
						ImageItem(promptComponents[i]).tabEnabled = false;
						ImageItem(promptComponents[i]).focusEnabled = false;
					}
					itemBank.addElement( promptComponents[i] );
				}
			}
			
			len = stims.length;
			for( i = 0; i < len; i++ )
			{
				itemBank.addElement(  stims[i] ); 
				itemBank.addElement( zones[i] ); 
				tabbedItems.push( DraggableItem(stims[i]).item );
			}
			
			callLater( layout );  // to give components time to size themselves
			
			super.updateTabIndices( "add" );
		}
		
		private function layout():void
		{
			var len:uint = stims.length;
			var item:DraggableItem;
			var zone:ZoneItem;
			var itemY:uint = 0;
			var h:Number = getMaxHeight(); 
			
			for( var i:uint; i < len; i++ )
			{
				item = stims[i] as DraggableItem;
				zone = zones[i] as ZoneItem;
				
				item.height = h;
				item.y = item.startY = itemY;
				
				zone.x = zone.xPos;
				zone.y = zone.yPos;
				zone.height = item.height;
				zone.showConnector = false;
				
				itemY = itemY + item.height + YGAP;
			}
			
			if( promptComponents.length )
				positionPromptComponents();
			
			restore();
		}
		
		private function positionPromptComponents():void
		{
			var stim:DraggableItem = stims[0] as DraggableItem;
			var len:uint = promptComponents.length;
			var comp:IItem;
			var y:Number = itemBank.y;
			for( var i:uint = 0; i < len; i++ )
			{
				comp = promptComponents[i] as IItem;
				comp.x = stim.x + stim.width + XGAP + comp.x;
				comp.y = y + comp.y;
				
				y = comp.height + YGAP;
			}
		}
		
		private function restore():void
		{
			var zone:ZoneItem;
			for each( var stim:DraggableItem in stims )
			{
				if( stim.vo.inZoneIndex != -1 )
				{
					
					zone = getItemByKey( zones, "index", stim.vo.inZoneIndex );
					stim.inZoneIndex = stim.vo.inZoneIndex;
					stim.depth = 100;
					stim.x = zone.x;
					stim.y = zone.y + (zone.height/2 - stim.height/2);
					stim.enableDrop();
					zone.isOccupied = true;
				}
			}
			
			super.display();  // in the event complete state needs to be shown, call this here
		}
		
		private function getMaxHeight():Number
		{
			var max:Number = stims[0].height;
			for each( var stim:DraggableItem in stims )
			{
				if( stim.height > max )
					max = stim.height;
			}
			return max;
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
			
			var zone:ZoneItem;
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
				bc.x = zone.x;
				bc.y = zone.y + zone.height + YGAP;
				
				/* use the code below when we have other item type
				var bd:BitmapData = new BitmapData( correctItem.width, correctItem.height );
				bd.draw( correctItem );
				var bm:Bitmap = new Bitmap( bd );
				bm.x = 0;
				bm.y = zone.y + (zone.height/2 - correctItem.height/2) 
				
				var uiComp:UIComponent = new UIComponent();
				uiComp.addChild( bm );
				itemBank.addElement( uiComp ); */
				
				itemBank.addElement( bc );
			}
		}
	}
}