package game.play.notes;

import flixel.FlxSprite;

class Strum extends FlxSprite {
	public final index:Int;

	public var parentLine:Strumline;

	public var scrollSpeed = 1.0;
	public var scrollDirection = 90.0;

	public var glowCountdown = 0.0;

	public function new(index:Int) {
		super();
		this.index = index;
	}

	public function reloadNote():Strum {
		frames = Paths.getSparrowAtlas('notes/default');

		var directionName = Const.NOTE_DIRECTIONS[index];
		animation.addByPrefix('static', 'arrow${directionName.toUpperCase()}', 24);
		animation.addByPrefix('pressed', '${directionName} press', false);
		animation.addByPrefix('confirm', '${directionName} confirm', false);

		setGraphicSize(width * Const.NOTE_SCALE);
		updateHitbox();
		antialiasing = Options.data.antialiasing;

		playAnim('static', true);

		return this;
	}

	public function playAnim(name:String, force = false, reversed = false, frame = 0) {
		animation.play(name, force, reversed, frame);
		if (animation.curAnim != null) {
			centerOffsets();
			centerOrigin();
		}
	}

	override function update(elapsed:Float) {
		if (glowCountdown > 0.0) {
			glowCountdown -= elapsed;
			if (glowCountdown <= 0) {
				playAnim('static');
				glowCountdown = 0;
			}
		}
		super.update(elapsed);
	}
}
