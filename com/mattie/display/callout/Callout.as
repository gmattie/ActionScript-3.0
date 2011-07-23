package com.mattie.display.callout
{
    //Imports
    import com.mattie.display.callout.CalloutStemStyle;
    import com.mattie.display.callout.CalloutStemLocation;
    import flash.display.CapsStyle;
    import flash.display.DisplayObject;
    import flash.display.JointStyle;
    import flash.display.LineScaleMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
 
    //Constructor
    public class Callout extends Sprite
    {
        //Constants
        private static const TOP_LEFT:String = "topLeft";
        private static const TOP_RIGHT:String = "topRight";
        private static const BOTTOM_RIGHT:String = "bottomRight";
        private static const BOTTOM_LEFT:String = "bottomLeft";
        
        //Properties
        private var contentContainer:DisplayObject;
        private var bodyWidthProperty:Number;
        private var bodyHeightProperty:Number;
        private var fillColorProperty:uint;
        private var fillAlphaProperty:Number;
        private var strokeWidthProperty:Number;
        private var strokeColorProperty:uint;
        private var strokeAlphaProperty:Number;
        private var roundCornersProperty:Number;
        private var stemWidthProperty:Number;
        private var stemHeightProperty:Number;
        private var stemAlignProperty:Number;
        private var stemStyleProperty:String;
        private var stemLocationProperty:String;
        private var maskContentProperty:Boolean;
        private var centerContentProperty:Boolean;
        private var alignCornersOffsetProperty:Boolean;
        
        //Variables
        private var updatable:Boolean;
        private var fill:Shape = new Shape();
        private var contentMask:Shape = new Shape();
        private var stroke:Shape = new Shape();
        private var bodyCenter:Point = new Point();
        private var stemStyleOffset:Number;
        private var drawingDirections:Vector.<String>;
        private var hasNewFillProperty:Boolean;
        private var hasNewContentMaskProperty:Boolean;
        private var hasNewStrokeProperty:Boolean;	
        
        //Constructor
        public function Callout (
                                contentContainer:DisplayObject,
                                fillColor:uint = 0x000000,
                                fillAlpha:Number = 0.75,
                                strokeWidth:Number = 2.0,
                                strokeColor:uint = 0xFFFFFF,
                                strokeAlpha:Number = 1.0,
                                roundCorners:Number = 0.0,
                                stemWidth:Number = 25,
                                stemHeight:Number = 15,
                                stemAlign:Number = 0,
                                stemStyle:String = CalloutStemStyle.ISOSCELES,
                                stemLocation:String = CalloutStemLocation.BOTTOM,
                                centerContent:Boolean = true,
                                alignCornersOffset:Boolean = true
                                )
        {
            this.contentContainer = contentContainer;
            
            bodyWidthProperty = contentContainer.width;
            bodyHeightProperty = contentContainer.height;
            fillColorProperty = fillColor;
            fillAlphaProperty = fillAlpha;
            strokeWidthProperty = strokeWidth;
            strokeColorProperty = strokeColor;
            strokeAlphaProperty = strokeAlpha;
            roundCornersProperty = roundCorners;
            stemWidthProperty = stemWidth;
            stemHeightProperty = stemHeight;
            stemAlignProperty = stemAlign;
            stemStyleProperty = stemStyle;
            stemLocationProperty = stemLocation;
            centerContentProperty = centerContent;
            alignCornersOffsetProperty = alignCornersOffset;
            
            init();
        }
        
        //Initialize
        private function init():void
        {
            visible = false;
            createCallout(fill, contentMask, stroke);
            contentContainer.mask = contentMask;
            
            addChild(fill);
            addChild(contentContainer);
            addChild(contentMask);
            addChild(stroke);
            
            updatable = true;
            visible = true;
        }
        
        //Create Callout 
        private function createCallout(...shapes):void
        {
            for each (var element:Shape in shapes)
            {
                element.graphics.clear();
                
                if  (element == stroke)
                    element.graphics.lineStyle((strokeWidthProperty == 0) ? NaN : strokeWidthProperty, strokeColorProperty, strokeAlphaProperty, true, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);
                    else
                    element.graphics.beginFill(fillColorProperty, fillAlphaProperty);
                
                switch (stemLocationProperty)
                {
                    case CalloutStemLocation.BOTTOM:    switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(-stemWidthProperty / 2, -stemHeightProperty);
                                                                                                stemStyleOffset = 0;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(-stemWidthProperty, -stemHeightProperty);
                                                                                                stemStyleOffset = -stemWidthProperty / 2;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(0, -stemHeightProperty);
                                                                                                stemStyleOffset = stemWidthProperty / 2;
                                                        }
                        
                                                        bodyCenter.x = element.x + (bodyWidthProperty / 2 - stemWidthProperty / 2 - ((alignCornersOffset) ? roundCornersProperty / 2 : 0)) * stemAlignProperty + stemStyleOffset;
                                                        bodyCenter.y = element.y - bodyHeightProperty / 2 - stemHeightProperty;
                                                        drawingDirections = new <String>[BOTTOM_LEFT, TOP_LEFT, TOP_RIGHT, BOTTOM_RIGHT];
                                                        break;
                    
                    case CalloutStemLocation.LEFT:      switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(stemWidthProperty, -stemHeightProperty / 2);
                                                                                                stemStyleOffset = 0;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(stemWidthProperty, -stemHeightProperty);
                                                                                                stemStyleOffset = -stemHeightProperty / 2;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(stemWidthProperty, 0);
                                                                                                stemStyleOffset = stemHeightProperty / 2;
                                                        }
                        
                                                        bodyCenter.x = element.x + bodyWidthProperty / 2 + stemWidthProperty;
                                                        bodyCenter.y = element.y + (bodyHeightProperty / 2 - stemHeightProperty / 2 - ((alignCornersOffset) ? roundCornersProperty / 2 : 0)) * stemAlignProperty + stemStyleOffset;
                                                        drawingDirections = new <String>[TOP_LEFT, TOP_RIGHT, BOTTOM_RIGHT, BOTTOM_LEFT];
                                                        break;
                    
                    case CalloutStemLocation.TOP:       switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(stemWidthProperty / 2, stemHeightProperty);
                                                                                                stemStyleOffset = 0;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(stemWidthProperty, stemHeightProperty);
                                                                                                stemStyleOffset = stemWidthProperty / 2;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(0, stemHeightProperty);
                                                                                                stemStyleOffset = -stemWidthProperty / 2;
                                                        }
                        
                                                        bodyCenter.x = element.x + (bodyWidthProperty / 2 - stemWidthProperty / 2 - ((alignCornersOffset) ? roundCornersProperty / 2 : 0)) * stemAlignProperty + stemStyleOffset;
                                                        bodyCenter.y = element.y + bodyHeightProperty / 2 + stemHeightProperty;
                                                        drawingDirections = new <String>[TOP_RIGHT, BOTTOM_RIGHT, BOTTOM_LEFT, TOP_LEFT];
                                                        break;
                    
                    case CalloutStemLocation.RIGHT:     switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(-stemWidthProperty, stemHeightProperty / 2);
                                                                                                stemStyleOffset = 0;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(-stemWidthProperty, stemHeightProperty);
                                                                                                stemStyleOffset = stemHeightProperty / 2;
                                                                                                break;
                                                            
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(-stemWidthProperty, 0);
                                                                                                stemStyleOffset = -stemHeightProperty / 2;
                                                        }
                        
                                                        bodyCenter.x = element.x - bodyWidthProperty / 2 - stemWidthProperty;
                                                        bodyCenter.y = element.y + (bodyHeightProperty / 2 - stemHeightProperty / 2 - ((alignCornersOffset) ? roundCornersProperty / 2 : 0)) * stemAlignProperty + stemStyleOffset;
                                                        drawingDirections = new <String>[BOTTOM_RIGHT, BOTTOM_LEFT, TOP_LEFT, TOP_RIGHT];
                }
                
                for each (var direction:String in drawingDirections)
                {
                    switch (direction)
                    {
                        case TOP_LEFT:      element.graphics.lineTo     (
                                                                            bodyCenter.x - bodyWidthProperty / 2,
                                                                            bodyCenter.y - bodyHeightProperty / 2 + roundCornersProperty / 2
                                                                        );
                            
                                            element.graphics.curveTo    (
                                                                            bodyCenter.x - bodyWidthProperty / 2,
                                                                            bodyCenter.y - bodyHeightProperty / 2,
                                                                            bodyCenter.x - bodyWidthProperty / 2 + roundCornersProperty / 2,
                                                                            bodyCenter.y - bodyHeightProperty / 2
                                                                        );
                                            break;
                        
                        case TOP_RIGHT:     element.graphics.lineTo     (
                                                                            bodyCenter.x + bodyWidthProperty / 2 - roundCornersProperty / 2,
                                                                            bodyCenter.y - bodyHeightProperty / 2
                                                                        );
                            
                                            element.graphics.curveTo    (
                                                                            bodyCenter.x + bodyWidthProperty / 2,
                                                                            bodyCenter.y - bodyHeightProperty / 2,
                                                                            bodyCenter.x + bodyWidthProperty / 2,
                                                                            bodyCenter.y - bodyHeightProperty / 2 + roundCornersProperty / 2
                                                                        );
                                            break;
                        
                        case BOTTOM_RIGHT:  element.graphics.lineTo     (
                                                                            bodyCenter.x + bodyWidthProperty / 2,
                                                                            bodyCenter.y + bodyHeightProperty / 2 - roundCornersProperty / 2
                                                                        );
                            
                                            element.graphics.curveTo    (
                                                                            bodyCenter.x + bodyWidthProperty / 2,
                                                                            bodyCenter.y + bodyHeightProperty / 2,
                                                                            bodyCenter.x + bodyWidthProperty / 2 - roundCornersProperty / 2,
                                                                            bodyCenter.y + bodyHeightProperty / 2
                                                                        );
                                            break;
                        
                        case BOTTOM_LEFT:   element.graphics.lineTo     (
                                                                            bodyCenter.x - bodyWidthProperty / 2 + roundCornersProperty / 2,
                                                                            bodyCenter.y + bodyHeightProperty / 2
                                                                        );
                            
                                            element.graphics.curveTo    (
                                                                            bodyCenter.x - bodyWidthProperty / 2,
                                                                            bodyCenter.y + bodyHeightProperty / 2,
                                                                            bodyCenter.x - bodyWidthProperty / 2,
                                                                            bodyCenter.y + bodyHeightProperty / 2 - roundCornersProperty / 2
                                                                        );
                    }
                }
                
                switch (stemLocationProperty)
                {
                    case CalloutStemLocation.BOTTOM:    switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(stemWidthProperty / 2, -stemHeightProperty);    break;
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(0, -stemHeightProperty);                        break;
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(stemWidthProperty, -stemHeightProperty);		
                                                        }
                                                        break;
                    
                    case CalloutStemLocation.LEFT:      switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(stemWidthProperty, stemHeightProperty / 2);     break;
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(stemWidthProperty, 0);                          break;
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(stemWidthProperty, stemHeightProperty);			
                                                        }
                                                        break;
                    
                    case CalloutStemLocation.TOP:       switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(-stemWidthProperty / 2, stemHeightProperty);    break;
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(0, stemHeightProperty);                         break;
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(-stemWidthProperty, stemHeightProperty);		
                                                        }
                                                        break;
                    
                    case CalloutStemLocation.RIGHT:     switch (stemStyleProperty)
                                                        {
                                                            case CalloutStemStyle.ISOSCELES:    element.graphics.lineTo(-stemWidthProperty, -stemHeightProperty / 2);   break;
                                                            case CalloutStemStyle.HYPOTENUSE:   element.graphics.lineTo(-stemWidthProperty, 0);                         break;
                                                            case CalloutStemStyle.OPPOSITE:     element.graphics.lineTo(-stemWidthProperty, -stemHeightProperty);		
                                                        }
                }
                
                element.graphics.lineTo(0, 0);
            }
            
            if  (centerContentProperty)
                centerContentContainer();
        }
        
        //Center Content Container
        private function centerContentContainer():void
        {		
            contentContainer.x = bodyCenter.x - contentContainer.width / 2;
            contentContainer.y = bodyCenter.y - contentContainer.height / 2;
        }
        
        //Override Set visible
        override public function set visible(value:Boolean):void
        {
            if  (super.visible == false && value == true) 
            {
                if  (hasNewContentMaskProperty)
                {
                    createCallout(fill, contentMask, stroke);
                    hasNewFillProperty = false;
                    hasNewContentMaskProperty = false;
                    hasNewStrokeProperty = false;
                }
                
                if  (hasNewFillProperty)
                {
                    createCallout(fill);
                    hasNewFillProperty = false;
                }
                
                if  (hasNewStrokeProperty)
                {
                    createCallout(stroke);
                    hasNewStrokeProperty = false;
                }
            }
            
            super.visible = value;
        }
        
        //Update
        private function update(...shapes):void
        {
            if  (updatable)
                if  (visible)
                    createCallout.apply(this, shapes);
                    else
                    for each (var element:Shape in shapes)
                    {
                        switch (element)
                        {
                            case fill:          hasNewFillProperty = true;          break;
                            case contentMask:   hasNewContentMaskProperty = true;   break;
                            case stroke:        hasNewStrokeProperty = true;	
                        }
                    }
        }
        
        //Set bodyWidth
        public function set bodyWidth(value:Number):void
        {
            bodyWidthProperty = (isNaN(value)) ? contentContainer.width : Math.max(0, value);
            update(fill, contentMask, stroke);
        }
        
        //Get bodyWidth
        public function get bodyWidth():Number
        {
            return bodyWidthProperty;
        }
        
        //Set bodyHeight
        public function set bodyHeight(value:Number):void
        {
            bodyHeightProperty = (isNaN(value)) ? contentContainer.height : Math.max(0, value);
            update(fill, contentMask, stroke);
        }
        
        //Get bodyHeight
        public function get bodyHeight():Number
        {
            return bodyHeightProperty;
        }
        
        //Set fillColor
        public function set fillColor(value:uint):void
        {
            fillColorProperty = value;
            update(fill);
        }
        
        //Get fillColor
        public function get fillColor():uint
        {
            return fillColorProperty;
        }
        
        //Set fillAlpha
        public function set fillAlpha(value:Number):void
        {
            fillAlphaProperty = Math.max(0.0, Math.min(value, 1.0));;
            update(fill);
        }
        
        //Get fillAlpha
        public function get fillAlpha():Number
        {
            return fillAlphaProperty;
        }
        
        //Set strokeWidth
        public function set strokeWidth(value:Number):void
        {
            strokeWidthProperty = Math.max(0, value);
            update(stroke);
        }
        
        //Get strokeWidth
        public function get strokeWidth():Number
        {
            return strokeWidthProperty;
        }
        
        //Set strokeColor
        public function set strokeColor(value:uint):void
        {
            strokeColorProperty = value;
            update(stroke);
        }
        
        //Get strokeColor
        public function get strokeColor():uint
        {
            return strokeColorProperty
        }
        
        //Set strokeAlpha
        public function set strokeAlpha(value:Number):void
        {
            strokeAlphaProperty = Math.max(0.0, Math.min(value, 1.0));;
            update(stroke);
        }
        
        //Get strokeAlpha
        public function get strokeAlpha():Number
        {
            return strokeAlphaProperty;
        }
        
        //Set roundCorners
        public function set roundCorners(value:Number):void
        {
            roundCornersProperty = Math.max(0, Math.min(value, Math.min(bodyWidthProperty, bodyHeightProperty)));
            update(fill, contentMask, stroke);
        }
        
        //Get roundCorners
        public function get roundCorners():Number
        {
            return roundCornersProperty;
        }
        
        //Set stemWidth
        public function set stemWidth(value:Number):void
        {
            stemWidthProperty = Math.max(0, value);
            update(fill, contentMask, stroke);
        }
        
        //Get stemWidth
        public function get stemWidth():Number
        {
            return stemWidthProperty;
        }
        
        //Set stemHeight
        public function set stemHeight(value:Number):void
        {
            stemHeightProperty = Math.max(0, value);
            update(fill, contentMask, stroke);
        }
        
        //Get stemHeight
        public function get stemHeight():Number
        {
            return stemHeightProperty;
        }
        
        //Set stemAlign
        public function set stemAlign(value:Number):void
        {
            stemAlignProperty = Math.max(-1, Math.min(value, 1)) * -1;
            update(fill, contentMask, stroke);
        }
        
        //Get stemAlign
        public function get stemAlign():Number
        {
            return stemAlignProperty * -1;
        }
        
        //Set stemStyle
        public function set stemStyle(value:String):void
        {
            if  (value == CalloutStemStyle.ISOSCELES || value == CalloutStemStyle.HYPOTENUSE || value == CalloutStemStyle.OPPOSITE)
                stemStyleProperty = value;
                else
                throw new ArgumentError("Callout stemStyle property must be either CalloutStemStyle.ISOSCELES, CalloutStemStyle.HYPOTENUSE or CalloutStemStyle.OPPOSITE");
            
            update(fill, contentMask, stroke);
        }
        
        //Get stemStyle
        public function get stemStyle():String
        {
            return stemStyleProperty;
        }
        
        //Set stemLocation
        public function set stemLocation(value:String):void
        {
            if  (value == CalloutStemLocation.TOP || value == CalloutStemLocation.BOTTOM || value == CalloutStemLocation.LEFT || value == CalloutStemLocation.RIGHT)
                stemLocationProperty = value;
                else
                throw new ArgumentError("Callout stemLocation property must be either CalloutStemLocation.BOTTOM, CalloutStemLocation.LEFT, CalloutStemLocation.TOP or CalloutStemLocation.RIGHT");
            
            update(fill, contentMask, stroke);
        }
        
        //Get stemLocation
        public function get stemLocation():String
        {
            return stemLocationProperty;
        }
        
        //Set centerContent
        public function set centerContent(value:Boolean):void
        {
            centerContentProperty = value;
            
            if  (updatable)
                if  (centerContentProperty)
                    centerContentContainer();
        }
        
        //Get centerContent
        public function get centerContent():Boolean
        {
            return centerContentProperty;
        }
        
        //Set alignCornersOffset
        public function set alignCornersOffset(value:Boolean):void
        {
            alignCornersOffsetProperty = value;
            update(fill, contentMask, stroke);
        }
        
        //Get alignCornersOffset
        public function get alignCornersOffset():Boolean
        {
            return alignCornersOffsetProperty;
        }
    }
}