package org.nflc.activities.components
{
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.model.ChoiceVO;
	
	import spark.components.Group;

	public class MediaItem extends Group implements IItem
	{
		private var _source:String;
		private var _item:IItem;
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
		
		public function get source():String
		{
			return _source;
		}
		
		public function set source( value:String ):void
		{
			_source = value;
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
				
		public function MediaItem( item:IItem ) 
		{
			_item = item;
			addElement( _item )
			// event listeners
		}
	}
}