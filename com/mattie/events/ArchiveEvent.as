package com.mattie.events
{
    //Imports
    import flash.events.Event;
    
    //Class
    public class ArchiveEvent extends Event
    {
        //Constants
        public static const LOAD:String = "load";
        public static const WRITE:String = "write";
        public static const DELETE:String = "delete";
        public static const SAVE:String = "save";
        
        //Properties
        public var key:String;
        public var oldValue:*;
        public var newValue:*;
        
        //Constructor
        public function ArchiveEvent(type:String, key:String = null, oldValue:* = null, newValue:* = null) 
        {
            super(type);
            
            this.key = key;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
        
        //Clone
        public override function clone():Event
        {
            return new ArchiveEvent(type, key, oldValue, newValue);
        }
        
        //To String
        public override function toString():String
        {
            return formatToString("ArchiveEvent", "type", "key", "oldValue", "newValue");
        }
    }
}