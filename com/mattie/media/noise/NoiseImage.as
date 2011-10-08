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
        //Assets
        [Embed(source = "../assets/StaticSheet.jpg")]
        private var SpriteSheetAsset:Class;
        
        //Constants
        private static const ZERO_POINT:Point = new Point(0, 0);
        private static const MAX_INDEX:uint = 60;
        
        //Properties
        private var widthProperty:uint;
        private var heightProperty:uint;
        private var isPlayingProperty:Boolean;
        
        //Variables
        private var spriteSheet:BitmapData;
        private var canvas:BitmapData;
        private var rectangleVector:Vector.<Rectangle>;
        private var index:uint;
        
        //Constructor
        public function NoiseImage(width:uint, height:uint)
        {
            spriteSheet = (new SpriteSheetAsset() as Bitmap).bitmapData;
            
            widthProperty = width;
            heightProperty = height;
            
            draw();
        }
        
        //Draw
        private function draw():void
        {
            while (numChildren) removeChildAt(numChildren - 1);
            
            canvas = new BitmapData(widthProperty, heightProperty, false);
            rectangleVector = new Vector.<Rectangle>;
            
            for (var i:uint = 0; i < MAX_INDEX; i++)
                rectangleVector.push(new Rectangle(Math.round(Math.random() * (spriteSheet.width - widthProperty)), Math.round(Math.random() * (spriteSheet.height - heightProperty)), widthProperty, heightProperty));
            
            index = 0;
            canvas.copyPixels(spriteSheet, rectangleVector[index], ZERO_POINT);
            
            addChild(new Bitmap(canvas));
        }
        
        //Play
        public function play():void
        {
            if  (!isPlayingProperty)
            {
                addEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
                isPlayingProperty = true;
            }
        }
        
        //Stop
        public function stop():void
        {
            if  (isPlayingProperty)
            {
                removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
                isPlayingProperty = false;   
            }
        }
        
        //Enter Frame Event Handler
        private function enterFrameEventHandler(evt:Event):void
        {
            index == MAX_INDEX - 1 ? index = 0 : index++
            canvas.copyPixels(spriteSheet, rectangleVector[index], ZERO_POINT);
        }
        
        //Dispose
        public function dispose():void
        {
            stop();
            
            canvas.dispose();
            spriteSheet.dispose();
            
            while (numChildren) removeChildAt(numChildren - 1);
        }
        
        //Width Setter
        override public function set width(value:Number):void
        {
            widthProperty = Math.min(Math.max(0, value), spriteSheet.width);
            draw();
        }
        
        //Width Getter
        override public function get width():Number
        {
            return widthProperty;
        }
        
        //Height Setter
        override public function set height(value:Number):void
        {
            heightProperty = Math.min(Math.max(0, value), spriteSheet.height);
            draw();
        }
        
        //Height Getter
        override public function get height():Number
        {
            return heightProperty;
        }
        
        //isPlaying Getter
        public function get isPlaying():Boolean
        {
            return isPlayingProperty;
        }       
    }
}