package fnf.backend;

import haxe.ds.ReadOnlyArray;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

enum Action {
	UP;
	DOWN;
	LEFT;
	RIGHT;

	BACK;
	ACCEPT;

	RESET;
}

class Controls {
	public static final NAV_CONTROLS:ReadOnlyArray<Action> = [ LEFT, DOWN, UP, RIGHT ];
	public static final NOTE_CONTROLS = NAV_CONTROLS;

	public static function justPressed(action:Action):Bool {
		var keys = ClientPrefs.data.keyBinds.get(action);
		return keys != null ? FlxG.keys.anyJustPressed(keys) : false;
	}

	public static function pressed(action:Action):Bool {
		var keys = ClientPrefs.data.keyBinds.get(action);
		return keys != null ? FlxG.keys.anyPressed(keys) : false;
	}

	public static function justReleased(action:Action):Bool {
		var keys = ClientPrefs.data.keyBinds.get(action);
		return keys != null ? FlxG.keys.anyJustReleased(keys) : false;
	}

	public static function getKeys(action:Action):Array<FlxKey> {
		var keys = ClientPrefs.data.keyBinds.get(action);
		return keys ?? [];
	}
}
