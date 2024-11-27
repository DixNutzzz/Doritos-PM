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
			return fromPsych(json);
		}

		return createEmpty(song);
	}

	public static function createEmpty(?song:String):BeatmapData {
		return {
			song: song ?? 'Unknown',
			bpm: 100,
			needsVoices: false,

			stage: 'stage',

			scrollSpeed: 1,

			eventKinds: [],
			eventParams: [],
			events: [],

			noteKinds: [],
			strumLines: []
		};
	}

	private static function fromPsych(json:Dynamic) {
		var beatmap:BeatmapData = {
			song: json.song,
			bpm: json.bpm,
			needsVoices: json.needsVoices,

			stage: json.stage ?? 'stage',

			scrollSpeed: json.speed ?? 1,

			eventKinds: [],
			eventParams: [],
			events: [],

			noteKinds: [],
			strumLines: [
				{ char: json.player2, strumPos: [0.25, 50], notes: [], charVisible: true, strumVisible: true },
				{ char: json.player1, strumPos: [0.75, 50], notes: [], charVisible: true, strumVisible: true },
				{ char: json.gfVersion ?? json.player3 ?? 'gf', strumPos: [0.25, 50], notes: [], charVisible: true, strumVisible: false }
			]
		}

		for (sectionDat in (json.notes : Array<Dynamic>)) {
			var mustHitSection:Bool = sectionDat.mustHitSection;
			var gfSection:Bool = sectionDat.gfSection ?? false;
			for (noteDat in (sectionDat.sectionNotes : Array<Dynamic>)) {
				var t = noteDat[0];
				var l = noteDat[2];
				var p = Math.floor(noteDat[1] / 4);
				var s = Math.floor(noteDat[1] % 4);
				var k = noteDat[3] ?? '';

				if (noteDat[1] < 4) {
					if (mustHitSection) p = 1;
					else if (gfSection) p = 2;
				}

				addNote(beatmap, t, l, p, s, k);
			}
		}

		return beatmap;
	}

	public static function addNote(beatmap:BeatmapData, time:Float, length:Float, player:Int, strum:Int, kind:String) {
		var kindIndex = beatmap.noteKinds.indexOf(kind);
		if (kindIndex < 0) {
			kindIndex = beatmap.noteKinds.length;
			beatmap.noteKinds.push(kind);
		}
		beatmap.strumLines[player].notes.push({
			t: time,
			l: length,
			s: strum,
			k: kindIndex
		});
	}

	public static function addEvent(beatmap:BeatmapData, time:Float, kind:String, params:Array<Dynamic>) {
		var kindIndex = beatmap.eventKinds.indexOf(kind);
		if (kindIndex < 0) {
			kindIndex = beatmap.eventKinds.length;
			beatmap.eventKinds.push(kind);
		}

		var paramIndices:Array<Int> = [];
		for (param in params) {
			var paramIndex = beatmap.eventParams.indexOf(param);
			if (paramIndex < 0) {
				paramIndex = beatmap.eventParams.length;
				beatmap.eventParams.push(param);
			}
			paramIndices.push(paramIndex);
		}

		beatmap.events.push({
			t: time,
			k: kindIndex,
			p: paramIndices
		});
	}
}
