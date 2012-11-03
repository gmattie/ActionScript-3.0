package com.mattie.data
{
    //Imports
    import com.mattie.events.ArchiveEvent;
    import flash.data.EncryptedLocalStore;
    import flash.desktop.NativeApplication;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.registerClassAlias;
    import flash.utils.ByteArray;
    
    //Class
    public final class Archive extends EventDispatcher
    {
        //Properties
        private static var singleton:Archive;
        
        //Variables
        private var file:File;
        private var data:Object;
        
        //Constructor
        public function Archive()
        {
            if (singleton)
            {
                throw new Error("Archive is a singleton that is only accessible via the \"archive\" public property.");
            }
            
            file = File.applicationStorageDirectory.resolvePath(NativeApplication.nativeApplication.applicationID + "Archive");
            
            data = new Object();

            registerClassAlias("Item", Item);
        }
        
        //Load
        public function load():void
        {
            if (file.exists)
            {
                var fileStream:FileStream = new FileStream();
                fileStream.open(file, FileMode.READ);
                
                data = fileStream.readObject();
                
                fileStream.close();
            }
            
            dispatchEvent(new ArchiveEvent(ArchiveEvent.LOAD));
        }
        
        //Read
        public function read(key:String, defaultValue:* = null):*
        {
            var value:* = defaultValue;
            
            if (data[key] != undefined)
            {
                var item:Item = Item(data[key]);
                
                if (item.encrypted)
                {
                    var bytes:ByteArray = EncryptedLocalStore.getItem(key);
                    
                    if (bytes == null)
                    {                       
                        return value;
                    }
                    
                    switch (item.value)
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
                {
                    value = item.value;                    
                }
            }
            
            return value;
        }
        
        //Write
        public function write(key:String, value:*, encrypted:Boolean = false, autoSave:Boolean = false):void
        {
            var oldValue:* = read(key);
            
            if (oldValue != value)
            {
                var item:Item = new Item();
                item.encrypted = encrypted;
                
                if (encrypted)
                {
                    var constructorString:String = String(value.constructor);
                    constructorString = constructorString.substring(constructorString.lastIndexOf(" ") + 1, constructorString.length - 1);
                    
                    item.value = constructorString;
                    
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
                {
                    item.value = value;                    
                }
                
                data[key] = item;
                
                dispatchEvent(new ArchiveEvent(ArchiveEvent.WRITE, key, oldValue, value));
                
                if (autoSave)
                {                    
                    save();
                }
            }
        }
        
        //Remove
        public function remove(key:String, autoSave:Boolean = false):void
        {
            if (data[key] != undefined)
            {
                var oldValue:* = read(key);
                
                if (Item(data[key]).encrypted)
                {                    
                    EncryptedLocalStore.removeItem(key);
                }
                
                delete data[key];

                dispatchEvent(new ArchiveEvent(ArchiveEvent.DELETE, key, oldValue));
                
                if (autoSave)
                {                    
                    save();
                }
            }
        }
        
        //Contains
        public function contains(key:String):Boolean
        {
            return (data[key] != undefined);
        }
        
        //Save
        public function save():void
        {
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.WRITE);
            fileStream.writeObject(data);
            fileStream.close();
            
            dispatchEvent(new ArchiveEvent(ArchiveEvent.SAVE));
        }
        
        //Get Singleton
        public static function get archive():Archive
        {
            if (!singleton)
            {
                singleton = new Archive();
            }
            
            return singleton;
        }
    }
}

//Item
class Item
{
    //Variables
    public var value:*;
    public var encrypted:Boolean = false;
}