package game.utils.tools;

import flixel.sound.FlxSound;

class FlxSoundTools {
	public static function getAccurateTime(snd:FlxSound):Float {
		return @:privateAccess snd._channel?.position ?? snd.time;
	}
}
