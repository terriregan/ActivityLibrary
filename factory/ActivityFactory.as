package org.nflc.activities.factory
{
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	
	import mx.core.UIComponent;
	import mx.utils.StringUtil;
	
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.factory.SimpleItemFactory;
	import org.nflc.activities.model.ActivityConfiguration;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ActivityData;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.model.SessionData;
	import org.nflc.activities.view.Activity;
	import org.nflc.util.XMLParseUtil;
	
	import spark.components.Group;
	import spark.utils.TextFlowUtil;
	
	import utils.string.removeExtraWhitespace;
	
	public class ActivityFactory
	{
		protected var activity:Activity;
		protected var activityType:String;
		protected var itemFactory:SimpleItemFactory;
		
		public function ActivityFactory() 
		{
			itemFactory = new SimpleItemFactory();  // generates choice items
		}
		
		public function display( target:Group, activityData:ActivityData ):Activity
		{
			activity = this.createActivity( activityData.interactionType );
	
			if( activity )
			{
				activity.percentWidth = 100;
				activity.percentHeight = 100;
				activity.itemFactory = itemFactory;
				activity.data = activityData;
				
				var content:XML = activity.data.content;
				target.addElement( activity );
				activity.populateTitle( content.title[0] );
				
				if( content.hasOwnProperty("purpose") )
					activity.addPurposeToTitle( content.purpose[0] );
					
				activity.populateStandardInstructions();
				
				if( content.hasOwnProperty("question") )
					populatePrompt( content.question[0] );
				else
					activity.itemBankYGap = 0;  // FIX this ugly workaround
			
				populateItemBank( content );
			
				activity.display();
				
				return activity;
			}
			else
			{
				trace("Unable to create activity");
			}
			return null;
		}
		
		public function createActivity( type:String ):Activity
		{
			throw new IllegalOperationError( "Abstract method must be overidden in a subclass" );
			return null;
		}
		
		public function populatePrompt( xml:XML ):void 
		{
			var item:IItem;
			for each ( var component:XML in xml.component )
			{
				item =  fetchPromptComponent( component );
				if( item )
					activity.promptComponents.push( item );
			}
			
			//if( !ConfigurationManager.getInstance().testMode )
			//	activity.promptText = removeExtraWhitespace( XMLParseUtil.getContentNode(xml) );
			//else
			
			activity.prompt = TextFlowUtil.importFromXML( XMLParseUtil.getContentNode(xml) );
		}
		
		protected function populateObjectProps( xml:XML ):Object
		{
			var obj:Object = {};
			obj.source = xml.@image;
			obj.alt = xml.@alt;
			obj.x = ( xml.@x.length() ) ? uint(xml.@x)  : 0;
			obj.y = ( xml.@y.length() ) ? uint(xml.@y)  : 0;
			
			return obj;
		}
			
			
		protected function fetchPromptComponent( xml:XML ):IItem
		{
			var item:IItem;
			
			if( xml.@image.length() )
			{
				item = itemFactory.createItem( ActivityConstants.IMAGE_ITEM, populateObjectProps(xml) );	
				return item;
			}
				
			else if( xml.@media.length() )
			{
				item = itemFactory.createItem( ActivityConstants.MEDIA_ITEM, 
					{source: "get icon data from xml", mediaSource: "get media data from xml"} );
				return item;
			}
		
			return null;
		}
		
		public function populateItemBank( xml:XML ):void 
		{
			throw new IllegalOperationError( "Abstract method must be overidden in a subclass" );
			return null;
		}
	}
}