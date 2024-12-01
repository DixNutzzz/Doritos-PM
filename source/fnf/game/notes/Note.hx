package fnf.game.notes;

import fnf.backend.Conductor;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import haxe.ds.ReadOnlyArray;
import flixel.FlxSprite;

@:allow(fnf.game.notes.StrumLine)
class Note extends FlxSprite {
	public static inline var DEFAULT_SCALE = 0.7;
	public static inline var UNSCALED_WIDTH = 160;
	public static inline var WIDTH = UNSCALED_WIDTH * DEFAULT_SCALE;
	public static inline var WIDTH_DIV2 = WIDTH / 2;
	public static inline var SUSTAIN_SIZE = 44;

	public static final DIRECTIONS:ReadOnlyArray<String> = ['left', 'down', 'up', 'right'];
	public static final COLORS:ReadOnlyArray<String> = ['purple', 'blue', 'green', 'red'];

	public final songTime:Float;
	public final noteKind:String;
	public final sustainLength:Float;

	public var strumIndex(get, never):Null<Int>;

	@:noCompletion inline function get_strumIndex()
		return parentStrum?.index;

	public final isSustain = false;

	public var parentStrum:Strum;

	// Customization variables
	public var scrollSpeed = 1.0;
	public var lowPriority = false;

	private var spawned = false;
	private var pressed = false;
	private var missed = false;

	public function new(time:Float, strum:Strum, kind:String, ?length:Float, sustain = false) {
		super(0, FlxG.height * 3);
		songTime = time;
		parentStrum = strum;
		noteKind = kind;
		sustainLength = length;
		isSustain = sustain;

		if (isSustain) scale.y = 0.7;
	}

	public function reloadNote(texture = 'default', scale = 1.0):Note {
		frames = Paths.getSparrowAtlas('game/notes/${texture}');
		antialiasing = ClientPrefs.data.antialiasing;

		var color = COLORS[strumIndex];
		if (isSustain) {
			animation.addByPrefix('hold', '${color} hold piece', 24);
			animation.addByPrefix('holdend', '${color} hold end', 24);

			if (!animation.exists('end') && color == 'purple')
				animation.addByPrefix('holdend', 'pruple end hold', 24);

			animation.play('holdend');

			this.scale.x = scale;
		} else {
			animation.addByPrefix('scroll', color + '0', 24);
			animation.play('scroll');

			setGraphicSize(width * scale);
		}
		updateHitbox();

		return this;
	}

	public function getScrollSpeed():Float {
		var result = scrollSpeed;
		if (PlayState.ME?.beatmap != null)
			result *= PlayState.ME.beatmap.scrollSpeed;
		if (parentStrum != null) {
			result *= parentStrum.scrollSpeed;
			if (parentStrum.parentLine != null)
				result *= parentStrum.parentLine.scrollSpeed;
		}
		return result;
	}

	public function isPossibleToHit(time:Float):Bool {
		if (isSustain) return songTime - time <= 0;
		else return Math.abs(songTime - time) <= PlayState.NOTE_HIT_WINDOW;
		return false;
	}

	override function update(elapsed:Float) {
		// if (missed && !isOnScreen(camera)) kill();
		if (alive && exists) super.update(elapsed);
	}

	public function updatePosition(time:Float) {
		var timeDiff = songTime - time;
		var angleRad = parentStrum.scrollDirection * FlxAngle.TO_RAD;

		var distance = timeDiff * 0.45 * Math.fround(getScrollSpeed() * 100) / 100;

		x = parentStrum.x + (parentStrum.width - width) / 2 + FlxMath.fastCos(angleRad) * distance;
		y = parentStrum.y + FlxMath.fastSin(angleRad) * distance;
		if (isSustain)
			y += WIDTH_DIV2;

		alpha = parentStrum.alpha * (isSustain ? 0.6 : 1);
		angle = parentStrum.scrollDirection - 90 + parentStrum.angle;
	}

	public function updateClipping(time:Float) {
		if (!isSustain) return;

		var tempRect = clipRect?.set() ?? FlxRect.get();
		var clipHeight:Float = frameHeight;

		var stepDuration = 60 / Conductor.ME.bpm * 1000 / 4;
		clipHeight = frameHeight * (songTime - time) / stepDuration / getScrollSpeed();

		clipHeight = Math.min(clipHeight + WIDTH_DIV2, frameHeight);
		tempRect.setSize(frameWidth, clipHeight);
		if (!ClientPrefs.data.downscroll) tempRect.y = frameHeight - clipHeight;
		clipRect = tempRect;
	}

	public function resizeByRatio(ratio:Float) {
		if (!isSustain || animation.name != 'hold' || ratio == 0) return;

		scale.y *= ratio;
		updateHitbox();
	}

	override function set_clipRect(v):FlxRect {
		clipRect = v;
		if (frames != null) frame = frames.frames[animation.frameIndex];
		return v;
	}
}
