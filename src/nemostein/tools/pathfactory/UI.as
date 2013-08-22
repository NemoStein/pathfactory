package nemostein.tools.pathfactory
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.Window;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class UI extends Sprite
	{
		[Embed(source = "assets/HelpText.txt",mimeType="application/octet-stream")]
		static private const HelpText:Class;
		
		[Embed(source = "assets/MenuMCML.xml",mimeType="application/octet-stream")]
		static private const MenuMCML:Class;
		
		private var _pathFactory:PathFactory;
		
		public var menuPanel:Panel;
		public var dataPanel:Panel;
		public var helpButton:PushButton;
		public var helpWindow:Window;
		
		public var helpText:Text;
		public var xText:Text;
		public var yText:Text;
		public var anchorText:Text;
		public var tensionText:Text;
		
		public var showBackgroundCheckBox:CheckBox;
		public var showGuidesCheckBox:CheckBox;
		public var showNodesCheckBox:CheckBox;
		public var showPathsCheckBox:CheckBox;
		
		public function UI(pathFactory:PathFactory)
		{
			_pathFactory = pathFactory;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			new MinimalConfigurator(this).parseXML(XML(new MenuMCML()));
			
			initializeMenu();
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame);
		}
		
		private function initializeMenu():void
		{
			helpText.text = String(new HelpText());
			
			helpWindow.visible = false;
		}
		
		private function updateMenu():void
		{
			var stageWidth:int = stage.stageWidth;
			var stageHeight:int = stage.stageHeight;
			
			menuPanel.width = stageWidth;
			dataPanel.height = stageHeight - menuPanel.height;
			
			dataPanel.x = stageWidth - dataPanel.width;
			dataPanel.y = menuPanel.height;
			
			helpButton.x = stageWidth - helpButton.width - 20;
			
			helpText.width = 250;
			helpText.height = 275;
			
			helpWindow.width = helpText.width + 20;
			helpWindow.height = helpText.height + 40;
			
			helpWindow.x = (stageWidth - helpText.width) * 0.5;
			helpWindow.y = (stageHeight - helpText.height) * 0.5;
		}
		
		public function onNewClick(event:Event):void
		{
			_pathFactory.newFile();
		}
		
		public function onLoadClick(event:Event):void
		{
			_pathFactory.loadFile();
		}
		
		public function onSaveClick(event:Event):void
		{
			_pathFactory.saveFile();
		}
		
		public function onHelpClick(event:Event):void
		{
			helpWindow.visible = true;
		}
		
		public function onHelpWindowClose(event:Event):void
		{
			helpWindow.visible = false;
		}
		
		public function onCheckBoxClick(event:Event):void
		{
			var checkBox:CheckBox = event.target as CheckBox;
			
			if (checkBox == showBackgroundCheckBox)
			{
				PathService.toggleBackground();
			}
			else if (checkBox == showGuidesCheckBox)
			{
				PathService.toggleGuides();
			}
			else if (checkBox == showNodesCheckBox)
			{
				PathService.toggleNodes();
			}
			else if (checkBox == showPathsCheckBox)
			{
				PathService.togglePaths();
			}
		}
		
		private function onStageEnterFrame(event:Event):void
		{
			stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrame);
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			updateMenu();
		}
		
		private function onStageResize(event:Event):void
		{
			updateMenu();
		}
	}
}