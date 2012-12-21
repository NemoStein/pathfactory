package nemostein.tools.pathfactory.filesystem;

import flash.events.Event;
import flash.filesystem.File;
import flash.geom.Point;
import flash.net.FileFilter;
import nemostein.tools.pathfactory.PathService;
import nemostein.tools.pathfactory.segments.nodes.Anchor;
import nemostein.tools.pathfactory.segments.nodes.EndPoint;
import nemostein.tools.pathfactory.segments.nodes.Node;

class FileLoader
{
	private var file:File;
	
	public function new() 
	{
		
	}
	
	public function startLoading() 
	{
		file = new File();
		
		file.addEventListener(Event.SELECT, onFileSelect);
		file.addEventListener(Event.COMPLETE, onFileComplete);
		file.browse([new FileFilter("Paths File (*.paf)", "*.paf"), new FileFilter("Any file", "*.*")]);
	}
	
	private function onFileSelect(event:Event):Void 
	{
		file.load();
	}
	
	private function onFileComplete(event:Event):Void 
	{
		var pathsXML:Xml = Xml.parse(file.data.readMultiByte(file.data.bytesAvailable, "utf-8")).firstChild();
		
		var backgroundXML:Xml = pathsXML.elementsNamed("background").next();
		var nodesXML:Xml = pathsXML.elementsNamed("nodes").next();
		var segmentsXML:Xml = pathsXML.elementsNamed("segments").next();
		
		var backgroundPath:String = backgroundXML.get("path");
		var backgroundLoader:BackgroundLoader = new BackgroundLoader(PathService.addBackground, null, backgroundPath);
		backgroundLoader.startLoading();
		
		var nodes:Array<Node> = new Array<Node>();
		
		for (nodeXML in nodesXML) 
		{
			var node:Node;
			
			var id:Int = Std.parseInt(nodeXML.get("id"));
			var x:Int = Std.parseInt(nodeXML.get("x"));
			var y:Int = Std.parseInt(nodeXML.get("y"));
			var anchor:Bool = (nodeXML.get("anchor") == "true");
			
			if(anchor)
			{
				node = new Anchor();
				node.x = x;
				node.y = y;
			}
			else
			{
				node = PathService.createEndPoint(x, y);
			}
			
			node.id = id;
			nodes.push(node);
		}
		
		for (segmentXML in segmentsXML) 
		{
			var start:Node = findNode(Std.parseInt(segmentXML.get("a")), nodes);
			var end:Node = findNode(Std.parseInt(segmentXML.get("b")), nodes);
			var anchor:Node = findNode(Std.parseInt(segmentXML.get("c")), nodes);
			
			var anchorPoint:Point = new Point(anchor.x, anchor.y);
			
			PathService.createSegment(cast(start, EndPoint), cast(end, EndPoint), anchorPoint);
		}
	}
	
	private function findNode(id:Int, nodes:Array<Node>):Node
	{
		for (node in nodes) 
		{
			if (node.id == id)
			{
				return node;
			}
		}
		
		return null;
	}
}