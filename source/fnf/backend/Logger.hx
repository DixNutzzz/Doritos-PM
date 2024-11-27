package fnf.backend;

import flixel.FlxG;
import haxe.PosInfos;

class Logger {
	public static function notice(v:Dynamic, ?pos:PosInfos) {
		FlxG.log.notice(v);
	}

	public static function warn(v:Dynamic, ?pos:PosInfos) {
		FlxG.log.warn(v);
	}

	public static function error(v:Dynamic, ?pos:PosInfos) {
		FlxG.log.error(v);
	}
}
