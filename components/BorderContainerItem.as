package org.nflc.activities.components
{
	import spark.components.BorderContainer;
	import spark.components.Group;
	import org.nflc.activities.components.ImageItem;
	
	public class BorderContainerItem extends BorderContainer
	{
		private var _item:IItem;

		public function get item():IItem
		{
			return _item;
		}

		public function set item(value:IItem):void
		{
			_item = value;
		}

		
		public function BorderContainerItem( item:IItem ) 
		{
			_item = item;
			this.mouseChildren = false;
			
			if( _item is ImageItem )
				setStyle( "styleName", "imageContainerItem" );
			else
				setStyle( "styleName", "borderContainerItem" );
		}
		
		override protected function partAdded( partName:String, instance:Object ):void 
		{ 
			super.partAdded( partName, instance ); 
			if( instance == contentGroup )
			{
				instance.addElement( _item );
			}
		}
		
		public function dispose():void
		{
			_item.dispose();
		}
	}
}