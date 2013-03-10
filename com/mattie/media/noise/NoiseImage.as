package com.mattie.media.noise
{
    //Imports
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    //Class
    public class NoiseImage extends Sprite
    {
        //Constants
        private static const ZERO_POINT:Point = new Point(0, 0);
        private static const MAX_INDEX:uint = 60;
        
        //Properties
        private var widthProperty:uint;
        private var heightProperty:uint;
        
        //Variables
        private var bitmapNoise:BitmapData;
        private var canvas:BitmapData;
        private var rectangleVector:Vector.<Rectangle>;
        private var index:uint;
        private var isPlaying:Boolean;
        
        //Constructor
        public function NoiseImage(maxWidth:uint, maxHeight:uint)
        {
            bitmapNoise = new BitmapData(maxWidth * 2, maxHeight * 2, false);
            bitmapNoise.noise(Math.random() * int.MAX_VALUE, 0, 255, 0, true);
        }
        
        //Draw
        private function draw():void
        {
            if (widthProperty != 0 && heightProperty != 0)
            {
                while (numChildren)
                {
                    removeChildAt(numChildren - 1);
                }
                
                canvas = new BitmapData(widthProperty, heightProperty, false);
                rectangleVector = new Vector.<Rectangle>;
                
                for (var i:uint = 0; i < MAX_INDEX; i++)
                {
                    rectangleVector.push(new Rectangle(Math.round(Math.random() * (bitmapNoise.width - widthProperty)), Math.round(Math.random() * (bitmapNoise.height - heightProperty)), widthProperty, heightProperty));
                }
                
                index = 0;
                canvas.copyPixels(bitmapNoise, rectangleVector[index], ZERO_POINT);
                
                addChild(new Bitmap(canvas));
            }
        }
        
        //Play
        public function play():void
        {
            if  (!isPlaying)
            {
                addEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
                isPlaying = true;
            }
        }
        
        //Stop
        public function stop():void
        {
            if  (isPlaying)
            {
                removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
                isPlaying = false;   
            }
        }
        
        //Enter Frame Event Handler
        private function enterFrameEventHandler(evt:Event):void
        {
            (index == MAX_INDEX - 1) ? index = 0 : index++
            canvas.copyPixels(bitmapNoise, rectangleVector[index], ZERO_POINT);
        }
        
        //Dispose
        public function dispose():void
        {
            stop();
            
            canvas.dispose();
            bitmapNoise.dispose();
            
            while (numChildren)
            {
                removeChildAt(numChildren - 1);
            }
        }
        
        //Set Width
        override public function set width(value:Number):void
        {
            widthProperty = Math.min(Math.max(0, value), bitmapNoise.width);
            draw();
        }
        
        //Get Width
        override public function get width():Number
        {
            return widthProperty;
        }
        
        //Set Height
        override public function set height(value:Number):void
        {
            heightProperty = Math.min(Math.max(0, value), bitmapNoise.height);
            draw();
        }
        
        //Get Height
        override public function get height():Number
        {
            return heightProperty;
        }      
    }
}