package fnf.game;

import openfl.Assets;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite {
	public var name(default, null):String;
	public final isPlayer:Bool;

	public function new(char:String, player:Bool) {
		super();
		isPlayer = player;
		reloadIcon(char);
	}

	public function reloadIcon(char:String):HealthIcon {
		var bmp = Assets.getBitmapData(Paths.image('game/icons/$char'));
		loadGraphic(bmp, true, Math.floor(bmp.width / 2), bmp.height);
		animation.add(char, [ 0, 1 ], 0, false, isPlayer);
		animation.play(char);
		return this;
	}

	public function updateIcon(healthPercent:Float) {
		var losing = (!isPlayer && healthPercent > 80) || (isPlayer && healthPercent < 20);
		animation.curAnim.curFrame = losing ? 1 : 0;
	}
}
