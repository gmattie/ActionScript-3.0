package com.mattie.media.noise
{
    //Imports
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    
    //Class
    public class NoiseImage extends Sprite
    {
        //Properties
        private var widthProperty:uint;
        private var heightProperty:uint;
        private var zoomProperty:uint;
        
        public var grayscale:Boolean;
        
        //Variables
        private var image:Sprite;
        private var imageBitmapData:BitmapData;
        private var zoomMatrix:Matrix;
        
        //Constructor
        public function NoiseImage(width:uint, height:uint, zoom:uint = 2, grayscale:Boolean = true)
        {
            this.width = width;
            this.height = height;
            this.zoom = zoom;
            this.grayscale = grayscale;
            
            init();
        }
        
        //Initialize
        private function init():void
        {
            imageBitmapData = new BitmapData(200, 200, false);
            
            image = new Sprite();
            addEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
            
            addChild(image);
        }
        
        //Enter Frame Event Handler
        private function enterFrameEventHandler(evt:Event):void
        {
            imageBitmapData.noise(Math.random() * int.MAX_VALUE, 0, 255, 7, grayscale);
            
            image.graphics.clear();
            image.graphics.beginBitmapFill(imageBitmapData, zoomMatrix, true);
            image.graphics.drawRect(0, 0, widthProperty, heightProperty);
        }
        
        //Dispose
        public function dispose():void
        {
            removeEventListener(Event.ENTER_FRAME, enterFrameEventHandler);
            
            imageBitmapData.dispose();
            imageBitmapData = null;
            image = null;
            zoomMatrix = null;
        }
        
        //Set Width
        override public function set width(value:Number):void
        {
            widthProperty = value;
        }
        
        //Get Width
        override public function get width():Number
        {
            return widthProperty;
        }
        
        //Set Height
        override public function set height(value:Number):void
        {
            heightProperty = value;
        }
        
        //Get Height
        override public function get height():Number
        {
            return heightProperty;
        }
        
        //Set Zoom
        public function set zoom(value:uint):void
        {
            zoomProperty = Math.max(1, value);
            
            zoomMatrix = new Matrix(zoomProperty, 0, 0, zoomProperty)
        }
        
        //Get Zoom
        public function get zoom():uint
        {
            return zoomProperty;
        }
    }
}