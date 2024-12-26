package game.backend;

import haxe.rtti.Rtti;

@:rtti
class Options {
	public var antialiasing = true;
	public var framerate = 144;

	public var downscroll = false;

	public var showFPS = true;
	public var showRAM = true;
	public var showVRAM = true;

	public var joinVocals = false;

	private function new() {}

	public static var data(default, null) = new Options();

	public static function load() {
		var rtti = Rtti.getRtti(Options);
		for (f in rtti.fields) {
			if (f.isFinal) continue;

			switch f.type {
				case CUnknown:
				default:
			}
		}
	}

	public static function save() {

	}

	public static function reset() {
		data = new Options();
	}
}
