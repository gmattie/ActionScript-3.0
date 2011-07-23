package com.mattie.events
{
    //Imports
    import flash.events.Event;
    
    //Class
    public class HistoryEvent extends Event
    {
        //Constants
        public static const CHANGE:String = "change";
        public static const STATUS:String = "status";
        
        //Variables
        public var action:String;
        public var name:String;
        public var data:Object;
        public var undoable:Boolean;
        public var undoableName:String;
        public var redoable:Boolean;
        public var redoableName:String;
        public var index:uint;
        
        //Constructor
        public function HistoryEvent(type:String, action:String = null, name:String = null, data:Object = null, undoable:Boolean = false, undoableName:String = null, redoable:Boolean = false, redoableName:String = null, index:uint = 0) 
        {
            super(type);
            
            this.action = action;
            this.name = name;
            this.data = data;
            this.undoable = undoable;
            this.undoableName = undoableName;
            this.redoable = redoable;
            this.redoableName = redoableName;
            this.index = index;
        }
        
        //Override clone
        override public function clone():Event
        {
            return new HistoryEvent(type, action, name, data, undoable, undoableName, redoable, redoableName, index);
        }
        
        //Override toString
        override public function toString():String
        {
            switch (type)
            {
                case CHANGE:    return formatToString("HistoryEvent", "type", "action", "name", "data");
                case STATUS:    return formatToString("HistoryEvent", "type", "undoable", "undoableName", "redoable", "redoableName", "index");
                default:        return null;
            }
        }
    }
}