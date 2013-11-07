package starling.extensions
{
	//Imports
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	//Class
	public class Vignette extends DisplayObjectContainer
	{
		//Properties
		private var m_Width:Number;
		private var m_Height:Number;
		private var m_Amount:Number;
		private var m_Strength:uint;
		private var m_Color:uint;

		private var m_VignetteShape:Shape;
		private var m_VignetteShapeBlurFilter:BlurFilter;
		private var m_VignetteBitmapData:BitmapData;
		private var m_VignetteTexture:Texture;
		private var m_Vignette:Sprite;
		
		private var m_IsInstantiated:Boolean;
		
		//Constructor
		public function Vignette(width:Number, height:Number, amount:Number = 0.25, strength:uint = 7, color:uint = 0x000000)
		{
			this.width = width;
			this.height = height;
			this.amount = amount;
			this.strength = strength;
			this.color = color;
			
			init();
		}

		//Init
		private function init():void
		{
			touchable = false;
			m_IsInstantiated = true;
			
			m_VignetteShape = new Shape();
			m_VignetteShapeBlurFilter = new BlurFilter();
			m_Vignette = new Sprite();
			
			draw();
		}
		
		//Draw
		private function draw():void
		{
			var vignetteAmount:Number = Math.min(m_Width, m_Height) / 2 * m_Amount;
			
			m_VignetteShape.filters = [];
			m_VignetteShape.graphics.clear();
			m_VignetteShape.graphics.beginFill(m_Color, 1.0);
			m_VignetteShape.graphics.drawRect(-m_Width / 2, -m_Height / 2, m_Width * 2, m_Height * 2);
			m_VignetteShape.graphics.drawEllipse(vignetteAmount, vignetteAmount, m_Width - vignetteAmount * 2, m_Height - vignetteAmount * 2);
			m_VignetteShape.graphics.endFill();
			
			var vignetteStrength:uint = Math.pow(2, m_Strength);
			
			m_VignetteShapeBlurFilter.blurX = vignetteStrength;
			m_VignetteShapeBlurFilter.blurY = vignetteStrength;
			m_VignetteShapeBlurFilter.quality = 3;
			
			m_VignetteShape.filters = [m_VignetteShapeBlurFilter];
			
			m_VignetteBitmapData = new BitmapData(m_Width / 2, m_Height / 2, true, 0x000000);
			m_VignetteBitmapData.drawWithQuality(m_VignetteShape);
			
			m_VignetteTexture = Texture.fromBitmapData(m_VignetteBitmapData, false);
			
			if (m_Vignette.numChildren)
			{
				m_Vignette.unflatten();
				
				while (m_Vignette.numChildren > 0)
				{
					m_Vignette.getChildAt(0).dispose();
					m_Vignette.removeChildAt(0);					
				}				
			}
			
			for (var i:uint; i < 4; i++)
			{
				var vignetteCorner:Image = new Image(m_VignetteTexture);
				
				switch (i)
				{
					case 1:		vignetteCorner.scaleX = -1.0;
								vignetteCorner.x = m_Width;
								
								break;
								
					case 2:		vignetteCorner.scaleY = -1.0;
								vignetteCorner.y = m_Height;
								break;
								
					case 3:		vignetteCorner.scaleX = -1.0;
								vignetteCorner.scaleY = -1.0;
								vignetteCorner.x = m_Width;
								vignetteCorner.y = m_Height;
				}
				
				m_Vignette.addChild(vignetteCorner);
			}			

			m_Vignette.flatten();
			
			if (!contains(m_Vignette))
			{
				addChild(m_Vignette);				
			}
		}
		
		//Dispose
		override public function dispose():void
		{
			m_VignetteShapeBlurFilter = null;
			m_VignetteShape = null;
			m_VignetteBitmapData.dispose();
			m_VignetteTexture.dispose();
			
			super.dispose();
		}
		
		//Set Size
		public function setSize(width:Number, height:Number):void
		{
			m_Width = width;
			m_Height = height;
			
			draw();
		}
		
		//Set Width
		override public function set width(value:Number):void
		{
			m_Width = value;
			
			if (m_IsInstantiated) draw();
		}
		
		//Get Width
		override public function get width():Number
		{
			return m_Width;
		}
		
		//Set Height
		override public function set height(value:Number):void
		{
			m_Height = value;
			
			if (m_IsInstantiated) draw();
		}
		
		//Get Height
		override public function get height():Number
		{
			return m_Height;
		}
		
		//Set Amount
		public function set amount(value:Number):void
		{
			m_Amount = Math.max(0.0, Math.min(value, 1.0));
			
			if (m_IsInstantiated) draw();
		}
		
		//Get Amount
		public function get amount():Number
		{
			return m_Amount;
		}
		
		//Set Strength
		public function set strength(value:uint):void
		{
			m_Strength = Math.max(0, Math.min(value, 8));
			
			if (m_IsInstantiated) draw();
		}
		
		//Get Strength
		public function get strength():uint
		{
			return m_Strength;
		}
		
		//Set Color
		public function set color(value:uint):void
		{
			m_Color = value;
			
			if (m_IsInstantiated) draw();
		}
		
		//Get Color
		public function get color():uint
		{
			return m_Color;
		}
	}
}