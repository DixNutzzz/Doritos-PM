package fnf.scripting;

import haxe.io.Path;

abstract class Script {
	public abstract function get(name:String):Dynamic;
	public abstract function set(name:String, value:Dynamic):Dynamic;
	public abstract function call(name:String, args:Array<Dynamic>):Dynamic;

	public static function fromAsset(path:String):Script {
		switch Path.extension(path) {
			case 'hx': return new HScript(path);
			case 'expr': return new PreparsedHScript(path);
		}
	}
}
