import lime.system.Locale;
import lime.system.System;
import flixel.FlxG;
import game.backend.Logger;

class DeviceInfos {
	public static function print() {
		FlxG.log.notice('Platform: ${System.platformName}');
		FlxG.log.notice('Locale: ${Locale.currentLocale}');

		FlxG.log.notice('Render driver: ${FlxG.stage.context3D.driverInfo}');
		FlxG.log.notice('Max back buffer size: ${FlxG.stage.context3D.maxBackBufferWidth}x${FlxG.stage.context3D.maxBackBufferHeight}');
	}
}
