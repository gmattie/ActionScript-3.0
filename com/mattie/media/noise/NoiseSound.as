package com.mattie.media.noise
{
    //Imports
    import flash.events.EventDispatcher;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    
    //Class
    public class NoiseSound extends EventDispatcher
    {
        //Constants
        private static const SAMPLE_RATE:uint = 2048;
        
        //Properties
        private var volumeProperty:Number;
        private var volumeLeftProperty:Number;
        private var volumeRightProperty:Number;
        private var depthProperty:Number;
        private var depthLeftProperty:Number;
        private var depthRightProperty:Number;
        
        public var isPlaying:Boolean;
        
        //Variables
        private var sound:Sound;
        private var soundChannel:SoundChannel;
        private var sampleLeft:Number;
        private var sampleRight:Number;
        
        private var a1Left:Number;
        private var a1Right:Number;
        private var a2Left:Number;
        private var a2Right:Number;
        private var a3Left:Number;
        private var a3Right:Number;
        private var b1Left:Number;
        private var b1Right:Number;
        private var b2Left:Number;
        private var b2Right:Number;
        private var cLeft:Number;
        private var cRight:Number;
        private var in1Left:Number;
        private var in1Right:Number;
        private var in2Left:Number;
        private var in2Right:Number;
        private var out1Left:Number;
        private var out1Right:Number;
        private var out2Left:Number;
        private var out2Right:Number;
        
        private var output:Number;
        private var i:uint;
        
        //Constructor
        public function NoiseSound(volume:Number = 0.0, depth:Number = 1.0)
        {
            this.volume = volume;
            this.depth = depth;
            
            init();
        }
        
        //Initialize
        private function init():void
        {
            in1Left = in1Right = in2Left = in2Right = out1Left = out1Right = out2Left = out2Right = 0;
            
            sound = new Sound();
            sound.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataEventHandler);
        }
        
        //Sample Data Event Handler
        private function sampleDataEventHandler(evt:SampleDataEvent):void
        {
            for (i = 0; i < SAMPLE_RATE; i++)
            {
                sampleLeft = frequencyFilter(true, Math.random() * 2.0 - 1.0);
                sampleRight = frequencyFilter(false, Math.random() * 2.0 - 1.0);
                
                evt.data.writeFloat(sampleLeft * volumeLeftProperty);
                evt.data.writeFloat(sampleRight * volumeRightProperty);
            }	
        }
   
        //Frequency Filter
        public function frequencyFilter(leftChannel:Boolean, input:Number):Number
        {
            if  (leftChannel)
            {
                output = a1Left * input + a2Left * in1Left + a3Left * in2Left - b1Left * out1Left - b2Left * out2Left;
                
                in2Left = in1Left;
                in1Left = input;
                out2Left = out1Left;
                out1Left = output; 
            }
            else
            {
                output = a1Right * input + a2Right * in1Right + a3Right * in2Right - b1Right * out1Right - b2Right * out2Right;
                
                in2Right = in1Right;
                in1Right = input;
                out2Right = out1Right;
                out1Right = output;   
            }
            
            return output;
        }
        
        //Play
        public function play():void
        {
            if  (!isPlaying)
            {
                soundChannel = sound.play();
                isPlaying = true;
            }
        }
        
        //Stop
        public function stop():void
        {
            if  (isPlaying && soundChannel)
            {
                soundChannel.stop();
                isPlaying = false;
            }
        }
        
        //Dispose
        public function dispose():void
        {
            stop();
            sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleDataEventHandler);
            
            soundChannel = null;
            sound = null;
        }
        
        //Set Volume
        public function set volume(value:Number):void
        {
            volumeProperty = volumeLeftProperty = volumeRightProperty = Math.max(0.0, Math.min(value, 1.0));
        }
        
        //Get Volume
        public function get volume():Number
        {
            return volumeProperty;
        }
        
        //Set Volume Left
        public function set volumeLeft(value:Number):void
        {
            volumeLeftProperty = Math.max(0.0, Math.min(value, 1.0));
        }
        
        //Get Volume Left
        public function get volumeLeft():Number
        {
            return volumeLeftProperty;
        }
        
        //Set Volume Right
        public function set volumeRight(value:Number):void
        {
            volumeRightProperty = Math.max(0.0, Math.min(value, 1.0));
        }
        
        //Get Volume Right
        public function get volumeRight():Number
        {
            return volumeRightProperty;
        }
        
        //Set Depth
        public function set depth(value:Number):void
        {
            depthProperty = depthLeft = depthRight = Math.max(0.0, Math.min(value, 1.0));
        }
        
        //Get Depth
        public function get depth():Number
        {
            return depthProperty;
        }
        
        //Set Depth Left
        public function set depthLeft(value:Number):void
        {
            depthLeftProperty = Math.max(0.0, Math.min(value, 1.0));
            
            cLeft = 1 / Math.tan(Math.PI * Math.max(1.0, Math.min((SAMPLE_RATE / 2 - 1.0) * depthLeftProperty, SAMPLE_RATE / 2 - 1.0)) / SAMPLE_RATE);
            a1Left = 1.0 / (1.0 + Math.SQRT2 * cLeft + cLeft * cLeft);
            a2Left = 2 * a1Left;
            a3Left = a1Left;
            b1Left = 2.0 * (1.0 - cLeft * cLeft) * a1Left;
            b2Left = (1.0 - Math.SQRT2 * cLeft + cLeft * cLeft) * a1Left;
        }
        
        //Get Depth Left
        public function get depthLeft():Number
        {
            return depthLeftProperty;
        }
        
        //Set Depth Right
        public function set depthRight(value:Number):void
        {
            depthRightProperty = Math.max(0.0, Math.min(value, 1.0));
            
            cRight = 1 / Math.tan(Math.PI * Math.max(1.0, Math.min((SAMPLE_RATE / 2 - 1.0) * depthRightProperty, SAMPLE_RATE / 2 - 1.0)) / SAMPLE_RATE);
            a1Right = 1.0 / (1.0 + Math.SQRT2 * cRight + cRight * cRight);
            a2Right = 2 * a1Right;
            a3Right = a1Right;
            b1Right = 2.0 * (1.0 - cRight * cRight) * a1Right;
            b2Right = (1.0 - Math.SQRT2 * cRight + cRight * cRight) * a1Right;
        }
        
        //Get Depth Right
        public function get depthRight():Number
        {
            return depthRightProperty;
        }
    }
}