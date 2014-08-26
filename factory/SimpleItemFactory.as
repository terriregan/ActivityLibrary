package org.nflc.activities.factory
{
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.components.ImageItem;
	import org.nflc.activities.components.MediaItem;
	import org.nflc.activities.components.RichTextItem;
	import org.nflc.activities.components.TextItem;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ConfigurationManager;
	
	import spark.utils.TextFlowUtil;
	
	import utils.string.removeExtraWhitespace;
	
	public class SimpleItemFactory
	{
		public function SimpleItemFactory() {}

		
		public function createItem( type:String, params:Object ):IItem
		{
			switch( type )
			{
				// create image item 
				case ActivityConstants.IMAGE_ITEM:
					var imageItem:ImageItem = new ImageItem();
					imageItem.source = ConfigurationManager.getInstance().assetPath + "/" + params.source;
					imageItem.alt = params.alt;
					imageItem.accessibilityName = params.alt;
					imageItem.x = params.x;
					imageItem.y = params.y;
					imageItem.correctindex = params.correctIndex;
					imageItem.vo  = params.vo;
					return imageItem;
								
				// create media item 
				case ActivityConstants.MEDIA_ITEM:
					var item:ImageItem = new ImageItem();
					item.source = params.source;
					var mediaItem:MediaItem = new MediaItem( imageItem );
					mediaItem.source = params.mediaSource;
					mediaItem.correctindex = params.correctIndex;
					mediaItem.vo  = params.vo;
					return mediaItem;
					
				// create text item 
				case ActivityConstants.TEXT_ITEM:
					
					var rti:RichTextItem = getRichTextItem( params );
					rti.correctindex = params.correctIndex;
					rti.vo = params.vo;
					return rti;
					/*if( ConfigurationManager.getInstance().testMode )
					{
						var rti:RichTextItem = getRichTextItem( params );
						return rti;
					}
					else
					{
						var ti:TextItem = getTextItem( params );
						return ti;
					}
					
					return null;*/
			}
			return null;
		}
		
		private function getTextItem( params:Object ):TextItem
		{
			var textItem:TextItem = new TextItem();
			textItem.minWidth = 0;
			textItem.percentWidth = 100;
			textItem.setStyle( "styleName", "textItem" );
			if( params.xml )
				textItem.htmlText = removeExtraWhitespace(params.xml);	
			
			else if( params.text )
				textItem.htmlText = removeExtraWhitespace(params.text);	
			
			return textItem;
		}
		
		private function getRichTextItem( params:Object ):RichTextItem
		{
			var textItem:RichTextItem = new RichTextItem();
			textItem.minWidth = 0;
			textItem.percentWidth = 100;
			textItem.setStyle( "styleName", "richTextItem" );
			
			if( params.xml )
			{
				textItem.textFlow = TextFlowUtil.importFromXML( params.xml );
				textItem.alt = params.xml;
			}
			
			else if( params.text )
			{
				textItem.textFlow = TextFlowUtil.importFromString( params.text );
				textItem.alt = params.text;
			}
			
			return textItem;
		}
		
	}
	
}