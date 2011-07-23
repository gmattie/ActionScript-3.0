package com.mattie.events
{
    //Imports
    import flash.events.Event;
    
    //Class
    public class MagnifiedImageEvent extends Event
    {
        //Constants
        public static const LOADER_INIT:String = "loaderInit";
        public static const LOADER_PROGRESS:String = "loaderProgress";
        public static const LOADER_COMPLETE:String = "loaderComplete";
        public static const CHANGE:String = "change";
        
        //Variables
        public var bytesLoaded:Number;
        public var bytesTotal:Number;
        public var contentWidth:uint;
        public var contentHeight:uint;
        public var maximumScale:Number;
        public var magnificationScale:Number;
        public var thumbScale:Number;
        
        //Constructor
        public function MagnifiedImageEvent(type:String, bytesLoaded:Number = 0.0, bytesTotal:Number = 0.0, contentWidth:uint = 0, contentHeight:uint = 0, maximumScale:Number = 0.0, magnificationScale:Number = 0.0, thumbScale:Number = 0.0)
        {
            super(type);
            
            this.bytesLoaded = bytesLoaded;
            this.bytesTotal = bytesTotal;
            this.contentWidth = contentWidth;
            this.contentHeight = contentHeight;
            this.maximumScale = maximumScale;
            this.magnificationScale = magnificationScale;
            this.thumbScale = thumbScale;
        }
        
        //Override clone
        override public function clone():Event
        {
            return new MagnifiedImageEvent(type, bytesLoaded, bytesTotal, contentWidth, contentHeight, maximumScale, magnificationScale, thumbScale);
        }
        
        //Override toString
        override public function toString():String
        {
            return formatToString("MagnifiedImageEvent", "type", "bytesLoaded", "bytesTotal", "contentWidth", "contentHeight", "maximumScale", "magnificationScale", "thumbScale");
        }
    }
}