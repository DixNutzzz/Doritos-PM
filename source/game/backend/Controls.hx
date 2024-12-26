package game.backend;

import haxe.ds.ReadOnlyArray;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

enum Action {
	NOTE_UP;
	NOTE_DOWN;
	NOTE_LEFT;
	NOTE_RIGHT;

	UI_UP;
	UI_DOWN;
	UI_LEFT;
	UI_RIGHT;

	BACK;
	ACCEPT;
}

class Controls {
	public static final NOTE_CONTROLS:ReadOnlyArray<Action> = [
		NOTE_LEFT,
		NOTE_DOWN,
		NOTE_UP,
		NOTE_RIGHT
	];

	public static var keyboardBinds:Map<Action, Array<FlxKey>> = [
		NOTE_UP    => [ W, UP ],
		NOTE_DOWN  => [ S, DOWN ],
		NOTE_LEFT  => [ A, LEFT ],
		NOTE_RIGHT => [ D, RIGHT ],

		UI_UP      => [ W, UP ],
		UI_DOWN    => [ S, DOWN ],
		UI_LEFT    => [ A, LEFT ],
		UI_RIGHT   => [ D, RIGHT ],

		BACK       => [ ESCAPE, BACKSPACE ],
		ACCEPT     => [ SPACE, ENTER ]
	];

	public static function justPressed(action:Action):Bool {
		var keys = keyboardBinds.get(action);
		return keys != null ? FlxG.keys.anyJustPressed(keys) : false;
	}

	public static function pressed(action:Action):Bool {
		var keys = keyboardBinds.get(action);
		return keys != null ? FlxG.keys.anyPressed(keys) : false;
	}

	public static function justReleased(action:Action):Bool {
		var keys = keyboardBinds.get(action);
		return keys != null ? FlxG.keys.anyJustReleased(keys) : false;
	}

	public static function turboPressed(action:Action):Bool {
		// FlxG.log.warn('Turbo keys not implemented yet');
		return justPressed(action);
	}

	public static function getKeys(action:Action):Array<FlxKey> {
		var keys = keyboardBinds.get(action);
		return keys ?? [];
	}
}
