package nemostein.tools.pathfactory
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Node extends Sprite
	{
		private var _head:Segment;
		private var _tail:Segment;
		private var _anchor:Segment;
		
		private var _headMark:Shape;
		private var _tailMark:Shape;
		
		public function Node(anchor:Segment = null)
		{
			_anchor = anchor;
			
			initialize();
		}
		
		private function initialize():void
		{
			_headMark = new Shape();
			_tailMark = new Shape();
			
			_headMark.graphics.beginFill(0xffff00);
			_tailMark.graphics.beginFill(0xffff00);
			
			_headMark.graphics.drawCircle(0, 0, 1.5);
			_tailMark.graphics.drawCircle(0, 0, 1.5);
			
			_headMark.graphics.endFill();
			_tailMark.graphics.endFill();
			
			_headMark.x = 4;
			_tailMark.x = -4;
			
			_headMark.y = -4;
			_tailMark.y = -4;
			
			_headMark.visible = false;
			_tailMark.visible = false;
			
			addChild(_headMark);
			addChild(_tailMark);
			
			graphics.lineStyle(0, 0);
			
			if (_anchor)
			{
				graphics.beginFill(0xaa00aa);
				graphics.drawCircle(0, 0, 2);
			}
			else
			{
				graphics.beginFill(0xaa0000);
				graphics.drawCircle(0, 0, 3);
			}
			
			graphics.endFill();
		}
		
		public function get head():Segment 
		{
			return _head;
		}
		
		public function set head(value:Segment):void 
		{
			_head = value;
			
			if(value)
			{
				_headMark.visible = true;
			}
			else
			{
				_headMark.visible = false;
			}
		}
		
		public function get tail():Segment 
		{
			return _tail;
		}
		
		public function set tail(value:Segment):void 
		{
			_tail = value;
			
			if(value)
			{
				_tailMark.visible = true;
			}
			else
			{
				_tailMark.visible = false;
			}
		}
		
		public function get anchor():Segment 
		{
			return _anchor;
		}
	}
}