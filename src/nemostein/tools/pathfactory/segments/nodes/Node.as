package nemostein.tools.pathfactory.segments.nodes
{
	import flash.display.Sprite;
	import nemostein.tools.pathfactory.PathService;
	
	public class Node extends Sprite
	{
		public var id:int;
		
		protected function draw(color:uint, radius:Number):void
		{
			graphics.lineStyle(0, 0);
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
		
		public function destroy():void
		{
			PathService.removeNode(this);
		}
	}
}