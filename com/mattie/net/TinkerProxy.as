package com.mattie.net
{
    //Imports
    import com.mattie.events.TinkerProxyEvent;
    import flash.desktop.NativeApplication;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.desktop.NativeProcess;
    import flash.errors.IOError;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.net.Socket;
    import flash.system.Capabilities;
    import flash.utils.Timer;
    import flash.utils.Endian;
    
    //Class
    public class TinkerProxy extends Socket
    {
        //Properties
        private var systemIsWindowsProperty:Boolean;
        private var openingProperty:Boolean;
        private var connectedProperty:Boolean;
        
        //Variables
        private var windowsProxyFile:String;
        private var macProxyFile:String;
        private var tinkerProxyApplication:File;
        private var tinkerProxyConfigurationFile:File;
        private var serialPort:String;
        private var baudRate:uint;
        private var networkAddress:String;
        private var networkPort:uint;
        private var loadDelay:uint;
        private var loadDelayTimer:Timer;
        private var initializeDelay:uint;
        private var initializeDelayTimer:Timer;
        private var comDatabits:uint;
        private var comStopbits:uint;
        private var proxyTimeout:uint;
        private var writeConfigStream:FileStream;
        private var tinkerProxyProcess:NativeProcess;
        
        //Constructor
        public function TinkerProxy(windowsProxyFile:String = "serproxy.exe", macProxyFile:String = "serproxy.osx", endian:String = Endian.LITTLE_ENDIAN)
        {
            this.windowsProxyFile = windowsProxyFile;
            this.macProxyFile = macProxyFile;
            
            super();
            super.endian = endian;
            
            init();
        }
        
        //Initialize
        private function init():void
        {
            if  (!File.applicationDirectory.resolvePath(windowsProxyFile).exists && !File.applicationDirectory.resolvePath(macProxyFile).exists)
                throw new Error("Tinker Proxy source files \"" + windowsProxyFile + "\" (Windows) and/or \"" + macProxyFile + "\" (Mac) cannot be found in application directory (Included Files)");
            
            if  (Capabilities.os.toLowerCase().indexOf("windows") > -1)
            {
                systemIsWindowsProperty = true;
                tinkerProxyApplication = File.applicationDirectory.resolvePath(windowsProxyFile);
                tinkerProxyConfigurationFile = File.applicationStorageDirectory.resolvePath(windowsProxyFile.substring(0, windowsProxyFile.lastIndexOf(".exe")) + ".cfg");	
            }
            else if (Capabilities.os.toLowerCase().indexOf("mac") > -1)
            {
                systemIsWindowsProperty = false;
                tinkerProxyApplication = File.applicationDirectory.resolvePath(macProxyFile);
                tinkerProxyConfigurationFile = File.applicationStorageDirectory.resolvePath(macProxyFile + ".cfg");
            }
            else
            {
                throw new Error("TinkerProxy Error:  Operating System Is Not Supported");
            }
        }
        
        //Open
        public function open    (
                                serialPort:String,
                                baudRate:uint,
                                networkAddress:String = "127.0.0.1",
                                networkPort:uint = 5331,
                                loadDelay:uint = 1000,
                                initializeDelay:uint = 2000,
                                comDatabits:uint = 8,
                                comStopbits:uint = 1,
                                proxyTimeout:uint = 63115200
                                )
        {
            if  (!openingProperty)
            {
                openingProperty = true;
                dispatchEvent(new TinkerProxyEvent(TinkerProxyEvent.LOADING));
                
                if  (
                    this.serialPort == serialPort           &&
                    this.baudRate == baudRate               &&
                    this.networkAddress == networkAddress   &&
                    this.networkPort == networkPort         &&
                    this.comDatabits == comDatabits         &&
                    this.comStopbits == comStopbits         &&
                    this.proxyTimeout == proxyTimeout
                    )
                {
                    this.loadDelay = loadDelay;
                    this.initializeDelay = initializeDelay;

                    launchTinkerProxyApplication(null);
                    return;
                }
                
                this.serialPort = serialPort;
                this.baudRate = baudRate;
                this.networkAddress = networkAddress;
                this.networkPort = networkPort;
                this.loadDelay = loadDelay;
                this.initializeDelay = initializeDelay;
                this.comDatabits = comDatabits;
                this.comStopbits = comStopbits;
                this.proxyTimeout = proxyTimeout;
                
                writeConfigStream = new FileStream();
                writeConfigStream.addEventListener(Event.CLOSE, launchTinkerProxyApplication);
                writeConfigStream.addEventListener(IOErrorEvent.IO_ERROR, IOErrorEventHandler);
                
                writeConfigStream.openAsync(tinkerProxyConfigurationFile, FileMode.WRITE);
                
                writeConfigStream.writeUTFBytes("serial_device1=" + serialPort + File.lineEnding);
                writeConfigStream.writeUTFBytes("comm_ports=1" + File.lineEnding);
                writeConfigStream.writeUTFBytes("net_port1=" + networkPort + File.lineEnding);				
                writeConfigStream.writeUTFBytes("newlines_to_nils=false" + File.lineEnding);
                writeConfigStream.writeUTFBytes("comm_baud=" + baudRate + File.lineEnding);
                writeConfigStream.writeUTFBytes("comm_databits=" + comDatabits + File.lineEnding);
                writeConfigStream.writeUTFBytes("comm_stopbits=" + comStopbits+ File.lineEnding);
                writeConfigStream.writeUTFBytes("comm_parity=none" + File.lineEnding);
                writeConfigStream.writeUTFBytes("timeout=" + proxyTimeout + File.lineEnding);
                
                writeConfigStream.close();
            }
        }
        
        //Launch Tinker Proxy Application
        private function launchTinkerProxyApplication(evt:Event):void
        {
            if  (evt)
            {
                writeConfigStream.removeEventListener(Event.CLOSE, launchTinkerProxyApplication);
                writeConfigStream.removeEventListener(IOErrorEvent.IO_ERROR, IOErrorEventHandler);
            }
            
            var tinkerProxyProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            tinkerProxyProcessStartupInfo.executable = tinkerProxyApplication;
            
            var processArguments:Vector.<String> = new Vector.<String>();
            processArguments[0] = tinkerProxyConfigurationFile.nativePath;
            tinkerProxyProcessStartupInfo.arguments = processArguments;
            
            tinkerProxyProcess = new NativeProcess();
            tinkerProxyProcess.start(tinkerProxyProcessStartupInfo);
            
            loadDelayTimer = new Timer(loadDelay, 1);
            loadDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, connectTinkerProxy);
            loadDelayTimer.start();
        }
        
        //Connect Tinker Proxy
        private function connectTinkerProxy(evt:TimerEvent):void
        {
            dispatchEvent(new TinkerProxyEvent(TinkerProxyEvent.INITIALIZING));

            loadDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, connectTinkerProxy);
            loadDelayTimer = null;
            
            addEventListener(Event.CONNECT, initializeDelayTimerHandler);
            addEventListener(Event.CLOSE, connectionErrorEventHandler);
            addEventListener(IOErrorEvent.IO_ERROR, connectionErrorEventHandler);
            addEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionErrorEventHandler);
            
            try
            {
                super.connect(networkAddress, networkPort);
            }
                catch(error:IOError)        {connectionErrorEventHandler(null);}
                catch(error:SecurityError)  {connectionErrorEventHandler(null);}
        }
        
        //Initialize Delay Timer Handler
        private function initializeDelayTimerHandler(evt:Event):void
        {
            removeEventListener(Event.CONNECT, initializeDelayTimerHandler);
            
            initializeDelayTimer = new Timer(initializeDelay, 1);
            initializeDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tinkerProxyConnectionCompleteHandler);
            initializeDelayTimer.start();
        }
        
        //Tinker Proxy Connection Complete Handler
        private function tinkerProxyConnectionCompleteHandler(evt:TimerEvent):void
        {
            openingProperty = false;
            connectedProperty = true;
            
            dispatchEvent(new TinkerProxyEvent(TinkerProxyEvent.CONNECT));
            
            initializeDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, tinkerProxyConnectionCompleteHandler);
            initializeDelayTimer = null;
        }
        
        //Override connect
        override public function connect(host:String, port:int):void
        {
            throw new Error("Cannot call connect() method on TinkerProxy instance.  Call open() method instead."); 
        }
        
        //Override close
        override public function close():void
        {
            if  (openingProperty)
            {
                openingProperty = false;

                if  (writeConfigStream.hasEventListener(Event.CLOSE))
                {
                    writeConfigStream.close();
                    writeConfigStream.removeEventListener(Event.CLOSE, launchTinkerProxyApplication);
                    writeConfigStream.removeEventListener(IOErrorEvent.IO_ERROR, IOErrorEventHandler);
                }

                if  (loadDelayTimer.running)
                {
                    loadDelayTimer.stop();
                    loadDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, connectTinkerProxy);
                    loadDelayTimer = null;
                }

                if  (initializeDelayTimer.running)
                {
                    initializeDelayTimer.stop();
                    initializeDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, connectTinkerProxy);
                    initializeDelayTimer = null;
                }
            }

            super.close();
            
            tinkerProxyProcess.exit(true);
            tinkerProxyProcess = null;
            
            dispatchEvent(new TinkerProxyEvent(TinkerProxyEvent.DISCONNECT));
            
            connectedProperty = false;
            
            removeEventListener(Event.CLOSE, connectionErrorEventHandler);
            removeEventListener(IOErrorEvent.IO_ERROR, connectionErrorEventHandler);
            removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionErrorEventHandler);
        }
        
        //Connection Error Event Handler
        private function connectionErrorEventHandler(evt:*):void
        {
            openingProperty = false;
            connectedProperty = false;
            
            dispatchEvent(new TinkerProxyEvent(TinkerProxyEvent.ERROR));
            
            if  (initializeDelayTimer != null)
            {
                if  (initializeDelayTimer.running)
                    initializeDelayTimer.stop();
                
                initializeDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, tinkerProxyConnectionCompleteHandler);
                initializeDelayTimer = null;
            }
            
            removeEventListener(Event.CLOSE, connectionErrorEventHandler);
            removeEventListener(IOErrorEvent.IO_ERROR, connectionErrorEventHandler);
            removeEventListener(SecurityErrorEvent.SECURITY_ERROR, connectionErrorEventHandler);
            
            tinkerProxyProcess.exit(true);
            tinkerProxyProcess = null;
        }
        
        //IO Error Event Handler 
        private function IOErrorEventHandler(evt:IOErrorEvent):void
        {
            throw new Error("TinkerProxy IOError: " + evt);
        }
        
        //Get systemIsWindows
        public function get systemIsWindows():Boolean
        {
            return systemIsWindowsProperty;
        }
        
        //Get opening
        public function get opening():Boolean
        {
            return openingProperty;
        }
        
        //Override get connected
        override public function get connected():Boolean
        {
            return connectedProperty;
        }
    }
}