package com.mattie.utils
{
    //Class
    public final class ColorUtils
    {        
        //Blend
        public static function blend(rgb1:uint, rgb2:uint, partition:Number = 0.5):uint
        {
            partition = Math.max(0.0, Math.min(1.0, partition));
            
            var r:uint = getRed(rgb1)   * (1 - partition) + getRed(rgb2)   * partition;
            var g:uint = getGreen(rgb1) * (1 - partition) + getGreen(rgb2) * partition;
            var b:uint = getBlue(rgb1)  * (1 - partition) + getBlue(rgb2)  * partition;

            return r << 16 | g << 8 | b;
        }
        
        //Get Alpha
        public static function getAlpha(color:uint):uint
        {
            return (color >> 24) & 0xFF;
        }
        
        //Get Red
        public static function getRed(color:uint):uint
        {
            return (color >> 16) & 0xFF;
        }
        
        //Get Green
        public static function getGreen(color:uint):uint
        {
            return (color >> 8) & 0xFF;
        }
        
        //Get Blue
        public static function getBlue(color:uint):uint
        {
            return color & 0xFF;
        }
        
        //Get Hex
        public static function getHex(color:uint):String
        {
            var hex:String = color.toString(16).toUpperCase();
                
            while (hex.length < 8)
            {
                hex = "0" + hex;
            }
            
            return "0x" + hex;
        }
        
        //Get Components
        public static function getComponents(color:uint):Object
        {
            return  {
                    alpha:  getAlpha(color),
                    red:    getRed(color),
                    green:  getGreen(color),
                    blue:   getBlue(color),
                    hex:    getHex(color)
                    };
        }
    }
}