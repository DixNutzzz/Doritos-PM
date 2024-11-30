package fnf.game.notes;

import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.FlxSprite;

class Strum extends FlxSprite {
	public final index:Int;

	public var scrollDirection = 90.0;
	public var scrollSpeed = 1.0;

	public var scrollModX:(Note, Float) -> Void;
	public var scrollModY:(Note, Float) -> Void;

	public var parentLine:StrumLine;
	@:allow(fnf.game.notes.StrumLine)
	private var resetTimer = 0.0;

	public function new(index:Int) {
		super();
		this.index = index;
	}

	public function reloadNote(texture = 'default', scale = 1.0):Strum {
		frames = Paths.getSparrowAtlas('game/notes/${texture}');
		antialiasing = ClientPrefs.data.antialiasing;

		var direction = Note.DIRECTIONS[index];
		animation.addByPrefix('static', 'arrow${direction.toUpperCase()}', 24);
		animation.addByPrefix('pressed', '${direction} press', 24, false);
		animation.addByPrefix('confirm', '${direction} confirm', 24, false);

		playAnim('static', true);

		setGraphicSize(width * scale);
		updateHitbox();

		return this;
	}

	public function playAnim(name:String, force = false, reversed = false, frame = 0) {
		animation.play(name, force, reversed, frame);
		if (animation.curAnim == null) return;
		centerOffsets();
		centerOrigin();
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

	/*public function updatePlayerInput(justPressed:Bool, pressed:Bool, justReleased:Bool) {
		switch animation.name {
			case 'static':
				if (justPressed || pressed) playAnim('pressed');
			case 'pressed' | 'confirm':
				if (justReleased || !pressed) playAnim('static');
			default:
				playAnim('static');
		}
	}*/
}
