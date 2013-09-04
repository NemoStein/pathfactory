package nemostein.tools.pathfactory
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import nemostein.tools.pathfactory.filesystem.BackgroundData;
	import nemostein.tools.pathfactory.PathFactory;
	import nemostein.tools.pathfactory.segments.nodes.EndPoint;
	import nemostein.tools.pathfactory.segments.nodes.Node;
	import nemostein.tools.pathfactory.segments.Segment;
	import sourbit.library.bezier.QuadBezierSegment;
	import sourbit.library.color.Color;
	
	public class PathService
	{
		static public var backgroundPath:String;
		static public var nodes:Vector.<Node>;
		static public var segments:Vector.<Segment>;
		
		static public var factory:PathFactory;
		static public var container:Sprite;
		static public var ui:UI;
		static public var nodeContainer:Sprite;
		static public var guideContainer:Sprite;
		static public var backgroundContainer:Sprite;
		
		static private var resultPoint:Point;
		static private var drawGuides:Boolean;
		static private var drawPaths:Boolean;
		
		static public function setup(factory:PathFactory, container:Sprite, ui:UI):void
		{
			resultPoint = new Point();
			
			drawGuides = true;
			drawPaths = true;
			
			backgroundPath = "";
			PathService.factory = factory;
			PathService.container = container;
			PathService.ui = ui;
			
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
			
			nodes = new Vector.<Node>();
			segments = new Vector.<Segment>();
		}
		
		static public function createEndPoint(x:Number, y:Number):EndPoint
		{
			var endPoint:EndPoint = new EndPoint();
			
			endPoint.x = x;
			endPoint.y = y;
			
			addNode(endPoint);
			
			return endPoint;
		}
		
		static public function createSegment(startNode:EndPoint, endNode:EndPoint, anchorPoint:Point = null):void
		{
			var segment:Segment = new Segment(startNode, endNode, anchorPoint);
			
			addSegment(segment);
		}
		
		static public function addNode(node:Node):void
		{
			nodes.push(node);
			nodeContainer.addChild(node);
		}
		
		static public function removeNode(node:Node):void
		{
			var segmentsCopy:Vector.<Segment> = segments.concat();
			
			for each (var segment:Segment in segmentsCopy)
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
			
			nodes.splice(nodes.indexOf(node), 1);
			nodeContainer.removeChild(node);
		}
		
		static public function addSegment(segment:Segment):void
		{
			segments.push(segment);
		}
		
		static private function removeSegment(segment:Segment):void
		{
			segments.splice(segments.indexOf(segment), 1);
		}
		
		static public function addBackground(backgroundData:BackgroundData):void
		{
			backgroundPath = backgroundData.path;
			backgroundContainer.addChild(backgroundData.bitmap);
		}
		
		static public function draw():void
		{
			var graphics:Graphics = guideContainer.graphics;
			var color1:Color = new Color();
			var color2:Color = new Color();
			var color3:Color = new Color();
			var color4:Color = new Color();
			
			graphics.clear();
			
			if (drawGuides || drawPaths)
			{
				for each (var segment:Segment in segments)
				{
					var bezierSegment:QuadBezierSegment = segment.bezierSegment;
					
					var start:Point = bezierSegment.a;
					var end:Point = bezierSegment.b;
					var anchor:Point = bezierSegment.c;
					
					if (drawPaths)
					{
						color1.argb = 0xff004400;
						color2.argb = 0xff88ff88;
						
						graphics.moveTo(start.x, start.y);
						
						var i:Number = 0;
						while ((i += 0.1) <= 1)
						{
							graphics.lineStyle(6, Color.blend(color1, color2, i, color4).argb);
							bezierSegment.interpolate(i, resultPoint);
							graphics.lineTo(resultPoint.x, resultPoint.y);
						}
					}
					
					var distanceAB:Number = Point.distance(start, anchor);
					var distanceBC:Number = Point.distance(anchor, end);
					var ratioAB:Number = distanceAB / (distanceAB + distanceBC) * 2;
					var ratioBC:Number = 2 - ratioAB;
					
					segment.anchor.tesion = ratioAB - 1;
					
					if (drawGuides)
					{
						color1.argb = 0xffff0000;
						color2.argb = 0xffffffff;
						color3.argb = 0xff0000ff;
						
						var blendA:uint;
						var blendB:uint;
						
						if (ratioAB < 1)
						{
							blendA = Color.blend(color1, color2, ratioAB * 15 - 14, color4).argb;
							blendB = Color.blend(color2, color3, (ratioBC - 1) * 15, color4).argb;
						}
						else
						{
							blendA = Color.blend(color2, color3, (ratioAB - 1) * 15, color4).argb;
							blendB = Color.blend(color1, color2, ratioBC * 15 - 14, color4).argb;
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
		
		static public function toggleBackground():void
		{
			backgroundContainer.visible = !backgroundContainer.visible;
			ui.showBackgroundCheckBox.selected = backgroundContainer.visible;
		}
		
		static public function toggleGuides():void
		{
			drawGuides = !drawGuides;
			ui.showGuidesCheckBox.selected = drawGuides;
		}
		
		static public function toggleNodes():void
		{
			nodeContainer.visible = !nodeContainer.visible;
			ui.showNodesCheckBox.selected = nodeContainer.visible;
		}
		
		static public function togglePaths():void
		{
			drawPaths = !drawPaths;
			ui.showPathsCheckBox.selected = drawPaths;
		}
	}
}