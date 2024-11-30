package fnf.game;

import fnf.backend.Conductor;
import flixel.FlxG;
import fnf.backend.beatmap.Beatmap;
import fnf.game.notes.StrumLine;
import flixel.group.FlxGroup.FlxTypedGroup;
import fnf.backend.beatmap.BeatmapData;

class PlayState extends flixel.addons.transition.FlxTransitionableState {
	public static inline var NOTE_HIT_WINDOW = 160;

	public static var ME:PlayState;

	public var beatmap:BeatmapData;

	public var strumLines:FlxTypedGroup<StrumLine>;

	override function create() {
		ME = this;

		beatmap = Beatmap.get('test');
		Conductor.ME.uploadBeatmap(beatmap);

		strumLines = new FlxTypedGroup<StrumLine>();
		add(strumLines);

		FlxG.sound.playMusic(Paths.inst(beatmap.meta.song));

		for (i => dat in beatmap.strumLines) {
			var strumLine = new StrumLine(dat.strumPos, dat.strumScale, dat.scrollSpeed);
			strumLine.cpuControlled = dat.cpu;
			strumLine.generateNotes(beatmap, i);
			strumLines.add(strumLine);
		}

		super.create();
	}
}
