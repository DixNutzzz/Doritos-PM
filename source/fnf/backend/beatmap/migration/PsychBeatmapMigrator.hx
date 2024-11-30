package fnf.backend.beatmap.migration;

using StringTools;

typedef PsychChart = {
	var song:String;
	var notes:Array<PsychChartSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var ?offset:Float;

	var player1:String;
	var player2:String;
	var ?gfVersion:String;
	var ?stage:String;
}

typedef PsychChartSection = {
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var mustHitSection:Bool;
	var ?altAnim:Bool;
	var ?gfSection:Bool;
	var ?bpm:Float;
	var ?changeBPM:Bool;
}

class PsychBeatmapMigrator extends BaseBeatmapMigrator<{ song: PsychChart }> {
	override function match(data:Dynamic):Bool {
		if (data.song == null) return false;
		data = data.song;

		if (!isVarMatch(data.song, String)) return false;
		if (!isVarMatch(data.notes, Array)) return false;
		for (section in (data.notes : Array<Dynamic>)) {
			if (!isVarMatch(section.sectionNotes, Array)) return false;
			if (!isVarMatch(section.sectionBeats, Float)) return false;
			if (!isVarMatch(section.mustHitSection, Bool)) return false;
			if (!isOptionalVarMatch(section.altAnim, Bool)) return false;
			if (!isOptionalVarMatch(section.gfSection, Bool)) return false;
			if (!isOptionalVarMatch(section.bpm, Float)) return false;
			if (!isOptionalVarMatch(section.changeBPM, Bool)) return false;
		}
		if (!isVarMatch(data.events, Array)) return false;
		if (!isVarMatch(data.bpm, Float)) return false;
		if (!isVarMatch(data.needsVoices, Bool)) return false;
		if (!isVarMatch(data.speed, Float)) return false;
		if (!isOptionalVarMatch(data.offset, Float)) return false;

		if (!isVarMatch(data.player1, String)) return false;
		if (!isVarMatch(data.player2, String)) return false;
		if (!isOptionalVarMatch(data.gfVersion, String)) return false;
		if (!isOptionalVarMatch(data.stage, String)) return false;

		return true;
	}

	override function migrate(input:{ song: PsychChart }):BeatmapData {
		var data = input.song;

		var result:BeatmapData = {
			meta: {
				song: data.song,
				bpm: data.bpm,
				beatsPerMeasure: 4,
				stepsPerBeat: 4,
				needsVoices: data.needsVoices,
				offset: data.offset
			},
			events: [],

			scrollSpeed: data.speed,
			noteKinds: [ '' ],
			strumLines: [
				{
					charName: data.player2,
					charPos: OPPONENT,
					charVisible: true,

					strumPos: [ 0.25, 50 ],
					strumAlpha: 1,
					strumScale: 1,

					scrollSpeed: 1,
					cpu: true,
					notes: []
				},
				{
					charName: data.player1,
					charPos: PLAYER,
					charVisible: true,

					strumPos: [ 0.75, 50 ],
					strumAlpha: 1,
					strumScale: 1,

					scrollSpeed: 1,
					cpu: false,
					notes: []
				}
			],
			stage: data.stage ?? 'stage'
		}

		var opIsGF = data.player2.startsWith('gf');
		if (opIsGF)
			result.strumLines[0].charPos = ADDITIONAL;
		else
			result.strumLines.push({
				charName: data.gfVersion ?? 'gf',
				charPos: ADDITIONAL,
				charVisible: true,

				strumPos: [ 0.25, 50 ],
				strumAlpha: 0,
				strumScale: 1,

				scrollSpeed: 1,
				cpu: true,
				notes: []
			});

		var bpm = data.bpm;
		var camTarget = data.notes[0].mustHitSection ? 1 : 0;
		var beatsPerMeasure = data.notes[0].sectionBeats;
		var time = 0.0;

		for (section in data.notes) {
			if ((section.changeBPM && section.bpm != bpm) || section.sectionBeats != beatsPerMeasure) {
				bpm = section.changeBPM ? section.bpm : bpm;
				beatsPerMeasure = section.sectionBeats;
				result.events.push({ t: time, k: 'BPM Change', p: [ bpm, beatsPerMeasure, 4 ] });
			}

			if (camTarget != (camTarget = section.gfSection ? 2 : (section.mustHitSection ? 1 : 0)))
				result.events.push({ t: time, k: 'Camera Move', p: [ camTarget ] });

			for (note in section.sectionNotes) {
				var t = note[0];
				var s = Math.floor(note[1] % 4);
				var p = (note[1] > 3 ? !section.mustHitSection : section.mustHitSection) ? 1 : 0;

				var kind = note[3] ?? '';
				var k = result.noteKinds.indexOf(kind);
				if (k < 0) {
					k = result.noteKinds.length;
					result.noteKinds.push(kind);
				}

				result.strumLines[p].notes.push({ t: t, s: s, k: k, l: note[2] });
			}

			time += section.sectionBeats * (60 / bpm * 1000);
		}

		return result;
	}
}
