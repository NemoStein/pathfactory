package nemostein.tools.pathfactory.filesystem
{
	import flash.display.Bitmap;
	
	public class BackgroundData
	{
		public var path:String;
		public var bitmap:Bitmap;
		
		public function BackgroundData(path:String, bitmap:Bitmap)
		{
			this.path = path;
			this.bitmap = bitmap;
		}
	}
}