package com.mattie.display.colorWheel
{
    //Imports
    import com.mattie.display.colorWheel.ColorWheelQuality;
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    
    //Class
    public final class ColorWheel extends Sprite
    {
        //Properties
        private var radiusProperty:Number;
        private var qualityProperty:uint;
        private var centerGradientColorProperty:Number;
        private var centerGradientDistanceProperty:uint;
        
        //Variables
        private var centerGradient:Shape = new Shape();
        
        //Constructor
        public function ColorWheel(radius:Number, quality:uint = ColorWheelQuality.LOW, centerGradientColor:Number = 0xFFFFFF, centerGradientDistance:uint = 255)
        {
            radiusProperty = radius;
            qualityProperty = Math.max(1, Math.min(quality, 3));
            centerGradientColorProperty = centerGradientColor;
            centerGradientDistanceProperty = Math.max(0, Math.min(centerGradientDistance, 255));;
            
            drawSpectrum();
            
            if  (!isNaN(centerGradientColor))
                drawCenterGradient();
            
            addChild(centerGradient);
        }
        
        //Draw Spectrum
        private function drawSpectrum():void
        {
            var radians:Number;
            var radiusX:Number;
            var radiusY:Number;
            var previousRadiusX:Number;
            var previousRadiusY:Number;
            
            graphics.clear();
            
            for (var i:int = 0; i <= (360 * qualityProperty); i++)
            {
                radians = i * (Math.PI / ((360 * qualityProperty) / 2));
                
                radiusX = radiusProperty * Math.cos(radians);
                radiusY = radiusProperty * Math.sin(radians);
                
                graphics.beginFill(colorFromAngle((2 * Math.PI / (360 * qualityProperty)) * i), 1.0);
                graphics.moveTo(0, 0);
                graphics.lineTo(previousRadiusX, previousRadiusY);
                graphics.lineTo(radiusX, radiusY);
                graphics.lineTo(0, 0);
                graphics.endFill();
                
                previousRadiusX = radiusX;
                previousRadiusY = radiusY;
            }
        }
        
        //Draw Center Gradient
        private function drawCenterGradient():void
        {
            if  (isNaN(centerGradientColorProperty))
            {
                centerGradient.graphics.clear();
                return;
            }
            
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(radiusProperty * 2, radiusProperty * 2, 0, -radiusProperty, -radiusProperty);
            
            centerGradient.graphics.clear();
            centerGradient.graphics.beginGradientFill(GradientType.RADIAL, [centerGradientColorProperty, centerGradientColorProperty], [1.0, 0.0], [0, centerGradientDistanceProperty], matrix);
            centerGradient.graphics.drawCircle(0, 0, radiusProperty);
            centerGradient.graphics.endFill();
        }
        
        //Color From Angle
        private function colorFromAngle(angle:Number):uint
        {
            angle %= 2 * Math.PI;
            
            var r:Number;
            var g:Number;
            var b:Number;
            
            var hexArea:uint = Math.floor(angle / (Math.PI / 3));
            
            switch (hexArea)
            {
                case 0: r = 1; b = 0;   break;
                case 1: g = 1; b = 0;   break;
                case 2: r = 0; g = 1;   break;
                case 3: r = 0; b = 1;   break;
                case 4: g = 0; b = 1;   break;
                case 5: r = 1; g = 0;
            }
            
            if      (isNaN(r))  r = magnitudeFromHexArea(angle, hexArea);
            else if (isNaN(g))  g = magnitudeFromHexArea(angle, hexArea);
            else if (isNaN(b))  b = magnitudeFromHexArea(angle, hexArea);
            
            return ((r * 255) << 16) | ((g * 255) << 8) | (b * 255);
        }
        
        //Magnitude From Hex Area
        private function magnitudeFromHexArea(angle:Number, hexArea:uint):Number
        {
            angle -= (hexArea * (Math.PI / 3));
            
            if  ((hexArea % 2) != 0)
                angle = (Math.PI / 3) - angle;
            
            return (angle / (Math.PI / 3));
        }
        
        //Set radius
        public function set radius(value:Number):void
        {
            radiusProperty = value;
            drawSpectrum();
            drawCenterGradient();
        }
        
        //Get radius
        public function get radius():Number
        {
            return radiusProperty;
        }
        
        //Set quality
        public function set quality(value:uint):void
        {
            qualityProperty = Math.max(1, Math.min(value, 3));
            drawSpectrum();
        }
        
        //Get quality
        public function get quality():uint
        {
            return qualityProperty;
        }
        
        //Set centerGradientColor
        public function set centerGradientColor(value:Number):void
        {
            centerGradientColorProperty = value;
            drawCenterGradient();
        }
        
        //Get centerGradientColor
        public function get centerGradientColor():Number
        {
            return centerGradientColorProperty;
        }
        
        //Set centerGradientDistance
        public function set centerGradientDistance(value:uint):void
        {
            centerGradientDistanceProperty = Math.max(0, Math.min(value, 255));;
            drawCenterGradient();
        }
        
        //Get centerGradientDistance
        public function get centerGradientDistance():uint
        {
            return centerGradientDistanceProperty;
        }
    }
}