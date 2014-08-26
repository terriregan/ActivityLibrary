package org.nflc.activities.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.nflc.activities.model.ActivityConfiguration;
	
	[Event(name="complete", type="flash.events.Event")] 
	public class ConfigurationManager extends EventDispatcher
	{
		private static var _instance:ConfigurationManager;
		private static var _allowInstantiation:Boolean;	
		
		public var activities:Dictionary;								// dictionary of configuration info for each activity type
		public var randomizeActivityChoices:Boolean;					// should the choice itmes be randomized
		public var requireUserSelectionForFeedback:Boolean;				// should the ""CHECK" button be disabled until the user makes a selection
		public var lockUserResponseAfterAnswerGiven:Boolean;			// should the user be able to change response once answer is give
		public var displaySavedUserData:Boolean;						// should the user's data be saved and redisplay upon return to screen
		public var screenTitle:String;								    // lesson specific scteen title (the same for all activity screens)
		public var buttons:Array;										// buttons to display -- "CHECK", "RESET", etc.
		
		[Bindable] 
		public var testMode:Boolean = false;							// is course in test mode
		public var assetPath:String;									// if activity uses external assets, where are they located
		
		public static function getInstance():ConfigurationManager 
		{
			if ( _instance == null ) 
			{
				_allowInstantiation = true;
				_instance = new ConfigurationManager();
				_allowInstantiation = false;
			}
			return _instance;
		}
		
		public function initialize( url:String = null, loConfig:XML = null ):void
		{
			if( url )
			{
				var service:HTTPService = new HTTPService();
				service.url = url;
				service.resultFormat = "e4x";
				var token:AsyncToken = service.send();	
				token.addResponder( new mx.rpc.Responder(onConfigResult, onConfigFault) );
			}
			if( loConfig )
			{
				parseLOProps( loConfig );
			}
		}
				
		public function onConfigResult( e:ResultEvent ):void
		{
			var xml:XML = e.result as XML;
			var vo:ActivityConfiguration;
			activities = new Dictionary();
			for each( var activity:XML in xml..activity )
			{
				vo = new ActivityConfiguration();
				vo.name = activity.name;
				vo.defaultFeedback = activity.default_feedback;
				vo.instructions = activity.instructions;
				vo.UIinstructions = activity.ui_instructions;
				vo.UIinstructionsQuiz = activity.ui_instructions_quiz;
				vo.screenTitle = activity.screenTitle;
				vo.numberAttemptsAllowed = int(activity.numberAttemptsAllowed);
				
				activities[activity.type.toString()] = vo;			
			}
			dispatchEvent( new Event(Event.COMPLETE, false) );
		}
		
		public function onConfigFault( e:FaultEvent ):void
		{
			// error here
			trace('config error')
		}
		
		private function parseLOProps( xml:XML ):void
		{
			screenTitle = xml.screenTitle; 
			assetPath = xml.assetPath;
			randomizeActivityChoices = ( xml.randomizeActivityChoices == "true" ) ? true : false;
			requireUserSelectionForFeedback = ( xml.requireUserSelectionForFeedback == "true" ) ? true : false;
			lockUserResponseAfterAnswerGiven = ( xml.lockUserResponseAfterAnswerGiven == "true" ) ? true : false;
			displaySavedUserData = ( xml.displaySavedUserData == "true" ) ? true : false;
			
			buttons = [];
			var btn:Object;
			for each( var button:XML in xml..button )
			{
				btn = {};
				btn.type = button.@type;
				btn.label = button.@label;
				buttons.push( btn );
			}
		}
	}
}