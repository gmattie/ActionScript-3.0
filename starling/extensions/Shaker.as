package starling.extensions  
{
	//Imports
	import starling.animation.Juggler;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	//Class
	public class Shaker extends DisplayObjectContainer 
	{
		//Properties
		public static var juggler:Juggler;
		
		private var m_FadeInDuration:uint;
		private var m_MaxAmplitudeDuration:uint;
		private var m_FadeOutDuration:uint;
		private var m_MaxAmplitude:uint;
		private var m_FrequencyDuration:Number;
		private var m_EaseFadeIn:Boolean;
		private var m_EaseFadeOut:Boolean;
		
		private var m_ShakeTween:Tween;
		private var m_AmplitudeTimeGraph:Vector.<Number>;
		
		private var m_IsInstantiated:Boolean;
		private var m_IsPlaying:Boolean;
		private var m_IsPaused:Boolean;

		//Constructor
		public function Shaker(maxAmplitude:uint, fadeInDuration:uint, maxAmplitudeDuration:uint, fadeOutDuration:uint, frequencyDuration:Number = 0.05, easeFadeIn:Boolean = true, easeFadeOut:Boolean = true):void
		{
			if (!juggler)
			{
				juggler = Starling.juggler;
			}
			
			m_ShakeTween = new Tween(null, NaN, Transitions.LINEAR);
			
			m_AmplitudeTimeGraph = new Vector.<Number>;
			
			reset(maxAmplitude, fadeInDuration, maxAmplitudeDuration, fadeOutDuration, frequencyDuration, easeFadeIn, easeFadeOut);
		}
		
		//Reset
		public function reset(maxAmplitude:uint, fadeInDuration:uint, maxAmplitudeDuration:uint, fadeOutDuration:uint, frequencyDuration:Number = 0.05, easeFadeIn:Boolean = true, easeFadeOut:Boolean = true):void
		{
			m_IsInstantiated = false

			this.maxAmplitude = maxAmplitude;
			this.fadeInDuration = fadeInDuration;
			this.maxAmplitudeDuration = maxAmplitudeDuration;
			this.fadeOutDuration = fadeOutDuration;
			this.frequencyDuration = frequencyDuration;
			this.easeFadeIn = easeFadeIn;
			this.easeFadeOut = easeFadeOut;
			
			updateAmplitudeTimeGraph();
			
			m_IsInstantiated = true;
		}
		
		//Update Amplitude Time Graph
		private function updateAmplitudeTimeGraph(replay:Boolean = true):void
		{			
			m_AmplitudeTimeGraph.length = 0;
			
			var i:uint;
			var frequencyPartition:uint;
			var linearValue:Number;
			var ratio:Number;
			var easeValue:Number;
			
			if (m_FadeInDuration != 0)
			{
				frequencyPartition = Math.round(m_FadeInDuration / m_FrequencyDuration);

				for (i = 1; i <= frequencyPartition; i++)
				{
					linearValue = i * m_MaxAmplitude / frequencyPartition;
					
					if (m_EaseFadeIn)
					{
						ratio = 1.0 / m_MaxAmplitude * linearValue;
						easeValue = m_MaxAmplitude * ratio * ratio * ratio;
						
						m_AmplitudeTimeGraph.push(easeValue);						
					}
					else
					{
						m_AmplitudeTimeGraph.push(linearValue);
					}
				}
			}
			
			if (m_MaxAmplitudeDuration != 0)
			{
				frequencyPartition = Math.round(m_MaxAmplitudeDuration / m_FrequencyDuration);

				for (i = 0; i < frequencyPartition; i++)
				{
					m_AmplitudeTimeGraph.push(m_MaxAmplitude);
				}
			}
			
			if (m_FadeOutDuration != 0)
			{
				frequencyPartition = Math.round(m_FadeOutDuration / m_FrequencyDuration);

				for (i = 0; i < frequencyPartition; i++)
				{
					linearValue = m_MaxAmplitude - (m_MaxAmplitude / frequencyPartition * i);
					
					if (m_EaseFadeOut)
					{
						ratio = 1.0 / m_MaxAmplitude * linearValue;
						easeValue = m_MaxAmplitude * ratio * ratio * ratio;
						
						m_AmplitudeTimeGraph.push(easeValue);						
					}
					else
					{
						m_AmplitudeTimeGraph.push(linearValue);
					}
				}
			}
			
			m_AmplitudeTimeGraph.push(0);

			if (replay && m_IsPlaying)
			{
				animateShake();
			}
		}
		
		//Play
		public function play():void
		{
			if (m_IsPaused)
			{
				juggler.add(m_ShakeTween);
			}
			else
			{
				animateShake();				
			}
			
			m_IsPlaying = true;
			m_IsPaused = false;
		}
		
		//Stop
		public function stop(pause:Boolean = false):void
		{
			juggler.remove(m_ShakeTween);
			
			if (pause)
			{	
				m_IsPaused = true;
			}
			else
			{
				x = 0;
				y = 0;
				
				m_IsPaused = false;
			}
			
			m_IsPlaying = false;
		}

		
		//Animate Shake
		private function animateShake(amplitudeTimeGraphIndex:uint = 0):void
		{
			m_ShakeTween.reset(this, m_FrequencyDuration, Transitions.LINEAR);
			m_ShakeTween.animate("x", 0 + m_AmplitudeTimeGraph[amplitudeTimeGraphIndex] * randomAxisDirection);
			m_ShakeTween.animate("y", 0 + m_AmplitudeTimeGraph[amplitudeTimeGraphIndex] * randomAxisDirection);
			m_ShakeTween.onComplete = (amplitudeTimeGraphIndex + 1 < m_AmplitudeTimeGraph.length) ? animateShake : animateShakeComplete;
			m_ShakeTween.onCompleteArgs = (amplitudeTimeGraphIndex + 1 < m_AmplitudeTimeGraph.length) ? [++amplitudeTimeGraphIndex] : null;

			juggler.add(m_ShakeTween);
		}
		
		//Animate Shake Complete
		private function animateShakeComplete():void
		{
			stop();
			
			dispatchEventWith(Event.COMPLETE);
		}

		//Get Random Axis Direction
		private function get randomAxisDirection():Number
		{
			return Math.random() * 2.0 - 1.0;
		}

		//Set Max Amplitude
		public function set maxAmplitude(value:uint):void
		{
			m_MaxAmplitude = Math.max(1, value);
			
			if (m_IsInstantiated) updateAmplitudeTimeGraph(false);
		}
		
		//Get Max Amplitude
		public function get maxAmplitude():uint
		{
			return m_MaxAmplitude;
		}
		
		//Set Fade In Duration
		public function set fadeInDuration(value:uint):void
		{
			m_FadeInDuration = value;
			
			if (m_IsInstantiated) updateAmplitudeTimeGraph();
		}
		
		//Get Fade In Duration
		public function get fadeInDuration():uint
		{
			return m_FadeInDuration;
		}
		
		//Set Max Amplitude Duration
		public function set maxAmplitudeDuration(value:uint):void
		{
			m_MaxAmplitudeDuration = value;
			
			if (m_IsInstantiated) updateAmplitudeTimeGraph();
		}
		
		//Get Max Amplitude Duration
		public function get maxAmplitudeDuration():uint
		{
			return m_MaxAmplitudeDuration;
		}
		
		//Set Fade Out Duration
		public function set fadeOutDuration(value:uint):void
		{
			m_FadeOutDuration = value;
			
			if (m_IsInstantiated) updateAmplitudeTimeGraph();
		}
		
		//Get Fade Out Duration
		public function get fadeOutDuration():uint
		{
			return m_FadeOutDuration;
		}
		
		//Set Frequency Duration
		public function set frequencyDuration(value:Number):void
		{
			m_FrequencyDuration = Math.min(0.1, Math.max(value, 0.01));
			
			if (m_IsInstantiated) updateAmplitudeTimeGraph();
		}
		
		//Get Frequency Duration
		public function get frequencyDuration():Number
		{
			return m_FrequencyDuration;
		}
		
		//Set Ease Fade In
		public function set easeFadeIn(value:Boolean):void
		{
			m_EaseFadeIn = value;
			
			if (m_IsInstantiated) updateAmplitudeTimeGraph();
		}
		
		//Get Ease Fade In
		public function get easeFadeIn():Boolean
		{
			return m_EaseFadeIn;
		}
		
		//Set Ease Fade Out
		public function set easeFadeOut(value:Boolean):void
		{
			m_EaseFadeOut = value;
			
			if (m_IsInstantiated) updateAmplitudeTimeGraph();
		}
		
		//Get Ease Fade Out
		public function get easeFadeOut():Boolean
		{
			return m_EaseFadeOut;
		}
		
		//Get Is Playing
		public function get isPlaying():Boolean
		{
			return m_IsPlaying;
		}
		
		//Get Is Paused
		public function get isPaused():Boolean
		{
			return m_IsPaused;
		}
		
		//Dispose
		override public function dispose():void
		{
			stop();
			
			juggler = null;
			m_ShakeTween = null;
			m_AmplitudeTimeGraph = null;
			
			super.dispose();
		}
	}
}