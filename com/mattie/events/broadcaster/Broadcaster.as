package com.mattie.events.broadcaster
{
    //Imports
    import flash.utils.Dictionary;
    
    //Class
    public final class Broadcaster
    {
        //Properties
        private static var singleton:Broadcaster;
        
        private var publicationsProperty:Dictionary;
        private var subscriptionsProperty:Array;
        
        //Constructor
        public function Broadcaster()
        {
            if  (singleton)
                throw new Error("Broadcaster is a singleton that cannot be publically instantiated and is only accessible thru the \"broadcaster\" public property.");
            
            publicationsProperty = new Dictionary(true);
            subscriptionsProperty = new Array();
        }
        
        //Publish
        public function publish(name:String, data:Object = null):void
        {
            publicationsProperty[name] = data;
            
            for (var i:uint = 0; i < subscriptionsProperty.length; i++)
                if  (subscriptionsProperty[i].name == name)
                {
                    var handler:Function = subscriptionsProperty[i].handler;
                    handler(new Broadcast(name, data));
                }
        }
        
        //Subscribe
        public function subscribe(name:String, handler:Function):void
        {
            if  (publicationsProperty[name])
                handler(new Broadcast(name, publicationsProperty[name]));
            
            for (var i:uint = 0; i < subscriptionsProperty.length; i++)
                if  (subscriptionsProperty[i].name == name && subscriptionsProperty[i].handler == handler)
                    return;
            
            subscriptionsProperty.push({name: name, handler: handler});
        }
        
        //Unpublish
        public function unpublish(name:String):void
        {
            delete publicationsProperty[name];
        }
        
        //Unsubscribe
        public function unsubscribe(name:String, handler:Function):void
        {
            for (var i:uint = 0; i < subscriptionsProperty.length; i++)
                if  (subscriptionsProperty[i].name == name && subscriptionsProperty[i].handler == handler)
                {
                    subscriptionsProperty.splice(i, 1);
                    return;
                }
        }
        
        //Get publications
        public function get publications():Dictionary
        {
            return publicationsProperty;
        }
        
        //Get subscriptions
        public function get subscriptions():Array
        {
            return subscriptionsProperty;
        }
        
        //Get broadcaster
        public static function get broadcaster():Broadcaster
        {
            if  (!singleton)
                singleton = new Broadcaster();
            
            return singleton;
        }
    }
}