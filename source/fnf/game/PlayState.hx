package fnf.game;

import flixel.sound.FlxSound;
import flixel.addons.display.FlxZoomCamera;
import fnf.backend.MemUtil;
import fnf.backend.Conductor;
import flixel.FlxG;
import fnf.backend.beatmap.Beatmap;
import fnf.game.notes.StrumLine;
import flixel.group.FlxGroup.FlxTypedGroup;
import fnf.backend.beatmap.BeatmapData;

class PlayState extends MusicBeatState {
	public static inline var NOTE_HIT_WINDOW = 160;

	public static var ME:PlayState;

	public var beatmap:BeatmapData;
	public final difficulty = 'normal';

	public var strumLines:FlxTypedGroup<StrumLine>;

	/** Alias to `FlxG.sound.music` **/
	public var inst:FlxSound;
	public var vocals:Array<FlxSound> = [];
	public var skipping = false;

	public var camGame:FlxZoomCamera;
	public var camHUD:FlxZoomCamera;

	public var cameraBopStrength = 1.0;

	override function create() {
		ME = this;

		beatmap = Beatmap.get('test');
		Conductor.ME.uploadBeatmap(beatmap);

		FlxG.sound.music = inst = FlxG.sound.load(Paths.inst(beatmap.meta.song, difficulty));
		inst.persist = true;

		var pushedVocals:Array<String> = [];
		for (dat in beatmap.strumLines) {
			var path = Paths.vocals(beatmap.meta.song, difficulty, dat.vocalsSuffix);
			if (pushedVocals.contains(path)) continue;

			vocals.push(FlxG.sound.load(path));
			pushedVocals.push(path);
		}

		camGame = new FlxZoomCamera(0, 0, 0, 0, 1);
		camGame.zoomSpeed = 9;
		FlxG.cameras.reset(camGame);

		camHUD = new FlxZoomCamera(0, 0, 0, 0, 1);
		camHUD.zoomSpeed = 9;
		FlxG.cameras.add(camHUD, false);

		strumLines = new FlxTypedGroup<StrumLine>();
		strumLines.cameras = [ camHUD ];
		add(strumLines);

		for (i => dat in beatmap.strumLines) {
			var strumLine = new StrumLine(dat.strumPos, dat.strumScale, dat.strumAlpha, dat.scrollSpeed);
			strumLine.cpuControlled = dat.cpu;
			strumLine.generateNotes(beatmap, i);
			strumLines.add(strumLine);

			strumLine.owner = new Character(0, 0, dat.charName, !dat.cpu);
			add(strumLine.owner);
		}

		super.create();
		startSong();
		MemUtil.clear(true);
	}

	function startSong() {
		inst.play();
		for (vocal in vocals) vocal.play();
	}

	override function update(elapsed:Float) {
		Conductor.ME.update(FlxG.sound.music);
		skipping = FlxG.keys.pressed.THREE;

		if (FlxG.sound.music.pitch != (FlxG.sound.music.pitch = skipping ? 3 : 1))
			resyncVocals();

		super.update(elapsed);
	}

	override function destroy() {
		super.destroy();
		MemUtil.clear(true);
	}

	public function resyncVocals() @:privateAccess {
		for (vocal in vocals) if (inst._channel.position <= vocal.length) {
			vocal.time = inst._channel.position;
			vocal.pitch = inst.pitch;
		}
	}

	override function stepHit(step:Int) @:privateAccess {
		for (vocal in vocals) {
			if (Math.abs(vocal._channel.position) - inst._channel.position > 20)
				resyncVocals();
		}
	}

	override function beatHit(beat:Int) {
		for (sl in strumLines) if (beat % sl.owner.danceEvery == 0) sl.owner.dance();
	}

	override function measureHit(measure:Int) {
		if (camGame.zoom < 1.35) {
			camGame.zoom += 0.015 * cameraBopStrength;
			camHUD.zoom += 0.03 * cameraBopStrength;
		}
	}
}
