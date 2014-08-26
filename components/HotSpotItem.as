package org.nflc.activities.components
{
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import org.nflc.activities.model.ActivityConstants;
	
	import spark.core.SpriteVisualElement;
	
	public class HotSpotItem extends SpriteVisualElement implements ISelectableItem
	{
		private var _isCorrect:Boolean;
		private var _isSelected:Boolean = false;
		private var _type:String;
		private var _index:int;
		
		public var bgColor:Number = 0xffffff;
		public var bgAlpha:Number = .3;
		public var borderColor:Number = 0xf3d161;
		public var borderSize:uint = 2;
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
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type( value:String ):void
		{
			_type = value;
		}
		
		public function get selected():Boolean
		{
			return _isSelected;
		}
		
		public function set selected( value:Boolean ):void
		{
			_isSelected = value;
			if( _isSelected )
			{
				enabled = false;
				setSelectedState();
			}
			else
			{
				enabled = true;
				setUnselectedState();
			}
		}
		
		public function set correctState( value:String ):void
		{
			var indicator:IndicatorItem = new IndicatorItem();
			indicator.currentState = value;
			var uiComp:UIComponent = new UIComponent();
			uiComp.x = this.width/2 - 8;
			uiComp.y = -15;
			uiComp.addChild( indicator );
			this.addChild( uiComp );
			
			if( value == ActivityConstants.CORRECT )
			{
				borderColor = 0x00ff00;
				setSelectedState();
			}
			else if ( selected )
				setSelectedState();
			
			enabled = false;
		}
		
		public function set enabled( value:Boolean ):void
		{
			if( value )
			{
				this.addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
				this.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut);
				this.buttonMode = true;
				this.mouseEnabled = true;
			}
			else
			{
				this.removeEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
				this.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
				this.buttonMode = false;
				this.mouseEnabled = false;
			}
				
		}
		
		public function HotSpotItem()
		{
			super();
			enabled = true;
		}
		
		public function dispose():void
		{
			enabled = false;
		}
		
		public function initializeGraphic( info:Object ):void
		{
			_type = info.type;
			selected = false;
		}
		
		public function setUnselectedState():void
		{
			graphics.clear();
			graphics.beginFill( bgColor, bgAlpha );
			drawShape();
			graphics.endFill();
			this.alpha = 0
		}
		
		public function setSelectedState():void
		{
			graphics.clear();
			graphics.beginFill( bgColor, 0 );
			graphics.lineStyle( borderSize, borderColor );
			drawShape();
			graphics.endFill();
			this.alpha = 1;
		}
		
		private function drawShape():void
		{
			switch( _type )
			{
				case ActivityConstants.RECT:
					graphics.drawRect( 0, 0, this.width, this.height );
					break;
				
				case ActivityConstants.CIRCLE:
					graphics.drawCircle( 0, 0, this.width/2 );
					break;
			}
		}
		
		private function onMouseOver( e:MouseEvent ):void
		{
			this.alpha = 1;
		}
		
		private function onMouseOut( e:MouseEvent ):void
		{
			this.alpha = 0;
		}
	}
}