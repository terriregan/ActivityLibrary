package org.nflc.activities.components
{
	import mx.controls.Image;
	
	import org.nflc.activities.model.ChoiceVO;
	import org.nflc.common.FocusableImage;
	
	public class ImageItem extends FocusableImage implements IItem
	{
		private var _alt:String;
		private var _correctIndex:uint;
		private var _index:int;
		
		public var vo:ChoiceVO;
		
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
		
		public function set index( value:int ):void
		{
			_index = value;
		}
		
		public function get correctindex():uint
		{
			return _correctIndex;
		}
		
		public function set correctindex( value:uint ):void
		{
			_correctIndex = value;
		}
				
		public function dispose():void {}
		
		public function ImageItem()
		{
			super();
			this.smoothBitmapContent = true;
		}
		
	}
}