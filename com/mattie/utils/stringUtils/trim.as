package com.mattie.utils.stringUtils
{
    //Trim
    public function trim(targetString:String):String
    {
        return targetString.replace(/^\s+|\s+$/g, "");
    }
}