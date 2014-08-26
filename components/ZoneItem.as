package org.nflc.activities.components
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.controls.Image;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.states.State;
	
	import org.nflc.activities.components.DraggableItem;
	import org.nflc.activities.events.DraggableEvent;
	import org.nflc.activities.events.ToggleEvent;
	
	import org.nflc.managers.KeyCodes;
	import spark.components.SkinnableContainer;
	
	[SkinState("normal")]
	[SkinState("dragOver")]
	[SkinState("disabled")]
	public class ZoneItem extends SkinnableContainer implements IItem
	{
		protected var _index:int = -1;
		protected var _isOccupied:Boolean = false;
		protected var _style:String = "zoneItem";
		protected var _xPos:Number;
		protected var _yPos:Number = 30;
		protected var _tabKey:TabKey;
		private var _showConnector:Boolean = true;
		private var _alt:String;
		private var _draggable:DraggableItem;
				
		public function get alt():String
		{
			return _alt;
		}
		
		public function set alt( value:String ):void
		{
			_alt = value;
		}

		[Bindable]
		public function get showConnector():Boolean
		{
			return _showConnector;
		}

		public function set showConnector(value:Boolean):void
		{
			_showConnector = value;
		}

		[Bindable]
		public function get xPos():Number
		{
			return _xPos;
		}
		
		public function set xPos(value:Number):void
		{
			_xPos = value;
		}
		
		[Bindable]
		public function get yPos():Number
		{
			return _yPos;
		}
		
		public function set yPos(value:Number):void
		{
			_yPos = value;
		}


		public function get style():String
		{
			return _style;
		}

		public function set style( value:String ):void
		{
			_style = value;
			applyStyle();
		}


		public function get isOccupied():Boolean
		{
			return _isOccupied;
		}

		public function set isOccupied(value:Boolean):void
		{
			_isOccupied = value;
		}
		
		[Bindable]
		public function get index():int
		{
			return _index;
		}
		
		public function set index(value:int):void
		{
			_index = value;
			addTabKey();
		}
		
		// add key display on focus for ADA access 
		protected function addTabKey():void
		{
			_tabKey = new TabKey();
			_tabKey.index = _index;
			_tabKey.x = -30;
			_tabKey.visible = false;
			addElement( _tabKey );
		}
		
		private function handleKeyUpHandler( e:KeyboardEvent ):void
		{
			var zoneIndex:int = -1;
			switch( e.keyCode )
			{
				case KeyCodes.NUM_1:
					zoneIndex = 0;
					break;
				
				case KeyCodes.NUM_2:
					zoneIndex = 1;
					break;	
				
				case KeyCodes.NUM_3:
					zoneIndex = 2;
					break;
				
				case KeyCodes.NUM_4:
					zoneIndex = 3;
					break;
				
				case KeyCodes.NUM_5:
					zoneIndex = 4;
					break;
				
				case KeyCodes.NUM_6:
					zoneIndex = 5;
					break;
				
				case KeyCodes.NUM_7:
					zoneIndex = 6
					break;
				
				case KeyCodes.NUM_8:
					zoneIndex = 7;
					break;
				
				case KeyCodes.NUM_9:
					zoneIndex = 8;
					break;
			}
			
			if( zoneIndex == index )
			{
				dispatchEvent( new DraggableEvent(DraggableEvent.DROP, this, _draggable, false) );
				_draggable.depth = 300;
			}
		}
		
		private function toggleTab( e:ToggleEvent ):void
		{
			if( e.target is DraggableItem )
			{
				if( e.type == ToggleEvent.ON )
				{
					FlexGlobals.topLevelApplication.stage.addEventListener( KeyboardEvent.KEY_UP, handleKeyUpHandler );
					_tabKey.visible = true;
					_draggable = e.target as DraggableItem;
				}
				else
				{
					FlexGlobals.topLevelApplication.stage.removeEventListener( KeyboardEvent.KEY_UP, handleKeyUpHandler );
					_tabKey.visible = false;
					_draggable = null;
				}
			}
		}
		
		protected function dragEnterHandler( e:DragEvent ):void
		{
			DragManager.acceptDragDrop( UIComponent(e.currentTarget) );
			this.currentState = "dragOver";
			invalidateSkinState();
		}
		
		protected function dragExitHandler( e:DragEvent ):void
		{
			this.currentState = "normal";
			invalidateSkinState();
		}
		
		protected function dragDropHandler( e:DragEvent ):void
		{
			this.currentState = "normal";
			invalidateSkinState();
			
			var zone:ZoneItem = ZoneItem(e.currentTarget);
			var draggable:DraggableItem = DraggableItem(e.dragInitiator);
			
			dispatchEvent( new DraggableEvent(DraggableEvent.DROP, zone, draggable) );
		}
		
		public function ZoneItem( style:String = "zoneItem" )
		{
			super();
			this.style = style;
			setStates();
		
			addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			addEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
			addEventListener( DragEvent.DRAG_DROP, dragDropHandler );
			
			FlexGlobals.topLevelApplication.stage.addEventListener( ToggleEvent.OFF, toggleTab );
			FlexGlobals.topLevelApplication.stage.addEventListener( ToggleEvent.ON, toggleTab );
		}
		
		protected function setStates():void
		{
			var normalState:State = new State();
			normalState.name = "normal";
						
			var dragOverState:State = new State();
			dragOverState.name = "dragOver";
			
			states.push( normalState, dragOverState );
		}
		
		
		override protected function getCurrentSkinState():String 
		{
			return currentState;
		}
		
		public function applyStyle():void 
		{
			setStyle( "styleName", _style );
		}
				
		public function dispose():void 
		{
			removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
			removeEventListener( DragEvent.DRAG_EXIT, dragExitHandler );
			removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
			
			FlexGlobals.topLevelApplication.stage.removeEventListener( ToggleEvent.OFF, toggleTab );
			FlexGlobals.topLevelApplication.stage.removeEventListener( ToggleEvent.ON, toggleTab );
			FlexGlobals.topLevelApplication.stage.removeEventListener( KeyboardEvent.KEY_UP, handleKeyUpHandler );
		}
		
	}
}