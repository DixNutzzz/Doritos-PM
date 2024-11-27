package fnf.backend.beatmap;

import haxe.Json;
import haxe.Unserializer;
import openfl.Assets;

class Beatmap {
	public static function get(song:String, diff = 'normal'):BeatmapData {
		var path = Paths.beatmap(song, diff);
		if (Assets.exists(path)) return parseBeatmap(Assets.getText(path), song);

		path = Paths.chart(song, diff);
		if (Assets.exists(path)) return parseJson(Assets.getText(path), song);

		return createEmpty(song);
	}

	public static function parseBeatmap(text:String, ?song:String):BeatmapData {
		var beatmap:BeatmapData = null;

		try beatmap = Unserializer.run(text)
			catch(e) Logger.warn('Beatmap parsing: $e');

		if (beatmap != null) {
			// safety stuff
		}

		return beatmap ?? createEmpty(song);
	}

	public static function parseJson(text:String, ?song:String):BeatmapData {
		var json:Dynamic = null;
		try json = Json.parse(text)
			catch(e) Logger.warn('Chart parsing: $e');

		if (json.song is String) return json;
		else if (json.codenameChart) { // codename
			Logger.warn('Chart parsing: Codename chart not supported yet');
			return createEmpty(song);
		} else if (json.song != null) { // psych / legacy
			json = json.song;
			var beatmap:BeatmapData = {
				song: json.song,
				bpm: json.bpm,
				needsVoices: json.needsVoices,

				playerChar: json.player1,
				opponentChar: json.player2,
				additionalChar: json.gfVersion ?? json.player3 ?? 'gf',
				stage: json.stage ?? 'stage',

				scrollSpeed: json.speed ?? 1,

				events: {
					kinds: [],
					params: [],
					list: []
				},
				notes: {
					kinds: [],
					list: []
				}
			}
			return beatmap;
		}

		return createEmpty(song);
	}

	public static function createEmpty(?song:String):BeatmapData {
		return {
			song: song ?? 'Unknown',
			bpm: 100,
			needsVoices: false,

			playerChar: 'bf',
			opponentChar: 'bf-pixel-opponent',
			additionalChar: null,
			stage: 'stage',

			scrollSpeed: 1,

			events: {
				kinds: [],
				params: [],
				list: []
			},
			notes: {
				kinds: [],
				list: []
			}
		};
	}
}
