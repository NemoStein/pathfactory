package 
{
	import flash.display.Sprite;
	import nemostein.tools.pathfactory.PathFactory;
	
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			addChild(new PathFactory());
		}
	}
}