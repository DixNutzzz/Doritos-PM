package game.play;

import flixel.FlxCamera;
import lime.media.AudioBuffer;
import openfl.media.Sound;
import flixel.addons.display.FlxZoomCamera;
import flixel.FlxSubState;
import flixel.sound.FlxSound;
import game.backend.Conductor;
import flixel.FlxG;
import game.play.notes.*;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.data.song.SongRegistry;
import game.data.song.SongData;

using game.utils.tools.FlxSoundTools;

class PlayState extends MusicBeatState {
	public static var ME:PlayState;

	public var song(default, null):SongData;
	public var difficulty(default, null):String;

	public var camGame(default, null):FlxZoomCamera;
	public var camHUD(default, null):FlxZoomCamera;
	public var camOther(default, null):FlxCamera;

	public var strumlines(default, null):FlxTypedGroup<Strumline>;

	public var paused(default, null) = false;
	public var pauseMenu:FlxSubState;

	public var inst:FlxSound;
	public var vocals:Array<FlxSound> = [];

	public var maxHealth = 2.0;
	public var health:Float;

	public function new() {
		super();

		health = maxHealth / 2;

		destroySubStates = false;
	}

	override function create() {
		song = SongRegistry.get('dermo', difficulty = 'normal');
		Conductor.uploadSong(song);

		camGame = new FlxZoomCamera(0, 0, 0, 0, 0.9);
		FlxG.cameras.reset(camGame);

		camHUD = new FlxZoomCamera(0, 0, 0, 0, 1);
		camHUD.bgColor = 0x00000000;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.bgColor = 0x00000000;
		FlxG.cameras.add(camOther, false);

		strumlines = new FlxTypedGroup<Strumline>();
		strumlines.cameras = [ camHUD ];
		add(strumlines);

		for (i => dat in song.playData.strumlines) {
			var strumline = new Strumline(dat);
			strumline.cpuControlled = dat.cpu;
			strumline.strums.forEach(strum -> strum.scrollSpeed = song.playData.scrollSpeed);
			strumlines.add(strumline);

			var character = new Character(dat.char.name, dat.char.pos == 1);
			strumline.owner = character;
			add(character);
		}

		for (dat in song.notes) {
			var strumline = strumlines.members[dat.p];
			if (strumline == null) continue;

			strumline.addNote(dat.t, dat.l, dat.s, song.playData.noteKinds[dat.k]);
		}

		inst = FlxG.sound.music = FlxG.sound.load(Paths.inst(song.meta.song, difficulty));

		var pushedSuffixes:Array<String> = [];
		if (Options.data.joinVocals) {
			for (dat in song.playData.strumlines) if (!pushedSuffixes.contains(dat.vocalsSuffix)) {
				pushedSuffixes.push(dat.vocalsSuffix);
			}
			var buffer = AudioBuffer.fromFiles([ for (suffix in pushedSuffixes) Paths.vocals(song.meta.song, difficulty, suffix) ]);
			var sound = Sound.fromAudioBuffer(buffer);
			vocals.push(FlxG.sound.load(sound));
		} else {
			for (dat in song.playData.strumlines) if (!pushedSuffixes.contains(dat.vocalsSuffix)) {
				vocals.push(FlxG.sound.load(Paths.vocals(song.meta.song, difficulty, dat.vocalsSuffix)));
				pushedSuffixes.push(dat.vocalsSuffix);
			}
		}

		pauseMenu = new PauseSubState(song, difficulty);
		pauseMenu.cameras = [ camOther ];

		super.create();

		startSong();
	}

	public function startSong() {
		inst.play();
		for (vocal in vocals) vocal.play();
	}

	override function onFocus() {
		inst.resume();
		super.onFocus();
	}

	override function update(elapsed:Float) {
		Conductor.update(FlxG.sound.music.getAccurateTime());

		if (FlxG.keys.justPressed.ENTER)
			openPauseMenu();

		super.update(elapsed);
	}

	override function destroy() {
		pauseMenu?.destroy();
		super.destroy();
	}

	private function onNoteMiss(note:Note) {
		note.kill();
		health -= 0.08;
	}

	public function openPauseMenu() {
		paused = true;
		openSubState(pauseMenu);
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			inst.pause();
			for (vocal in vocals) vocal.pause();
		}
		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			inst.resume();
			for (vocal in vocals) vocal.resume();
			paused = false;
		}

		super.closeSubState();
	}
}
