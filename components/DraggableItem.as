package org.nflc.activities.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Image;
	import mx.core.DragSource;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import org.nflc.activities.events.DraggableEvent;
	import org.nflc.activities.events.ToggleEvent;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.DraggableChoiceVO;
	import org.nflc.activities.view.Activity;
		
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import mx.managers.IFocusManagerComponent;
	
	public class DraggableItem extends SkinnableComponent implements IItem
	{
		[SkinPart(required="true")] 
		public var contentGroup:Group;
				
		[Bindable]
		public var correctState:String;
		
		public var vo:DraggableChoiceVO;
								
		private var _item:IItem;
		private var _startY:Number;
		private var _index:int;
		private var _correctZoneIndex:int;
		private var _stateWatcher:ChangeWatcher;
		private var _alt:String;		
		
		public var inZoneIndex:int = -1;
		
		public function get alt():String
		{
			return _alt;
		}
		
		public function set alt( value:String ):void
		{
			_alt = value;
		}
		
		[Bindable]
		public function get item():IItem
		{
			return _item;
		}
		
		public function set item( value:IItem ):void
		{
			_item = value;
		}

		public function get startY():Number
		{
			return _startY;
		}
		
		public function set startY( value:Number ):void
		{
			_startY = value;
		}
		
		public function get index():int
		{
			return _index;
		}

		public function set index( value:int ):void
		{
			_index = value;
		}
		
		public function get correctZoneIndex():int
		{
			return _correctZoneIndex;
		}
		
		public function set correctZoneIndex(value:int):void
		{
			_correctZoneIndex = value;
		}
	
		public function DraggableItem( item:IItem, activity:Activity ) 
		{
			this.mouseChildren = false;
			_item = item;
			_stateWatcher = BindingUtils.bindSetter( setEnabledState, activity, "completeState" );
			setStyle( "styleName", "draggableItem" );
		
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true );
			addEventListener( FocusEvent.FOCUS_IN, itemFocusInHandler, false, 0, true );
			addEventListener( FocusEvent.FOCUS_OUT, itemFocusOutHandler, false, 0, true );
		}
		
		
		override protected function partAdded( partName:String, instance:Object ):void 
		{ 
			super.partAdded( partName, instance ); 
			if( instance == contentGroup )
			{
				instance.addElement( _item );  
			}
		}
	
		protected function itemFocusInHandler( e:FocusEvent):void 
		{ 
			dispatchEvent( new ToggleEvent(ToggleEvent.ON, true) );
		}	
		
		protected function itemFocusOutHandler( e:FocusEvent):void 
		{ 
			dispatchEvent( new ToggleEvent(ToggleEvent.OFF, true) );
		}
		
				
		private function mouseDownHandler( e:MouseEvent):void 
		{                
			this.depth = 100;  // so item appear on top
			
			var dragInitiator:DraggableItem = DraggableItem( e.currentTarget );
			var ds:DragSource = new DragSource();
			ds.addData( dragInitiator, "item" ); 
			
			// create a copy of btn to drag
			var bd:BitmapData = new BitmapData( dragInitiator.width, dragInitiator.height );
			bd.draw( dragInitiator );
			var bm:Bitmap = new Bitmap( bd );
			bm.alpha = .8;
			
			// create the proxy or ghost which will follow the mouse when dragged
			var dragProxy:Image = new Image();
			dragProxy.addChild( bm );
			
			DragManager.doDrag( dragInitiator, ds, e, dragProxy );
			
			focusManager.setFocus( IFocusManagerComponent(item) );
			dispatchEvent( new ToggleEvent(ToggleEvent.OFF, true) );
			
		}
		
		private function dragEnterHandler( e:DragEvent ):void
		{
			DragManager.acceptDragDrop( UIComponent(e.currentTarget) );
		}
		
		
		private function dragDropHandler( e:DragEvent ):void
		{
			var dropppedOn:DraggableItem = DraggableItem(e.currentTarget);
			var draggable:DraggableItem = DraggableItem(e.dragInitiator);
			
			dispatchEvent( new DraggableEvent(DraggableEvent.DROP, dropppedOn, draggable, false) );
		}
		
		public function enableDrop():void
		{
			addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			addEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		}
		
		public function disableDrop():void
		{
			removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		}
		
		public function dispose():void
		{
			_item.dispose();
			_stateWatcher.unwatch();
			_stateWatcher = null;
			
			disableDrop();
			removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			removeEventListener( FocusEvent.FOCUS_IN, itemFocusInHandler );
			removeEventListener( FocusEvent.FOCUS_OUT, itemFocusOutHandler );
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