package fnf.game;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxCamera;

class HUDCamera extends FlxCamera {
	public function new(x = 0.0, y = 0.0, width = 0, height = 0, zoom = 0.0) {
		super(x, y, width, height, zoom);
		bgColor = 0x00000000;
	}

	override function alterPosition(result:FlxPoint, object:FlxObject):FlxPoint {
		if (ClientPrefs.data.downscroll) result.y = height - result.y - object.height;
		return result;
	}
}
