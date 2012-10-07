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
        
        private var pitchProperty:Number;
        private var pitchLeftProperty:Number;
        private var pitchRightProperty:Number;
        
        //Variables
        private var sound:Sound;
        private var soundChannel:SoundChannel;
        
        private var sampleLeft:Number;
        private var sampleRight:Number;
        
        private var output:Number;
        
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
        
        private var input1Left:Number;
        private var input1Right:Number;
        
        private var input2Left:Number;
        private var input2Right:Number;
        
        private var output1Left:Number;
        private var output1Right:Number;
        
        private var output2Left:Number;
        private var output2Right:Number;
        
        private var isPlaying:Boolean;
        private var i:uint;
        
        //Constructor
        public function NoiseSound(volume:Number = 0.0, pitch:Number = 1.0)
        {
            this.volume = volume;
            this.pitch = pitch;
            
            init();
        }
        
        //Initialize
        private function init():void
        {
            input1Left = input1Right = input2Left = input2Right = output1Left = output1Right = output2Left = output2Right = 0;
            
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
                output = a1Left * input + a2Left * input1Left + a3Left * input2Left - b1Left * output1Left - b2Left * output2Left;
                
                input2Left = input1Left;
                input1Left = input;
                output2Left = output1Left;
                output1Left = output; 
            }
            else
            {
                output = a1Right * input + a2Right * input1Right + a3Right * input2Right - b1Right * output1Right - b2Right * output2Right;
                
                input2Right = input1Right;
                input1Right = input;
                output2Right = output1Right;
                output1Right = output;   
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
        
        //Set Pitch
        public function set pitch(value:Number):void
        {
            pitchProperty = pitchLeft = pitchRight = Math.max(0.0, Math.min(value, 1.0));
        }
        
        //Get Pitch
        public function get pitch():Number
        {
            return pitchProperty;
        }
        
        //Set Pitch Left
        public function set pitchLeft(value:Number):void
        {
            pitchLeftProperty = Math.max(0.0, Math.min(value, 1.0));
            
            cLeft = 1 / Math.tan(Math.PI * Math.max(1.0, Math.min((SAMPLE_RATE / 2 - 1.0) * pitchLeftProperty, SAMPLE_RATE / 2 - 1.0)) / SAMPLE_RATE);
            a1Left = 1.0 / (1.0 + Math.SQRT2 * cLeft + cLeft * cLeft);
            a2Left = 2 * a1Left;
            a3Left = a1Left;
            b1Left = 2.0 * (1.0 - cLeft * cLeft) * a1Left;
            b2Left = (1.0 - Math.SQRT2 * cLeft + cLeft * cLeft) * a1Left;
        }
        
        //Get Pitch Left
        public function get pitchLeft():Number
        {
            return pitchLeftProperty;
        }
        
        //Set Pitch Right
        public function set pitchRight(value:Number):void
        {
            pitchRightProperty = Math.max(0.0, Math.min(value, 1.0));
            
            cRight = 1 / Math.tan(Math.PI * Math.max(1.0, Math.min((SAMPLE_RATE / 2 - 1.0) * pitchRightProperty, SAMPLE_RATE / 2 - 1.0)) / SAMPLE_RATE);
            a1Right = 1.0 / (1.0 + Math.SQRT2 * cRight + cRight * cRight);
            a2Right = 2 * a1Right;
            a3Right = a1Right;
            b1Right = 2.0 * (1.0 - cRight * cRight) * a1Right;
            b2Right = (1.0 - Math.SQRT2 * cRight + cRight * cRight) * a1Right;
        }
        
        //Get Pitch Right
        public function get pitchRight():Number
        {
            return pitchRightProperty;
        }
    }
}