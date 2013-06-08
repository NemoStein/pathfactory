package nemostein.tools.pathfactory
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import nemostein.tools.pathfactory.filesystem.BackgroundLoader;
	import nemostein.tools.pathfactory.filesystem.FileLoader;
	import nemostein.tools.pathfactory.filesystem.FileSaver;
	import nemostein.tools.pathfactory.segments.nodes.Anchor;
	import nemostein.tools.pathfactory.segments.nodes.EndPoint;
	import nemostein.tools.pathfactory.segments.nodes.Node;
	
	public class PathFactory extends Sprite
	{
		public var newMouse:Point;
		public var oldMouse:Point;
		public var creatingSegment:EndPoint;
		
		private var _ui:UI;
		private var _container:Sprite;
		
		private var _navigating:Boolean;
		private var _scrollUp:Boolean;
		private var _scrollDown:Boolean;
		private var _scrollLeft:Boolean;
		private var _scrollRight:Boolean;
		
		private var _draggingNode:Node;
		private var _uiNode:Node;
		
		private var _file:File;
		
		public function PathFactory()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_ui = new UI(this);
			_container = new Sprite();
			
			mouseEnabled = false;
			
			newMouse = new Point();
			oldMouse = new Point();
			
			reset();
			
			addChild(_container);
			addChild(_ui);
			
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onStageRightMouseDown);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onStageRightMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
		}
		
		//{ Update
		
		private function onStageEnterFrame(event:Event):void
		{
			newMouse.x = mouseX;
			newMouse.y = mouseY;
			
			if (_navigating)
			{
				_container.x += newMouse.x - oldMouse.x;
				_container.y += newMouse.y - oldMouse.y;
			}
			else
			{
				var scrollOffset:Point = new Point();
				
				if (_scrollUp)
				{
					scrollOffset.y += 1;
				}
				else if (_scrollDown)
				{
					scrollOffset.y -= 1;
				}
				
				if (_scrollLeft)
				{
					scrollOffset.x += 1;
				}
				else if (_scrollRight)
				{
					scrollOffset.x -= 1;
				}
				
				_container.x += scrollOffset.x * 3;
				_container.y += scrollOffset.y * 3;
			}
			
			if (_draggingNode != null)
			{
				_draggingNode.x = oldMouse.x - _container.x;
				_draggingNode.y = oldMouse.y - _container.y;
			}
			
			PathService.draw();
			
			oldMouse.x = newMouse.x;
			oldMouse.y = newMouse.y;
			
			updateUI();
		}
		
		//}
		
		//{ Mouse
		
		private function onStageMouseOver(event:MouseEvent):void 
		{
			if (event.target is Node)
			{
				_uiNode = event.target as Node;
			}
		}
		
		//}
		
		//{ Left Mouse
		
		private function onStageMouseDown(event:MouseEvent):void
		{
			if (event.target is Stage)
			{
				if (creatingSegment != null)
				{
					PathService.createSegment(creatingSegment, PathService.createEndPoint(event.localX - _container.x, event.localY - _container.y));
					creatingSegment = null;
				}
				else
				{
					_navigating = true;
				}
			}
			else if (event.target is EndPoint && creatingSegment != null)
			{
				PathService.createSegment(creatingSegment, EndPoint(event.target));
				creatingSegment = null;
			}
			else if (event.target is Node)
			{
				_draggingNode = Node(event.target);
			}
		}
		
		private function onStageMouseUp(event:MouseEvent):void
		{
			if (event.ctrlKey)
			{
				if (event.target is Stage)
				{
					creatingSegment = PathService.createEndPoint(event.localX - _container.x, event.localY - _container.y);
				}
				else if (event.target is EndPoint)
				{
					creatingSegment = EndPoint(event.target);
				}
			}
			
			if (_navigating)
			{
				_navigating = false;
			}
			
			if (_draggingNode != null)
			{
				_draggingNode = null;
			}
		}
		
		//}
		
		//{ Right Mouse
		
		private function onStageRightMouseDown(event:MouseEvent):void
		{
			if (creatingSegment != null)
			{
				creatingSegment = null;
			}
		}
		
		private function onStageRightMouseUp(event:MouseEvent):void
		{
			if (event.target is Node)
			{
				Node(event.target).destroy();
			}
		}
		
		//}
		
		//{ Keyboard
		
		private function onStageKeyDown(event:KeyboardEvent):void
		{
			if (event.ctrlKey)
			{
				if (event.keyCode == Keyboard.N)
				{
					newFile();
				}
				else if (event.keyCode == Keyboard.L)
				{
					loadFile();
				}
				else if (event.keyCode == Keyboard.S)
				{
					saveFile();
				}
				else if (event.keyCode == Keyboard.W)
				{
					reset();
				}
			}
			else if (event.altKey && event.keyCode == Keyboard.ENTER)
			{
				toggleScreenState();
			}
			else if (event.keyCode == Keyboard.B)
			{
				PathService.toggleBackground();
			}
			else if (event.keyCode == Keyboard.G)
			{
				PathService.toggleGuides();
			}
			else if (event.keyCode == Keyboard.N)
			{
				PathService.toggleNodes();
			}
			else if (event.keyCode == Keyboard.P)
			{
				PathService.togglePaths();
			}
			else if (event.keyCode == Keyboard.W)
			{
				_scrollUp = true;
			}
			else if (event.keyCode == Keyboard.S)
			{
				_scrollDown = true;
			}
			else if (event.keyCode == Keyboard.A)
			{
				_scrollLeft = true;
			}
			else if (event.keyCode == Keyboard.D)
			{
				_scrollRight = true;
			}
			
			event.preventDefault();
		}
		
		private function onStageKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.W)
			{
				_scrollUp = false;
			}
			else if (event.keyCode == Keyboard.S)
			{
				_scrollDown = false;
			}
			else if (event.keyCode == Keyboard.A)
			{
				_scrollLeft = false;
			}
			else if (event.keyCode == Keyboard.D)
			{
				_scrollRight = false;
			}
		}
		
		//}
		
		//{ Custom Methods
		
		public function updateUI():void 
		{
			if (_uiNode)
			{
				_ui.xText.text = String(_uiNode.x);
				_ui.yText.text = String(_uiNode.y);
				
				if (_uiNode is Anchor)
				{
					var anchor:Anchor = _uiNode as Anchor;
					
					_ui.anchorText.text = "true";
					_ui.tensionText.text = String(anchor.tesion.toFixed(3));
				}
				else
				{
					_ui.anchorText.text = "false";
					_ui.tensionText.text = "0.000";
				}
			}
			else
			{
				_ui.xText.text = "";
				_ui.yText.text = "";
				_ui.anchorText.text = "";
				_ui.tensionText.text = "";
			}
		}
		
		private function reset():void
		{
			_container.x = 0;
			_container.y = 40;
			
			while (_container.numChildren)
			{
				_container.removeChildAt(0);
			}
			
			PathService.setup(this, _container, _ui);
		}
		
		private function toggleScreenState():void
		{
			if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
			else
			{
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}
		
		public function newFile():void
		{
			loadBackground();
		}
		
		public function loadFile():void
		{
			var fileLoader:FileLoader = new FileLoader();
			fileLoader.startLoading(loadingSucceeded);
		}
		
		public function saveFile():void
		{
			var fileSaver:FileSaver = new FileSaver();
			fileSaver.startSaving();
		}
		
		public function loadBackground():void
		{
			var backgroundLoader:BackgroundLoader = new BackgroundLoader(PathService.addBackground, loadingSucceeded);
			backgroundLoader.startLoading();
		}
		
		private function loadingSucceeded():void
		{
			reset();
		}
		
		//}
	}
}