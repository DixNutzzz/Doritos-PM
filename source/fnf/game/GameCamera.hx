package fnf.game;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxMatrix;
import flixel.FlxCamera;

class GameCamera extends FlxCamera {
	public var rotation:Float;

	public final rotationOffset:FlxCallbackPoint;

	public function new(x = 0, y = 0, width = 0, height = 0, zoom = 0.0) {
		rotationOffset = new FlxCallbackPoint(_setRotationOffset);
		super(x, y, width, height, zoom);
		rotationOffset.set(0.5, 0.5);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		updateRotation();
	}

	private function _setRotationOffset(point:FlxPoint) {
		updateRotation();
	}

	public function updateRotation() {
		flashSprite.x -= _flashOffset.x;
		flashSprite.y -= _flashOffset.y;

		var matrix = new FlxMatrix();
		// matrix.concat(canvas.transform.matrix); // DON'T EVEN THINK ABOUT IT.
		matrix.translate(-width * rotationOffset.x, -height * rotationOffset.y);
		matrix.scale(scaleX, scaleY);
		matrix.rotate(angle * (Math.PI / 180));
		matrix.translate(width * rotationOffset.x, height * rotationOffset.y);
		matrix.translate(flashSprite.x, flashSprite.y); // for shake event
		matrix.scale(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
		canvas.transform.matrix = matrix;

		flashSprite.x = width * 0.5 * FlxG.scaleMode.scale.x;
		flashSprite.y = height * 0.5 * FlxG.scaleMode.scale.y;
		flashSprite.rotation = 0;
	}
}
