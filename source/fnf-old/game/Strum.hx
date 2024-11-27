package fnf.game;

import flixel.FlxG;
import flixel.FlxSprite;

class Strum extends FlxSprite {
	public var direction = 90.0;

	public var resetTimer = 0.0;

	public final noteData:Int;
	public final player:Int;

	public function new(data:Int, player:Int) {
		super();
		noteData = data;
		this.player = player;
	}

	public function reloadNote():Strum {
		frames = Paths.getSparrowAtlas('game/notes/default');

		antialiasing = true;
		setGraphicSize(width * 0.7);

		switch noteData % 4 {
			case 0:
				animation.addByPrefix('static', 'arrowLEFT', 24);
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrowDOWN', 24);
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrowUP', 24);
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT', 24);
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		updateHitbox();

		playAnim('static', true);

		return this;
	}

	public function playerPosition() {
		x += Note.STRUM_SIZE * noteData;
		x += FlxG.width / 2 * player;
	}

	override function update(elapsed:Float) {
		if (resetTimer > 0) {
			resetTimer -= elapsed;
			if (resetTimer <= 0) {
				playAnim('static');
				resetTimer = 0;
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
