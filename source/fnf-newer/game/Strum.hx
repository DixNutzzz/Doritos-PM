package fnf.game;

import flixel.FlxG;
import flixel.FlxSprite;

class Strum extends FlxSprite {
	public final index:Int;

	public var scrollSpeed = 1.0;
	public var direction = 90.0;

	public var resetAnim = 0.0;

	public function new(index:Int) {
		super();
		this.index = index;
	}

	static final dirArray = [ 'left', 'down', 'up', 'right' ];
	public function reloadNote():Strum {
		frames = Paths.getSparrowAtlas('game/notes/default');
		antialiasing = true;

		animation.addByPrefix('static', 'arrow' + dirArray[index].toUpperCase(), 24);
		animation.addByPrefix('pressed', dirArray[index] + ' press', 24, false);
		animation.addByPrefix('confirm', dirArray[index] + ' confirm', 24, false);

		playAnim('static', true);

		setGraphicSize(width * 0.7);
		updateHitbox();

		return this;
	}

	override function update(elapsed:Float) {
		if (resetAnim > 0) {
			resetAnim -= elapsed;
			if (resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(name:String, force = false, reversed = false, frame = 0) {
		animation.play(name, force, reversed, frame);
		if (animation.curAnim != null) {
			centerOffsets();
			centerOrigin();
		}
	}
}
