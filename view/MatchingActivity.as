package org.nflc.activities.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import org.nflc.activities.components.BorderContainerItem;
	import org.nflc.activities.components.DraggableItem;
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
	
	public class MatchingActivity extends DraggableActivity
	{
		public static const XGAP:uint = 10;	
		public static const YGAP:uint = 5;	
		
		private var _imgCtr:int = 0;
		private var _imgTotal:int = 0;
		
		public function MatchingActivity()
		{
			super();
			configuration = configManager.activities[ActivityConstants.MATCHING];
		}
		
		override public function display():void
		{
			stims = items[0].stims;
			zones = items[0].zones;
			matches = items[0].matches;
			
			tabbedItems = [];
			
			_imgTotal = countNumberOfLoadingImages();
			itemBank.x = -10;				
			var len:uint = stims.length;
			for( var i:uint; i < len; i++ )
			{
				itemBank.addElement(  stims[i] ); 
				itemBank.addElement( zones[i] ); 
				tabbedItems.push( DraggableItem(stims[i]).item );
				
				if( DraggableItem(stims[i]).item is ImageItem )
					DraggableItem(stims[i]).item.addEventListener( Event.COMPLETE, onImageLoadingComplete );
				
				if( BorderContainerItem(matches[i]).item is ImageItem )
					BorderContainerItem(matches[i]).item.addEventListener( Event.COMPLETE, onImageLoadingComplete );
				
				itemBank.addElement( matches[i] ); 
			}
			
			// if not an image, then use callLater to give components time to size themselves
			// else, listen for 'onImageLoadingComplete' event and then layout as we need to the size
			// of the loading images for positioning purposes
			if( !(BorderContainerItem(matches[0]).item is ImageItem) )
				callLater( layout );  
			
			super.updateTabIndices( "add" );
		}
		
		private function countNumberOfLoadingImages():int
		{
			var num:int = 0;
			var len:uint = stims.length;
			for( var i:uint; i < len; i++ )
			{
				if( DraggableItem(stims[i]).item is ImageItem )
					num++;
				
				if( BorderContainerItem(matches[i]).item is ImageItem )
					num++
			}
			return num;
		}
		
		private function onImageLoadingComplete( e:Event ):void
		{
			_imgCtr++;
			if( _imgCtr == _imgTotal )
				layout();
		}
		
		private function layout():void
		{
			if( layoutStyle == ActivityConstants.COLUMN )
				layoutColumns();
			else
				layoutStandard();
			
			restore();
		}
		private function layoutStandard():void
		{
			if( stims && stims.length )
			{
				var len:uint = stims.length;
				var item:DraggableItem;
				var zone:ZoneItem;
				var match:BorderContainerItem;
				var itemY:uint = offset;
				var matchY:uint = 0;
				for( var i:uint; i < len; i++ )
				{
					item = stims[i] as DraggableItem;
					zone = zones[i] as ZoneItem;
					match = matches[i] as BorderContainerItem;	
					
					if( item && (item.item is ImageItem) )
					{
						item.height = ImageItem(item.item).contentHeight + 10;
					}
					
					if( match && (match.item is ImageItem) )
					{
						match.height = ImageItem(match.item).contentHeight;
						match.width = ImageItem(match.item).contentWidth;
						zone.height = item.height;
					}
					else
					{
						if( zone )
							zone.height =  match.height;
					}
					
					item.y = item.startY = itemY;				
					zone.x = item.width + XGAP + 25;
					zone.y = matchY;
					match.x = zone.x + zone.width + XGAP;
					match.y = matchY;
					
					if( match.item is ImageItem )
					{
						zone.y = match.y + (match.height - zone.height)/2;
					}
					
					itemY = itemY + item.height + YGAP;
					matchY = matchY + match.height + YGAP;
				}
				itemBank.y -= offset;
			}
		}
				
		private function layoutColumns():void
		{
			var len:uint = stims.length;
			var item:DraggableItem;
			var zone:ZoneItem;
			var match:BorderContainerItem;
			var itemY:uint = 0;
			var itemX:uint = 0;
			var matchY:uint = 0;
			var matchX:uint = 0;
			
			for( var i:uint; i < len; i++ )
			{
				item = stims[i] as DraggableItem;
				zone = zones[i] as ZoneItem;
				match = matches[i] as BorderContainerItem;				
				item.y = item.startY = itemY;
				
				if( i >= _imgCtr/2 &&  i <  _imgCtr/2 + 1)
				{
					itemX = 330;
					matchY = 0;
				}
				
				zone.x = itemX + item.width + XGAP;
				zone.y = matchY;
				match.x = zone.x + zone.width + XGAP;
				match.y = matchY;
				
				if( match.item is ImageItem )
				{
					match.height = ImageItem(match.item).contentHeight;
					match.width = ImageItem(match.item).contentWidth;
					zone.height = item.height;
					zone.y = match.y + (match.height - zone.height)/2;
				}
				else
				{
					zone.height = match.height;
				}
				
				itemY = itemY + item.height + YGAP;
				matchY = matchY + match.height + YGAP;
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
				
				if(ri.item is ImageItem)
				{
					//var imgItem:ImageItem = ImageItem(correctItem.item);
					var bd:BitmapData = new BitmapData( correctItem.width, correctItem.height, true, 0x333333 );
					bd.draw( correctItem );
					var bm:Bitmap = new Bitmap( bd );
			
					var uiComp:UIComponent = new UIComponent();
					uiComp.x = ( !zone.x )? 0 : zone.x - zone.width - XGAP;
					uiComp.y = zone.y + (zone.height/2 - correctItem.height/2);
					uiComp.addChild( bm );
					itemBank.addElement( uiComp );
				}
				else
				{
					bc = new BorderContainerItem( itemFactory.createItem(ActivityConstants.TEXT_ITEM, {text: correctItem.vo.itemContent.source }) );
					bc.enabled = false;
					bc.setStyle( "styleName", "draggableItem" );
					bc.width = correctItem.width;
					bc.height = correctItem.height;
					bc.x = ( !zone.x )? 0 : zone.x - zone.width - XGAP;
					bc.y = zone.y + (zone.height/2 - correctItem.height/2);
					itemBank.addElement( bc );
				}
					
				
			}
		}
		
	}
}