package fnf.game.notes;

import flixel.FlxCamera;
import fnf.backend.Conductor;
import fnf.backend.beatmap.BeatmapData;
import flixel.util.FlxSort;
import fnf.backend.Controls;
import fnf.backend.Controls.Action;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StrumLine extends FlxTypedSpriteGroup<Strum> {
	public var scrollSpeed = 1.0;

	public var notes:FlxTypedGroup<Note>;
	public final noteScale = 1.0;

	public var cpuControlled = false;

	public function new(pos:Array<Float>, scale:Float, speed:Float) {
		super(pos[0] * FlxG.width, pos[1]);
		scrollSpeed = speed;
		noteScale = scale * 0.7;

		for (i in 0...4) {
			var strum = new Strum(i);
			strum.parentLine = this;
			strum.reloadNote(noteScale);
			add(strum);

			strum.x += i * (Note.UNSCALED_WIDTH * noteScale);
			strum.updateHitbox();
		}
		x -= width / 2;

		notes = new FlxTypedGroup<Note>();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, handleInput);
	}

	public function generateNotes(beatmap:BeatmapData, index:Int) {
		var data = beatmap.strumLines[index];
		for (dat in data.notes) {
			var note = new Note(dat.t, members[dat.s], beatmap.noteKinds[dat.k], dat.l);
			note.reloadNote(noteScale);

			var startStepDuration = 60 / Conductor.ME.getEventAtTime(0).bpm * 1000 / 4;
			var stepDuration = 60 / Conductor.ME.getEventAtTime(note.songTime).bpm * 1000 / 4;

			var numSustains = Math.floor(dat.l / stepDuration);
			var oldSustain:Note = null;
			if (numSustains > 0) for (i in 0...numSustains) {
				var sustain = new Note(note.songTime + stepDuration * i, note.parentStrum, note.noteKind, 0, true);
				sustain.reloadNote(noteScale);
				notes.add(sustain);

				sustain.animation.play('holdend');
				if (oldSustain != null) {
					oldSustain.animation.play('hold');
					oldSustain.resizeByRatio(stepDuration / 100 * 1.05);
					oldSustain.resizeByRatio(Note.SUSTAIN_SIZE / oldSustain.frameHeight);
					oldSustain.resizeByRatio(stepDuration / startStepDuration);
				}
				oldSustain = sustain;
			}

			notes.add(note);
		}
	}

	override function draw() @:privateAccess {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null) FlxCamera._defaultCameras = _cameras;

		for (basic in members) if (basic != null && basic.exists && basic.visible) basic.draw();
		notes.draw();

		FlxCamera._defaultCameras = oldDefaultCameras;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		notes.update(elapsed);

		var time = @:privateAccess FlxG.sound.music?._channel?.position ?? 0;
		notes.forEachAlive(note -> !note.spawned ? {
			var spawnDelay = 2000 / note.getScrollSpeed();
			if (note.songTime - time < spawnDelay) {
				note.spawned = true;
				trace('spawn note!');
			}
		} : {
			note.updatePosition(time);
			note.updateClipping(time);
		});

		if (cpuControlled) {
			notes.forEachAlive(note -> if (note.spawned) {
				if (note.songTime <= time) hitNote(note);
			});
		} else {
			for (i => action in Controls.NOTE_CONTROLS)
				if (Controls.pressed(action)) keyHold(i);
		}
	}

	override function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, handleInput);

		super.destroy();
	}

	private function handleInput(e:KeyboardEvent) {
		if (cpuControlled) return;
		if (e.altKey) return;

		for (i => action in Controls.NOTE_CONTROLS) {
			var keys = Controls.getKeys(action);
			if (keys.contains(e.keyCode)) {
				switch e.type {
					case KeyboardEvent.KEY_DOWN: keyPress(i);
					case KeyboardEvent.KEY_UP: keyRelease(i);
				}
			}
		}
	}

	public function keyPress(key:Int) {
		var time = @:privateAccess FlxG.sound.music?._channel?.position ?? 0;
		var inputNotes = notes.members.filter(note -> note.alive && note.strumIndex == key && !note.isSustain && note.isPossibleToHit(time));
		inputNotes.sort(sortInputNotes);

		if (inputNotes.length > 0) {
			var note = inputNotes[0];

			if (inputNotes.length > 1) {
				var doubleNote = inputNotes[1];

				if (doubleNote.strumIndex == note.strumIndex) {
					if (Math.abs(doubleNote.songTime - note.songTime) < 1) doubleNote.kill();
					else if (doubleNote.songTime < note.songTime) note = doubleNote;
				}
			}
			hitNote(note);
		}

		var strum = members[key];
		if (strum != null && strum.animation.name != 'confirm') strum.playAnim('pressed');
	}

	public function keyHold(key:Int) {

	}

	public function keyRelease(key:Int) {
		notes.forEachAlive(note -> if (note.spawned && note.isSustain && note.pressing && note.strumIndex == key) {
			note.pressing = false;
		});

		members[key]?.playAnim('static');
	}

	public static function sortInputNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority) return 1;
		if (!a.lowPriority && b.lowPriority) return -1;
		return FlxSort.byValues(FlxSort.ASCENDING, a.songTime, b.songTime);
	}

	private function hitNote(note:Note) {
		note.parentStrum.playAnim('confirm', true);
		if (!note.isSustain) note.kill();
		else note.pressing = true;
	}

	public function strumPlayAnim(index:Int, name:String, force = false, reversed = false, frame = 0) {
		var strum = members[index];
		if (strum == null) return;

		strum.playAnim(name, force, reversed, frame);
		if (cpuControlled) strum.resetTimer = (60 / Conductor.ME.bpm * 1000 / 4) * 1.25 / 1000;
	}
}
