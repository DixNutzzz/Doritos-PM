package fnf.backend.beatmap;

import fnf.backend.beatmap.migration.LegacyBeatmapMigrator;
import fnf.backend.beatmap.migration.PsychBeatmapMigrator;
import haxe.Json;
import haxe.Unserializer;
import openfl.Assets;
import haxe.io.Path;

class Beatmap {
	private static var psychMigrator = new PsychBeatmapMigrator();
	private static var legacyMigrator = new LegacyBeatmapMigrator();

	public static function get(song:String, diff = 'normal'):BeatmapData {
		var fmtSong = Paths.formatSongPath(song),
			fmtDiff = Paths.formatSongPath(diff);

		var beatmapPath = Paths.data(Path.join(['beatmaps', Paths.formatSongPath(song), Paths.formatSongPath(diff) + '.beatmap']));
		if (Assets.exists(beatmapPath, TEXT)) {
			var beatmap = Unserializer.run(Assets.getText(beatmapPath));

			for (name in ['meta-${fmtDiff}.json', 'meta.json']) {
				if (beatmap.meta != null) break; // in case if meta is embed in beatmap
				var metaPath = Paths.data(Path.join(['beatmaps', fmtSong, name]));
				if (Assets.exists(metaPath, TEXT))
					beatmap.meta = Json.parse(Assets.getText(metaPath));
			}

			if (beatmap.meta == null) {
				Logger.error('There is no meta for ${song}');
				return createEmpty(song);
			}

			for (name in ['events-${fmtDiff}.json', 'events.json']) {
				if (beatmap.events != null) break; // in case if events are embed in beatmap
				var eventsPath = Paths.data(Path.join(['beatmaps', fmtSong, name]));
				if (Assets.exists(eventsPath, TEXT))
					beatmap.events = Json.parse(Assets.getText(eventsPath));
			}

			if (beatmap.events == null)
				beatmap.events = [];

			return beatmap;
		}

		var jsonPath = Paths.data(Path.join(['beatmaps', Paths.formatSongPath(song), Paths.formatSongPath(diff) + '.json']));
		if (Assets.exists(jsonPath, TEXT)) {
			var json:Dynamic = Json.parse(Assets.getText(jsonPath));
			Logger.notice('Check psych chart match');
			if (psychMigrator.match(json)) {
				Logger.notice('Psych chart matched');
				return psychMigrator.migrate(json);
			}
			Logger.notice('Check legacy chart match');
			if (legacyMigrator.match(json)) {
				Logger.notice('Legacy chart matched');
				return legacyMigrator.migrate(json);
			}
		}

		Logger.error('Invalid chart');
		return createEmpty(song);
	}

	public static function createEmpty(song:String):BeatmapData {
		return {
			meta: {
				song: song,
				bpm: 0,
				beatsPerMeasure: 4,
				stepsPerBeat: 4,
				needsVoices: false,
				offset: 0
			},
			events: [],

			scrollSpeed: 1,
			noteKinds: [],
			strumLines: [],
			stage: 'stage'
		}
	}
}
