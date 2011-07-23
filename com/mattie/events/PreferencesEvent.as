package com.mattie.events
{
    //Imports
    import flash.events.Event;
    
    //Class
    public class PreferencesEvent extends Event
    {
        //Constants
        public static const LOAD:String = "load";
        public static const SET:String = "set";	
        public static const DELETE:String = "delete";
        public static const SAVE:String = "save";
        
        //Properties
        public var key:String;
        public var oldValue:*;
        public var newValue:*;
        
        //Constructor
        public function PreferencesEvent(type:String, key:String = null, oldValue:* = null, newValue:* = null) 
        {
            super(type);
            
            this.key = key;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
        
        //Override clone
        public override function clone():Event
        {
            return new PreferencesEvent(type, key, oldValue, newValue);
        }
        
        //Override toString
        public override function toString():String
        {
            return formatToString("PreferencesEvent", "type", "key", "oldValue", "newValue");
        }
    }
}