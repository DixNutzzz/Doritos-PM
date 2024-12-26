package game.data.song.migration;

using StringTools;

class LegacySongMigrator extends BaseSongMigrator {
	override function match(input:Dynamic):Bool {
		if (input.song == null) return false;

		if (!matchVar(input.song.song, String)) return false;
		if (!matchVar(input.song.notes, Array)) return false;
		for (section in (input.song.notes : Array<Dynamic>)) {
			if (!matchVar(section.sectionNotes, Array)) return false;
			if (!matchVar(section.lengthInSteps, Int)) return false;
			if (!matchOptVar(section.typeOfSection, Int)) return false;
			if (!matchVar(section.mustHitSection, Bool)) return false;
			if (!matchOptVar(section.bpm, Float)) return false;
			if (!matchOptVar(section.changeBPM, Bool)) return false;
			if (!matchOptVar(section.altAnim, Bool)) return false;
		}
		if (!matchVar(input.song.bpm, Float)) return false;
		if (!matchVar(input.song.needsVoices, Bool)) return false;
		if (!matchVar(input.song.speed, Float)) return false;

		if (!matchVar(input.song.player1, String)) return false;
		if (!matchVar(input.song.player2, String)) return false;
		if (!matchOptVar(input.song.player3, String)) return false;
		if (!matchOptVar(input.song.gfVersion, String)) return false;

		return true;
	}

	override function migrate(input:Dynamic):Dynamic {
		var ret:SongData = {
			meta: {
				song: input.song.song,
				bpm: input.song.bpm,
				beatsPerMeasure: 4,
				stepsPerBeat: 4
			},
			playData: {
				stage: input.song.stage,
				scrollSpeed: input.song.speed,
				noteKinds: [ '' ],
				strumlines: [
					{
						cpu: true,
						char: { name: input.song.player2, pos: 0 },
						pos: [ 0.25, 50 ],
						alpha: 1,
						scale: 1,
						vocalsSuffix: ''
					},
					{
						cpu: false,
						char: { name: input.song.player1, pos: 1 },
						pos: [ 0.75, 50 ],
						alpha: 1,
						scale: 1,
						vocalsSuffix: ''
					}
				]
			},

			needsVoices: input.song.needsVoices,
			events: [],
			notes: [],

			isDoritos: true
		}

		if ((input.song.player2 : String).startsWith('gf'))
			ret.playData.strumlines[0].char.pos = 2;
		else
			ret.playData.strumlines.push({
				cpu: true,
				char: { name: input.song.gfVersion ?? input.song.player3, pos: 2 },
				pos: [ 0.25, 50 ],
				alpha: 1,
				scale: 1,
				vocalsSuffix: ''
			});

		var following = 0;
		var bpm = ret.meta.bpm;
		var stepsPerMeasure = 16;
		var time = 0.0;

		for (section in (input.song.notes : Array<Dynamic>)) {
			if ((section.changeBPM && bpm != (bpm = section.bpm)) || stepsPerMeasure != (stepsPerMeasure = section.lengthInSteps))
				ret.events.push({ t: time, k: 'BPM Change', p: [ bpm, stepsPerMeasure / 4, 4 ] });

			if (following != (following = section.mustHitSection ? 1 : 0))
				ret.events.push({ t: time, k: 'Camera Move', p: [ following ] });

			for (note in (section.sectionNotes : Array<Dynamic>)) {
				var t = note[0];
				var l = note[2];
				var p = section.mustHitSection ? (note[1] >= 4 ? 0 : 1) : (note[1] >= 4 ? 1 : 0);
				var s = Math.floor(note[1] % 4);

				ret.notes.push({ t: t, l: l, k: 0, p: p, s: s });
			}

			time += section.lengthInSteps * (60 / bpm * 1000 / 4);
		}

		return ret;
	}
}
