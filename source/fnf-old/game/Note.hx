package fnf.game;

import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.FlxSprite;

class Note extends FlxSprite {
	public static inline var STRUM_SIZE = 160 * 0.7;
	public static inline var SUSTAIN_HEIGHT = 44;

	public var songTime:Float;
	public final player:Int;
	public final strum:Int;
	public final kind:String;

	public var sustainLength = 0.0;
	public var isSustain = false;
	public var parent:Note;
	public var tail:Array<Note>;
	public var prevNote:Note;

	public var hasBeenHit = false;
	public var handledMiss = false;

	public var ignoreNote = false;
	public var lowPriority = false;
	public var earlyHitMult = 1.0;
	public var lateHitMult = 1.0;

	public var offsetX = 0.0;
	public var offsetY = 0.0;
	public var offsetAngle = 0.0;
	public var multAlpha = 1.0;
	public var multSpeed(default, set) = 1.0;
		@:noCompletion inline function set_multSpeed(v) {
			resizeByRatio(v / multSpeed);
			return multSpeed = v;
		}

	public var copyX = true;
	public var copyY = true;
	public var copyAngle = true;
	public var copyAlpha = true;

	public function resizeByRatio(ratio:Float) {
		if (!isSustain || !parent.tail.contains(this) || parent.tail.indexOf(this) == parent.tail.length - 1)
			return;

		scale.y *= ratio;
		updateHitbox();
	}

	public function new(songTime:Float, player:Int, strum:Int, kind:String) {
		super();

		this.songTime = songTime;
		this.player = player;
		this.strum = strum % 4;
		this.kind = kind;
	}

	public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	public function reloadNote():Note {
		frames = Paths.getSparrowAtlas('game/notes/default');
		antialiasing = true;

		if (isSustain) {
			animation.addByPrefix('holdend', colArray[strum] + 'hold end', 24, true);
			animation.addByPrefix('hold', colArray[strum] + 'hold piece', 24, true);

			if (strum == 0 && !animation.exists('holdend'))
				animation.addByPrefix('holdend', 'pruple end hold', 24, true);

			if (parent == null) Logger.error('Sustain note without parent');
			else if (parent.tail.indexOf(this) == parent.tail.length - 1) animation.play('holdend');
			else animation.play('hold');
		} else {
			animation.addByPrefix('scroll', colArray[strum] + '0', 24, true);
			animation.play('scroll');
		}

		setGraphicSize(width * 0.7);
		updateHitbox();

		return this;
	}

	public function createTail():Array<Note> {
		for (note in tail) note.destroy();

		var stepDuration = (60 / Conductor.getBPMAtTime(songTime) * 1000) / 4;
		var startStepDuration = (60 / Conductor.getBPMAtTime(0) * 1000) / 4;

		var numSustains = Math.floor(sustainLength / stepDuration);
		if (numSustains > 0) for (i in 0...numSustains) {
			var note = new Note(songTime + stepDuration * i, player, strum, kind);
			note.isSustain = true;
			note.parent = this;
			note.prevNote = tail[tail.length - 1];
			note.reloadNote();
			tail.push(note);

			note.prevNote.scale.y *= SUSTAIN_HEIGHT / note.prevNote.frameHeight;
			note.prevNote.resizeByRatio(stepDuration / startStepDuration);
		}

		return tail.copy();
	}

	public function followStrum(strum:Strum, scrollSpeed:Float) {
		var distance = -0.45 * (Conductor.songPosition - songTime) * scrollSpeed * multSpeed;

		var rotation = strum.direction * FlxAngle.TO_RAD;
		if (copyAngle) angle = strum.direction - 90 + strum.angle + offsetAngle;

		if (copyAlpha) alpha = strum.alpha * multAlpha;

		if (isSustain && parent != null) {
			if (copyX) x = strum.x + offsetX + FlxMath.fastCos(rotation) * distance;
			if (copyY) y = strum.y + offsetY + FlxMath.fastSin(rotation) * distance;
		}
	}

	public function clipToStrum(strum:Strum) {

	}
}
