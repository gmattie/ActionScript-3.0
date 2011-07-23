package com.mattie.events.broadcaster
{
    //Class
    public class Broadcast
    {
        //Variables
        public var name:String;
        public var data:Object;
        
        //Constructor
        public function Broadcast(name:String, data:Object) 
        {
            this.name = name;
            this.data = data;
        }
    }
}