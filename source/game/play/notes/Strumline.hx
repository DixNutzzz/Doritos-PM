package game.play.notes;

import game.backend.Controls;
import flixel.util.FlxSort;
import game.backend.Controls;
import openfl.events.KeyboardEvent;
import game.backend.Conductor;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.FlxG;
import game.data.song.SongData;
import flixel.group.FlxSpriteGroup;

using game.utils.tools.FlxSoundTools;

class Strumline extends FlxSpriteGroup {
	public var strums(default, null):FlxTypedSpriteGroup<Strum>;
	public var notes(default, null):FlxTypedSpriteGroup<Note>;

	private var _unspawnNotes:Array<Note> = [];

	public var onNoteSpawn(default, null):FlxTypedSignal<Note->Void>;
	public var onNoteHit(default, null):FlxTypedSignal<Note->Void>;
	public var onNoteMiss(default, null):FlxTypedSignal<Note->Void>;

	public var cpuControlled = true;

	public var owner:Character;

	public function new(dat:StrumlineData) {
		super(dat.pos[0] * FlxG.width, dat.pos[1]);

		strums = new FlxTypedSpriteGroup<Strum>();
		add(strums);

		notes = new FlxTypedSpriteGroup<Note>();
		add(notes);

		for (i in 0...4) {
			var strum = new Strum(i);
			strum.parentLine = this;
			strum.reloadNote();
			strums.add(strum);

			strum.x += Const.NOTE_WIDTH * i;
		}

		x -= strums.width / 2;

		onNoteSpawn = new FlxTypedSignal<Note->Void>();
		onNoteHit = new FlxTypedSignal<Note->Void>();
		onNoteMiss = new FlxTypedSignal<Note->Void>();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, handleInput);
	}

	public function addNote(time:Float, length:Float, strum:Int, kind:String) {
		var note = new Note(time, kind);
		note.parentStrum = strums.members[strum];
		note.reloadNote();
		_unspawnNotes.push(note);
		// notes.add(note);

		var bpmChange = Conductor.getEvent(time);
		var stepDuration = 60 / bpmChange.bpm * 1000 / bpmChange.stepsPerBeat;

		var sustainLength = Math.floor(length / stepDuration);
		if (sustainLength > 0) for (i in 0...sustainLength) {
			var holdNote = new Note(time + i * stepDuration, kind);
			holdNote.originNote = note;
			holdNote.reloadNote(true, i == sustainLength - 1);
			_unspawnNotes.insert(_unspawnNotes.indexOf(note), holdNote);
			// notes.insert(notes.members.indexOf(note), holdNote);
		}
	}

	public inline function sortUnspawnNotes() {
		_unspawnNotes.sort((a, b) -> return FlxSort.byValues(FlxSort.ASCENDING, a.songTime, b.songTime));
	}

	private function hitNote(note:Note) {
		if (note.hasBeenHit) return;

		note.parentStrum.playAnim('confirm', true);

		if (cpuControlled) {
			var bpmChange = Conductor.getEvent(FlxG.sound.music.getAccurateTime());
			note.parentStrum.glowCountdown = (60 / bpmChange.bpm * 1000 / bpmChange.stepsPerBeat) * 1.25 / 1000;
		}

		note.hasBeenHit = true;
		if (!note.isHold || (note.clipRect != null && note.clipRect.height <= 0)) note.kill();

		owner?.sing(note.parentStrum.index);

		onNoteHit.dispatch(note);
	}

	private function missNote(note:Note) {
		onNoteMiss.dispatch(note);
	}

	override function update(elapsed:Float) {
		var time = FlxG.sound.music.getAccurateTime();

		if (_unspawnNotes.length > 0) {
			while (_unspawnNotes.length > 0) {
				var note = _unspawnNotes[0];
				var spawnDelay = Const.NOTE_SPAWN_DELAY;
				if (note.parentStrum.scrollSpeed < 1) spawnDelay /= note.parentStrum.scrollSpeed;
				else spawnDelay *= note.parentStrum.scrollSpeed;

				if (note.songTime - time < spawnDelay) {
					_unspawnNotes.remove(note);
					notes.add(note);
				} else
					break;
			}
		}

		var bpmChange = Conductor.getEvent(time);
		notes.forEachAlive(note -> {
			note.updatePosition(time);
			note.updateClipping(time, 60 / bpmChange.bpm * 1000 / bpmChange.stepsPerBeat);
		});

		if (cpuControlled) {
			notes.forEachAlive(note -> {
				if (note.songTime <= time) hitNote(note);
			});
		} else {
			for (i => control in Controls.NOTE_CONTROLS)
				if (Controls.pressed(control)) keyHold(i);
		}

		super.update(elapsed);
	}

	override function destroy() {
		onNoteSpawn.destroy();
		onNoteHit.destroy();
		onNoteMiss.destroy();

		onNoteSpawn = onNoteHit = onNoteMiss = null;

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
					case KeyboardEvent.KEY_DOWN: if (FlxG.keys.checkStatus(e.keyCode, JUST_PRESSED)) keyPress(i);
					case KeyboardEvent.KEY_UP: keyRelease(i);
				}
			}
		}
	}

	public function keyPress(key:Int) {
		var time = FlxG.sound.music.getAccurateTime();
		var inputNotes = notes.members.filter(note -> note.alive && !note.hasBeenHit && !note.missed && note.parentStrum.index == key && !note.isHold && note.isPossibleToHit(time));
		inputNotes.sort(sortInputNotes);

		if (inputNotes.length > 0) {
			var note = inputNotes[0];

			if (inputNotes.length > 1) {
				var doubleNote = inputNotes[1];

				if (doubleNote.parentStrum.index == note.parentStrum.index) {
					if (Math.abs(doubleNote.songTime - note.songTime) < 1) doubleNote.kill();
					else if (doubleNote.songTime < note.songTime) note = doubleNote;
				}
			}
			hitNote(note);
		}

		var strum = strums.members[key];
		if (strum != null && strum.animation.name != 'confirm') strum.playAnim('pressed');
	}

	public function keyHold(key:Int) {
		var time = FlxG.sound.music.getAccurateTime();
		notes.forEachAlive(note -> if (note.isHold && !note.hasBeenHit && !note.missed && note.parentStrum.index == key) {
			if (note.isPossibleToHit(time)) hitNote(note);
		});
	}

	public function keyRelease(key:Int) {
		strums.members[key]?.playAnim('static');
	}

	public static function sortInputNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority) return 1;
		if (!a.lowPriority && b.lowPriority) return -1;
		return FlxSort.byValues(FlxSort.ASCENDING, a.songTime, b.songTime);
	}
}
