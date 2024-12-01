package fnf.backend.save;

import flixel.input.keyboard.FlxKey;
import fnf.backend.Controls.Action;

class ClientPrefs {
	public var antialiasing = true;
	public var downscroll = false;

	public var keyBinds:Map<Action, Array<FlxKey>> = [
		UP     => [FlxKey.W, FlxKey.UP],
		DOWN   => [FlxKey.S, FlxKey.DOWN],
		LEFT   => [FlxKey.A, FlxKey.LEFT],
		RIGHT  => [FlxKey.D, FlxKey.RIGHT],

		BACK   => [FlxKey.ESCAPE, FlxKey.BACKSPACE],
		ACCEPT => [FlxKey.SPACE, FlxKey.ENTER],

		RESET  => [FlxKey.R]
	];

	public static var data(default, null) = new ClientPrefs();

	public static function save() {}

	public static function load() {}

	public static function reset() {
		data = new ClientPrefs();
	}

	private function new() {}
}
