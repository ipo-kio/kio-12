package ru.ipo.kio._12.kran.model
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import ru.ipo.kio._12.kran.graphics.KranGraphic;
	/**
	 * ...
	 * @author Eddiw
	 */
	public class Kran
	{
		
		private var Graphic:KranGraphic;
		
		private var position:uint;
		
		private var height:uint; //насколько опущен
		
		private var closed:Boolean;
		
		private var verticalLock:Boolean // нужен для предотвращения опускания 2 раза подряд
		
		private var cube:Cube;
		
		public function Kran() 
		{
				super();
				Graphic = new KranGraphic();
				Graphic.x = 0;
				Graphic.y = 0;
				position = 0;
				closed = true;
				verticalLock = false;
				cube = null;
		}
		
		public function addToStage(stage:Stage):void
		{
				stage.addChild(this.Graphic);
		}
		
		public function moveLeft():void
		{	
			-- position;
			Graphic.moveLeft();
			if (cube != null)
				cube.moveLeft();
		}
		public function moveRight():void
		{ 
			++ position; 
			Graphic.moveRight();
			if (cube != null)
				cube.moveRight();
		}
		
		public function reset():void
		{
			position = 0;
			verticalLock = false;
			if (!isClosed())
				close();
			if (hasCube())
				this.cube.clear();
			this.cube = null;
			this.Graphic.reset();
		}
		
		public function moveDown(howMuch:int):void 
		{
			if (!verticalLock)
				Graphic.moveDown(howMuch);
			if (cube != null)
				cube.moveDown(howMuch);
			verticalLock = true;
		}
		
		public function moveUp():void
		{
			if (verticalLock)
				Graphic.moveUp();
			if (cube != null)
				cube.moveUp();
			verticalLock = false;
		}
		public function close():void
		{
			if  (closed == false)
			{
				closed = true;
				this.Graphic.Rightfoot.rotation += 30;
				this.Graphic.rotateAroundPoint(Graphic.Leftfoot, -20 , Graphic.leftAxizPoint);
			}
		}
		
		public function release():void
		{
			if (this.cube != null && !this.isDown())
				throw "Can't release at top";
			if (closed == true)
			{
				closed = false;
				this.Graphic.Rightfoot.rotation -= 30;
				this.Graphic.rotateAroundPoint(Graphic.Leftfoot, 20 , Graphic.leftAxizPoint);
				cube = null;	
			}
		}
		
		public function get Position():uint
		{
			return this.position;
		}
		
		public function getCube():Cube
		{
			return this.cube;
		}
		
		public function setCube(cube:Cube):void
		{
			this.cube = cube;
		}
		
		public function isClosed():Boolean
		{
			return closed;
		}
		
		public function hasCube():Boolean
		{
			return (cube == null) ? false : true;
		}
		
		public function isDown():Boolean
		{
			return verticalLock ? true : false;
		}
	}
}