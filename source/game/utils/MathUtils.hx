package game.utils;

import flixel.FlxG;

class MathUtils {
	public static function fpsSensitiveLerp(a:Float, b:Float, ratio:Float):Float {
		return a + (a - b) * ratio * (60 / FlxG.updateFramerate);
	}
}
