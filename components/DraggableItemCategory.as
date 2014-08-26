package org.nflc.activities.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.controls.Image;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import org.nflc.activities.events.DraggableEvent;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.DraggableChoiceVO;
	import org.nflc.activities.view.Activity;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	
	
	public class DraggableItemCategory extends DraggableItem   
	{
		private var _depth:Number;
	
		public function DraggableItemCategory( item:IItem, activity:Activity ) 
		{
			super( item, activity );
		
			addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true );
			addEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true );
			addEventListener( FocusEvent.FOCUS_IN, itemFocusInHandler, false, 0, true );
			addEventListener( FocusEvent.FOCUS_OUT, itemFocusOutHandler, false, 0, true );
		}
		
		
		private function mouseOverHandler( e:MouseEvent ):void 
		{                
			_depth = e.target.parent.depth;
			this.depth = 100;
		}
		
		private function mouseOutHandler( e:MouseEvent ):void 
		{                
			this.depth = _depth;
		}
		
		override protected function itemFocusInHandler( e:FocusEvent ):void 
		{ 
			_depth = e.target.parent.depth;
			this.depth = 100;
			super.itemFocusInHandler(e);
		}	
		
		override protected function itemFocusOutHandler( e:FocusEvent ):void 
		{ 
			this.depth = _depth;
			super.itemFocusOutHandler(e);
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			
			removeEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler );
			removeEventListener( MouseEvent.MOUSE_OUT, mouseOutHandler );
			removeEventListener( FocusEvent.FOCUS_IN, itemFocusInHandler );
			removeEventListener( FocusEvent.FOCUS_OUT, itemFocusOutHandler );
		}
		
		
	}
}