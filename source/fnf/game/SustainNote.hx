package fnf.game;

import flixel.math.FlxRect;

class SustainNote extends Note {
	public var parentNote:Note;

	@:allow(fnf.game.Note)
	private var isEnd = false;

	override function reloadNote():SustainNote {
		frames = Paths.getSparrowAtlas('game/notes/default');
		antialiasing = true;

		animation.addByPrefix('piece', Note.colArray[strumIndex] + ' hold piece', 24);
		animation.addByPrefix('end', Note.colArray[strumIndex] + ' hold end', 24);

		if (strumIndex == 0 && !animation.exists('end'))
			animation.addByPrefix('end', 'pruple end hold', 24);

		animation.play(isEnd ? 'end' : 'piece');

		scale.copyFrom(parentNote.scale);
		updateHitbox();

		addX = (parentNote.width - width) / 2;
		addY = parentNote.height / 2;

		return this;
	}

	override function update(elapsed:Float) {
		updateClipping();
		super.update(elapsed);
		visible = spawned && (clipRect == null || clipRect.height > 0);
	}

	public function updateClipping() {
		var tempRect = clipRect?.set() ?? FlxRect.get();
		var clipHeight:Float = frameHeight;

		if (ClientPrefs.data.noteClipByTime) {
			var stepDuration = 60 / Conductor.bpm * 1000 / 4;
			clipHeight = frameHeight * (songTime - Conductor.songPosition) / stepDuration / parentNote.parentStrum.scrollSpeed / multSpeed + addY;
			clipHeight = Math.min(clipHeight, frameHeight);
		} else {
			var center = parentNote.parentStrum.y + addY + Note.STRUM_SIZE / 2;
			clipHeight = frameHeight - (center - y) / scale.y;
			clipHeight = Math.min(clipHeight, frameHeight);
		}

		clipHeight += Note.STRUM_SIZE / 2;
		clipHeight = Math.min(clipHeight, frameHeight);

		tempRect.setSize(frameWidth, clipHeight);
		if (!ClientPrefs.data.downscroll) tempRect.y = frameHeight - tempRect.height;
		clipRect = tempRect;
	}

	override function set_clipRect(v):FlxRect {
		clipRect = ClientPrefs.data.highAccuracyNoteClip ? v : v.round();
		if (frames != null) frame = frames.frames[animation.frameIndex];
		return v;
	}
}
