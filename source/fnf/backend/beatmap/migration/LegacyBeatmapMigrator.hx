package fnf.backend.beatmap.migration;

using StringTools;

typedef LegacyChart = {
	var song:String;
	var notes:Array<LegacyChartSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var ?player3:String;
}

typedef LegacyChartSection = {
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var ?typeOfSection:Int;
	var mustHitSection:Bool;
	var ?bpm:Float;
	var ?changeBPM:Bool;
	var ?altAnim:Bool;
}

class LegacyBeatmapMigrator extends BaseBeatmapMigrator<{song:LegacyChart}> {
	override function match(data:Dynamic):Bool {
		if (data.song == null)
			return false;
		data = data.song;

		if (!isVarMatch(data.song, String))
			return false;
		if (!isVarMatch(data.notes, Array))
			return false;
		for (section in (data.notes : Array<Dynamic>)) {
			if (!isVarMatch(section.sectionNotes, Array))
				return false;
			if (!isVarMatch(section.lengthInSteps, Int))
				return false;
			if (!isOptionalVarMatch(section.typeOfSection, Int))
				return false;
			if (!isVarMatch(section.mustHitSection, Bool))
				return false;
			if (!isOptionalVarMatch(section.bpm, Float))
				return false;
			if (!isOptionalVarMatch(section.changeBPM, Bool))
				return false;
			if (!isOptionalVarMatch(section.altAnim, Bool))
				return false;
		}
		if (!isVarMatch(data.bpm, Float))
			return false;
		if (!isVarMatch(data.needsVoices, Bool))
			return false;
		if (!isVarMatch(data.speed, Float))
			return false;

		if (!isVarMatch(data.player1, String))
			return false;
		if (!isVarMatch(data.player2, String))
			return false;
		if (!isOptionalVarMatch(data.player3, String))
			return false;

		return true;
	}

	override function migrate(input:{song:LegacyChart}):BeatmapData {
		var data = input.song;

		var result:BeatmapData = {
			meta: {
				song: data.song,
				bpm: data.bpm,
				beatsPerMeasure: 4,
				stepsPerBeat: 4,
				needsVoices: data.needsVoices,
				offset: 0
			},
			events: [],

			scrollSpeed: data.speed,
			noteKinds: [''],
			strumLines: [
				{
					charName: data.player2,
					charPos: OPPONENT,
					charVisible: true,

					strumPos: [0.25, 50],
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

					strumPos: [0.75, 50],
					strumAlpha: 1,
					strumScale: 1,

					scrollSpeed: 1,
					cpu: false,
					notes: []
				}
			],
			stage: switch (data.song.toLowerCase()) {
				case 'spookeez', 'south', 'monster': 'spooky';
				case 'pico', 'philly', 'philly-nice', 'blammed': 'pico';
				case 'satin-panties', 'high', 'milf': 'limo';
				case 'cocoa', 'eggnog': 'mall';
				case 'winter-horrorland': 'mallEvil';
				case 'senpai', 'roses': 'school';
				case 'thorns': 'schoolEvil';
				case 'ugh', 'guns', 'stress': 'tank';
				default: 'stage';
			}
		}

		if (data.player2.startsWith('gf'))
			result.strumLines[0].charPos = ADDITIONAL;
		else
			result.strumLines.push({
				charName: data.player3 ?? switch result.stage {
					case 'limo': 'gf-car';
					case 'mall' | 'mallEvil': 'gf-christmas';
					case 'school' | 'schoolEvil': 'gf-pixel';
					case 'tank': 'gf-tankmen';
					default: 'gf';
				},
				charPos: ADDITIONAL,
				charVisible: true,

				strumPos: [0.25, 50],
				strumAlpha: 0,
				strumScale: 1,

				scrollSpeed: 1,
				cpu: true,
				notes: []
			});

		var bpm = data.bpm;
		var camTarget = data.notes[0].mustHitSection ? 1 : 0;
		var stepsPerMeasure = data.notes[0].lengthInSteps;
		var time = 0.0;

		for (section in data.notes) {
			if ((section.changeBPM && section.bpm != null && section.bpm != bpm) || section.lengthInSteps != stepsPerMeasure) {
				bpm = section.changeBPM ? section.bpm : bpm;
				stepsPerMeasure = section.lengthInSteps;
				result.events.push({t: time, k: 'BPM Change', p: [bpm, 4, stepsPerMeasure / 4]});
			}

			if (camTarget != (camTarget = section.mustHitSection ? 1 : 0))
				result.events.push({t: time, k: 'Camera Move', p: [camTarget]});

			for (note in section.sectionNotes) {
				var t = note[0];
				var s = Math.floor(note[1] % 4);
				var p = (note[1] > 3 ? !section.mustHitSection : section.mustHitSection) ? 1 : 0;

				result.strumLines[p].notes.push({
					t: t,
					s: s,
					k: 0,
					l: note[2]
				});
			}

			time += section.lengthInSteps * (60 / bpm * 1000 / 4);
		}

		return null;
	}
}
