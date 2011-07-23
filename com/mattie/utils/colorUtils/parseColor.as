package com.mattie.utils.colorUtils
{
    //Parse Color
    public function parseColor(argb:Number = NaN, rgb:Number = NaN, rgbAlpha:Number = 255):Object
    {
        var color:uint;
        
        if  (!isNaN(argb))
            color = argb;
            else
            color = Math.max(0, Math.min(rgbAlpha, 255)) << 24 | rgb;
        
        var a:uint = (color >> 24) & 0xFF;
        var r:uint = (color >> 16) & 0xFF;
        var g:uint = (color >> 8) & 0xFF;
        var b:uint = color & 0xFF;
        
        var h:String = color.toString(16).toUpperCase();
        
        while (h.length < 8) h = "0" + h;
        
        h = "0x" + h;
        
        return {color: color, alpha: a, red: r, green: g, blue: b, hex: h};
    }
}