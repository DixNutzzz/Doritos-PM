package fnf.game;

import flixel.FlxG;
import flixel.FlxSprite;

@:allow(fnf.game.StrumLine)
class Note extends FlxSprite {
	public static inline var STRUM_SIZE = 160 * 0.7;
	public static inline var SUSTAIN_HEIGHT = 44;

	public final songTime:Float;
	public final strumIndex:Int;
	public var parentStrum:Strum;
	public final noteKind:String;

	public var addX = 0.0;
	public var addY = 0.0;
	public var addAngle = 0.0;

	public var multAlpha = 1.0;
	public var multSpeed = 1.0;

	public var lowPriority = false;

	private var spawned = false;
	private var hasBeenHit = false;

	public var skin(default, set):String;
		@:noCompletion inline function set_skin(v) {
			if (skin != v) {
				skin = v;
				reloadNote();
			}
			return v;
		}

	public function new(time:Float, strum:Int, parent:Strum, kind:String) {
		super();
		y = FlxG.width * 2;

		strumIndex = strum;

		songTime = time;

		parentStrum = parent;
		noteKind = kind;
	}

	static var colArray = [ 'purple', 'blue', 'green', 'red' ];
	public function reloadNote():Note {
		frames = Paths.getSparrowAtlas('game/notes/default');
		antialiasing = true;

		animation.addByPrefix('scroll', colArray[strumIndex] + '0', 24);

		animation.play('scroll', true);

		setGraphicSize(width * 0.7);
		updateHitbox();

		return this;
	}

	public function createSustains(holdTime:Float):Array<SustainNote> {
		var sustains:Array<SustainNote> = [];

		var stepDuration = 60 / Conductor.getBPMAtTime(songTime) * 1000 / 4;
		var numSustains = Math.floor(holdTime / stepDuration);
		if (numSustains > 0) {
			for (i in 0...numSustains) {
				var sustainNote = new SustainNote(songTime + stepDuration * i, strumIndex, parentStrum, noteKind);
				sustainNote.parentNote = this;
				sustains.push(sustainNote);
			}
			sustains[sustains.length - 1].isEnd = true;
		}

		return sustains;
	}

	public function isPossibleToHit():Bool {
		return Math.abs(songTime - Conductor.songPosition) <= Conductor.NOTE_HIT_WINDOW;
	}

	public function isSustain():Bool {
		return false;
	}
}
