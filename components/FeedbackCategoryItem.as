package org.nflc.activities.components
{
	import flashx.textLayout.elements.TextFlow;
	import spark.components.RichText;
	import spark.utils.TextFlowUtil;
	import spark.components.VGroup;
	
	public class FeedbackCategoryItem extends VGroup
	{
		public function FeedbackCategoryItem()
		{
			super();
			this.percentWidth = 100;
			this.percentHeight = 100;
		}
		
		public function display( xml:XML ):void
		{
			var richText:RichText;
			var xmlList:XMLList;
			var markup:String;
			
			for each( var category:XML in xml..category )
			{
				richText =  new RichText();
				richText.percentWidth = 100;
				
				xmlList = xml..item.(@categoryId == category.@id);
				markup = "<span fontWeight='bold'>" + category + "</span><br/>" + getMarkup( xmlList );
				richText.textFlow = TextFlowUtil.importFromString( markup );
				
				addElement( richText );
			}
		}
		
		private function getMarkup( xml:XMLList ):String
		{
			var markup:String = "";
			for each( var item:XML in xml )
			{
				markup += item.p;
				markup += "<br/>";
			}
			
			return markup;
		}
	}
}