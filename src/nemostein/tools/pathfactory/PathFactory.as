package nemostein.tools.pathfactory
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class PathFactory extends Sprite
	{
		static public const UP:int = 0;
		static public const DOWN:int = 1;
		static public const LEFT:int = 2;
		static public const RIGHT:int = 3;
		static public const SPACE:int = 4;
		
		private var _scrollContainer:ScrollContainer;
		private var _pathLayer:Shape;
		private var _guideLayer:Shape;
		private var _nodesLayer:Sprite;
		private var _selectedNode:Node;
		private var _draggingNode:Node;
		private var _creatingSegment:Node;
		private var _segments:Dictionary;
		private var _file:File;
		private var _keys:Array;
		private var _backgroundPath:String;
		
		public function PathFactory()
		{
			initialize();
		}
		
		private function initialize():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			_keys = [];
			
			newFile(true);
			
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onStageRightMouseDown);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onStageRightMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
		}
		
		private function newFile(ignoreBackground:Boolean = false):void 
		{
			if (!ignoreBackground)
			{
				loadBackground();
			}
			
			_segments = new Dictionary(true);
			
			if(_scrollContainer)
			{
				removeChild(_scrollContainer);
			}
			
			_scrollContainer = new ScrollContainer();
			addChild(_scrollContainer);
			
			_pathLayer = new Shape();
			_scrollContainer.addChild(_pathLayer);
			
			_guideLayer = new Shape();
			_scrollContainer.addChild(_guideLayer);
			
			_nodesLayer = new Sprite();
			_scrollContainer.addChild(_nodesLayer);
		}
		
		private function onNewFileSelect(event:Event):void 
		{
			_backgroundPath = _file.nativePath;
			_file.load();
		}
		
		private function onNewFileComplete(event:Event):void 
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.loadBytes(_file.data);
		}
		
		private function onLoaderComplete(event:Event):void 
		{
			_scrollContainer.addChildAt(LoaderInfo(event.target).content, 0);
		}
		
		private function onStageEnterFrame(event:Event):void
		{
			var mouseX:Number= stage.mouseX;
			var mouseY:Number = stage.mouseY;
			
			for (var i:int = 0; i < _keys.length; ++i) 
			{
				if(_keys[i])
				{
					if(i == UP)
					{
						scrollOffset(0, -5);
					}
					else if (i == DOWN)
					{
						scrollOffset(0, 5);
					}
					else if (i == LEFT)
					{
						scrollOffset(-5, 0);
					}
					else if (i == RIGHT)
					{
						scrollOffset(5, 0);
					}
				}
			}
			
			if (_keys[SPACE])
			{
				scrollOffset((mouseX / (stage.stageWidth / 2) - 1) * 50, (mouseY / (stage.stageHeight / 2) - 1) * 50);
			}
			
			if (_draggingNode)
			{
				_draggingNode.x = mouseX - _scrollContainer.x;
				_draggingNode.y = mouseY - _scrollContainer.y;
			}
			
			_pathLayer.graphics.clear();
			_pathLayer.graphics.lineStyle(2, 0x006600);
			
			for each (var segment:Segment in _segments)
			{
				segment.draw(_pathLayer.graphics);
			}
			
			_pathLayer.graphics.endFill();
			
			_guideLayer.graphics.clear();
			
			if (_creatingSegment)
			{
				_guideLayer.graphics.lineStyle(2, 0x00aa00);
				_guideLayer.graphics.moveTo(_creatingSegment.x, _creatingSegment.y);
				_guideLayer.graphics.lineTo(mouseX - _scrollContainer.x, mouseY - _scrollContainer.y);
				_guideLayer.graphics.endFill();
			}
		}
		
		private function onStageMouseDown(event:MouseEvent):void
		{
			if (event.target is Node)
			{
				dragNode(event.target as Node);
			}
		}
		
		private function onStageMouseUp(event:MouseEvent):void
		{
			var node:Node = _selectedNode;
			releaseNode();
			
			if (event.target is ScrollContainer && (event.ctrlKey || _creatingSegment))
			{
				node = createNode(event.localX, event.localY);
			}
			
			if (node && (!node.tail || !node.head))
			{
				if (_creatingSegment)
				{
					finishSegment(node);
				}
				
				if (event.ctrlKey)
				{
					createSegment(node);
				}
			}
		}
		
		private function onStageRightMouseDown(event:MouseEvent):void
		{
			if (_creatingSegment)
			{
				cancelSegment();
			}
		}
		
		private function onStageRightMouseUp(event:MouseEvent):void
		{
			if (event.target is Node)
			{
				destroyNode(event.target as Node);
			}
		}
		
		private function onStageKeyDown(event:KeyboardEvent):void
		{
			if (event.ctrlKey)
			{
				if (event.keyCode == Keyboard.C)
				{
					copyData();
				}
				else if (event.keyCode == Keyboard.S)
				{
					saveFile();
				}
				else if (event.keyCode == Keyboard.L)
				{
					loadFile();
				}
				else if (event.keyCode == Keyboard.N)
				{
					newFile();
				}
				else if (event.keyCode == Keyboard.Q)
				{
					exitApp();
				}
			}
			else if (event.keyCode == Keyboard.W)
			{
				_keys[UP] = true;
			}
			else if (event.keyCode == Keyboard.S)
			{
				_keys[DOWN] = true;
			}
			else if (event.keyCode == Keyboard.A)
			{
				_keys[LEFT] = true;
			}
			else if (event.keyCode == Keyboard.D)
			{
				_keys[RIGHT] = true;
			}
			else if (event.keyCode == Keyboard.SPACE)
			{
				_keys[SPACE] = true;
			}
			
			event.preventDefault();
		}
		
		private function onStageKeyUp(event:KeyboardEvent):void 
		{
			if (event.keyCode == Keyboard.W)
			{
				_keys[UP] = false;
			}
			else if (event.keyCode == Keyboard.S)
			{
				_keys[DOWN] = false;
			}
			else if (event.keyCode == Keyboard.A)
			{
				_keys[LEFT] = false;
			}
			else if (event.keyCode == Keyboard.D)
			{
				_keys[RIGHT] = false;
			}
			else if (event.keyCode == Keyboard.SPACE)
			{
				_keys[SPACE] = false;
			}
		}
		
		private function scrollOffset(xOffset:Number, yOffset:Number):void 
		{
			_scrollContainer.x -= xOffset;
			_scrollContainer.y -= yOffset;
		}
		
		private function createNode(x:Number, y:Number):Node
		{
			var node:Node = new Node();
			
			node.x = x;
			node.y = y;
			
			_nodesLayer.addChild(node);
			
			return node;
		}
		
		private function destroyNode(node:Node):void
		{
			_nodesLayer.removeChild(node);
			
			if (node.anchor)
			{
				node.anchor.start.head = null;
				node.anchor.end.tail = null;
				
				delete _segments[node.anchor.anchor];
			}
			else
			{
				var head:Segment = node.head;
				var tail:Segment = node.tail;
				
				if (head)
				{
					_nodesLayer.removeChild(head.anchor);
					head.end.tail = null;
					delete _segments[head.anchor];
				}
				
				if (tail)
				{
					_nodesLayer.removeChild(tail.anchor);
					tail.start.head = null;
					delete _segments[tail.anchor];
				}
			}
		}
		
		private function selectNode(node:Node):void
		{
			_selectedNode = node;
		}
		
		private function deselectNode():void
		{
			_selectedNode = null;
		}
		
		private function dragNode(node:Node):void
		{
			selectNode(node);
			_draggingNode = node;
		}
		
		private function releaseNode():void
		{
			deselectNode();
			_draggingNode = null;
		}
		
		private function createSegment(node:Node):void
		{
			_creatingSegment = node;
		}
		
		private function finishSegment(node:Node):void
		{
			var start:Node;
			var end:Node;
			
			if (!_creatingSegment.head && !node.tail)
			{
				start = _creatingSegment;
				end = node;
			}
			else if (!node.head && !_creatingSegment.tail)
			{
				start = node;
				end = _creatingSegment;
			}
			
			if (start && end)
			{
				var segment:Segment = new Segment(start, end);
				
				_nodesLayer.addChild(segment.anchor);
				
				_segments[segment.anchor] = segment;
			}
			
			cancelSegment();
		}
		
		private function cancelSegment():void
		{
			_creatingSegment = null;
		}
		
		private function exitApp():void 
		{
			NativeApplication.nativeApplication.exit();
		}
		
		private function loadFile():void 
		{
			_file = new File();
			
			_file.addEventListener(Event.SELECT, onFileSelect);
			_file.addEventListener(Event.COMPLETE, onFileComplete);
			_file.browse([new FileFilter("Paths File (*.paf)", "*.paf"), new FileFilter("Any file", "*.*")]);
		}
		
		private function saveFile():void 
		{
			_file = new File();
			
			var dataToSave:ByteArray = new ByteArray();
			var serialized:String = serializePaths();
			
			dataToSave.writeMultiByte(serialized, "utf-8");
			_file.save(dataToSave, "paths.paf");
		}
		
		private function copyData():void 
		{
			var data:String = "";
			var paths:Vector.<Segment> = extractPaths();
			
			for (var i:int = 0; i < paths.length; ++i)
			{
				data += "\r\nvar path" + i + ":Path = new Path();\r\n";
				
				var currentSegment:Segment = paths[i];
				do
				{
					data += "path" + i + ".addSegment(";
					data += currentSegment.start.x + ", " + currentSegment.start.y + ", ";
					data += currentSegment.end.x + ", " + currentSegment.end.y + ", ";
					data += currentSegment.anchor.x + ", " + currentSegment.anchor.y + ");\r\n";
				} while (currentSegment = currentSegment.end.head);
			}
			
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, data, false);
		}
		
		private function onFileSelect(event:Event):void
		{
			_file.load();
		}
		
		private function onFileComplete(event:Event):void
		{
			var pathsXML:XML = new XML(_file.data.readMultiByte(_file.data.bytesAvailable, "utf-8"));
			
			newFile(true);
			loadBackground(pathsXML.background);
			
			for each (var pathXML:XML in pathsXML.path)
			{
				var nodePoints:Array = [];
				var nodes:Array = [];
				
				var nodesXML:XML = pathXML.nodes[0];
				var segmentsXML:XML = pathXML.segments[0];
				
				for each (var nodeXML:XML in nodesXML.node) 
				{
					nodePoints[nodeXML.@id] = new Point(nodeXML.@x, nodeXML.@y);
				}
				
				for each (var segmentXML:XML in segmentsXML.segment) 
				{
					var startID:int = segmentXML.@start;
					var anchorID:int = segmentXML.@anchor;
					var endID:int = segmentXML.@end;
					
					var start:Node = nodes[startID];
					var end:Node = nodes[endID];
					var anchorPoint:Point = nodePoints[anchorID];
					
					if (!start)
					{
						start = nodes[startID] = new Node();
						
						start.x = nodePoints[startID].x;
						start.y = nodePoints[startID].y;
						
						_nodesLayer.addChild(start);
					}
					
					if (!end)
					{
						end = nodes[endID] = new Node();
						
						end.x = nodePoints[endID].x;
						end.y = nodePoints[endID].y;
						
						_nodesLayer.addChild(end);
					}
					
					var segment:Segment = new Segment(start, end, anchorPoint);
					_segments[segment.anchor] = segment;
					
					_nodesLayer.addChild(segment.anchor);
				}
			}
		}
		
		private function serializePaths():String
		{
			var nodeId:int;
			var paths:Vector.<Segment> = extractPaths();
			var pathsXML:XML = <paths />;
			
			pathsXML.appendChild(<background>{_backgroundPath}</background>);
			
			for (var i:int = 0; i < paths.length; ++i)
			{
				var segment:Segment = paths[i];
				var pathXML:XML = <path />;
				var nodesXML:XML = <nodes />;
				var segmentsXML:XML = <segments />;
				
				nodesXML.appendChild(<node id={nodeId++} x={segment.start.x} y={segment.start.y} />);
				
				do
				{
					nodesXML.appendChild(<node id={nodeId++} x={segment.anchor.x} y={segment.anchor.y} />);
					nodesXML.appendChild(<node id={nodeId++} x={segment.end.x} y={segment.end.y} />);
					segmentsXML.appendChild(<segment start={nodeId-3} anchor={nodeId-2} end={nodeId-1} />);
				}
				while (segment = segment.end.head);
				
				pathXML.appendChild(nodesXML);
				pathXML.appendChild(segmentsXML);
				pathsXML.appendChild(pathXML);
			}
			
			return pathsXML.toXMLString();
		}
		
		private function extractPaths():Vector.<Segment>
		{
			var paths:Vector.<Segment> = new Vector.<Segment>();
			
			for each (var segment:Segment in _segments)
			{
				if (!segment.start.tail)
				{
					paths.push(segment);
				}
			}
			
			return paths;
		}
		
		private function loadBackground(path:String = null):void 
		{
			_file = new File(path);
			
			_file.addEventListener(Event.COMPLETE, onNewFileComplete);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onFileIoError);
			
			if (!path)
			{
				_file.addEventListener(Event.SELECT, onNewFileSelect);
				_file.browse([new FileFilter("Image File", "*.png;*.jpg;*.jpeg"), new FileFilter("Any file", "*.*")]);
			}
			else
			{
				_file.load();
			}
		}
		
		private function onFileIoError(event:IOErrorEvent):void 
		{
			loadBackground();
		}
	}
}