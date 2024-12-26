package game.backend;

import game.data.song.SongData;
import flixel.util.FlxSignal.FlxTypedSignal;

typedef BPMChangeEvent = {
	var time:{
		var ms:Float;
		var step:Float;
	}
	var bpm:Float;
	var beatsPerMeasure:Float;
	var stepsPerBeat:Float;
}

class Conductor {
	private static var bpmChangeMap = new List<BPMChangeEvent>();

	public static final onStepHit = new FlxTypedSignal<Int->Void>();
	public static final onBeatHit = new FlxTypedSignal<Int->Void>();
	public static final onMeasureHit = new FlxTypedSignal<Int->Void>();

	public static var step(default, null) = 0.0;
	public static var beat(default, null) = 0.0;
	public static var measure(default, null) = 0.0;

	public static function getEvent(time:Float):BPMChangeEvent {
		var ret:BPMChangeEvent = null;
		for (e in bpmChangeMap) if (e.time.ms <= time) ret = e;
		return Reflect.copy(ret);
	}

	public static function uploadSong(song:SongData) {
		bpmChangeMap.clear();
		bpmChangeMap.add({
			time: { ms: 0, step: 0 },
			bpm: song.meta.bpm,
			beatsPerMeasure: song.meta.beatsPerMeasure,
			stepsPerBeat: song.meta.stepsPerBeat
		});

		for (e in song.events) if (e.k == 'BPM Change') {
			var prev = bpmChangeMap.last();
			bpmChangeMap.add({
				time: { ms: e.t, step: prev.time.step + (e.t - prev.time.ms) / (60 / prev.bpm * 1000 / prev.stepsPerBeat) },
				bpm: e.p[0],
				beatsPerMeasure: e.p[1],
				stepsPerBeat: e.p[2]
			});
		}
	}

	public static function update(time:Float) {
		var event = getEvent(time);

		var prevStep = Math.floor(step);
		var floorStep = Math.floor(step = event.time.step + (time - event.time.ms) / (60 / event.bpm * 1000 / event.stepsPerBeat));
		if (floorStep > prevStep) for (i in prevStep + 1...floorStep + 1) onStepHit.dispatch(i);

		var prevBeat = Math.floor(beat);
		var floorBeat = Math.floor(beat = step / event.stepsPerBeat);
		if (floorBeat > prevStep) for (i in prevBeat + 1...floorBeat + 1) onBeatHit.dispatch(i);

		var prevMeasure = Math.floor(measure);
		var floorMeasure = Math.floor(measure = beat / event.beatsPerMeasure);
		if (floorMeasure > prevMeasure) for (i in prevMeasure + 1...floorMeasure + 1) onMeasureHit.dispatch(i);
	}
}
