package com.mattie.display
{
    //Imports
    import com.mattie.events.MagnifiedImageEvent;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.PixelSnapping;
    import flash.errors.IOError;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Transform;
    import flash.net.URLRequest;
    
    //Class
    public class MagnifiedImage extends Sprite
    {
        //Constants
        private static const MAX_BITMAP_MEASUREMENT:uint = 7000;
        private static const MAX_BITMAP_PIXELS:uint = 12250000;
        private static const CACHED_IMAGE_BYTES_TOTAL:String = "cachedImageBytesTotal";
        
        //Properties
        public var minimumThumbScale:Number = 0.1;
        public var minimumMagnificationScale:Number = 0.25;
        
        private var imageURLProperty:String;
        private var thumbProperty:Sprite;
        private var imageProperty:Bitmap;
        private var loupeProperty:DisplayObject;
        private var loupeBaseProperty:Shape;
        private var loupeMaskProperty:Shape;
        private var loupeBackgroundColorProperty:uint;
        private var maximumScaleProperty:Number;
        private var thumbScaleProperty:Number;
        private var magnificationScaleProperty:Number;
        private var loupeBackgroundColorTransform:ColorTransform;
        
        //Static Variables
        private static var cachedImages:Object = new Object();
        
        //Variables
        private var constructorSettings:Object;
        private var imageLoader:Loader;
        private var imageLoaderContentBytesTotal:uint;
        private var imageWidth:uint;
        private var imageHeight:uint;
        private var imageBitmapData:BitmapData;
        
        //Constructor
        public function MagnifiedImage(imageURL:String, loupe:DisplayObject, loupeMask:Shape, loupeBackgroundColor:uint = 0xFFFFFF, thumbScale:Number = 0.5, magnificationScale:Number = 1.0)
        {
            imageURLProperty = imageURL;
            loupeProperty = loupe;
            loupeMaskProperty = loupeMask;
            
            constructorSettings = {loupeBackgroundColor: loupeBackgroundColor, thumbScale: thumbScale, magnificationScale: (magnificationScale > thumbScale) ? magnificationScale : thumbScale};
        }
        
        //Load
        public function load():void
        {
            if  (cachedImages[imageURL])
                init(cachedImages[imageURL]);
                else
                {
                    dispatchEvent(new MagnifiedImageEvent(MagnifiedImageEvent.LOADER_INIT));
                    
                    imageLoader = new Loader();
                    imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageLoaderErrorEventHandler);
                    imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, imageLoaderProgressEventHandler);
                    imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaderCompleteEventHandler);
                    imageLoader.load(new URLRequest(imageURL));
                }
        }
        
        //Image Loader Error Event Handler
        private function imageLoaderErrorEventHandler(evt:IOErrorEvent):void
        {
            throw new IOError(evt.text);
        }
        
        //Image Loader Progress Event Handler
        private function imageLoaderProgressEventHandler(evt:ProgressEvent):void
        {
            dispatchEvent(new MagnifiedImageEvent(MagnifiedImageEvent.LOADER_PROGRESS, evt.bytesLoaded, evt.bytesTotal));
        }
        
        //Image Loader Complete Event Handler
        private function imageLoaderCompleteEventHandler(evt:Event):void
        {
            evt.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, imageLoaderErrorEventHandler);
            evt.currentTarget.removeEventListener(ProgressEvent.PROGRESS, imageLoaderProgressEventHandler);
            evt.currentTarget.removeEventListener(Event.COMPLETE, imageLoaderCompleteEventHandler);
            
            if  (evt.currentTarget.content.width > MAX_BITMAP_MEASUREMENT || evt.currentTarget.content.height > MAX_BITMAP_MEASUREMENT || (evt.currentTarget.content.width * evt.currentTarget.content.height) > MAX_BITMAP_PIXELS)
                throw new ArgumentError("MagnifiedImage: Loaded image from \"" + imageURL + "\" exceeds the maximum supported size (" + MAX_BITMAP_MEASUREMENT + " height or width, " + MAX_BITMAP_PIXELS + " total pixels).");
            
            if  (!cachedImages[imageURL])
            {
                cachedImages[imageURLProperty] = evt.currentTarget.content;
                cachedImages[(CACHED_IMAGE_BYTES_TOTAL + imageURLProperty)] = evt.currentTarget.bytesTotal;
            }
            
            imageLoaderContentBytesTotal = cachedImages[(CACHED_IMAGE_BYTES_TOTAL + imageURLProperty)];
            
            init(evt.currentTarget.content);
        }
        
        //Initialize
        private function init(target:Bitmap):void
        {
            imageWidth = target.width;
            imageHeight = target.height;
            
            maximumScaleProperty = Math.sqrt(MAX_BITMAP_PIXELS / (imageWidth * imageHeight));

            if  (Math.max(imageWidth * maximumScaleProperty, imageHeight * maximumScaleProperty) > MAX_BITMAP_MEASUREMENT)
                maximumScaleProperty = Math.min(Math.sqrt(MAX_BITMAP_PIXELS / (imageWidth * imageHeight)), MAX_BITMAP_MEASUREMENT / imageWidth, MAX_BITMAP_MEASUREMENT / imageHeight);
                
            imageBitmapData = new BitmapData(imageWidth, imageHeight);
            imageBitmapData.draw(target);
            
            imageProperty = new Bitmap(imageBitmapData, PixelSnapping.AUTO, true);
            imageProperty.alpha = 0.0;
            imageProperty.mask = loupeMask;
            
            thumbProperty = new Sprite();
            thumbProperty.graphics.beginBitmapFill(imageBitmapData, null, false, true);
            thumbProperty.graphics.drawRect(0, 0, imageWidth, imageHeight);
            thumbProperty.graphics.endFill();		
            
            loupeBaseProperty = new Shape();
            loupeBaseProperty.graphics.copyFrom(loupeMask.graphics);
            loupeBaseProperty.cacheAsBitmap = true;
            
            loupeBackgroundColor = constructorSettings.loupeBackgroundColor;
            thumbScale = constructorSettings.thumbScale;
            magnificationScale = constructorSettings.magnificationScale;
            
            loupeBaseProperty.alpha = loupeProperty.alpha = 0.0;
            loupeBaseProperty.visible = loupeProperty.visible = false;
            
            addChild(loupeBaseProperty);
            addChild(thumbProperty);
            addChild(image);
            addChild(loupeMask);
            addChild(loupeProperty);
            
            dispatchEvent(new MagnifiedImageEvent(MagnifiedImageEvent.LOADER_COMPLETE, imageLoaderContentBytesTotal, imageLoaderContentBytesTotal, imageWidth, imageHeight, maximumScaleProperty, magnificationScaleProperty, thumbScaleProperty));
        }
        
        //Align Components
        public function alignComponents():void
        {
            loupeProperty.x = Math.round(thumbProperty.mouseX * thumbScale) - loupeProperty.width / 2;
            loupeProperty.y = Math.round(thumbProperty.mouseY * thumbScale) - loupeProperty.height / 2;
            
            loupeMask.x = loupeBaseProperty.x = Math.round(thumbProperty.mouseX * thumbScale) - loupeMask.width / 2;
            loupeMask.y = loupeBaseProperty.y = Math.round(thumbProperty.mouseY * thumbScale) - loupeMask.height / 2;
            
            imageProperty.x = thumbProperty.x + Math.max(0.0, Math.min((Math.round(thumbProperty.mouseX * thumbScale) - 1.0) / (thumbProperty.width - 1.0), 1.0)) * (thumbProperty.width - imageProperty.width);
            imageProperty.y = thumbProperty.y + Math.max(0.0, Math.min((Math.round(thumbProperty.mouseY * thumbScale) - 1.0) / (thumbProperty.height - 1.0), 1.0)) * (thumbProperty.height - imageProperty.height);
        }
        
        //Dispose
        public function dispose():void
        {
            constructorSettings = null;
            
            while (numChildren) removeChildAt(0);
            
            if  (imageLoader)
            {
                if  (imageLoader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS))
                    imageLoader.close();
                    
                imageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, imageLoaderErrorEventHandler);
                imageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, imageLoaderProgressEventHandler);
                imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaderCompleteEventHandler);
                imageLoader.unload();
            }
            
            if  (imageProperty)
            {
                imageBitmapData.dispose();
                imageBitmapData = null;
                imageProperty = null;
            }
            
            if  (thumbProperty)			
                thumbProperty = null;
            
            if  (loupeBaseProperty)
                loupeBaseProperty = null;
        }
        
        //Get imageURL
        public function get imageURL():String
        {
            return imageURLProperty;
        }
        
        //Get thumb
        public function get thumb():Sprite
        {
            return thumbProperty;
        }
        
        //Get image
        public function get image():Bitmap
        {
            return imageProperty;
        }
        
        //Get loupe
        public function get loupe():DisplayObject
        {
            return loupeProperty;
        }
        
        //Get loupeBase
        public function get loupeBase():Shape
        {
            return loupeBaseProperty;
        }
        
        //Get loupeMask
        public function get loupeMask():Shape
        {
            return loupeMaskProperty;
        }
        
        //Get maximumScale
        public function get maximumScale():Number
        {
            return maximumScaleProperty;
        }
        
        //Set thumbScale
        public function set thumbScale(value:Number):void
        {
            if  (thumbProperty)
            {
                thumbScaleProperty = Math.max(minimumThumbScale, Math.min(value, maximumScaleProperty - minimumMagnificationScale));
                thumbProperty.scaleX = thumbProperty.scaleY = thumbScaleProperty;
                
                if  (magnificationScaleProperty < thumbScaleProperty + minimumMagnificationScale)
                    magnificationScale = thumbScaleProperty + minimumMagnificationScale;
                
                if  (numChildren != 0)
                    dispatchEvent(new MagnifiedImageEvent(MagnifiedImageEvent.CHANGE, imageLoaderContentBytesTotal, imageLoaderContentBytesTotal, imageWidth, imageHeight, maximumScaleProperty, magnificationScaleProperty, thumbScaleProperty));
            }
        }
        
        //Get thumbScale
        public function get thumbScale():Number
        {
            return thumbScaleProperty;
        }
        
        //Set magnification
        public function set magnificationScale(value:Number):void
        {
            if  (thumbProperty)
            {
                magnificationScaleProperty = Math.max(thumbScaleProperty + minimumMagnificationScale, Math.min(value, maximumScaleProperty));			
                imageProperty.scaleX = imageProperty.scaleY = magnificationScaleProperty;
                alignComponents();
            
                if  (numChildren != 0)
                    dispatchEvent(new MagnifiedImageEvent(MagnifiedImageEvent.CHANGE, imageLoaderContentBytesTotal, imageLoaderContentBytesTotal, imageWidth, imageHeight, maximumScaleProperty, magnificationScaleProperty, thumbScaleProperty));
            }
        }
        
        //Get magnification
        public function get magnificationScale():Number
        {
            return magnificationScaleProperty;
        }
        
        //Set loupeBackgroundColor
        public function set loupeBackgroundColor(value:uint):void
        {
            loupeBackgroundColorProperty = value;
            
            loupeBackgroundColorTransform = new ColorTransform();
            loupeBackgroundColorTransform.color = loupeBackgroundColorProperty;
            
            loupeBase.transform.colorTransform = loupeBackgroundColorTransform;
        }
        
        //Get loupeBackgroundColor
        public function get loupeBackgroundColor():uint
        {
            return loupeBackgroundColorProperty;
        }
    }
}