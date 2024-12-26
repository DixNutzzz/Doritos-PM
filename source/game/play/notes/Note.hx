package game.play.notes;

import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import game.backend.Conductor;
import flixel.FlxSprite;

using game.utils.tools.FlxSoundTools;

class Note extends FlxSprite {
	public final songTime:Float;
	public final noteKind:String;

	public var lowPriority = false;

	@:allow(game.play.notes.Strumline)
	public var hasBeenHit(default, null) = false;
	@:allow(game.play.notes.Strumline)
	public var missed(default, null) = false;

	@:allow(game.play.notes.Strumline)
	public var originNote(default, null):Note;
	public var isHold(default, null) = false;
	public var isHoldEnd(default, null) = false;

	@:isVar public var parentStrum(get, set):Strum;
		@:noCompletion function get_parentStrum() return isHold ? originNote.parentStrum : parentStrum;
		@:noCompletion function set_parentStrum(v) return isHold ? originNote.parentStrum = v : parentStrum = v;

	public function new(time:Float, kind:String) {
		super();
		songTime = time;
		noteKind = kind;
	}

	public function reloadNote(hold = false, holdEnd = false):Note {
		frames = Paths.getSparrowAtlas('notes/default');

		isHold = hold;
		isHoldEnd = holdEnd;

		var colorName = Const.NOTE_COLORS[parentStrum.index];

		if (hold) {
			if (holdEnd) {
				animation.addByPrefix('holdend', '${colorName} hold end', 24);
				if (!animation.exists('holdend') && parentStrum.index == 0)
					animation.addByPrefix('holdend', 'pruple end hold', 24);
				animation.play('holdend');
				setGraphicSize(frameWidth * Const.NOTE_SCALE);
			} else {
				animation.addByPrefix('hold', '${colorName} hold piece');
				animation.play('hold');
				setGraphicSize(frameWidth * Const.NOTE_SCALE);

				var bpmChangeAtStart = Conductor.getEvent(0);
				var stepDurationAtStart = 60 / bpmChangeAtStart.bpm * 1000 / bpmChangeAtStart.stepsPerBeat;

				var bpmChange = Conductor.getEvent(songTime);
				var stepDuration = 60 / bpmChange.bpm * 1000 / bpmChange.stepsPerBeat;

				scale.y = stepDurationAtStart / 100 * 1.05;
				scale.y *= parentStrum.scrollSpeed;
				scale.y *= Const.SUSTAIN_NOTE_HEIGHT / frameHeight;
				scale.y *= stepDuration / stepDurationAtStart;
			}
		} else {
			animation.addByPrefix('scroll', '${colorName}0', 24);
			animation.play('scroll');
			setGraphicSize(frameWidth * Const.NOTE_SCALE);
		}
		updateHitbox();
		antialiasing = Options.data.antialiasing;

		return this;
	}

	public function updatePosition(time:Float) {
		var timeDiff = songTime - time;
		var angleRad = (parentStrum.scrollDirection) * FlxAngle.TO_RAD;

		var distance = timeDiff * 0.45 * parentStrum.scrollSpeed;

		x = parentStrum.x + (parentStrum.width - width) / 2 + FlxMath.fastCos(angleRad) * distance;
		y = parentStrum.y + FlxMath.fastSin(angleRad) * distance;
		if (isHold) y += Const.NOTE_WIDTH_DIV2;

		alpha = parentStrum.alpha /* * (isHold ? 0.6 : 1) */;
		angle = parentStrum.scrollDirection - 90 + parentStrum.angle;
	}

	public function updateClipping(time:Float, stepDuration:Float) {
		if (!isHold || !hasBeenHit) return;

		var tempRect = clipRect?.set() ?? FlxRect.get();
		var clipHeight:Float = frameHeight * (songTime - time) / stepDuration / originNote.parentStrum.scrollSpeed;

		clipHeight = Math.min(clipHeight + Const.NOTE_WIDTH_DIV2, frameHeight);
		tempRect.setSize(frameWidth, clipHeight);
		if (!Options.data.downscroll) tempRect.y = frameHeight - clipHeight;
		clipRect = tempRect;
	}

	public inline function forceHit() {
		@:privateAccess parentStrum.parentLine.hitNote(this);
	}

	public inline function forceMiss() {
		@:privateAccess parentStrum.parentLine.missNote(this);
	}

	public function isPossibleToHit(time:Float):Bool {
		if (isHold) return songTime - time <= 0;
		else return Math.abs(songTime - time) <= Const.NOTE_HIT_WINDOW;
	}
}
