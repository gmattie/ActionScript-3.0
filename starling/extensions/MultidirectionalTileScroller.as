package starling.extensions
{
	//Imports
	import flash.geom.Point;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.textures.Texture;

	//Class
	public class MultidirectionalTileScroller extends DisplayObjectContainer
	{
		//Properties
		private var m_Canvas:Sprite;
		private var m_Width:uint;
		private var m_Height:uint;
		private var m_PivotPoint:Point;
		
		private var m_Texture:Texture;
		private var m_TextureScaleX:Number;
		private var m_TextureScaleY:Number;
		private var m_TextureWidth:Number;
		private var m_TextureHeight:Number;

		private var m_IsAnimating:Boolean;
		private var m_Speed:Number;
		private var m_Angle:Number;
		
		//Constructor
		public function MultidirectionalTileScroller(width:uint, height:uint, texture:Texture, textureScaleX:Number = 1.0, textureScaleY:Number = 1.0)
		{
			m_Width = width;
			m_Height = height;
			m_Texture = texture;
			m_TextureScaleX = textureScaleX;
			m_TextureScaleY = textureScaleY;
			
			touchable = false;
			
			init();
		}
		
		//Init
		private function init():void
		{
			m_Canvas = new Sprite();
			
			for (var columns:uint = 0; columns <= Math.ceil(m_Width / (m_Texture.nativeWidth * m_TextureScaleX)) + 1; columns++)
			{
				for (var rows:uint = 0; rows <= Math.ceil(m_Height / (m_Texture.nativeHeight * m_TextureScaleY)) + 1; rows++)
				{
					var image:Image = new Image(m_Texture);
					image.scaleX = m_TextureScaleX;
					image.scaleY = m_TextureScaleY;
					image.x = m_Texture.nativeWidth * m_TextureScaleX * columns;
					image.y = m_Texture.nativeHeight * m_TextureScaleY * rows;
			
					m_Canvas.addChild(image);
				}
			}
			
			m_TextureWidth = m_Texture.nativeWidth * m_TextureScaleX;
			m_TextureHeight = m_Texture.nativeHeight * m_TextureScaleY;
			
			m_PivotPoint = new Point(m_Width / 2, m_Height / 2);
			
			m_Canvas.x = m_PivotPoint.x;
			m_Canvas.y = m_PivotPoint.y;
			m_Canvas.alignPivot();
			m_Canvas.flatten();
			
			addChild(m_Canvas);
		}
		
		//Start
		public function start(speed:Number = NaN, angle:Number = NaN):void
		{
			this.speed = (isNaN(speed)) ? this.speed : speed;
			this.angle = (isNaN(speed)) ? this.angle : angle;
			
			m_IsAnimating = true;
			
			m_Canvas.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameEventHandler);
		}
		
		//Stop
		public function stop():void
		{
			m_IsAnimating = false;
			
			if (m_Canvas.hasEventListener(EnterFrameEvent.ENTER_FRAME))
			{
				m_Canvas.removeEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameEventHandler);
			}
		}
		
		//Enter Frame Event Handler
		private function enterFrameEventHandler(event:EnterFrameEvent):void
		{
			m_Canvas.x += Math.cos(m_Angle) * m_Speed;
			m_Canvas.y += Math.sin(m_Angle) * m_Speed;
			
			if (m_Canvas.x < m_PivotPoint.x - m_TextureWidth)
			{
				m_Canvas.x += m_TextureWidth;
			}
			
			if (m_Canvas.x > m_PivotPoint.x + m_TextureWidth)
			{
				m_Canvas.x -= m_TextureWidth;
			}
			
			if (m_Canvas.y < m_PivotPoint.y - m_TextureHeight)
			{
				m_Canvas.y += m_TextureHeight;
			}
			
			if (m_Canvas.y > m_PivotPoint.y + m_TextureHeight)
			{
				m_Canvas.y -= m_TextureHeight;
			}
		}
		
		//Dispose
		override public function dispose():void
		{
			stop();
			
			m_Texture.dispose();
			
			super.dispose();
		}

		//Get isAnimating
		public function get isAnimating():Boolean
		{
			return m_IsAnimating;
		}
		
		//Set Speed
		public function set speed(value:Number):void
		{
			m_Speed = (isNaN(value) || value <= 0.0) ? 0.0 : Math.min(value, Math.min(m_TextureWidth, m_TextureHeight));
		}
		
		//Get Speed
		public function get speed():Number
		{
			return m_Speed;
		}
		
		//Set Angle
		public function set angle(value:Number):void
		{
			m_Angle = (isNaN(value) ? 180 : 180 - value) * Math.PI / 180;
		}

		//Get Angle
		public function get angle():Number
		{
			return 180 - m_Angle * 180 / Math.PI;
		}
	}
}