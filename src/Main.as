package
{
	import com.bit101.components.Component;
	import com.bit101.components.Panel;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import nemostein.tools.pathfactory.PathFactory;
	
	public class Main extends Sprite
	{
		public var panel:Panel;
		
		public function Main():void
		{
			addChild(new PathFactory());
		}
	}
}