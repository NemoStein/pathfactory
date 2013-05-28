package nemostein.tools.pathfactory
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
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
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import nemostein.tools.pathfactory.filesystem.BackgroundLoader;
	import nemostein.tools.pathfactory.filesystem.FileLoader;
	import nemostein.tools.pathfactory.filesystem.FileSaver;
	import nemostein.tools.pathfactory.segments.nodes.EndPoint;
	import nemostein.tools.pathfactory.segments.nodes.Node;
	import nemostein.tools.pathfactory.segments.Segment;
	
	public class PathFactory extends Sprite
	{
		public var newMouse:Point;
		public var oldMouse:Point;
		
		private var container:Sprite;
		
		private var navigating:Boolean;
		private var scrollUp:Boolean;
		private var scrollDown:Boolean;
		private var scrollLeft:Boolean;
		private var scrollRight:Boolean;
		
		public var creatingSegment:EndPoint;
		private var draggingNode:Node;
		private var file:File;
		private var helpText:TextField;
		
		public function PathFactory()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			mouseEnabled = false;
			
			newMouse = new Point();
			oldMouse = new Point();
			
			addHelpText();
			reset();
			
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onStageRightMouseDown);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onStageRightMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
		}
		
		//{ Help Text
		
		private function addHelpText():void
		{
			helpText = new TextField();
			
			helpText.mouseEnabled = false;
			helpText.selectable = false;
			helpText.autoSize = TextFieldAutoSize.LEFT;
			helpText.x = 10;
			helpText.y = 10;
			
			helpText.text = "Shortcuts:\n\n";
			helpText.text += "\tCTRL+N - New File (will ask for background image, if none is provided (canceled), this hints will be displayed)\n";
			helpText.text += "\tCTRL+L - Load File\n";
			helpText.text += "\tCTRL+S - Save File\n";
			helpText.text += "\tCTRL+C - Copy Paths (will copy the paths as text, ready to be used into, the clipboard)\n";
			helpText.text += "\tCRTL+Q - Quit\n";
			helpText.text += "\tB - Show/Hide Background\n";
			helpText.text += "\tG - Show/Hide Guides\n";
			helpText.text += "\tN - Show/Hide Nodes\n";
			helpText.text += "\tP - Show/Hide Paths\n";
			helpText.text += "\tCTRL+Left Click - Place Node / Resume Path\n";
			helpText.text += "\tLeft Click (on node) - Drag Node\n";
			helpText.text += "\tLeft Click (on stage) - Navigate\n";
			helpText.text += "\tW/A/S/D - Navigate\n";
			helpText.text += "\tRight Click - Delete Node\n";
			helpText.text += "\tRight Click (creating node) - Cancel Creation\n";
			
			addChild(helpText);
		}
		
		//}
		
		//{ Update
		
		private function onStageEnterFrame(event:Event):void
		{
			newMouse.x = mouseX;
			newMouse.y = mouseY;
			
			if (navigating)
			{
				container.x += newMouse.x - oldMouse.x;
				container.y += newMouse.y - oldMouse.y;
			}
			else
			{
				var scrollOffset:Point = new Point();
				
				if (scrollUp)
				{
					scrollOffset.y += 1;
				}
				else if (scrollDown)
				{
					scrollOffset.y -= 1;
				}
				
				if (scrollLeft)
				{
					scrollOffset.x += 1;
				}
				else if (scrollRight)
				{
					scrollOffset.x -= 1;
				}
				
				container.x += scrollOffset.x * 3;
				container.y += scrollOffset.y * 3;
			}
			
			if (draggingNode != null)
			{
				draggingNode.x = oldMouse.x - container.x;
				draggingNode.y = oldMouse.y - container.y;
			}
			
			PathService.draw();
			
			oldMouse.x = newMouse.x;
			oldMouse.y = newMouse.y;
		}
		
		//}
		
		//{ Left Mouse
		
		private function onStageMouseDown(event:MouseEvent):void
		{
			if (event.target is Stage)
			{
				if (creatingSegment != null)
				{
					PathService.createSegment(creatingSegment, PathService.createEndPoint(event.localX - container.x, event.localY - container.y));
					creatingSegment = null;
				}
				else
				{
					navigating = true;
				}
			}
			else if (event.target is EndPoint && creatingSegment != null)
			{
				PathService.createSegment(creatingSegment, EndPoint(event.target));
				creatingSegment = null;
			}
			else if (event.target is Node)
			{
				draggingNode = Node(event.target);
			}
		}
		
		private function onStageMouseUp(event:MouseEvent):void
		{
			if (event.ctrlKey)
			{
				if (event.target is Stage)
				{
					creatingSegment = PathService.createEndPoint(event.localX - container.x, event.localY - container.y);
				}
				else if (event.target is EndPoint)
				{
					creatingSegment = EndPoint(event.target);
				}
			}
			
			if (navigating)
			{
				navigating = false;
			}
			
			if (draggingNode != null)
			{
				draggingNode = null;
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
				else if (event.keyCode == Keyboard.Q)
				{
					exitApp();
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
				scrollUp = true;
			}
			else if (event.keyCode == Keyboard.S)
			{
				scrollDown = true;
			}
			else if (event.keyCode == Keyboard.A)
			{
				scrollLeft = true;
			}
			else if (event.keyCode == Keyboard.D)
			{
				scrollRight = true;
			}
			
			event.preventDefault();
		}
		
		private function onStageKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.W)
			{
				scrollUp = false;
			}
			else if (event.keyCode == Keyboard.S)
			{
				scrollDown = false;
			}
			else if (event.keyCode == Keyboard.A)
			{
				scrollLeft = false;
			}
			else if (event.keyCode == Keyboard.D)
			{
				scrollRight = false;
			}
		}
		
		//}
		
		//{ Custom Methods
		
		private function reset():void
		{
			helpText.visible = true;
			
			if (container != null)
			{
				removeChild(container);
			}
			
			container = new Sprite();
			PathService.setup(this, container);
			addChild(container);
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
		
		private function newFile():void
		{
			reset();
			
			loadBackground();
		}
		
		private function loadFile():void
		{
			reset();
			
			helpText.visible = false;
			
			var fileLoader:FileLoader = new FileLoader();
			fileLoader.startLoading(loadingCanceledOrFailed);
		}
		
		private function saveFile():void
		{
			var fileSaver:FileSaver = new FileSaver();
			fileSaver.startSaving();
		}
		
		private function loadBackground():void
		{
			helpText.visible = false;
			
			var backgroundLoader:BackgroundLoader = new BackgroundLoader(PathService.addBackground, loadingCanceledOrFailed);
			backgroundLoader.startLoading();
		}
		
		private function loadingCanceledOrFailed():void
		{
			reset();
		}
		
		private function exitApp():void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		//}
	}
}