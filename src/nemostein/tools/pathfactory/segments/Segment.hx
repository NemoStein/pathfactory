package nemostein.tools.pathfactory.segments;

import flash.geom.Point;
import nemostein.bezier.QuadBezierSegment;
import nemostein.tools.pathfactory.PathService;
import nemostein.tools.pathfactory.segments.nodes.Anchor;
import nemostein.tools.pathfactory.segments.nodes.EndPoint;

class Segment 
{
	public var start:EndPoint;
	public var end:EndPoint;
	public var anchor:Anchor;
	public var bezierSegment(getBezierSegment, never):QuadBezierSegment;
	
	public function new(start:EndPoint, end:EndPoint, ?anchorPoint:Point)
	{
		this.start = start;
		this.end = end;
		
		anchor = new Anchor();
		
		if (anchorPoint != null)
		{
			anchor.x = anchorPoint.x;
			anchor.y = anchorPoint.y;
		}
		else
		{
			anchor.x = start.x + (end.x - start.x) / 2;
			anchor.y = start.y + (end.y - start.y) / 2;
		}
		
		PathService.addNode(anchor);
	}
	
	private function getBezierSegment():QuadBezierSegment
	{
		return new QuadBezierSegment(start.x, start.y, end.x, end.y, anchor.x, anchor.y);
	}
}