package nemostein.tools.pathfactory.filesystem
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import nemostein.tools.pathfactory.PathService;
	import nemostein.tools.pathfactory.segments.nodes.Anchor;
	import nemostein.tools.pathfactory.segments.nodes.EndPoint;
	import nemostein.tools.pathfactory.segments.nodes.Node;
	
	public class FileLoader
	{
		private var _file:File;
		private var _onSuccess:Function;
		
		public function FileLoader()
		{
		
		}
		
		public function startLoading(onSuccess:Function):void
		{
			_onSuccess = onSuccess;
			
			_file = new File();
			
			_file.addEventListener(Event.SELECT, onFileSelect);
			_file.addEventListener(Event.COMPLETE, onFileComplete);
			_file.browse([new FileFilter("Paths File (*.xml)", "*.xml"), new FileFilter("Any file", "*.*")]);
		}
		
		private function onFileSelect(event:Event):void
		{
			_file.load();
		}
		
		private function onFileComplete(event:Event):void
		{
			if (_onSuccess != null)
			{
				_onSuccess();
			}
			
			var xmlData:String = _file.data.readMultiByte(_file.data.bytesAvailable, "utf-8");
			var pathsXML:XML = new XML(xmlData);
			
			var backgroundXML:XML = pathsXML.background[0];
			var nodesXML:XML = pathsXML.nodes[0];
			var segmentsXML:XML = pathsXML.segments[0];
			
			var backgroundPath:String = backgroundXML.@path;
			var backgroundLoader:BackgroundLoader = new BackgroundLoader(PathService.addBackground, null, backgroundPath);
			backgroundLoader.startLoading();
			
			var nodes:Vector.<Node> = new Vector.<Node>();
			
			for each (var nodeXML:XML in nodesXML.children())
			{
				var node:Node;
				
				var id:int = parseInt(nodeXML.@id);
				var x:int = parseInt(nodeXML.@x);
				var y:int = parseInt(nodeXML.@y);
				
				if (nodeXML.@anchor == "true")
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
			
			for each (var segmentXML:XML in segmentsXML.children())
			{
				var start:Node = findNode(parseInt(segmentXML.@a), nodes);
				var end:Node = findNode(parseInt(segmentXML.@b), nodes);
				var anchor:Node = findNode(parseInt(segmentXML.@c), nodes);
				
				var anchorPoint:Point = new Point(anchor.x, anchor.y);
				
				PathService.createSegment(EndPoint(start), EndPoint(end), anchorPoint);
			}
		}
		
		private function findNode(id:int, nodes:Vector.<Node>):Node
		{
			for each (var node:Node in nodes)
			{
				if (node.id == id)
				{
					return node;
				}
			}
			
			return null;
		}
	}
}