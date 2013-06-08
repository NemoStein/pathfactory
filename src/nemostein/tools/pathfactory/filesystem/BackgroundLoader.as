package nemostein.tools.pathfactory.filesystem
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	public class BackgroundLoader
	{
		private var _file:File;
		private var _path:String;
		private var _onComplete:Function;
		private var _onSuccess:Function;
		private var _loader:Loader;
		
		public function BackgroundLoader(onComplete:Function, onSuccess:Function, path:String = null)
		{
			_onComplete = onComplete;
			_onSuccess = onSuccess;
			_path = path;
		}
		
		public function startLoading():void
		{
			_file = new File(_path);
			
			_file.addEventListener(Event.COMPLETE, onFileComplete);
			
			if (_path == null || !_file.exists)
			{
				_file.addEventListener(Event.SELECT, onFileSelect);
				_file.browse([new FileFilter("Image File", "*.png;*.jpg;*.jpeg"), new FileFilter("Any file", "*.*")]);
			}
			else
			{
				_file.load();
			}
		}
		
		private function onFileComplete(event:Event):void
		{
			if (_onSuccess != null)
			{
				_onSuccess();
			}
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			_loader.loadBytes(_file.data);
		}
		
		private function onLoaderComplete(event:Event):void
		{
			_onComplete(new BackgroundData(_file.nativePath, Bitmap(event.target.content)));
		}
		
		private function onFileSelect(event:Event):void
		{
			_file.load();
		}
	}
}