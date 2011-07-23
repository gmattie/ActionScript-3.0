package com.mattie.events
{
    //Imports
    import flash.events.Event;
    
    //Class
    public class TinkerProxyEvent extends Event
    {
        //Constants
        public static const LOADING:String = "Loading";
        public static const INITIALIZING:String = "Initializing";
        public static const CONNECT:String = "Connect";
        public static const DISCONNECT:String = "Disconnect";
        public static const ERROR:String = "Error";
        
        //Constructor
        public function TinkerProxyEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
        }
        
        //Override clone
        override public function clone():Event
        {
            return new TinkerProxyEvent(type, bubbles, cancelable);
        }
        
        //Override toString
        override public function toString():String
        {
            return formatToString("TinkerProxyEvent", "type", "bubbles", "cancelable");
        }
    }
}