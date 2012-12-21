package nemostein.tools.pathfactory;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import nemostein.bezier.QuadBezierSegment;
import nemostein.color.Color;
import nemostein.tools.pathfactory.filesystem.BackgroundLoader;
import nemostein.tools.pathfactory.filesystem.BackgroundLoader.BackgroundData;
import nemostein.tools.pathfactory.PathFactory;
import nemostein.tools.pathfactory.segments.nodes.EndPoint;
import nemostein.tools.pathfactory.segments.nodes.Node;
import nemostein.tools.pathfactory.segments.Segment;

class PathService
{
	static public var backgroundPath:String;
	static public var nodes:Array<Node>;
	static public var segments:Array<Segment>;
	
	static public var factory:PathFactory;
	static public var container:Sprite;
	static public var nodeContainer:Sprite;
	static public var guideContainer:Sprite;
	static public var backgroundContainer:Sprite;
	
	static private var resultPoint:Point;
	static private var drawGuides:Bool;
	static private var drawPaths:Bool;
	
	static public function setup(factory:PathFactory, container:Sprite):Void
	{
		resultPoint = new Point();
		
		drawGuides = true;
		drawPaths = true;
		
		backgroundPath = "";
		PathService.container = container;
		PathService.factory = factory;
		
		nodeContainer = new Sprite();
		guideContainer = new Sprite();
		backgroundContainer = new Sprite();
		
		container.mouseEnabled = false;
		nodeContainer.mouseEnabled = false;
		guideContainer.mouseEnabled = false;
		backgroundContainer.mouseEnabled = false;
		
		guideContainer.mouseChildren = false;
		backgroundContainer.mouseChildren = false;
		
		container.addChild(backgroundContainer);
		container.addChild(guideContainer);
		container.addChild(nodeContainer);
		
		nodes = new Array<Node>();
		segments = new Array<Segment>();
	}
	
	static public function createEndPoint(x:Float, y:Float):EndPoint
	{
		var endPoint:EndPoint = new EndPoint();
		
		endPoint.x = x;
		endPoint.y = y;
		
		addNode(endPoint);
		
		return endPoint;
	}
	
	static public function createSegment(startNode:EndPoint, endNode:EndPoint, ?anchorPoint:Point):Void
	{
		var segment:Segment = new Segment(startNode, endNode, anchorPoint);
		
		addSegment(segment);
	}
	
	static public function addNode(node:Node):Void
	{
		nodes.push(node);
		nodeContainer.addChild(node);
	}
	
	static public function removeNode(node:Node):Void
	{
		var segmentsCopy:Array<Segment> = segments.copy();
		
		for (segment in segmentsCopy) 
		{
			if (node == segment.anchor)
			{
				removeSegment(segment);
			}
			else if (node == segment.start || node == segment.end)
			{
				removeNode(segment.anchor);
			}
		}
		
		nodes.remove(node);
		nodeContainer.removeChild(node);
	}
	
	static public function addSegment(segment:Segment):Void
	{
		segments.push(segment);
	}
	
	static private function removeSegment(segment:Segment):Void
	{
		segments.remove(segment);
	}
	
	static public function addBackground(backgroundData:BackgroundData):Void
	{
		backgroundPath = backgroundData.path;
		backgroundContainer.addChild(backgroundData.bitmap);
	}
	
	static public function draw():Void
	{
		var graphics:Graphics = guideContainer.graphics;
		
		graphics.clear();
		
		if(drawGuides || drawPaths)
		{
			for (segment in segments)
			{
				var bezierSegment:QuadBezierSegment = segment.bezierSegment;
				
				var start:Point = bezierSegment.a;
				var end:Point = bezierSegment.b;
				var anchor:Point = bezierSegment.c;
				
				if (drawPaths)
				{
					var colorArcA:Color = new Color(0x004400);
					var colorArcB:Color = new Color(0x88ff88);
					
					graphics.moveTo(start.x, start.y);
					
					var i:Float = 0;
					while ((i += 0.1) <= 1) 
					{
						graphics.lineStyle(6, Color.blend(colorArcA, colorArcB, i).argb);
						bezierSegment.interpolate(i, resultPoint);
						graphics.lineTo(resultPoint.x, resultPoint.y);
					}
				}
				
				if (drawGuides)
				{
					var colorTensionA:Color = new Color(0xff0000);
					var colorTensionB:Color = new Color(0xffffff);
					var colorTensionC:Color = new Color(0x0000ff);
					
					var distanceAB:Float = Point.distance(start, anchor);
					var distanceBC:Float = Point.distance(anchor, end);
					var ratioAB:Float = distanceAB / (distanceAB + distanceBC) * 2;
					var ratioBC:Float = 2 - ratioAB;
					
					var blendA:UInt;
					var blendB:UInt;
					
					if (ratioAB < 1)
					{
						blendA = Color.blend(colorTensionA, colorTensionB, ratioAB * 15 - 14).argb;
						blendB = Color.blend(colorTensionB, colorTensionC, (ratioBC - 1) * 15).argb;
					}
					else
					{
						blendA = Color.blend(colorTensionB, colorTensionC, (ratioAB - 1) * 15).argb;
						blendB = Color.blend(colorTensionA, colorTensionB, ratioBC * 15 - 14).argb;
					}
					
					graphics.lineStyle(2, blendA, 1, true);
					graphics.moveTo(start.x, start.y);
					graphics.lineTo(anchor.x, anchor.y);
					
					graphics.lineStyle(2, blendB, 1, true);
					graphics.moveTo(anchor.x, anchor.y);
					graphics.lineTo(end.x, end.y);
				}
			}
			
			graphics.endFill();
		}
		
		if (factory.creatingSegment != null)
		{
			graphics.lineStyle(2, 0x44aaff);
			graphics.moveTo(factory.creatingSegment.x, factory.creatingSegment.y);
			graphics.lineTo(factory.oldMouse.x - container.x, factory.oldMouse.y - container.y);
			graphics.endFill();
		}
	}
	
	static public function toggleBackground():Void
	{
		backgroundContainer.visible = !backgroundContainer.visible;
	}
	
	static public function toggleGuides():Void
	{
		drawGuides = !drawGuides;
	}
	
	static public function toggleNodes():Void
	{
		nodeContainer.visible = !nodeContainer.visible;
	}
	
	static public function togglePaths():Void
	{
		drawPaths = !drawPaths;
	}
	
	private function new() { }
}