package com.mattie.data
{
    //Imports
    import com.mattie.events.HistoryEvent;
    import flash.events.EventDispatcher;
    
    //Class
    public class History extends EventDispatcher
    {
        //Constants
        public static const UNDO:String = "undo";
        public static const REDO:String = "redo";
        
        //Revert Action
        public static function revertAction(action:String):String
        {
            if  (action != UNDO && action != REDO)
                throw new ArgumentError("History.revertAction \"action\" parameter must be either History.UNDO or History.REDO");
            
            return (action == UNDO) ? REDO : UNDO;
        }
        
        //Properties
        public var maximumStates:uint;	
        
        //Variables
        private var undoStates:Array = new Array();
        private var redoStates:Array = new Array();
        
        //Constructor
        public function History(maximumStates:uint)
        {
            this.maximumStates = maximumStates;
        }
        
        //Record State
        public function recordState(action:String, name:String, data:Object, spliceStates:Boolean):void
        {
            if  (action != UNDO && action != REDO)
                throw new ArgumentError("History.recordState \"action\" parameter must be either History.UNDO or History.REDO");
            
            if  (action == UNDO)
            {
                undoStates.push({name:name, data:data});
                
                if  (undoStates.length > maximumStates)
                    undoStates.shift();
                
                if  (spliceStates)
                {
                    redoStates.splice(0);
                    dispatchEvent(new HistoryEvent(HistoryEvent.STATUS, null, null, null, true, lastStateName(undoStates), false, null, undoStates.length));
                }
            }
            else
            redoStates.push({name:name, data:data});
        }
        
        //Undo
        public function undo():void
        {
            if  (undoable)
            {
                var state:Object = undoStates.pop();
                dispatchEvent(new HistoryEvent(HistoryEvent.CHANGE, UNDO, state.name, state.data));
                dispatchEvent(new HistoryEvent(HistoryEvent.STATUS, null, null, null, undoable, lastStateName(undoStates), redoable, lastStateName(redoStates), undoStates.length));
            }
        }
        
        //Redo
        public function redo():void
        {
            if  (redoable)
            {
                var state:Object = redoStates.pop();
                dispatchEvent(new HistoryEvent(HistoryEvent.CHANGE, REDO, state.name, state.data));
                dispatchEvent(new HistoryEvent(HistoryEvent.STATUS, null, null, null, undoable, lastStateName(undoStates), redoable, lastStateName(redoStates), undoStates.length));
            }
        }
        
        //Last State Name
        private function lastStateName(array:Array):String
        {
            return (array.length) ? array[array.length - 1].name : null;
        }
        
        //Get undoable
        private function get undoable():Boolean
        {
            return undoStates.length > 0;
        }
        
        //Get redoable
        private function get redoable():Boolean
        {
            return redoStates.length > 0; 
        }
    }
}