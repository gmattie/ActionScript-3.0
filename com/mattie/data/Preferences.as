package com.mattie.data
{
    //Imports
    import com.mattie.events.PreferencesEvent;
    import flash.data.EncryptedLocalStore;
    import flash.desktop.NativeApplication;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.registerClassAlias;
    import flash.utils.Dictionary;
    import flash.utils.ByteArray;
    
    //Class
    public final class Preferences extends EventDispatcher
    {
        //Properties
        private static var singleton:Preferences;
        
        //Variables
        private var preferenceFile:File;
        private var preferenceData:Object = new Object();
        
        //Constructor
        public function Preferences()
        {
            if  (singleton)
                throw new Error("Preferences is a singleton that cannot be publicly instantiated and is only accessible thru the \"preferences\" public property.");
            
            registerClassAlias("PreferencesItem", PreferencesItem);			
            preferenceFile = File.applicationStorageDirectory.resolvePath("Preferences");
        }
        
        //Load
        public function load():void
        {
            if  (preferenceFile.exists)
            {
                var fileStream:FileStream = new FileStream();
                fileStream.open(preferenceFile, FileMode.READ);
                preferenceData = fileStream.readObject();
                fileStream.close();
            }
            
            dispatchEvent(new PreferencesEvent(PreferencesEvent.LOAD));
        }
        
        //Save
        public function save():void
        {
            var fileStream:FileStream = new FileStream();
            fileStream.open(preferenceFile, FileMode.WRITE);
            fileStream.writeObject(preferenceData);
            fileStream.close();
            
            dispatchEvent(new PreferencesEvent(PreferencesEvent.SAVE));
        }
        
        //Get Preference
        public function getPreference(key:String, defaultValue:* = null):*
        {
            var value:* = defaultValue;
            
            if  (preferenceData[key] != undefined)
            {
                var preferenceItem:PreferencesItem = PreferencesItem(preferenceData[key]);
                
                if  (preferenceItem.encrypted)
                {
                    var bytes:ByteArray = EncryptedLocalStore.getItem(key);
                    
                    if  (bytes == null)
                        return value;
                    
                    switch (preferenceItem.value)
                    {
                        case "Boolean":     value = bytes.readBoolean();                        break;
                        case "int":         value = bytes.readInt();                            break;
                        case "uint":        value = bytes.readUnsignedInt();                    break;
                        case "Number":      value = bytes.readDouble();                         break;
                        case "ByteArray":           bytes.readBytes(value = new ByteArray());   break;
                        default:            value = bytes.readUTFBytes(bytes.length);
                    }
                }
                else
                value = preferenceItem.value;
            }
            
            return value;
        }
        
        //Set Preference
        public function setPreference(key:String, value:*, encrypted:Boolean = false, autoSave:Boolean = false):void
        {
            var oldValue:* = getPreference(key);
            
            if  (oldValue != value)
            {
                var preferenceItem:PreferencesItem = new PreferencesItem();
                preferenceItem.encrypted = encrypted;
                
                var constructorString:String = String(value.constructor);
                constructorString = (constructorString.substring(constructorString.lastIndexOf(" ") + 1, constructorString.length - 1));
                preferenceItem.value = constructorString;
                
                if  (encrypted)
                {
                    var bytes:ByteArray = new ByteArray();
                    
                    switch (value.constructor)
                    {
                        case Boolean:       bytes.writeBoolean(value);          break;					
                        case int:           bytes.writeInt(value);              break;
                        case uint:          bytes.writeUnsignedInt(value);      break;
                        case Number:        bytes.writeDouble(value);           break;
                        case ByteArray:     bytes.writeBytes(value);            break;
                        default:            bytes.writeUTFBytes(value);
                    }
                    
                    EncryptedLocalStore.setItem(key, bytes);
                }
                else
                preferenceItem.value = value;
                
                preferenceData[key] = preferenceItem;
                dispatchEvent(new PreferencesEvent(PreferencesEvent.SET, key, oldValue, value));
                
                if  (autoSave)
                    save();
            }
        }
        
        //Delete Preference
        public function deletePreference(key:String, autoSave:Boolean = false):void
        {
            if  (preferenceData[key] != undefined)
            {
                var oldValue:* = getPreference(key);
                
                if  (PreferencesItem(preferenceData[key]).encrypted)
                    EncryptedLocalStore.removeItem(key);
                
                delete preferenceData[key];
                save();
                dispatchEvent(new PreferencesEvent(PreferencesEvent.DELETE, key, oldValue));
                
                if  (autoSave)
                    save();
            }
        }
        
        //Contains Preference
        public function containsPreference(key:String):Boolean
        {
            return (preferenceData[key] != undefined);
        }
        
        //Get Singleton
        public static function get preferences():Preferences
        {
            if  (!singleton)
                singleton = new Preferences();
            
            return singleton;
        }
    }
}