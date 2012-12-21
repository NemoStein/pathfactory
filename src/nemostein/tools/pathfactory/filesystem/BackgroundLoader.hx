package nemostein.tools.pathfactory.filesystem;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.net.FileFilter;

class BackgroundLoader 
{
	private var file:File;
	private var path:String;
	private var onComplete:BackgroundData->Void;
	private var onCancel:Void->Void;
	private var loader:Loader;

	public function new(onComplete:BackgroundData->Void, onCancel:Void->Void, ?path:String) 
	{
		this.onComplete = onComplete;
		this.onCancel = onCancel;
		this.path = path;
	}
	
	public function startLoading() 
	{
		file = new File(path);
		
		file.addEventListener(Event.COMPLETE, onFileComplete);
		file.addEventListener(IOErrorEvent.IO_ERROR, onFileIoError);
		
		if (path == null)
		{
			file.addEventListener(Event.SELECT, onFileSelect);
			file.addEventListener(Event.CANCEL, onFileCancel);
			file.browse([new FileFilter("Image File", "*.png;*.jpg;*.jpeg"), new FileFilter("Any file", "*.*")]);
		}
		else
		{
			file.load();
		}
	}
	
	private function onFileComplete(event:Event):Void 
	{
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
		loader.loadBytes(file.data);
	}
	
	private function onLoaderComplete(event:Event):Void 
	{
		onComplete(new BackgroundData(file.nativePath, cast(event.target.content, Bitmap)));
	}
	
	private function onFileIoError(event:IOErrorEvent):Void 
	{
		startLoading();
	}
	
	private function onFileSelect(event:Event):Void 
	{
		file.load();
	}
	
	private function onFileCancel(event:Event):Void 
	{
		if(onCancel != null)
		{
			onCancel();
		}
	}
}

class BackgroundData
{
	public var path(default, null):String;
	public var bitmap(default, null):Bitmap;
	
	public function new(path:String, bitmap:Bitmap)
	{
		this.path = path;
		this.bitmap = bitmap;
	}
}