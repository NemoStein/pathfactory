package nemostein.tools.pathfactory 
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import nemostein.bezier.QuadBezierSegment;

	public class Segment 
	{
		private var _start:Node;
		private var _end:Node;
		private var _anchor:Node;
		private var _anchorPoint:Point;
		
		public function Segment(start:Node, end:Node, anchorPoint:Point = null) 
		{
			_start = start;
			_end = end;
			_anchorPoint = anchorPoint;
			
			initialize();
		}
		
		private function initialize():void 
		{
			var anchor:Node = new Node(this);
			
			if (_anchorPoint)
			{
				anchor.x = _anchorPoint.x;
				anchor.y = _anchorPoint.y;
			}
			else
			{
				var startPoint:Point = new Point(_start.x, _start.y);
				var endPoint:Point = new Point(_end.x, _end.y);
				var anchorPoint:Point = Point.interpolate(startPoint, endPoint, 0.5);
				
				anchor.x = anchorPoint.x;
				anchor.y = anchorPoint.y;
			}
			
			_start.head = this;
			_end.tail = this;
			_anchor = anchor;
		}
		
		public function get start():Node 
		{
			return _start;
		}
		
		public function get end():Node 
		{
			return _end;
		}
		
		public function get anchor():Node 
		{
			return _anchor;
		}
		
		public function draw(graphics:Graphics):void
		{
			var bezier:QuadBezierSegment = new QuadBezierSegment(_start.x, _start.y, _end.x, _end.y, _anchor.x, _anchor.y);
			
			graphics.moveTo(_start.x, _start.y);
			
			for (var i:Number = 0; i < 1; i += 0.1) 
			{
				var vector3d:Array = bezier.interpolateObject(i);
				graphics.lineTo(vector3d[0], vector3d[1]);
			}
			
			graphics.lineTo(_end.x, _end.y);
		}
	}
}