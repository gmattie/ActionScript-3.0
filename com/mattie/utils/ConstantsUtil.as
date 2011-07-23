package com.mattie.utils
{
    //Imports
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import flash.utils.describeType;
    
    //Class
    public final class ConstantsUtil
    {
        //Class Has Public Constant
        public static function classHasPublicConstant(className:Class, constantName:String):Boolean 
        {
            var target:Class = getDefinitionByName(getQualifiedClassName(className)) as Class;
            var description:XML = describeType(target);      
            var result:Boolean = false;
            
            for each    (var publicConstant:XML in description.constant) 
                        if  (target[publicConstant.@name] == constantName)
                            result = true;
            
            target = null;
            description = null;
            
            return result;
        }
        
        //Class Public Constants Array
        public static function classPublicConstantsArray(className:Class):Array
        {
            var target:Class = getDefinitionByName(getQualifiedClassName(className)) as Class;
            var description:XML = describeType(target);
            
            var result:Array = new Array();
            
            for each    (var publicConst:XML in description.constant)
                        result.push(target[publicConst.@name]);
            
            target = null;
            description = null;
            
            return result;
        }
    }
}