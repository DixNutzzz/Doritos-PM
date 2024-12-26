package game.data.song;

import flixel.FlxG;
import haxe.Json;
import game.data.song.migration.*;

class SongRegistry {
	private static final legacyMigrator = new LegacySongMigrator();
	private static final psychMigrator = new PsychSongMigrator();

	public static function get(song:String, diff = 'normal'):SongData {
		final fmtSong = Paths.formatSongPath(song);
		final fmtDiff = Paths.formatSongPath(diff);

		var path = Paths.file('songs/${fmtSong}/charts/${fmtDiff}.json', TEXT);
		var content = FlxG.assets.getText(path);
		if (content == null) return create(song);

		var json:Dynamic = Json.parse(content);

		if (json.isDoritos) return json;
		else if (legacyMigrator.match(json)) {
			FlxG.log.notice('Parsing legacy chart...');
			return legacyMigrator.migrate(json);
		} else if (psychMigrator.match(json)) {
			FlxG.log.notice('Parsing psych chart...');
			return psychMigrator.migrate(json);
		}

		FlxG.log.error('Could not find any valid chart!');
		return create(song);
	}

	public static function create(song:String):SongData {
		return {
			meta: {
				song: song,
				bpm: 100,
				beatsPerMeasure: 4,
				stepsPerBeat: 4
			},
			playData: {
				stage: 'stage',
				scrollSpeed: 1,
				noteKinds: [ '' ],
				strumlines: []
			},

			needsVoices: false,
			events: [],
			notes: [],

			isDoritos: true
		}
	}
}
