package fnf.backend;

import flixel.FlxG;
import haxe.PosInfos;

class Logger {
	public static function notice(v:Dynamic, ?pos:PosInfos) {
		FlxG.log.notice(v);
		haxe.Log.trace('[NOTICE] ${v}', pos);
	}

	public static function warn(v:Dynamic, ?pos:PosInfos) {
		FlxG.log.warn(v);
		haxe.Log.trace('[WARN] $v', pos);
	}

	public static function error(v:Dynamic, ?pos:PosInfos) {
		FlxG.log.error(v);
		haxe.Log.trace('[ERROR] $v', pos);
	}
}
