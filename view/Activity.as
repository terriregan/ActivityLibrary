package org.nflc.activities.view
{
	import flash.errors.IllegalOperationError;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.nflc.activities.components.IItem;
	import org.nflc.activities.events.ActivityStatusEvent;
	import org.nflc.activities.factory.SimpleItemFactory;
	import org.nflc.activities.model.ActivityConfiguration;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ActivityData;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.skins.ActivitySkin;
	import org.nflc.common.FocusableRichText;
	import org.nflc.common.KeyboardController;
	import org.nflc.common.ResizableTitleWindow;
	import org.nflc.common.WindowManager;
	import org.nflc.managers.AccessibilityManager;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.supportClasses.SkinnableComponent;
	
	import utils.array.getItemByKey;
	import utils.string.removeExtraWhitespace;

	/* NOTE: s:RichText and mx:Text were used for the prompt and choices.  This was done because htmlText 
	   support was needed in these fields and a bug prevents htmlText from being displayed consistently
	   when the mx componnets are wired to use the mx.core.UIFTETextField for FTE support.  UIFTETextField 
	   was turned off, but to support the html fonts were embedded twice with different embedCFF setings.
	   This whole font issue is a result of the use of s:RichText fields.  When using s:RichText, loading
	   animations (swf files) loose all their embed font support.  
		TODO - separate rich text activity from activity that uses mx components in skin
	*/
	
	[SkinState("normal")]
	[SkinState("excludeButtons")]
	public class Activity extends SkinnableComponent
	{
		[SkinPart(required="false")] 
		public var title:Label;
		
		[SkinPart(required="true")] 
		public var standardInstructions:FocusableRichText;
		
		[SkinPart(required="true")] 
		public var promptComponent:Group;
		
		[SkinPart(required="true")] 
		public var itemBank:Group;
		
		[SkinPart(required="false")] 
		public var activityUIButton:Button;
		
		[SkinPart(required="false")] 
		public var checkButton:Button;
		
		[SkinPart(required="false")] 
		public var resetButton:Button;
		
		[SkinPart(required="false")] 
		public var buttonBar:Group;

		[Bindable(event="answerStateChange")]
		public function get answerState():String  
		{
			return _answerState;
		}

		public function set answerState( value:String ):void
		{
			_answerState = value;
			dispatchEvent( new ActivityStatusEvent(ActivityStatusEvent.ANSWER_STATE_CHANGE, _answerState) );
		}
		
		[Bindable(event="activityComplete")] 
		public function get completeState():String   
		{
			return _completeState;
		}
		
		public function set completeState( value:String ):void
		{
			_completeState = value;
			dispatchEvent( new ActivityStatusEvent(ActivityStatusEvent.COMPLETE) );
		}
		
		[Bindable]
		public var itemBankYGap:Number = 20;  // quick workaround-FIX
		
		public var items:Array = [];
		public var itemFactory:SimpleItemFactory;
		public var data:ActivityData;
		public var layoutStyle:String;
		public var offset:uint = 0;			// amount to move itemBank (closer to prompt) - the draggable item is moved down by the same amount
		protected var tabbedItems:Array;
		private var _keyboardController:KeyboardController;
		private var _win:ResizableTitleWindow;
		
		[Bindable]
		public var prompt:TextFlow;
		
		//[Bindable]
		//public var promptText:String;
		
		[Bindable]
		public var promptComponents:Array;
		
		protected var configManager:ConfigurationManager = ConfigurationManager.getInstance();
		protected var configuration:ActivityConfiguration;
		
		private var _completeState:String = ActivityConstants.INCOMPLETE;			// has the user exhausted all attempts and received feedback
		private var _answerState:String = ActivityConstants.UNANSWERED;				// has the user made a selection

		
		public function Activity()
		{
			super();
			
			this.addEventListener( FlexEvent.CREATION_COMPLETE, init );
			setStyles();
			setUpKeyboardSensor();
			
			promptComponents = [];
		}
		
		private function init( e:FlexEvent ):void
		{
			this.removeEventListener( FlexEvent.CREATION_COMPLETE, init );
			
			_keyboardController = KeyboardController.getInstance();
			_keyboardController.setFocusManager( focusManager );
			_keyboardController.createHotKey( activityUIButton, showUIInstructions );
			
			// do not add an ENTER keyboard handler if the Check button is not visible (i.e for the assessment)
			if( configManager.buttons.length )
				_keyboardController.createHotKey( checkButton, check );
		}
		
		public function setStyles():void
		{
			// should be moved OUT of this library and into the course code for maximun reuse
			///if( !configManager.testMode )
			//	setStyle( "skinClass", org.nflc.activities.skins.ActivitySkin );  
			//else
				//setStyle( "skinClass", org.nflc.activities.skins.RichActivitySkin ); 
			
			setStyle( "skinClass", org.nflc.activities.skins.ActivitySkin );  
			
			setStyle( "left", 36 ); 
			setStyle( "right", 36 ); 
			setStyle( "top", 28 ); 
			setStyle( "bottom", 25 ); 
		}
		
		private function setUpKeyboardSensor():void
		{
			FlexGlobals.topLevelApplication.stage.addEventListener( KeyboardEvent.KEY_UP, activityKeyHandler );
		}
		
		private function activityKeyHandler( e:KeyboardEvent ):void
		{
			if( e.ctrlKey && e.shiftKey && e.keyCode == ActivityConstants.KEY_UI_INSTRUCTIONS )
				showUIInstructions();
			
			if( e.keyCode == ActivityConstants.KEY_CLOSE_WINDOW )
				closeActivityWindows();
		}
		
		protected function setState():void
		{
			if( data.sessionData )
			{
				if(	data.sessionData.isAnswered )
					answerState = ActivityConstants.ANSWERED;
				
				if(	data.sessionData.isComplete )
				{
					completeState = ActivityConstants.COMPLETE;
					displayCompleteState();
				}
			}
		}
		
		protected function markAsComplete():void
		{
			data.sessionData.isComplete = true;
			completeState = ActivityConstants.COMPLETE;
		}
		
		override protected function partAdded( partName:String,instance:Object ):void
		{
			super.partAdded( partName, instance ); 
			if( instance == checkButton )
			{
				var btn:Object = getItemByKey( configManager.buttons, "type", ActivityConstants.CHECK_BUTTON );
				if( btn )
					instance.label = btn.label;
				instance.addEventListener( MouseEvent.CLICK, check, false, 0, true );
			}
			
			if( instance == buttonBar )
			{
				if( data.content.@buttons == "top" )
				{
					instance.setStyle( "top", 50 );
					instance.setStyle( "right", 0 );
				}
			}
		}
		
		override protected function partRemoved( partName:String,instance:Object ):void
		{
			super.partRemoved( partName, instance );
			if( instance == checkButton )
			{
				instance.removeEventListener( MouseEvent.CLICK, check );
			}
		}
		
		override protected function getCurrentSkinState():String 
		{ 
			var state:String = "normal";
			if(  !configManager.buttons.length )
			if(  !configManager.buttons.length )
			{
				state = "excludeButtons";
			}
			return state;
		}
		
		public function addPurposeToTitle( xml:XML ):void 
		{
			title.accessibilityName = title.text + " : " + xml;
		}
		
		public function populateTitle( xml:XML ):void 
		{
			// activity specific screen title--data from activity content xml file
			if( xml != null )   
			{
				title.text = xml;
			}
				
			// Activity type specific (i.e. "Multiple Choice") - different for each activity type
			// <activities><activity id="sata"><screenTitle> node of activity xml config file
			else if( configuration.screenTitle )
			{
				title.text = configuration.screenTitle;
			}
				
			// Lesson specific screen title (same for all screens)
			// <activities><configuration><screenTitle> node of activity xml config file
			else if( configManager.screenTitle )   
			{
				title.text = configManager.screenTitle;
			}
				
			// no title, hide text field
			else
			{
				title.includeInLayout = false;
				title.visible = false;
			}
		}
		
		public function populateStandardInstructions():void 
		{
			throw new IllegalOperationError( "Abstract method must be overidden in a subclass" );
			return null;
		}
						
		public function display():void 
		{
			setState();
		}
		
		protected function updateTabIndices( action:String ):void
		{
			if( action == "add" )
			{
				AccessibilityManager.getInstance().addDisplayObjects( promptComponents, AccessibilityManager.CONTENT );
				AccessibilityManager.getInstance().addDisplayObjects( tabbedItems, AccessibilityManager.CONTENT );
			}
			else
			{
				AccessibilityManager.getInstance().removeDisplayObjects( promptComponents, AccessibilityManager.CONTENT );
				AccessibilityManager.getInstance().removeDisplayObjects( tabbedItems, AccessibilityManager.CONTENT );
			}
		}
		
		public function dispose():void 
		{
			// need to save array of buttons fetched from xml configuration and then loop and remove all listeners
			if( checkButton )
			{
				checkButton.removeEventListener( MouseEvent.CLICK, check );
			}
			closeActivityWindows();
			FlexGlobals.topLevelApplication.stage.removeEventListener( KeyboardEvent.KEY_UP, activityKeyHandler );
			this.removeEventListener( FlexEvent.CREATION_COMPLETE, init );
			
			_keyboardController.removeHotKey( activityUIButton );
			_keyboardController.removeHotKey( checkButton );
			_keyboardController.removeHotKey( checkButton );
			
			if( _win )
			{
				_keyboardController.removeHotKey(  _win.closeButton );
				_win = null;
			}
			_keyboardController = null;
			
			updateTabIndices( "remove" );
			
			// this is ugly workaround- only want to remove focus if focused obj is child of activity
			// if focus is not removed then keyboard events are not captured -- need to look into why
			var focusedObj:* = FlexGlobals.topLevelApplication.stage.focus;
			if(focusedObj && focusedObj.parent.parent is ActivitySkin)
				FlexGlobals.topLevelApplication.stage.focus = null;  
		}
		
		private function closeActivityWindows():void
		{
			WindowManager.getInstance().closeAndRemoveWindow( ActivityConstants.FEEDBACK_WIN );
			WindowManager.getInstance().closeAndRemoveWindow( ActivityConstants.ACTIVITY_GUIDE_WIN );
		}
		
		public function showUIInstructions( e:MouseEvent = null ):void 
		{
			var instructions:String = ( configManager.testMode ) ? configuration.UIinstructionsQuiz : configuration.UIinstructions;
			var textItem:IItem = itemFactory.createItem( ActivityConstants.TEXT_ITEM, {text: instructions} );
			_win = WindowManager.getInstance().createPopUp( UIComponent(textItem), 
				ActivityConstants.ACTIVITY_GUIDE_WIN, 400, 0 );  
			_keyboardController.createHotKey(  _win.closeButton, WindowManager.getInstance().close, [_win] );
		}
		
		protected function displayFeedback( content:* ):void
		{
			var obj:Object = {};
			if( content is XML )
			{
				obj.xml = content;
			}
			else 
			{
				obj.text = content;
			}
			var textItem:IItem = itemFactory.createItem( ActivityConstants.TEXT_ITEM, obj );
			_win = WindowManager.getInstance().createPopUp( UIComponent(textItem), 
													 ActivityConstants.FEEDBACK_WIN, 400, 0 );  // tween in
			_keyboardController.createHotKey(  _win.closeButton, WindowManager.getInstance().close, [_win] );
		}
		
		protected function check( e:MouseEvent = null ):void {}
		
		protected function recordCorrectStatus():void {}
		
		protected function saveUserResponse( response:* ):void {}
		
		protected function processChoiceChange( e:MouseEvent = null ):void {}
		
		protected function processFeedback():void {}
		
		protected function displayCompleteState():void {}
		
		public function reset( e:MouseEvent ):void {}
	}
}