package org.nflc.activities.model
{
	
	import org.nflc.managers.KeyCodes;
	import flash.ui.Keyboard;
	
	final public class ActivityConstants
	{
		/* ACTIVITY TYPES */
		
		// selectable activity types
		public static const MULTIPLE_CHOICE:String = "multipleChoice";	
		public static const BINARY_CHOICE:String = "binaryChoice";	
		public static const SELECT_ALL_THAT_APPLY:String = "selectAllThatApply";	
		
		// draggable activity types
		public static const ORDERING:String = "ordering";	
		public static const DRAG_TO_IMAGE:String = "dragToImage";
		public static const MATCHING:String = "matching";	
		public static const CATEGORIZING:String = "categorizing";
		
		// clickable activity types
		public static const HOTSPOT:String = "hotSpot";	
		
		// writable activity types
		public static const CONSTRUCTED_RESPONSE:String = "constructedResponse";
		
		// alternative acessible activity types
		public static const DROP_DOWN_SELECT:String = "dropDownSelect";
		
		// item types
		public static const MEDIA_ITEM:String = "mediaItem";	
		public static const IMAGE_ITEM:String = "imageItem";	
		public static const TEXT_ITEM:String = "textItem";
		public static const RADIO_BUTTON_ITEM:String = "radioButtonItem";
		public static const CHECKBOX_ITEM:String = "checkBoxItem";
				
		// button types
		public static const CHECK_BUTTON:String = "checkButton";	
		public static const RESET_BUTTON:String = "resetButton";	
		
		// correct states
		public static const CORRECT:String = "correct";	
		public static const INCORRECT:String = "incorrect";	
		
		// answer states
		public static const ANSWERED:String = "answered";
		public static const UNANSWERED:String = "unanswered";
		
		// complete states
		public static const COMPLETE:String = "complete";
		public static const INCOMPLETE:String = "incomplete";	
		
		// window types
		public static const FEEDBACK_WIN:String = "FEEDBACK";
		public static const ACTIVITY_GUIDE_WIN:String = "ACTIVITY GUIDE";
		
		// hot keys
		public static const KEY_UI_INSTRUCTIONS:uint = KeyCodes.U;
		public static const KEY_CLOSE_WINDOW:uint = Keyboard.ESCAPE;
		
		public static const SELECTABLE_ACTIVITIES:Array = [ MULTIPLE_CHOICE, 
													  		BINARY_CHOICE, 
													  		SELECT_ALL_THAT_APPLY ];
		
		public static const DRAGGABLE_ACTIVITIES:Array = [ MATCHING ];
		
		public static const CLICKABLE_ACTIVITIES:Array = [ HOTSPOT ];
		
		public static const ORDERING_ACTIVITIES:Array = [ ORDERING, 
														  DRAG_TO_IMAGE ];
		
		public static const ACESSIBLE_ACTIVITIES:Array = [ ORDERING, 
														   DRAG_TO_IMAGE,
														   MATCHING,
														   CATEGORIZING ];
		
		// hotspot zone types
		public static const RECT:String = "rect";
		public static const CIRCLE:String = "circle";
		
		// layouts
		public static const EQUAL:String = "equal";
		public static const LEFT_DOMINANT:String = "leftDominant";
		public static const LEFT_DOMINANT_MID:String = "leftDominantMid";
		public static const RIGHT_DOMINANT:String = "rightDominant";
		public static const RIGHT_DOMINANT_SHORT:String = "rightDominantShort";
		public static const RIGHT_DOMINANT_MID:String = "rightDominantMid";
		public static const COLUMN:String = "column";
		public static const SHORT:String = "short";
		public static const SHORT_MID:String = "shortMid";
		public static const SHORT_LONG:String = "shortLong";
		public static const MEDIUM:String = "medium";
		public static const WIDE:String = "wide";
		
		// layout dimensions
		public static const DRAG_PADDING:int = 5;
		public static const GUTTER:int = 10;
		public static const ITEM_BANK_WIDTH:int = 700;
		
	}
}