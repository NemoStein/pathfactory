package nemostein.tools.pathfactory.filesystem
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import nemostein.tools.pathfactory.PathService;
	import nemostein.tools.pathfactory.segments.nodes.Anchor;
	import nemostein.tools.pathfactory.segments.nodes.Node;
	import nemostein.tools.pathfactory.segments.Segment;
	
	public class FileSaver
	{
		private var file:File;
		private var nodes:Vector.<Node>;
		private var segments:Vector.<Segment>;
		
		public function FileSaver()
		{
			nodes = PathService.nodes;
			segments = PathService.segments;
		}
		
		public function startSaving():void
		{
			file = new File();
			
			var dataToSave:ByteArray = new ByteArray();
			var serialized:String = serializePaths();
			
			dataToSave.writeMultiByte(serialized, "utf-8");
			file.save(dataToSave, "paths.xml");
		}
		
		private function serializePaths():String
		{
			var backgroundXML:XML = <background/>;
			var nodesXML:XML = <nodes/>;
			var segmentsXML:XML = <segments/>;
			
			backgroundXML.@path = PathService.backgroundPath;
			
			var id:int = 0;
			for each (var node:Node in nodes)
			{
				node.id = id++;
				
				var nodeXML:XML = <node/>;
				nodeXML.@id = node.id;
				nodeXML.@x = node.x;
				nodeXML.@y = node.y;
				nodeXML.@anchor = node is Anchor;
				
				nodesXML.appendChild(nodeXML);
			}
			
			for each (var segment:Segment in segments)
			{
				var segmentXML:XML = <segment/>;
				segmentXML.@a = segment.start.id;
				segmentXML.@b = segment.end.id;
				segmentXML.@c = segment.anchor.id;
				
				segmentsXML.appendChild(segmentXML);
			}
			
			var xml:XML = <paths/>;
			
			xml.appendChild(backgroundXML);
			xml.appendChild(nodesXML);
			xml.appendChild(segmentsXML);
			
			return xml.toString();
		}
	}
}