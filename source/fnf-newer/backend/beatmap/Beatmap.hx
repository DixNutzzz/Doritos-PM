package fnf.backend.beatmap;

import haxe.Json;
import haxe.Unserializer;
import openfl.Assets;

using StringTools;

class Beatmap {
	public static function get(song:String, diff = 'normal'):BeatmapData {
		var path = Paths.beatmap(song, diff);
		if (Assets.exists(path))
			return parseBeatmap(Assets.getText(path), song);

		path = Paths.chart(song, diff);
		if (Assets.exists(path))
			return parseJson(Assets.getText(path), song);

		return createEmpty(song);
	}

	public static function parseBeatmap(text:String, ?song:String):BeatmapData {
		var beatmap:BeatmapData = null;

		try beatmap = Unserializer.run(text)
		catch (e) Logger.warn('Beatmap parsing: ${e}');

		if (beatmap != null) {
			// safety stuff
		}

		return beatmap ?? createEmpty(song);
	}

	public static function parseJson(text:String, ?song:String):BeatmapData {
		var json:Dynamic = null;
		try json = Json.parse(text)
		catch (e) Logger.warn('Chart parsing: ${e}');

		if (json.song is String)
			return json;
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

			noteKinds: [''],
			strumLines: []
		};
	}

	private static function fromPsych(json:Dynamic) {
		var p2isGF = (json.player2 : String).startsWith('gf');

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
				{
					char: json.player2,
					charPos: p2isGF ? ADDITIONAL : OPPONENT,
					charVisible: true,
					strumPos: [0.25, 50],
					strumVisible: true,
					notes: [],
					cpu: true
				},
				{
					char: json.player1,
					charPos: PLAYER,
					charVisible: true,
					strumPos: [0.75, 50],
					strumVisible: true,
					notes: [],
					cpu: false
				}
			]
		}

		if (!p2isGF)
			beatmap.strumLines.push({
				char: json.gfVersion ?? json.player3 ?? 'gf',
				charPos: 2,
				charVisible: true,
				strumPos: [0.25, 50],
				strumVisible: false,
				notes: [],
				cpu: true
			});

		var camFocusedBF = false;
		var altAnim = false;
		var bpm = json.bpm;
		var curBPM = bpm;
		var time = 0.0;
		var stepDuration = 60 / curBPM * 1000 / 4;

		for (sectionDat in (json.notes : Array<Dynamic>)) {
			if (camFocusedBF != (camFocusedBF = sectionDat.mustHitSection))
				addEvent(beatmap, time, 'Camera Move', [camFocusedBF ? 1 : 0]);

			if (sectionDat.altAnim == null)
				sectionDat.altAnim = false;
			if (altAnim != (altAnim = sectionDat.altAnim))
				addEvent(beatmap, time, 'Alt Animation Toggle', [altAnim]);

			for (noteDat in (sectionDat.sectionNotes : Array<Dynamic>)) {
				var t = noteDat[0];
				var s = Math.floor(noteDat[1] % 4);
				var k = noteDat[3] ?? '';
				var p = (noteDat[1] >= 4 ? !sectionDat.mustHitSection : sectionDat.mustHitSection) ? 1 : 0;

				addNote(beatmap, t, noteDat[2], p, s, k);
			}

			time += stepDuration * 16;
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
