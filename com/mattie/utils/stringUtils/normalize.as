package com.mattie.utils.stringUtils
{
    //Normalize
    public function normalize(targetString:String):String
    {
        targetString = targetString.toLowerCase();
        
        targetString = targetString.replace(/á/g, "a");
        targetString = targetString.replace(/à/g, "a");
        targetString = targetString.replace(/â/g, "a");
        targetString = targetString.replace(/ä/g, "a");
        
        targetString = targetString.replace(/ç/g, "c");
        
        targetString = targetString.replace(/é/g, "e");
        targetString = targetString.replace(/è/g, "e");
        targetString = targetString.replace(/ê/g, "e");
        targetString = targetString.replace(/ë/g, "e");
        
        targetString = targetString.replace(/í/g, "i");
        targetString = targetString.replace(/ì/g, "i");
        targetString = targetString.replace(/î/g, "i");
        targetString = targetString.replace(/ï/g, "i");
        
        targetString = targetString.replace(/ñ/g, "n");
        
        targetString = targetString.replace(/ó/g, "o");
        targetString = targetString.replace(/ò/g, "o");
        targetString = targetString.replace(/ô/g, "o");
        targetString = targetString.replace(/ö/g, "o");
        
        targetString = targetString.replace(/ú/g, "u");
        targetString = targetString.replace(/ù/g, "u");
        targetString = targetString.replace(/û/g, "u");
        targetString = targetString.replace(/ü/g, "u");
        
        return targetString;
    }
}