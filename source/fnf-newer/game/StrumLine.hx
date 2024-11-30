package fnf.game;

import flixel.util.FlxSort;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import fnf.backend.beatmap.BeatmapData.NoteData;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StrumLine extends FlxTypedSpriteGroup<Strum> {
	public var notes:FlxTypedGroup<Note>;

	public var cpuControlled = false;

	public function new(pos:Array<Float>, visible = true, noteDatas:Array<NoteData>, noteKinds:Array<String>) {
		super(pos[0] * FlxG.width, pos[1]);
		for (i in 0...4) {
			var strum = new Strum(i);
			strum.reloadNote();
			strum.x += Note.STRUM_SIZE * i;
			add(strum);
		}
		x -= width / 2;

		notes = new FlxTypedGroup<Note>();

		for (dat in noteDatas) {
			var note = new Note(dat.t, dat.s, members[dat.s], noteKinds[dat.k]);
			note.reloadNote();
			for (sustain in note.createSustains(dat.l)) {
				sustain.reloadNote();
				notes.add(sustain);
			}
			notes.add(note);
		}
	}

	public function hitAllPossibleNotes(key:Int) {
		if (cpuControlled) return;

		var inputNotes = notes.members.filter(note -> note.alive && note?.strumIndex == key && !note?.isSustain() && note?.isPossibleToHit());
		inputNotes.sort(sortInputNotes);

		if (inputNotes.length != 0) {
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
	}

	public function hitAllPossibleSustains(key:Int) {
		if (cpuControlled) return;

		var inputNotes = notes.members.filter(note -> note.alive && note?.strumIndex == key && note?.isSustain() && note?.isPossibleToHit());
		for (note in inputNotes) hitNote(note);
	}

	public function hitNote(note:Note) {
		note.parentStrum.playAnim('confirm');
		if (note.isSustain()) note.hasBeenHit = true;
		else note.kill();

		if (cpuControlled) note.parentStrum.resetAnim = Conductor.stepDuration * 1.25 / 1000;
	}

	public static function sortInputNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority) return 1;
		if (!a.lowPriority && b.lowPriority) return -1;
		return FlxSort.byValues(FlxSort.ASCENDING, a.songTime, b.songTime);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		Conductor.updatePosition(FlxG.sound.music);
		notes.update(elapsed);

		notes.forEachAlive(note -> if (!note.spawned) {
			var time = 2000 / note.parentStrum.scrollSpeed;
			if (note.songTime - Conductor.songPosition < time) {
				note.spawned = true;
			}
		});

		notes.forEachAlive(note -> if (note.spawned) {
			var distance = -0.45 * (Conductor.songPosition - note.songTime) * note.parentStrum.scrollSpeed;
			var direction = note.parentStrum.direction * FlxAngle.TO_RAD;

			note.angle = note.parentStrum.direction - 90 + note.parentStrum.angle + note.addAngle;
			note.alpha = note.parentStrum.alpha * note.multAlpha;

			note.x = note.parentStrum.x + note.addX + FlxMath.fastCos(direction) * distance;
			note.y = note.parentStrum.y + note.addY + FlxMath.fastSin(direction) * distance;
		});
	}


	override function draw() @:privateAccess {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null) FlxCamera._defaultCameras = _cameras;

		for (basic in members) if (basic != null && basic.exists && basic.visible) basic.draw();
		notes.draw();

		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}
