package nemostein.tools.pathfactory.segments.nodes;

import flash.display.Sprite;
import nemostein.tools.pathfactory.PathService;

class Node extends Sprite
{
	public var id:Int;
	
	private function draw(color:UInt, radius:Float):Void 
	{
		graphics.lineStyle(0, 0);
		graphics.beginFill(color);
		graphics.drawCircle(0, 0, radius);
		graphics.endFill();
	}
	
	public function destroy():Void
	{
		PathService.removeNode(this);
	}
}