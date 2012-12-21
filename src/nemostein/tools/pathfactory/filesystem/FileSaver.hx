package nemostein.tools.pathfactory.filesystem;

import flash.filesystem.File;
import flash.utils.ByteArray;
import nemostein.tools.pathfactory.PathService;
import nemostein.tools.pathfactory.segments.nodes.Anchor;
import nemostein.tools.pathfactory.segments.nodes.Node;
import nemostein.tools.pathfactory.segments.Segment;

class FileSaver 
{
	private var file:File;
	private var nodes:Array<Node>;
	private var segments:Array<Segment>;
	
	public function new()
	{
		nodes = PathService.nodes;
		segments = PathService.segments;
	}
	
	public function startSaving() 
	{
		file = new File();
		
		var dataToSave:ByteArray = new ByteArray();
		var serialized:String = serializePaths();
		
		dataToSave.writeMultiByte(serialized, "utf-8");
		file.save(dataToSave, "paths.paf");
	}
	
	private function serializePaths():String
	{
		var backgroundXML:Xml = Xml.createElement("background");
		var nodesXML:Xml = Xml.createElement("nodes");
		var segmentsXML:Xml = Xml.createElement("segments");
		
		backgroundXML.set("path", PathService.backgroundPath);
		
		var id:Int = 0;
		for (node in nodes) 
		{
			node.id = id++;
			
			var nodeXML:Xml = Xml.createElement("node");
			nodeXML.set("id", Std.string(node.id));
			nodeXML.set("x", Std.string(node.x));
			nodeXML.set("y", Std.string(node.y));
			nodeXML.set("anchor", Std.string(Std.is(node, Anchor)));
			
			nodesXML.addChild(nodeXML);
		}
		
		for (segment in segments) 
		{
			var segmentXML:Xml = Xml.createElement("segment");
			segmentXML.set("a", Std.string(segment.start.id));
			segmentXML.set("b", Std.string(segment.end.id));
			segmentXML.set("c", Std.string(segment.anchor.id));
			
			segmentsXML.addChild(segmentXML);
		}
		
		var xml:Xml = Xml.createElement("paths");
		
		xml.addChild(backgroundXML);
		xml.addChild(nodesXML);
		xml.addChild(segmentsXML);
		
		return xml.toString();
	}
}