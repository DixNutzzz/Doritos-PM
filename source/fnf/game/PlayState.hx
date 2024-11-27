package fnf.game;

import flixel.sound.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import fnf.backend.beatmap.Beatmap;
import fnf.backend.beatmap.BeatmapData;

class PlayState extends MusicBeatState {
	public var beatmap:BeatmapData;

	public var camGame:GameCamera;
	public var camHUD:HudCamera;

	/** Alias to `FlxG.sound.music` **/
	public var inst:FlxSound;

	public var strumLines:FlxTypedGroup<StrumLine>;

	private var tryHits:Array<{ key:Int, time:Float }>;

	override function create() {
		beatmap = Beatmap.get('test');
		Conductor.mapBPMChanges(beatmap);

		camGame = new GameCamera();
		FlxG.cameras.reset(camGame);

		camHUD = new HudCamera();
		FlxG.cameras.add(camHUD, false);

		strumLines = new FlxTypedGroup<StrumLine>();
		strumLines.cameras = [ camHUD ];
		add(strumLines);

		for (strumDat in beatmap.strumLines) {
			var strumLine = new StrumLine(strumDat.strumPos, strumDat.strumVisible, strumDat.notes, beatmap.noteKinds);
			strumLines.add(strumLine);
		}

		FlxG.sound.playMusic(Paths.inst('test'));
		inst = FlxG.sound.music;

		super.create();
	}

	override function update(elapsed:Float) {
		Conductor.songPosition = inst.time;

		super.update(elapsed);
	}
}
